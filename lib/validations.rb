module Validations
	def validates(*names, options={})
		if options[:presence]
			return false unless names.all? { |name| self.send(name) }
		elsif options[:uniqueness] #scope
			return false unless names.all? { |name| self.uniqueness(name) }
		end

		return true
	end

	def uniqueness(name)
			where_clause = "#{name} = #{self.send(name)}"
			where_clause << "AND id != #{self.send(id)}" if self.send(id)

			query = DBConnection.execute2(<<-SQL)
				SELECT *
				FROM #{self.table_name}
				WHERE #{where_clause}
			SQL

			return false if query.length

			true
	end
end

