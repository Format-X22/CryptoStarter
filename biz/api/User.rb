helpers do

	def new_user(email, pass)
		model = User.new(email: email, pass: pass)

		if model.valid?
			model.session = make_session
			model.save!
			success
		else
			failure 'Invalid data'
		end
	end
end