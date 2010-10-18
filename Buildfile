require 'buildr_bnd'
require 'buildr_iidea'

desc 'Tide: Time Sheet Management'
define 'tilde' do
  project.version = "1.0.0-SNAPSHOT"
  project.group = 'au.com.stocksoftware.tide'

  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'
  SLF4J = [:slf4j_api, :slf4j_jdk14, :jcl_over_slf4j]
  compile.with :core, :jpa, :asm, :antlr, :persistence, :validation, :bval, SLF4J, :commons_lang, :commons_butils
  compile.from _(:target, :generated, :java)

  test.using :testng
  test.with :derbytools, :derby

  ipr.template = _('src/etc/project-template.ipr')

  domgen_gen( project )
  dbt_setup( project )
  
  package(:jar).with(
      :manifest => { 'Class-Path' => artifacts(compile.dependencies).map{|art| art.name.split(/\//)[-1]}.join(' '),
                     'Main-Class' => 'Main'}
    )

  desc "Copies all dependencies to target dir to make running stuff easier"
  task :copy_deps_to_target do
    artifacts(compile.dependencies).each{|art| cp( art.name, _(:target)); p "Copied #{art.name}"  }
  end

  task :run do
    Java::Commands.java "Main", :classpath => artifacts([compile.dependencies, project('tilde'), :jtds])
  end
end
