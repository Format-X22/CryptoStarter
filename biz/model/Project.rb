class Project
	include Mongoid::Document

	field :state, type: String
	field :lang,  type: Boolean, localize: true

	field :name,       type: String, localize: true
	field :short_desc, type: String, localize: true
	field :logo_id,    type: String, localize: true
	field :video_id,   type: String, localize: true
	field :present,    type: String, localize: true

	field :use_faq, type: Boolean, localize: true
	field :faq,     type: Array,   localize: true

	validates_length_of   :name,       in: 1..25,     if: :lang?
	validates_length_of   :short_desc, in: 1..100,    if: :lang?
	validates_length_of   :present,    in: 1..10000,  if: :lang?
	validates_presence_of :logo_id,                   if: :lang?

	validate :faq_format

	def faq_format
		faq.each do |qa|
			next if qa == nil

			unless (1..25) === qa[:question].length
				errors[:faq] = '- wrong question length'
			end

			unless (1..1000) === qa[:answer].length
				errors[:faq] = '- wrong answer length'
			end
		end
	end
end