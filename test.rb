require_relative "./lib/associatable"

class Cat < SQLObject
	validates :name, :owner_id, presence: true
	validates :name, uniqueness: true
	belongs_to :human, :foreign_key => :owner_id

	has_one_through :home, :human, :house
	finalize!
end

class Human < SQLObject
	belongs_to :house
	has_many :cats, :foreign_key => :owner_id
	self.table_name = "humans"

	finalize!
end

class House < SQLObject
	has_many :humans
	has_many_through :cats, :humans, :cats
	finalize!	
end