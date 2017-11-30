require 'sendgrid-ruby'

include SendGrid

helpers do

	if ENV['SENDGRID_API_KEY']
		SEND_GRID = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
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