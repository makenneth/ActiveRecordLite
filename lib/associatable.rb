require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    @class_name.underscore + "s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = options[:foreign_key] || "#{name}Id".underscore.to_sym 
    @class_name = options[:class_name] || name.to_s.camelcase
    @primary_key = options[:primary_key] || :id
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = options[:foreign_key] || "#{self_class_name}Id".underscore.to_sym
    @class_name = options[:class_name] || name.to_s.singularize.camelcase
    @primary_key = options[:primary_key] || :id
  end
end

module Associatable
  def belongs_to(name, options = {})
    self.assoc_options[name] = 
        BelongsToOptions.new(name, options)

    define_method(name) do 
      options = self.class.assoc_options[name]
      foreign_id = self.send(options.foreign_key)

      options.model_class.where(options.primary_key => foreign_id).first
    end
  end

  def has_many(name, options = {})
    self.assoc_options[name] =
          HasManyOptions.new(name, self.name, options)

    define_method(name) do
      options = self.class.assoc_options[name]
      primary_id = self.send(options.primary_key)

      options.model_class.where(options.foreign_key => primary_id)
    end
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do 
      through_class = self.send(through_name)
      through_class.send(source_name)
    end
  end

  def has_many_through(name, through_name, source_name)
    define_method(name) do 
      associated = self.send(through_name)

      associated = [associated] unless associated.is_a?(Array)
        
      has_many_through_objects = []

      associated.each do |object| 
        has_many_through_objects = 
            has_many_through_objects.concat(object.send(source_name))
      end

      has_many_through_objects
    end
  end

  def assoc_options
    @assoc_options ||= {}
    @assoc_options
  end
end

class SQLObject
  self.extend Associatable
end
