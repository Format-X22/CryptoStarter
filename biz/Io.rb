helpers do

	def page(path, data = {})
		page = File.read("./views/page/#{path}/main.html")

		erb(page, locals: {
			l: lang,
			d: data,
			u: user
		})
	end

	def inner_page(path, redirect_path, data = {})
		if logged_in?
			page path, data
		else
			redirect "/#{redirect_path}"
		end
	end

	def success(data = {})
		content_type :json
		halt 200, {success: true, data: data}.to_json
	end

	def failure(message='Unknown error')
		content_type :json
		halt 200, {success: false, message: message}.to_json
	end

	def parse_data
		JSON.parse request.body.read
	end
end