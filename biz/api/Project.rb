require 'ostruct' # TODO just for demo

helpers do

	def projects_demo(count, offset) # TODO just for demo
		result = []

		count.times do |i|
			result.push OpenStruct.new({
				id: i + offset,
				img: '/img/project_stub.jpeg',
				title: $locale[cookies[:lang] || 'en'].demo.project_title,
				description: $locale[cookies[:lang] || 'en'].demo.project_desc,
				progress: '75',
				count: '332',
				percent: '75',
				days: '10'
			})
		end

		result
	end

	def active_projects
		projects_demo(6, 0)
	end

	def prepared_projects
		projects_demo(3, 10)
	end

	def done_projects
		projects_demo(2, 15)
	end

	def project(id)
		# TODO
	end

end