class BeboistUserMigrationGenerator < Rails::Generator::Base
  
  def initialize(runtime_args, runtime_options={})
    super
  end
  
  def manifest
    record do |m|
      m.directory "/db"
      m.directory "/db/migrate"
      m.migration_template "user_migration.rb", "/db/migrate", :migration_file_name => "create_users"
      m.template "user.rb", File.join("/app/models/", "user.rb")
    end
  end
end