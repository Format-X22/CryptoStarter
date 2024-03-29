class AllPages < AbstractPage

	TO_TOP_EDGE = 100
	TO_TOP_SPEED = 800

	def initialize
		map_elements
		make_handlers
		expose_plugins
		init_rtl
		init_scroll_to_top
	end

	def map_elements
		e = Element

		@js_window      = e[`window`]
		@body_and_html  = e['body, html']
		@to_top         = e['#to-top']
		@main_langs     = e['#top-menu .main-lang']
	end

	def expose_plugins
		Element.expose :modal
	end

	def make_handlers
		@main_langs.on :click do |event|
			lang_link = event.current_target.children('a')
			lang = lang_link.attr('href').sub('#', '')

			$$.document.cookie = "lang=#{lang}"
			$$.location.reload
		end
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

	def init_rtl
		cookie = String.new($$.document.cookie)

		cookie.split(' ').each do |pair|
			key, value = pair.split('=')

			if key == 'lang' and value == 'ar'
				@body_and_html.add_class('rtl')
			end
		end
	end
end