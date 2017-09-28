class RegisterProjectPage < AbstractPage

	def initialize
		make_elements
		make_handlers
	end

	def make_elements
		e = Element

		@name = e['#name']
		@short = e['#short']
		@email = e['#email']
		@pass = e['#pass']
		@pass2 = e['#pass2']
		@term = e['#term']
		@register_btn = e['#register']
	end

	def make_handlers
		on_enter_key @name, @short, @email, @pass, @pass2 do
			try_register
		end

		@register_btn.on :click do
			try_register
		end
	end

	def try_register
		if name_valid and short_valid and email_valid and pass_valid and term_valid
			call_api({
				action: 'registerProject',
				name: @name.value,
				short: @short.value,
				email: @email.value,
				pass: @pass.value
			}) do
				$$.location.href = '/projectConstructor'
			end
		end
	end

	def name_valid
		valid_marker @name do
			(1..25) === @name.value.length
		end
	end

	def short_valid
		valid_marker @short do
			(1..100) === @short.value.length
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

		valid_marker @pass2 do
			@pass2.value == @pass.value
		end
	end

	def term_valid
		valid_marker @term do
			@term.is(':checked')
		end
	end

end