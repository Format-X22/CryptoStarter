class User
	include Mongoid::Document

	field :email,   type: String
	field :pass,    type: String
	field :session, type: String

	field :name, type: String
	field :desc, type: String

	field :projects, type: Array
	field :invested, type: Array

	index({email:   1}, {unique: true})
	index({session: 1}, {sparse: true})

	validates :email, length: {in:    5..150}, presence: true, format: /.+@.+\..+/
	validates :pass,  length: {in:    8..150}, presence: true
	validates :name,  length: {maximum:  150}
	validates :desc,  length: {maximum: 2000}
end