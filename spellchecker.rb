require 'net/http'
require 'certified'
require 'rubygems'
require 'json'

class Spellchecker
  	# text [String] the text that needs to be checked
  	# mkt [String] The market where the results come from. Typically, this is the country where the user is making the request from; however, it could be a different country if the user is not located in a country where Bing delivers results. The market must be in the form <language code>-<country code>. For example, en-US. The string is case insensitive. For a list of possible values that you may specify, see Market Codes.
  	# language [String] The language to use for user interface strings. Specify the language using the ISO 639-1 2-letter language code. 
	def initialize(text, mkt, language)
		begin
		@text = text
		@mkt = mkt
		@language = language
		uri = URI('https://api.cognitive.microsoft.com/bing/v5.0/spellcheck/')
		uri.query = URI.encode_www_form({
			# Request parameters
			'mode' => 'spell', 
			'setLang' => @language,
			'mkt' => @mkt,
			'text' => text[1..-1]

		})
		request = Net::HTTP::Post.new(uri.request_uri)
		# Request headers
		request['Content-Type'] = 'String'
		# Request headers
		request['Ocp-Apim-Subscription-Key'] = '9337f74675eb47a1900ce6b43212985c'
		# Request body
		#request.body = "{body}"

		@response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
			http.request(request)
		end
	end until JSON.parse(@response.body)['_type'] != "ErrorResponse" #retry until no ErrorResponse
end

	#Returns an array = [position, wrong word, right word, score]
	def array
		ret = []
		i = 0
		while i < JSON.parse(@response.body)['flaggedTokens'].length do
			temp = JSON.parse(@response.body)['flaggedTokens'][i]
			word = []
			word.push(temp["offset"])
			word.push(temp["token"])
			temp = temp["suggestions"].first
			word.push(temp["suggestion"])
			word.push(temp["score"])
			ret.push(word)
			i += 1
		end
		return ret
	end

	# Returns a corrected string
	def str
		ctext = @text.clone
		i = 0
		while i < JSON.parse(@response.body)['flaggedTokens'].length do 
			temp = JSON.parse(@response.body)['flaggedTokens'][i]
			pos = temp["offset"]
			ww = temp["token"]
			temp = temp["suggestions"].first
			cw = temp["suggestion"]
			score = temp["score"]
			ctext = ctext.sub! ww, cw
			i += 1

		end
		return ctext
	end
end