module SQLite3

  # A class for differentiating between strings and blobs, when binding them
  # into statements.
  class Blob < String; end

  # TODO: call sqlite3_initalize if exists

  SQLITE_VERSION = '3.7.13' # ::SQLITE_VERSION
  SQLITE_VERSION_NUMBER = ::SQLITE_VERSION_NUMBER

  def libversion
    sqlite3_libversion_number
  end

end
