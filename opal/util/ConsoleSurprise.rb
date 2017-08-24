class ConsoleSurprise

	def initialize
		loc = $$.location
		port = ''

		if loc.port
			port = ':' + loc.port
		end

		$$.console.log(
			'%c+',
			'font-size: 1px;' +
				'padding: 60px 59.5px;' +
				'line-height: 120px;' +
				'background: url("' +
				"#{loc.protocol}//#{loc.hostname}#{port}/img/logo/120.png" +
				'");' +
				'background-size: 120px 120px;' +
				'color: transparent;'
		)

		$$.console.log('CryptoStarter console >>')
	end

end