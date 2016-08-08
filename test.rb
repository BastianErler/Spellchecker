require_relative 'spellchecker'
require 'tokenizer'


#Test texte in 5 Sprachen
DE_text = 'Was war pasiert? Am vergangenen Donnerstagabend hate Khizr Khan, Fater eines gefalenen muslimischen US-Soltaden, auf dem Parteitag derer Demmokraten in Philadelphia eine bewegende Rede gehalten. Vor Millionen Zuschauern erzählte er die Geschichte seines Sohnes Humayun, der 2004 im Irak mit 27 Jahren bei einem Autobombenanschlag ums Leben kam. "Mein Sohn opferte sich für sein Land", sagte Khan mit bebender Stimme - um sich im nächsten Satz Trump und dessen Kritik an Muslimen vorzunehmen: "Sie haben nichts und niemanden geopfert!"'
ES_text = 'Muschos países se ressisten a Uber, especialmente en Europa y en su modalida de transporte a cargo de particulares, pero la compañía se las ha ingeniado para ofrecer servicios alternativos y recordar así su presencia. Estas son algunas de las muchas ideas alejadas del habitual viaje en taxi que ha propuesto Uber, algunas como servicios estables y otras a modo de meros despliegues de marketing:'
EN_text = 'Mr. Kalanick, a famously competitiveand aggresive entreprneur, had apparentli studied these risks and semed determined to bridge that gulf. He wuld try to take on China not as an afterthoght, but as a central mission of his fledgling company. He would risk billions and spend a great deal of time in China to figure out the secrets of winning there. The goal seemed lofty, but the opportunity, after all, was eye-popping: Amazon has a market value of $365 billion, and Alibaba is worth about $200 billion. The ride-hailing business might one day grow to be as valuable as e-commerce, if not larger — and wouldn’t it be fantastic if you could own it all, everywhere?'
FR_text = 'Les perturbatyons sont purtant toujours bien présentes. Mardi matin, 17 vols au départ de Paris étaient annoncés annulés avant midi : 4 depuis Orly et 13 depuis Paris-Charles-de-Gaulle. Le sud de lEurope est particulièrement touché avec plusiurs suppressions de vols à destination de Lisbonne, Barcelone, Milan et Venise. Pour les vols intérieurs, les départs pour Nice et Lyon sont les plus impactés avec deux avions annulés pour chacune des deux destinations.'
NL_text = 'Door werkzamheden an het spoor is er de hele dag beperkt trainverkeer mogelijk richting Schiphol. Het spoor tussen Duivendrecht en Schiphol wordt verdubeld om ruimte te macen voor meer treinen. "Gezien de situatie op de weg rond Schiphol is het voor reizigers van groot belang om vóór vertrek de reisplanner van NS te checken", meldt ProRail. '
language = "DE" #DE, ES, EN, FR, NL                   language [String] The language to use for user interface strings. Specify the language using the ISO 639-1 2-letter language code. 
mkt = "de-DE" #de-DE, es-ES, en-EN, fr-FR, nl-NL      mkt [String] The market where the results come from. Typically, this is the country where the user is making the request from; however, it could be a different country if the user is not located in a country where Bing delivers results. The market must be in the form <language code>-<country code>. For example, en-US. The string is case insensitive. For a list of possible values that you may specify, see Market Codes.
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

# jeden 9er string durch den Spellchecker laufen lassen und ausgeben
checking_tokens.each do |i|
	checked = Spellchecker.new(i,mkt,language)
	puts i                                                                      # zu checkender string
	puts ""                                                                     # leerzeile
	checked.array.each do |i|                                                   # 
		puts i[0].to_s + " " +  i[1].to_s + " " + i[2].to_s + " " + i[3].to_s   # [position, wrong word, right word, score]
		puts ""                                                                 # leerzeile
	end
	puts checked.str                                                            # checked string
	puts ""                                                                     # leerzeile
	puts "_____________________________________________________________________"
end