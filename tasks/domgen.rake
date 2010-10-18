workspace_dir = File.expand_path(File.dirname(__FILE__) + "/..")

$LOAD_PATH.insert(0, "#{workspace_dir}/vendor/plugins/domgen/lib")

require 'domgen.rb'

Domgen::LoadSchema.new(File.expand_path("#{workspace_dir}/databases/schema_set.rb"))
Domgen::GenerateTask.new(:tide, :jpa, [:jpa], "#{workspace_dir}/target/generated") do |t|
  t.description = "Generates Java code for the persistent objects"
end
Domgen::GenerateTask.new(:tide, :sql, [:sql], "#{workspace_dir}/databases/generated") do |t|
  t.description = "Generates SQL for the construction of the database schema"
  t.clobber_dir = false
end

def domgen_gen(project)
  output_dir = project._(:target, :generated, :java)
  cache_file = "#{output_dir}/domgen.cache"
  project.file(cache_file => [File.expand_path(project._("databases/schema_set.rb"))]) do
    info("Generating persistent objects.")
    task('domgen:jpa').invoke
    touch cache_file
  end

  project.compile do
    info "Copying generated resources to target"
    filter(_('target/generated/resources')).into(_(:target, :resources)).run
  end

  project.compile.prerequisites << cache_file
  project.compile.from output_dir
end
