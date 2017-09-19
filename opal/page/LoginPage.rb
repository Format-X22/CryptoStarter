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
		#
	end

end