helpers do

	def logged_in?
		session = cookies[:session]

		!!session and User.where(session: session).exists?
	end

	def auth_data
		{} # TODO
	end
end