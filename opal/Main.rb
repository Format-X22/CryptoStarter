require 'opal'
require 'native'
require 'opal-jquery'

require 'page/AbstractPage'
require 'page/AllPages'
require 'page/IndexPage'
require 'page/LoginPage'
require 'page/ProfilePage'
require 'page/ProjectPage'
require 'page/RegisterPage'
require 'page/RegisterProjectPage'
require 'page/RestorePassPage'
require 'util/ConsoleSurprise'

Document.ready? do
	ConsoleSurprise.new
	AllPages.new

	case $$[:location].pathname
		when /^\//                then IndexPage.new
		when /^\/login/           then LoginPage.new
		when /^\/profile/         then ProfilePage.new
		when /^\/project/         then ProjectPage.new
		when /^\/registerProject/ then RegisterProjectPage.new
		when /^\/register/        then RegisterPage.new
		when /^\/restorePass/     then RestorePassPage.new
		else                      # do nothing
	end
end