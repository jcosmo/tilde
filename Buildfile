require 'buildr_bnd'
require 'buildr_iidea'
require 'buildr_ipojo'

Dir.new("vendor/plugins").reject{|x| %w(. ..).include?(x)}.each{ |x| $: << "vendor/plugins/#{x}/lib"}

require 'db_tasks.rb'
require 'domgen.rb'

VERSION_NUMBER = "1.0.0-SNAPSHOT"
GROUP = "au.com.stocksoftware.tide"

repositories.remote << 'https://repository.apache.org/content/repositories/releases'
repositories.remote << 'http://repository.springsource.com/maven/bundles/external'
repositories.remote << 'http://repository.jboss.com/maven2' # Hibernate
repositories.remote << 'http://repository.code-house.org/content/repositories/release' # OSGi - jmx RI

repositories.remote << Buildr::Bnd.remote_repository
repositories.remote << Buildr::Ipojo.remote_repository

KARAF_DIR="../apache-karaf-2.0.1-SNAPSHOT/"
JPA = [:hibernate_persistence, :hibernate_annotation, :javax_validation]

DbTasks::Config.app_version = VERSION_NUMBER
DbTasks::Config.environment = ENV['DB_ENV'] if ENV['DB_ENV']
DbTasks::Config.config_filename = File.expand_path("config/database.yml")
DbTasks::Config.log_filename = "tmp/logs/db.log"
DbTasks::Config.search_dirs = ["databases/generated", "databases" ]
DbTasks.add_database_driver_hook { db_driver_setup }
DbTasks.add_database :core, [:Core],
                     :schema_overrides => {:Core => :dbo}

desc 'Tide: Time Sheet Management'
define 'tide' do
  compile.with :osgi_core,
               :osgi_compendium,
               Buildr::Ipojo.annotation_artifact,
               :ipojo_eventadmin,
               JPA
  compile.from _(:target, :generated, :java)


  project.version = VERSION_NUMBER
  project.group = GROUP
  ipr.template = _('src/etc/project-template.ipr')

  package(:bundle).tap do |bnd|
    bnd['Export-Package'] = "com.stocksoftware.tide.*;version=#{version}"
  end

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
end

Domgen::LoadSchema.new(File.expand_path("databases/schema_set.rb"))
Domgen::GenerateTask.new(:tide, :jpa, [:jpa], "target/generated")
Domgen::GenerateTask.new(:tide, :sql, [:sql], "databases/generated") do |t|
  t.clobber_dir = false
end
