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
		@main_edit_forms    = e['#main-edit-forms']
		@body_and_html      = e['body, html']
		@cancel_about       = e['#cancel-about']
		@close_security     = e['#close-security']
	end

	def make_handlers
		@edit_profile_btn.on :click do
			@edit_security_form.add_class 'hidden'

			if @edit_profile_form.has_class? 'hidden'
				@edit_profile_form.remove_class 'hidden'
				scroll_to_main_edit_form
			else
				@edit_profile_form.add_class 'hidden'
			end
		end

		@edit_security_btn.on :click do
			@edit_profile_form.add_class 'hidden'

			if @edit_security_form.has_class? 'hidden'
				@edit_security_form.remove_class 'hidden'
				scroll_to_main_edit_form
			else
				@edit_security_form.add_class 'hidden'
			end
		end

		@create_project_btn.on :click do
			$$.location.href = '/projectConstructor-new'
		end

		@edit_projects_btns.on :click do |event|
			full_id = event.current_target.id
			id = full_id.split('-').last

			$$.location.href = "/projectConstructor-#{id}"
		end

		@cancel_about.on :click do
			@edit_profile_form.add_class 'hidden'
			scroll_to_main_edit_controls
		end

		@close_security.on :click do
			@edit_security_form.add_class 'hidden'
			scroll_to_main_edit_controls
		end
	end

	def scroll_to_main_edit_controls
		position = @edit_profile_btn.offset.top - 100

		@body_and_html.animate({scrollTop: position}, 800)
	end

	def scroll_to_main_edit_form
		position = @main_edit_forms.offset.top - 100

		@body_and_html.animate({scrollTop: position}, 800)
	end

	def scroll_to(position)
		@body_and_html.animate({scrollTop: position}, 800)
	end

end