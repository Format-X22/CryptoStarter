require 'UtilsPack'

class Landing
	include UtilsPack

	TO_TOP_EDGE = 100
	TO_TOP_SPEED = 800

	def initialize
		map_elements
		expose_plugins
		init_scroll_to_top
		init_pre_register
		init_ico

		after 0.250 do
			init_slider
		end
	end

	def map_elements
		e = Element

		@js_window      = e[`window`]
		@body_and_html  = e['body, html']
		@to_top         = e['#to-top']
		@project        = e['#project']
		@email          = e['#email']
		@description    = e['#description']
		@message        = e['#message']
		@send           = e['#send']
		@slider         = e['#wow-slider']
		@slider_loader  = e['#wow-fix-loader']
		@register_modal = e['#register-modal']
		@ico_confirm    = e['#ico-confirm']
		@ico_data       = e['#ico-data']
		@no_usa         = e['#no-usa']
	end

	def expose_plugins
		Element.expose :modal
		Element.expose :revolution
	end

	def init_scroll_to_top
		@js_window.on :scroll do
			@to_top.remove_class 'hidden'

			if @js_window.scroll_top > TO_TOP_EDGE
				@to_top.effect :fade_in
			else
				@to_top.effect :fade_out
			end
		end

		@to_top.on :click do
			@body_and_html.animate({scrollTop: 0}, TO_TOP_SPEED)
		end
	end

	def init_pre_register
		valid_tracker(@project, :change) do
			@project.value.length > 0
		end

		valid_tracker(@email, :change) do
			@email.value.length > 0
		end

		valid_tracker(@description, :change) do
			@description.value.length > 0
		end

		@send.on :click do
			try_send_registration
		end
	end

	def try_send_registration
		if @project.value.length == 0
			mark_invalid @project
			return
		end

		if @email.value.length == 0
			mark_invalid @email
			return
		end

		if @description.value.length == 0
			mark_invalid @description
			return
		end

		HTTP.post '/api/pre-register', payload: {
			project:     @project.value,
			email:       @email.value,
			description: @description.value,
			message:     @message.value
		} do |request|
			handle_registration(request)
		end
	end

	def handle_registration(request)
		if request.ok? and request.json['success']
			@register_modal.modal
		else
			show_error "Request error - #{request.json['message']}"
		end
	end

	def init_slider
		config = {
			dottedOverlay: 'none',
			delay: 9000,
			startwidth: 1170,
			startheight: 700,
			hideThumbs: 200,
			thumbWidth: 100,
			thumbHeight: 50,
			thumbAmount: 1,
			navigationType: 'none',
			touchenabled: 'on',
			onHoverStop: 'on',
			shadow: 0,
			fullWidth: 'on',
			fullScreen: 'off',
			spinner: 'spinner3',
			stopLoop: 'off',
			stopAfterLoops: -1,
			stopAtSlide: -1,
			shuffle: 'off',
			autoHeight: 'off',
			forceFullWidth: 'off',
			hideThumbsOnMobile: 'off',
			hideBulletsOnMobile: 'off',
			hideArrowsOnMobile: 'off',
			hideThumbsUnderResolution: 0,
			hideSliderAtLimit: 0,
			hideCaptionAtLimit: 0,
			hideAllCaptionAtLilmit: 0,
			startWithSlide: 0,
			fullScreenOffsetContainer: ''
		}.to_n

		@slider.show.revolution(config)
		@slider_loader.hide
	end

	def init_ico
		@no_usa.on :click do
			@ico_confirm.effect :fade_out do
				@ico_data.effect :fade_in
			end
		end

		init_copy_button('copy-contract')
		init_copy_button('copy-abi')
	end

	def init_copy_button(id)
		selector = "##{id}"
		button = Element[selector]
		button_clip = js_new($$[:Clipboard], selector)

		button_clip.on 'success', -> do
			button.add_class('btn-success')

			after 0.250 do
				button.remove_class('btn-success')
			end
		end

		button_clip.on 'error', -> do
			button.add_class('btn-danger')
		end
	end

end