helpers do

	def auth(email, pass)
		criteria = User.where(email: email, pass: pass)

		if criteria.exists?
			success
		else
			failure 'Bad auth data'
		end
	end

end