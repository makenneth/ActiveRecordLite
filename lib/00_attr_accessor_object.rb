class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
    		instance_variable_get("@#{name}")
    end

    names.each do |name|
    	instance_variable_set("@#{name}", var)
    end
  end
end
