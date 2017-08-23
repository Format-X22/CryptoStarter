require 'opal'
require 'native'
require 'opal-jquery'

require 'AllPages'
require 'RootPage'
require 'ConsoleSurprise'

Document.ready? do
	ConsoleSurprise.new
	AllPages.new
	RootPage.new
end