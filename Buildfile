require 'buildr_bnd'
require 'buildr_iidea'

Dir.new("vendor/plugins").reject{|x| %w(. ..).include?(x)}.each{ |x| $: << "vendor/plugins/#{x}/lib"}

require 'db_tasks.rb'
require 'domgen.rb'

VERSION_NUMBER = "1.0.0-SNAPSHOT"

SLF4J = [:slf4j_api, :slf4j_jdk14, :jcl_over_slf4j]

DbTasks::Config.app_version = VERSION_NUMBER
DbTasks::Config.environment = ENV['DB_ENV'] if ENV['DB_ENV']
DbTasks::Config.config_filename = File.expand_path("config/database.yml")
DbTasks::Config.log_filename = "tmp/logs/db.log"
DbTasks::Config.search_dirs = ["databases/generated", "databases" ]
DbTasks.add_database_driver_hook { db_driver_setup }
DbTasks.add_database :core, [:Core],
                     :schema_overrides => {:Core => :dbo}

desc 'Tide: Time Sheet Management'
define 'tilde' do
  project.version = VERSION_NUMBER
  project.group = 'au.com.stocksoftware.tide'

  project.resources.from _(:target, :generated, :resources)
  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'
  compile.with :core, :jpa, :asm, :antlr, :persistence, :validation, :bval, SLF4J, :commons_lang, :commons_butils
  compile.from _(:target, :generated, :java)

  test.using :testng
  test.with :derbytools, :derby

  ipr.template = _('src/etc/project-template.ipr')

  desc "Deploy files built by this project to a Karaf instance"
  task :deploy_to_karaf do
    deployment_artifacts =
      [project('tide').package(:bundle)]

    cp artifacts(deployment_artifacts).collect { |a| a.invoke; a.to_s }, "#{KARAF_DIR}/deploy"
  end

  desc "Deploy all files required to run to a Karaf instance"
  task :deploy_all_to_karaf => [:deploy_to_karaf] do
    cp_r Dir["#{_('src/main/dist')}/**"], KARAF_DIR
  end

  package(:jar).with(
      :manifest => { 'Class-Path' => artifacts(compile.dependencies).map{|art| art.name.split(/\//)[-1]}.join(' '),
                     'Main-Class' => 'Main'}
    ).tap do |jar|
      jar.meta_inf << _(:target, :generated, :resources, 'META-INF', 'persistence.xml')
    end

  desc "Copies all dependencies to target dir to make running stuff easier"
  task :copy_deps_to_target do
    artifacts(compile.dependencies).each{|art| cp( art.name, _(:target)); p "Copied #{art.name}"  }
  end

  task :run do
    Java::Commands.java "Main", :classpath => artifacts([compile.dependencies, project('tilde')])
  end
end

Domgen::LoadSchema.new(File.expand_path("databases/schema_set.rb"))
Domgen::GenerateTask.new(:tide, :jpa, [:jpa], "target/generated")
Domgen::GenerateTask.new(:tide, :sql, [:sql], "databases/generated") do |t|
  t.clobber_dir = false
end
