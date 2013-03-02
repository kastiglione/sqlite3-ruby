module SQLite3
  class Database

    def initialize(file, options={})
      @readonly = options[:readonly]
      @results_as_hash = options[:results_as_hash]
      @type_translation = options[:type_translation]

      db_out = Pointer.new(Sqlite3.type)
      check_status sqlite3_open_v2(file, db_out, open_mode, nil)
      @db = db_out.value

      if block_given?
        yield self
        close
      end
    end

    def collation
      raise NotImplementedError
    end

    def close
      check_status sqlite3_close(@db)
      @db = nil
      self
    end

    def closed?
      @db.nil?
    end

    def total_changes
      check_open
      sqlite3_total_changes(@db)
    end

    def trace
      raise NotImplementedError
    end

    def last_insert_row_id
      check_open
      sqlite3_last_insert_rowid(@db)
    end

    def define_function
      raise NotImplementedError
    end

    def define_aggregator
      raise NotImplementedError
    end

    def interrupt
      check_open
      sqlite3_interrupt(@db)
    end

    def errmsg
      check_open
      sqlite3_errmsg(@db)
    end

    def errcode
      check_open
      sqlite3_errcode(@db)
    end

    def complete?(sql)
      sqlite3_complete(sql) != 0
    end

    def changes
      check_open
      sqlite3_changes(@db)
    end

    def authorizer=(authorizer)
      raise NotImplementedError
    end

    def busy_handler
      raise NotImplementedError
    end

    def busy_timeout=(timeout)
      raise NotImplementedError
    end

    def transaction_active?
      check_open
      sqlite3_get_autocommit(@db) != 0
    end

    def encoding
      check_open
      if @encoding.nil?
        callback = lambda do |_, count, values, columns|
          @encoding = values.first; 0
        end
        sqlite3_exec(@db, 'PRAGMA encoding', callback, nil, nil)
        @encoding
      end
    end

    private

    def open_mode
      if @readonly
        SQLITE_OPEN_READONLY
      else
        SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
      end
    end

    def check_open
      @db or raise SQLite3::Exception, 'cannot use a closed database'
    end

    def check_status(status)
      SQLite3.check_status(self, status)
    end

  end
end
