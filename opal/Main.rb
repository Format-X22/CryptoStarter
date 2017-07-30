require 'opal'
require 'native'
require 'opal-jquery'

require 'Landing'
require 'ConsoleSurprise'

Document.ready? do
	ConsoleSurprise.new
	Landing.new
end