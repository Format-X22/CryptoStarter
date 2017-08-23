require 'UtilsPack'

class AllPages
	include UtilsPack

	def initialize
		map_elements
		expose_plugins
		init_scroll_to_top
	end

	def map_elements
		e = Element

		@js_window      = e[`window`]
		@body_and_html  = e['body, html']
		@to_top         = e['#to-top']
	end

	def expose_plugins
		Element.expose :modal
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
end