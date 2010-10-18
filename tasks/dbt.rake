workspace_dir = File.expand_path(File.dirname(__FILE__) + "/..")

$LOAD_PATH.insert(0, "#{workspace_dir}/vendor/plugins/dbt/lib")

require 'db_tasks'

DbTasks::Config.environment = ENV['DB_ENV'] if ENV['DB_ENV']
DbTasks::Config.config_filename = File.expand_path("#{workspace_dir}/config/database.yml")
DbTasks::Config.log_filename = "tmp/logs/db.log"
DbTasks::Config.search_dirs = ["databases/generated", "databases" ]
DbTasks.add_database_driver_hook { db_driver_setup }
DbTasks.add_database :core, [:Core],
                     :schema_overrides => {:Core => :dbo}

def dbt_setup(project)
  DbTasks::Config.app_version = project.version
end

