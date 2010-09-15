require "buildr/openjpa"

include Buildr::OpenJPA

Buildr::OpenJPA.send :remove_const, :REQUIRES
Buildr::OpenJPA.const_set(:REQUIRES, ["org.apache.openjpa:openjpa:jar:2.0.1",
                                      "commons-collections:commons-collections:jar:3.1",
                                      "commons-dbcp:commons-dbcp:jar:1.2.1",
                                      "commons-lang:commons-lang:jar:2.1",
                                      "commons-pool:commons-pool:jar:1.2",
                                      "org.hibernate.javax.persistence:hibernate-jpa-2.0-api:jar:1.0.0.Final",
                                      "org.apache.geronimo.specs:geronimo-j2ee-connector_1.5_spec:jar:1.0",
                                      "org.apache.geronimo.specs:geronimo-jta_1.0.1B_spec:jar:1.0",
                                      "org.apache.geronimo.specs:geronimo-jpa_2.0_spec:jar:1.1",
                                      "org.apache.geronimo.specs:geronimo-validation_1.0_spec:jar:1.1",
                                      "net.sourceforge.serp:serp:jar:1.13.1"])
