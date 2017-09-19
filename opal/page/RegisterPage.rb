class RegisterPage < AbstractPage

	def initialize
		map_elements
		make_handlers
	end

	def map_elements
		e = Element

		@email = e['#email']
		@pass = e['#pass']
		@pass2 = e['#pass2']
		@term = e['#term']
		@register_btn = e['#register']
	end

	def make_handlers
		@register_btn.on :click do
			if email_valid and pass_valid and term_valid
				try_register
			end
		end
	end

	def email_valid
		valid_marker @email do
			(0..150) === @email.value.length and
			/.+@.+/ === @email.value
		end
	end

	def pass_valid
		valid_marker @pass do
			(8..150) === @pass.value.length
		end
		valid_marker @pass2 do
			@pass2.value == @pass.value
		end
	end

	def term_valid
		valid_marker @term do
			@term.is(':checked')
		end
	end

	def try_register
		call_api({
			action: 'register',
			email: @email.value,
			pass: @pass.value
		}) do
			$$.location.href = '/profile'
		end
	end
end