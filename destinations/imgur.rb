require "rubygems"
require 'JSON' # 1.7.5
require "rest_client" # 1.6.7

IMGUR_API = "a5a8e2b827fad6823015edd44fa79a50"
IMGUR_SERVICE = URI("http://api.imgur.com/2/upload.json")

def imgur_api_upload(file, title="Uploaded with Put", caption="Uploaded with Put <http://github.com/gburtini/Put>")
	response = RestClient.post(IMGUR_SERVICE.to_s, 
		:image => File.new(file),
		:title => title,
		:caption => caption,
		:key => IMGUR_API
	)	

	# TODO: this responds with a deletehash, we should store it somewhere
	return JSON.parse(response.to_str)['upload']['links']['original']
end

def imgur_upload(file, dest_name=nil)
	return imgur_api_upload(file)
end
