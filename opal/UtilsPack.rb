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
			if cond.call
				unmark_invalid target
			else
				mark_invalid target
			end
		end
	end

	def mark_invalid(target)
		target
			.parent('.form-group')
			.add_class('has-error')
			.add_class('has-feedback')
			.children('.form-control-feedback')
			.remove_class('hidden')
	end

	def unmark_invalid(target)
		target
			.parent('.form-group')
			.remove_class('has-error')
			.remove_class('has-feedback')
			.children('.form-control-feedback')
			.add_class('hidden')
	end

end