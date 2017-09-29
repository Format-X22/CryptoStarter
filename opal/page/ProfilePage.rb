class ProfilePage < AbstractPage

	def initialize
		map_elements
		make_handlers
	end

	def map_elements
		e = Element

		@edit_profile_btn   = e['#edit-profile']
		@edit_profile_form  = e['#edit-profile-form']
		@edit_security_btn  = e['#edit-security']
		@edit_security_form = e['#edit-security-form']
		@create_project_btn = e['#create-project']
		@edit_projects_btns = e['#projects-table .cs-edit']
	end

	def make_handlers
		@edit_profile_btn.on :click do
			if @edit_profile_form.has_class? 'hidden'
				@edit_profile_form.remove_class 'hidden'
			else
				@edit_profile_form.add_class 'hidden'
			end

			@edit_security_form.add_class 'hidden'
		end

		@edit_security_btn.on :click do
			if @edit_security_form.has_class? 'hidden'
				@edit_security_form.remove_class 'hidden'
			else
				@edit_security_form.add_class 'hidden'
			end

			@edit_profile_form.add_class 'hidden'
		end

		@create_project_btn.on :click do
			$$.location.href = '/projectConstructor-new'
		end

		@edit_projects_btns.on :click do |event|
			full_id = event.current_target.id
			id = full_id.split('-').last

			$$.location.href = "/projectConstructor-#{id}"
		end
	end

end