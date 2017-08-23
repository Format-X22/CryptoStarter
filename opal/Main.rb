require 'opal'
require 'native'
require 'opal-jquery'

require 'AllPages'
require 'RootPage'
require 'ConsoleSurprise'

Document.ready? do
	ConsoleSurprise.new
	AllPages.new

	case $$[:location].pathname
		when '/'
			RootPage.new
	end
end