helpers do

	def auth(email, pass)
		criteria = User.where(email: email, pass: pass)

		if criteria.exists?
			model = criteria.first
			model.session = make_session
			model.save!

			success
		else
			failure 'Bad auth data'
		end
	end

	def make_session
		"#{('a'..'z').to_a[rand(25)]}-#{rand(721219873421) * rand(2314782314218321) * 648}"
	end

end