helpers do

	def page(path)
		page = File.read("./views/page/#{path}/main.html")

		erb(page, locals: {l: lang, auth_data: auth_data})
	end

	def inner_page(path, redirect_path)
		if logged_in?
			page path
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

	def data
		JSON.parse request.body.read
	end
end