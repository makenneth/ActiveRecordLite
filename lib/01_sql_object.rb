require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    query = DBConnection.execute2(<<-SQL)
      SELECT *
      FROM #{self.table_name}
    SQL
    @columns = query.first.map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |col|
      define_method("#{col}") do
        attributes[col]
      end

      define_method("#{col}=") do |var|
        attributes[col] = var
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.pluralize.underscore
  end

  def self.all
    query = DBConnection.execute2(<<-SQL).drop(1)
      SELECT *
      FROM #{self.table_name}
    SQL

    self.parse_all(query)
  end

  def self.parse_all(results)
    results.map do |result|
      self.new(result)
    end
  end

  def self.find(id)
    query = DBConnection.execute2(<<-SQL, id).drop(1)
      SELECT *
      FROM #{self.table_name}
      WHERE #{self.table_name}.id = ?
    SQL

    self.parse_all(query).first
  end

  def initialize(params = {})
    params.each do |attr, val| 
      attr = attr.to_sym
      raise "unknown attribute '#{attr}'" unless self.class.columns.include?(attr)
      self.send("#{attr}=", val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |col| self.send("#{col}") }
  end

  def insert
    question_marks = ["?"] * (attributes.length)
    col_names = self.class.columns.drop(1).join(", ")
    DBConnection.execute2(<<-SQL, *attribute_values.drop(1))
      INSERT INTO #{self.class.table_name}
        (#{col_names})
      VALUES
        (#{question_marks.join(", ")})
    SQL
    self.send("id=", DBConnection.last_insert_row_id)
  end

  def update
    set_line = self.class.columns.drop(1).map { |col| "#{col} = ?"}.join(", ")
    DBConnection.execute2(<<-SQL, *attribute_values.rotate)
      UPDATE #{self.class.table_name}
      SET #{set_line}
      WHERE id = ?
    SQL
  end

  def save
    self.send("id") ? update : insert
  end
end
