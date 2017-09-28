class LoginPage < AbstractPage

	def initialize
		map_elements
		make_handlers
	end

	def map_elements
		e = Element

		@email = e['#email']
		@pass = e['#pass']
		@login_btn = e['#login']
	end

	def make_handlers
		on_enter_key @email, @pass do
			try_login
		end

		@login_btn.on :click do
			try_login
		end
	end

	def try_login
		if email_valid and pass_valid
			call_api({
				action: 'login',
				email: @email.value,
				pass: @pass.value
			}) do
				$$.location.href = '/profile'
			end
		end
	end

	def email_valid
		valid_marker @email do
			(5..150) === @email.value.length and
			/.+@.+\..+/ === @email.value
		end
	end

	def pass_valid
		valid_marker @pass do
			(8..150) === @pass.value.length
		end
	end

end