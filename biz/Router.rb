get '/'                do page 'index'           end
get '/about'           do page 'about'           end
get '/login'           do page 'login'           end
get '/project'         do page 'project'         end
get '/register'        do page 'register'        end
get '/registerProject' do page 'registerProject' end
get '/restorePass'     do page 'restorePass'     end
get '/term'            do page 'term'            end

get '/profile'            do inner_page 'profile',            'login' end
get '/projectConstructor' do inner_page 'projectConstructor', 'login' end

not_found do
	status 404
	page 'error404'
end

post '/api/auth' do
	# TODO
end

post '/api/user' do
	# TODO
end

post '/api/project' do
	# TODO
end