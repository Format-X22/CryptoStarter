require 'recursive-open-struct'

$locale = {}

Dir['./locale/*'].each do |path|
	name = path.split('/').last.split('.').first
	hash = JSON.parse(File.read(path))

	$locale[name] = RecursiveOpenStruct.new(hash)
end

helpers do

	def lang
		$locale['ru']

		#$locale[cookies[:lang]] or $locale['en']  TODO
	end
end
