require_relative 'db_connection'
require_relative '01_sql_object'

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

end

class SQLObject
  self.extend Searchable
end
