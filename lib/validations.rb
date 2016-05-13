class Validations
	def validates(name, options={})
		uniqueness
		presence
	end
end