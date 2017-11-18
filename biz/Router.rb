get '/' do
	page 'index', {
		active_projects: active_projects,
		prepared_projects: prepared_projects,
		done_projects: done_projects
	}
end

get '/about' do
	page 'about'
end

get '/login' do
	page 'login'
end

get '/project-:id' do
	page 'project'
end

get '/register' do
	page 'register'
end

get '/registerProject' do
	page 'registerProject'
end

get '/restorePass' do
	page 'restorePass'
end

get '/term' do
	page 'term'
end

get '/profile-:id' do
	inner_page 'profile', 'login', user(params[:id])
end

get '/projectConstructor-:id' do
	inner_page 'projectConstructor', 'login'
end

post '/api/login' do
	data = parse_data

	auth(data['email'], data['pass'])
end

post '/api/register' do
	data = parse_data

	new_user(data['email'], data['pass'])
end

post '/api/register-project' do
	# TODO

	success
end

post '/api/restore-pass' do
	# TODO

	success
end

not_found do
	status 404
	page 'error404'
end