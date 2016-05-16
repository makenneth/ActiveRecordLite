
module Validations
	def validates(*names, options) #have to take in multiple options
		if options[:presence]
			self.validate_options[:presence] = names
			define_method(:presence) do |cols|
				cols.each do |col| 
					raise "#{col} must be present" unless self.send(col) 
				end
			end
		end

	end



	def validate_options
		@validate_options ||= {}
	end
end

