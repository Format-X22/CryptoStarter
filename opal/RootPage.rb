require 'UtilsPack'

class RootPage
	include UtilsPack

	TO_TOP_EDGE = 100
	TO_TOP_SPEED = 800

	def initialize
		map_elements
		expose_plugins
		init_tabs

		after 0.250 do
			init_slider
		end
	end

	def map_elements
		e = Element

		@slider            = e['#wow-slider']
		@slider_loader     = e['#wow-fix-loader']
		@active_projects   = e['#active-projects']
		@prepared_projects = e['#prepared-projects']
		@done_projects     = e['#done-projects']
		@project_tabs_btns = e['#project-tabs a']
	end

	def expose_plugins
		Element.expose :revolution
		Element.expose :tab
	end

	def init_tabs
		[
			@active_projects,
			@prepared_projects,
			@done_projects
		].each do |tab|
			tab.remove_class('hidden')
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