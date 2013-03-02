module SQLite3
  class Backup

    def initialize(source_db, source_name, dest_db, dest_name)
      @backup = sqlite3_backup_init(dest_db, dest_name, source_db, source_name)
    end

    def step(page_count)
      sqlite3_backup_step(@backup, page_count)
    end

    def finish
      sqlite3_backup_finish(@backup)
      @backup = nil
    end

    def remaining
      sqlite3_backup_remaining(@backup)
    end

    def pagecount
      sqlite3_backup_pagecount(@backup)
    end

  end
end
