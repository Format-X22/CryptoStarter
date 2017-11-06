require 'recursive-open-struct'
require 'sinatra'
require 'sendgrid-ruby'

include SendGrid

helpers do

	if ENV['SENDGRID_API_KEY']
		SEND_GRID = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
	end

	def get_data
		JSON.parse request.body.read
	end

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

	def send_mail(to, title, text)
		SEND_GRID.client.mail._('send').post(
			request_body: Mail.new(
				Email.new(email: 'no-reply@cryptostarter.io'),
				title,
				Email.new(email: to),
				Content.new(type: 'text/plain', value: text)
			).to_json
		)
	end
end

locale = OpenStruct.new

Dir['locale/*'].each do |path|
	name = path.split('/').last.split('.').first
	hash = JSON.parse(File.read(path))
	locale[name] = RecursiveOpenStruct.new(hash)
end

get '/' do
	page 'coming', locale.en
end
