require 'recursive-open-struct'
require 'sinatra'

helpers do
	def page(path, locale)
		erb(File.read("views/page/#{path}/main.html"), locals: {l: locale})
	end

	def success(data = {})
		content_type :json
		halt 200, {success: true, data: data}.to_json
	end

	def failure(message='Unknown error')
		content_type :json
		halt 200, {success: false, message: message}.to_json
	end
end

locale = OpenStruct.new

Dir['locale/*'].each do |path|
	name = path.split('/').last.split('.').first
	hash = JSON.parse(File.read(path))
	locale[name] = RecursiveOpenStruct.new(hash)
end

get '/' do
	page 'index', locale.en
end

get '/de' do
	page 'index', locale.de
end

get '/fr' do
	page 'index', locale.fr
end

get '/ch' do
	page 'index', locale.ch
end

get '/ar' do
	page 'index', locale.ar
end

get '/ru' do
	page 'index', locale.ru
end

post '/api/pre-register' do
	# TODO Register logic

	success
end