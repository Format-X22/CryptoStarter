require 'http'
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
	data = get_data

	if data['message'].length > 0
		# Silent ban
		success
		return
	end

	captcha_request = HTTP.post('https://www.google.com/recaptcha/api/siteverify', form: {
		secret: ENV['CAPTCHA'],
		response: data['captcha'],
		remoteip: request.ip
	})

	captcha_data = JSON.parse captcha_request.body.readpartial

	unless captcha_data['success']
		failure 'Bad Google captcha.'
	end

	user_mail = send_mail(
		data['email'],
		'Success CryptoStarter pre-registration!',
		'Your project successful registered in CryptoStarter project list!'
	)

	if user_mail.body.length == 0
		send_mail(
			ENV['TEAM_EMAIL'],
			'CryptoStarter pre-register',
			"Project data:\n\n#{data['project']}\n\n#{data['email']}\n\n#{data['description']}"
		)

		success
	else
		failure 'Invalid Email address.'
	end
end