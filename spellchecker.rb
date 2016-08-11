require 'net/http'
require 'certified'
require 'rubygems'
require 'json'
require 'tokenizer'

class Spellchecker
  	# text [String] the text that needs to be checked
  	# mkt [String] The market where the results come from. Typically, this is the country where the user is making the request from; however, it could be a different country if the user is not located in a country where Bing delivers results. The market must be in the form <language code>-<country code>. For example, en-US. The string is case insensitive. For a list of possible values that you may specify, see Market Codes.
  	# language [String] The language to use for user interface strings. Specify the language using the ISO 639-1 2-letter language code. 
  	def initialize(text, mkt, language)
		@mkt = mkt
		@language = language
		@text = text.clone
		need_check = tokener(text)
		@json_need_check = []
		@symbols = []
		@symbols.push(0)
		need_check.each do |checking|
			@symbols.push(checking.length)
			@json_need_check.push(requester(checking))
		end
		puts @symbols
	end

	def tokener(string)
		de_tokenizer = Tokenizer::WhitespaceTokenizer.new

		#text in tokens zerlgen
		tokens = []
		
		de_tokenizer.tokenize(DE_text).each do |i|
			tokens.push(i)
		
		end
		
		token = ""
		word = 1
		checking_tokens = []
		tokenized = false

		#9 tokens zu einem string verbinden diesen in array einfügen
		tokens.each do |i|
			
			tokenized = false
			token = token + " " + i.to_s
			word += 1
			
			if word == 9
				checking_tokens.push(token)
				word = 1
				token = ""
				tokenized = true
			end
		end

		#restlichen wörter anzahl < 9 in array einfügen
		if tokenized == false
			checking_tokens.push(token)
		end
		return checking_tokens
	end


	def requester(string)
  		begin
  			uri = URI('https://api.cognitive.microsoft.com/bing/v5.0/spellcheck/')
  			uri.query = URI.encode_www_form({
			# Request parameters
			'mode' => 'spell', 
			'setLang' => @language,
			'mkt' => @mkt,
			'text' => string[1..-1]

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
		puts @response.body
		
		return @response.body
	end



	#Returns an array = [position, wrong word, right word, score]
	def array
		ret = []
		p_i = 0
		p = 0
		@json_need_check.each do |x|
			i = 0
			p = p + @symbols[p_i].to_i
			puts JSON.parse(x)['flaggedTokens']
			while i < JSON.parse(x)['flaggedTokens'].length do
				temp = JSON.parse(x)['flaggedTokens'][i]
				word = []
				word.push(temp["offset"].to_i + p)
				word.push(temp["token"])
				temp = temp["suggestions"].first
				word.push(temp["suggestion"])
				word.push(temp["score"])
				ret.push(word)
				i += 1
			end
			p_i += 1
		end
		return ret
	end

	# Returns a corrected string
	def str
		ctext = @text.clone
		ret = []
		@json_need_check.each do |x|
			i = 0
			while i < JSON.parse(x)['flaggedTokens'].length do 
				temp = JSON.parse(x)['flaggedTokens'][i]
				pos = temp["offset"]
				ww = temp["token"]
				temp = temp["suggestions"].first
				cw = temp["suggestion"]
				score = temp["score"]
				ctext = ctext.sub! ww, cw
				i += 1
			end	
		end
		return ctext
	end
end