Domgen.define_schema_set(:tide) do |ss|
  ss.define_generator(:sql)
  ss.define_generator(:jpa)

  ss.define_schema("Core") do |s|
    s.java.package = 'au.com.stocksoftware.tide.model'
    s.sql.schema = 'dbo'

    s.define_object_type(:Client) do |t|
      t.integer(:ID, :primary_key => true)
      t.string(:Name, 255)
    end

    s.define_object_type(:Employee) do |t|
      t.integer(:ID, :primary_key => true)
      t.string(:Name, 255)
      t.string(:Email, 255)
    end

    s.define_object_type(:User) do |t|
      t.integer(:ID, :primary_key => true)
      t.string(:Name, 255)
      t.string(:Password, 255)
      t.reference(:Employee, :nullable => true, :relationship_type => :has_one, :inverse_relationship_type => :has_one)
    end
    
  end
end  