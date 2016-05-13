require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do 
    	through_class = self.send(through_name)
    	through_class.send(source_name)
    end
  end


  def has_many_through(name, through_name, source_name)
  	define_method(name) do
  		through_class = self.send(through_name)
  end
end
