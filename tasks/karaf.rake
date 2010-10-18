# TODO: Set this to something meaniful, or use an environment var
KARAF_DIR = "../karaf"

desc "Deploy files built by this project to a Karaf instance"
task :deploy_to_karaf => [:package] do
  deployment_artifacts = [project('tilde').package(:bundle)]
  cp artifacts(deployment_artifacts).collect { |a| a.invoke; a.to_s }, "#{KARAF_DIR}/deploy"
end

desc "Deploy all files required to run to a Karaf instance"
task :deploy_all_to_karaf => [:deploy_to_karaf] do
  cp_r Dir["#{_('src/main/dist')}/**"], KARAF_DIR
end

