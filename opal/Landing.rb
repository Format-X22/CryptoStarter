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

		after 0.250 do
			init_slider
		end
	end

	def map_elements
		@js_window = Element[`window`]
		@body_and_html = Element['body, html']
		@to_top = Element['#to-top']
		@project = Element['#project']
		@email = Element['#email']
		@description = Element['#description']
		@message = Element['#message']
		@send = Element['#send']
		@slider = Element['#wow-slider']
		@slider_loader = Element['#wow-fix-loader']
		@register_modal = Element['#register-modal']
	end

	def expose_plugins
		Element.expose :modal
		Element.expose :revolution
	end

	def init_scroll_to_top
		@js_window.on :scroll do
			if @body_and_html.width < 767
				@to_top.effect :fade_out
			end

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

end