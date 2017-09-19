class RestorePassPage < AbstractPage

	def initialize
		map_elements
		make_handlers
	end

	def map_elements
		e = Element

		@email = e['#email']
		@restore_btn = e['#restore']
	end

	def make_handlers
		on_enter_key @email do
			try_restore
		end

		@restore_btn.on :click do
			try_restore
		end
	end

	def email_valid
		valid_marker @email do
			(0..150) === @email.value.length and
			/.+@.+/ === @email.value
		end
	end

	def try_restore
		if email_valid
			call_api({
				action: 'restore_pass',
				email: @email.value
			}) do
				$$.location.href = '/login'
			end
		end
	end

end