namespace :db do
  desc "Seed the current environment's database." 
  task :seed => :environment do
    ActiveRecord::Base.transaction do
      # Settables
      find_or_create(Settable, :key, :key => "timezone", :name => "Time Zone", :description => "The time zone in which times are displayed throughout the Command Center", :kind => "timezone", :default => "UTC")
      # Languages
      english = find_or_create(Language, :code, :code => "eng", :active => "1")
      # Roles
      highest_role = find_or_create(Role, :name, :name => "Admin", :level => "3")
      find_or_create(Role, :name, :name => "Coordinator", :level => "2")
      find_or_create(Role, :name, :name => "Observer", :level => "1")
      # Initial superuser
      unless User.find_by_role_id(highest_role.id)
        User.ignore_blank_passwords = true
        find_or_create(User, :login, :login => "super", :name => "Super User", :login => "super",
          :email => "webmaster@cceom.org", :role_id => highest_role.id, :active => true, 
          :language_id => english.id, :password => "changeme", :password_confirmation => "changeme")
        User.ignore_blank_passwords = false
      end
      # QuestionTypes
      find_or_create(QuestionType, :name, :name => "text", :long_name => "Short Text", :odk_name => "string", :odk_tag => "input")
      find_or_create(QuestionType, :name, :name => "long_text", :long_name => "Long Text", :odk_name => "string", :odk_tag => "input")
      find_or_create(QuestionType, :name, :name => "integer", :long_name => "Integer", :odk_name => "int", :odk_tag => "input")
      find_or_create(QuestionType, :name, :name => "decimal", :long_name => "Decimal", :odk_name => "decimal", :odk_tag => "input")
      find_or_create(QuestionType, :name, :name => "location", :long_name => "GPS Location", :odk_name => "geopoint", :odk_tag => "input")
      find_or_create(QuestionType, :name, :name => "address", :long_name => "Address/Landmark", :odk_name => "string", :odk_tag => "input")
      find_or_create(QuestionType, :name, :name => "select_one", :long_name => "Select One", :odk_name => "select1", :odk_tag => "select1")
      find_or_create(QuestionType, :name, :name => "select_multiple", :long_name => "Select Multiple", :odk_name => "select", :odk_tag => "select")
      # PlaceTypes
      find_or_create(PlaceType, :level, :name => "Country", :short_name => "country", :level => "1")
      find_or_create(PlaceType, :level, :name => "State/Province", :short_name => "state", :level => "2")
      find_or_create(PlaceType, :level, :name => "Locality", :short_name => "locality", :level => "3")
      find_or_create(PlaceType, :level, :name => "Address/Landmark", :short_name => "address", :level => "4")
      find_or_create(PlaceType, :level, :name => "Point", :short_name => "point", :level => "5")
      # FormTypes
      find_or_create(FormType, :name, :name => "Type 1")
      find_or_create(FormType, :name, :name => "Type 2")
      
      # Report Calculations
      calc1 = find_or_create(Report::Calculation, :name, :name => "Zero/Nonzero", :code => "IF(? > 0, 1, 0)")
      
      # Report Groupings
      find_or_create(Report::ByAttribGrouping, :name, :name => "Form", :code => "forms.name", :join_tables => "forms")
      find_or_create(Report::ByAttribGrouping, :name, :name => "State", :code => "states.long_name", :join_tables => "states")
      find_or_create(Report::ByAttribGrouping, :name, :name => "Country", :code => "countries.long_name", :join_tables => "countries")
      
      # Report Aggregations
      find_or_create(Report::Aggregation, :name, :name => "Average", :code => "AVG(?)")
      find_or_create(Report::Aggregation, :name, :name => "Minimum", :code => "MIN(?)")
      find_or_create(Report::Aggregation, :name, :name => "Maximum", :code => "MAX(?)")
    end
  end
end

def find_or_create(klass, key_field, attribs)
  key_val = attribs[key_field]
  # try to find the object
  if obj = klass.send("find_by_#{key_field.to_s}", key_val)
    # update its attributes
    obj.attributes.each{|k,v| next if %w(id created_at updated_at).include?(k); obj.send("#{k}=", attribs[k.to_sym]) if attribs.keys.include?(k.to_sym)}
    # if it changed, say so and save it
    if obj.changed?
      puts "Updated #{klass.name} #{key_val} (#{obj.changed.join(', ')})"
      obj.save!
    end
    return obj
  else
    puts "Created #{klass.name} #{key_val}"
    return klass.create!(attribs)
  end
end

def remove(klass, key_field, key_value)
  if found = klass.send("find_by_#{key_field}", key_value)
    found.destroy
    puts "Deleted #{klass.name} #{key_value}"
  end
end