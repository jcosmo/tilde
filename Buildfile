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

HIBERNATE = [
  :hibernate_persistence,
  :javax_transaction,
  :javax_validation,
  :dom4j,
  :javassist,
  :commons_collections,
  :commons_lang,
  :hibernate_validator,
  :antlr,
  :hibernate_persistence,
  :hibernate_entitymanager,
  :hibernate_core,
  :hibernate_commons_annotations,
  :hibernate_annotation]

OPENJPA = [
  'commons-collections:commons-collections:jar:3.2.1',
  'commons-lang:commons-lang:jar:2.4',
  'commons-beanutils:commons-beanutils:jar:1.8.3',
  'commons-pool:commons-pool:jar:1.5.3',
  'org.apache.geronimo.specs:geronimo-jms_1.1_spec:jar:1.1.1',
  'org.apache.geronimo.specs:geronimo-jpa_2.0_spec:jar:1.0',
  'org.apache.geronimo.specs:geronimo-jta_1.1_spec:jar:1.1.1',
  'org.apache.geronimo.specs:geronimo-validation_1.0_spec:jar:1.0',
  'org.apache.bval:org.apache.bval.bundle:jar:0.2-incubating',
  'net.sourceforge.serp:serp:jar:1.13.1',
  'javax.validation:validation-api:jar:1.0.0.GA',
  'org.apache.openjpa:openjpa:jar:2.0.1',
  ]

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
  compile.with :osgi_core,
               :osgi_compendium,
               Buildr::Ipojo.annotation_artifact,
               :ipojo_eventadmin,
               #HIBERNATE,
               OPENJPA,
               SLF4J,
               :jtds
  compile.from _(:target, :generated, :java)

  # Only want this if using OPENJPA
  compile { open_jpa_enhance( :properties=>path_to(:target, :generated, :resources, 'META-INF/persistence.xml' )) }

  project.version = VERSION_NUMBER
  project.group = GROUP
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
