helpers do

	def new_user(email, pass)
		if User.where(email: email).exists?
			failure 'Email already registered'
		end

		model = User.new(email: email, pass: pass)

		if model.valid?
			session = make_session

			model.session = session
			model.save!

			cookies[:session] = session

			success
		else
			failure 'Invalid data'
		end
	end
end