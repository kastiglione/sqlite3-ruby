if defined? Motion::Project::App
  Motion::Project::App.setup do |app|
    app.libs << '/usr/lib/libsqlite3.dylib'

    # RubyMotion doesn't support require, list source files ordered manually
    app.detect_dependencies = false
    files = %w[
      ext/sqlite3/sqlite3.rb
      ext/sqlite3/database.rb
      ext/sqlite3/statement.rb
      lib/sqlite3/errors.rb
      ext/sqlite3/exception.rb
      lib/sqlite3/constants.rb
      lib/sqlite3/pragmas.rb
      lib/sqlite3/resultset.rb
      lib/sqlite3/statement.rb
      lib/sqlite3/translator.rb
      lib/sqlite3/value.rb
      lib/sqlite3/database.rb
      lib/sqlite3/version.rb
    ]
    # Convert above files to absolute paths before supplying them to RubyMotion
    root = File.realpath(File.join(File.dirname(__FILE__), '..'))
    files.map! { |f| File.join(root, f) }
    app.files.concat files

    # BridgeSupport file generation. Huge kludge.
    platform = 'iPhoneOS'
    config = Motion::Project::App.config_without_setup.variables
    include_path = "#{config['xcode_dir']}/Platforms/#{platform}.platforms/Developer/SDK/#{platform}#{config['sdk_version']}.sdk/usr/include"
    bridgesupport_file = './build/sqlite3.bridgesupport'
    unless File.exist?(bridgesupport_file)
      Dir.mkdir('./build') unless Dir.exist?('./build')
      `/usr/bin/gen_bridge_metadata --format complete --no-64-bit --cflags '-I#{include_path}' sqlite3.h > #{bridgesupport_file}`
    end
    app.bridgesupport_files << './sqlite3.bridgesupport'
  end
else

# support multiple ruby version (fat binaries under windows)
begin
  RUBY_VERSION =~ /(\d+\.\d+)/
  require "sqlite3/#{$1}/sqlite3_native"
rescue LoadError
  require 'sqlite3/sqlite3_native'
end

require 'sqlite3/database'
require 'sqlite3/version'

end
