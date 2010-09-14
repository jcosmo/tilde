Domgen.define_schema_set(:tide) do |ss|
  ss.define_generator(:sql)
  ss.define_generator(:jpa)

  ss.define_schema("core") do |s|
    s.sql.schema = 'dbo'
    s.define_object_type(:Clients) do |t|
      t.integer(:ID, :primary_key => true)
      t.string(:Name, 255)
    end
  end
end  