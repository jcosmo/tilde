
GLASSFISH_DIR = ENV["GLASSFISH_DEPLOY_DIR"] || "C:/glassfish/glassfish/domains/domain1/autodeploy"

desc "Deploy war to glassfish: #{GLASSFISH_DIR}"
task "tilde:glassfish:deploy" => [:package] do
  tilde = project('tilde')
  cp tilde.artifacts("#{tilde.group}:tilde:war:#{tilde.version}").to_s, GLASSFISH_DIR
end

