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
    DBConnection.execute2(<<-SQL, params)
      SELECT *
      FROM #{table_name}
      INNER JOIN #{params}
      ON #{table_name}
    SQL
  end

end

class SQLObject
  self.extend Searchable
end
