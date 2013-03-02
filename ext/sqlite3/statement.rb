module SQLite3
  class Statement

    def initialize(db, sql)
      if db.nil? || db.closed?
        raise ArgumentError, 'prepare called on a closed database'
      end

      db_ptr = db.instance_variable_get(:@db)
      sql_len = sql.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
      st_out = Pointer.new(Sqlite3_stmt.type)
      rem_out = Pointer.new(:string)
      status = sqlite3_prepare_v2(db_ptr, sql, sql_len, st_out, rem_out)
      SQLite3.check_status(db, status)

      @connection = db
      @st = st_out.value
      @remainder = rem_out.value
    end

    def close
      check_open
      sqlite3_finalize(@st)
      @st = nil
      self
    end

    def closed?
      @st.nil?
    end

    def step
      check_open
      return nil if @done

      value = sqlite3_step(@st)
      length = sqlite3_column_count(@st)
      list = Array.new(length)

      case value
      when SQLITE_ROW
        for index in 0...length do
          type = sqlite3_column_type(@st, index)
          case type
          when SQLITE_INTEGER
            list[index] = sqlite3_column_int64(@st, index)
          when SQLITE_FLOAT
            list[index] = sqlite3_column_double(@st, index)
          when SQLITE_TEXT
            list[index] = sqlite3_column_text(@st, index)
          when SQLITE_BLOB
            list[index] = sqlite3_column_blob(@st, index)
          when SQLITE_NULL
            list[index] = nil
          else
            raise RuntimeError, 'bad type'
          end
        end
      when SQLITE_DONE
        @done = true
        return nil
      else
        SQLite3.check_status(sqlite3_db_handle(@st), value)
      end
      list
    end

    def bind_param(key, value)
      check_open

      key = key.to_s if key.kind_of? Symbol
      index =
        if key.kind_of? String
          key = ":#{key}" unless key.start_with?(':')
          sqlite3_bind_parameter_index(@st, key)
        else
          key.to_i
        end

      if index == 0
        raise SQLite3::Exception, 'no such bind parameter'
      end

      status = 0
      case value
      when String
        if value.kind_of? SQLite3::Blob
          raise NotImplementedError
        end
        value_len = value.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        status = sqlite3_bind_text(@st, index, value, value_len, SQLITE_TRANSIENT)
      when Bignum
        raise NotImplementedError
      when Fixnum
        status = sqlite3_bind_int64(@st, index, value)
      when NilClass
        status = sqlite3_bind_null(@st, index)
      else
        raise RuntimeError, "can't prepare %s", value.class
      end

      SQLite3.check_status(sqlite3_db_handle(@st), status)

      self
    end

    def reset!
      check_open
      status = sqlite3_reset(@st)
      @done = false
      self
    end

    def clear_bindings!
      check_open
      sqlite3_clear_bindings(@st)
      @done = false
      self
    end

    def done?
      @done
    end

    def column_count
      check_open
      sqlite3_column_count(@st)
    end

    def column_name(index)
      check_open
      sqlite3_column_name(@st, index)
    end

    def column_decltype(index)
      check_open
      sqlite3_column_decltype(@st, index)
    end

    def bind_parameter_count
      check_open
      sqlite3_bind_parameter_count(@st)
    end

    private

    def check_open
      @st or raise SQLite3::Exception, 'cannot use a closed statement'
    end

  end
end
