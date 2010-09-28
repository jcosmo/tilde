require 'buildr_bnd'
require 'buildr_iidea'

desc 'JPA OSGi Testbed'
define 'jpa-osgi' do
  project.version = '0.9-SNAPSHOT'
  project.group = 'jpaosgi'

  compile.options.source = '1.6'
  compile.options.target = '1.6'
  compile.options.lint = 'all'
  compile.with :core, :jpa, :asm, :antlr, :persistence

  test.using :testng
  test.with :derbytools, :derby

  package(:bundle).tap do |bnd|
    bnd['Export-Package'] = "jpaosgi.*;version=#{version}"
    bnd['-removeheaders'] = "Include-Resource,Bnd-LastModified,Created-By,Implementation-Title,Tool"
  end
  package(:sources)
end
