require 'ostruct' # TODO just for demo

helpers do

	def projects_demo(count, offset) # TODO just for demo
		result = []

		count.times do |i|
			result.push OpenStruct.new({
				id: i + offset,
				img: '/img/project_stub.jpeg',
				title: 'Всемирный атлас кофе',
				description: 'Знаковая книга о кофе одного из самых известных и передовых профессионалов индустрии.',
				progress: '75',
				count: '332',
				percent: '75',
				days: '10'
			})
		end

		result
	end

	def active_projects
		projects_demo(10, 0)
	end

	def prepared_projects
		projects_demo(5, 10)
	end

	def done_projects
		projects_demo(2, 15)
	end

	def project(id)
		# TODO
	end

end