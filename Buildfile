require 'buildr_bnd'
require 'buildr_iidea'
require 'buildr_ipojo'

VERSION_NUMBER = "1.0.0"
GROUP = "stocksoftware"

repositories.remote << 'https://repository.apache.org/content/repositories/releases'
repositories.remote << 'http://repository.springsource.com/maven/bundles/external'
repositories.remote << 'http://repository.code-house.org/content/repositories/release' # OSGi - jmx RI

repositories.remote << Buildr::Bnd.remote_repository
repositories.remote << Buildr::Ipojo.remote_repository

KARAF_DIR="../apache-karaf-2.0.1-SNAPSHOT/"

desc 'Tide: Time Sheet Management'
define 'tide' do
  compile.with :osgi_core,
               :osgi_compendium,
               Buildr::Ipojo.annotation_artifact,
               :ipojo_eventadmin

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
