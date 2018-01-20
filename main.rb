require 'http'
require 'recursive-open-struct'
require 'sinatra'
require "sinatra/reloader"
require "sinatra/multi_route"
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
		erb(File.read("views/page/#{path}/main.html"), locals: {l: locale, earned: earned})
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

	def earned
		contract = '0xa6047765e275522bfa0ef6638cbc402de023aa86'
		link = "https://etherscan.io/readContract?a=#{contract}"
		raw = HTTP.get(link).to_s

		re = /earnedEthWei.*?<\/i>(.*?)<i>/
		parsed = raw.match(re)[1]

		wei = parsed.strip.to_f
		ether = wei * 10 ** -18
		dollar = ether * 300

		dollar.to_i
	rescue
		0
	end

	def earned_to_readable(earned)
		formed = '%6d' % earned
		left = formed[0..2].strip
		right = formed[3..5]

		"$#{left} #{right}"
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

get '/whitepaper', ['/wp', '/whitepaper/whitepaper.pdf', '/docs/whitepaper.pdf'] do
  send_file File.join(settings.public_folder, '/docs/whitepaper.pdf')
end

get '/logo', ['/presskit/logo', '/artassets/logo', '/cslogo.png', '/logo.png'] do
  send_file File.join(settings.public_folder, '/img/logo/origin.png')
end

get '/svglogo', ['/presskit/svglogo', '/artassets/svglogo', '/cslogo.svg', '/logo.svg'] do
  send_file File.join(settings.public_folder, '/img/logo/origin.svg')
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