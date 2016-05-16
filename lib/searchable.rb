require_relative 'db_connection'
require_relative 'sql_object'

module Searchable
  def where(params)
  	where_clause = params.keys.map { |col| "#{col} = ?" }.join(" AND ")
    query = DBConnection.execute(<<-SQL, *params.values)
    	SELECT *
    	FROM #{table_name}
    	WHERE #{where_clause}
    SQL
	  self.parse_all(query)
  end

  def joins(params)
    if params.is_a?(Symbol)
      assoc_options = self.assoc_options[params]

      this_table = table_name
      join_table_name = assoc_options.table_name

      if assoc_options.is_a? BelongsToOptions
        primary_key = "#{this_table}.#{assoc_options.foreign_key}"
        foreign_key = "#{join_table_name}.#{assoc_options.primary_key}"
      else
        primary_key = "#{join_table_name}.#{assoc_options.foreign_key}"
        foreign_key = "#{this_table}.#{assoc_options.primary_key}"
      end

      results = DBConnection.execute2(<<-SQL).drop(1)
        SELECT #{this_table}.*
        FROM #{this_table}
        INNER JOIN #{join_table_name}
        ON #{primary_key} = #{foreign_key}
      SQL
    else
      results = DBConnection.execute2(<<-SQL).drop(1)
        SELECT #{this_table}.*
        FROM #{this_table}
        #{params}
      SQL
    end

    self.parse_all(results)
  end

end

class SQLObject
  self.extend Searchable
end
