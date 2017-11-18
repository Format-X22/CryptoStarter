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

	def auth(email, pass)
		criteria = User.where(email: email, pass: pass)

		if criteria.exists?
			session = make_session

			model = criteria.first
			model.session = session
			model.save!

			cookies[:session] = session

			success
		else
			failure 'Bad auth data'
		end
	end

	def make_session
		"#{('a'..'z').to_a[rand(25)]}-#{rand(721219873421) * rand(2314782314218321) * 648}"
	end

	def logged_in?
		session = cookies[:session]

		!!session and User.where(session: session).exists?
	end
end