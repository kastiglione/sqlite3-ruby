#noinspection ALL
module SQLite3

  STATUS_CODE_EXCEPTIONS = {
    SQLITE_OK => nil,
    SQLITE_ERROR => SQLException,
    SQLITE_INTERNAL => InternalException,
    SQLITE_PERM => PermissionException,
    SQLITE_ABORT => AbortException,
    SQLITE_BUSY => BusyException,
    SQLITE_LOCKED => LockedException,
    SQLITE_NOMEM => MemoryException,
    SQLITE_READONLY => ReadOnlyException,
    SQLITE_INTERRUPT => InterruptException,
    SQLITE_IOERR => IOException,
    SQLITE_CORRUPT => CorruptException,
    SQLITE_NOTFOUND => NotFoundException,
    SQLITE_FULL => FullException,
    SQLITE_CANTOPEN => CantOpenException,
    SQLITE_PROTOCOL => ProtocolException,
    SQLITE_EMPTY => EmptyException,
    SQLITE_SCHEMA => SchemaChangedException,
    SQLITE_TOOBIG => TooBigException,
    SQLITE_CONSTRAINT => ConstraintException,
    SQLITE_MISMATCH => MismatchException,
    SQLITE_MISUSE => MisuseException,
    SQLITE_NOLFS => UnsupportedException,
    SQLITE_AUTH => AuthorizationException,
    SQLITE_FORMAT => FormatException,
    SQLITE_RANGE => RangeException,
    SQLITE_NOTADB => NotADatabaseException,
  }

  def self.check_status(db, status)
    exception = STATUS_CODE_EXCEPTIONS.fetch(status) { RuntimeError }
    return unless exception
    raise exception, db.errmsg
  end

end
