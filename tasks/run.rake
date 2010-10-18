desc 'Run the tilde app'
task 'tilde:run' => [:package] do
  tilde = project('tilde')
  Java::Commands.java "Main", :classpath => artifacts([tilde.compile.dependencies, tilde, :jtds])
end
