module UtilsPack

	def show_error(text)
		Element['#error-modal-body'].html = text
		Element['#error-modal'].modal
	end

	def after(delay, &block)
		$$[:setTimeout].call(block, delay * 1000)
	end

	def valid_tracker(target, event, &cond)
		target.on event do
			valid_marker target, &cond
		end
	end

	def valid_marker(target, &cond)
		if cond.call
			unmark_invalid target
		else
			mark_invalid target
		end
	end

	def mark_invalid(target)
		case target.attr('type')
			when 'checkbox'
				target
					.parent('label')
					.parent('.checkbox')
					.add_class('has-error')
			else
				target
					.parent('.form-group')
					.add_class('has-error')
					.add_class('has-feedback')
					.children('.form-control-feedback')
					.remove_class('hidden')
		end
	end

	def unmark_invalid(target)
		case target.attr('type')
			when 'checkbox'
				target
					.parent('label')
					.parent('.checkbox')
					.remove_class('has-error')
			else
				target
					.parent('.form-group')
					.remove_class('has-error')
					.remove_class('has-feedback')
					.children('.form-control-feedback')
					.add_class('hidden')
		end
	end

	def call_api(payload, &callback)
		HTTP.post '/api', payload: payload do |request|
			if request.ok? and request.json['success']
				callback.call request.json
			else
				show_error "Request error - #{request.json['message'] || 'Connection or Server internal'}"
			end
		end
	end

	def js_new(func, *args, &block)
		args.insert(0, `this`)
		args << block if block

		Native(`new (#{func}.bind.apply(#{func}, #{args}))`)
	end

end