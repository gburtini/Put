require 'rubygems'
require 'JSON' # 1.7.5
require 'rest_client' # 1.6.7
require 'webbrowser'

DROPBOX_OAUTH_SERVICE = [
				URI("https://api.dropbox.com/1/oauth/request_token"),
				URI("https://api.dropbox.com/1/oauth/authorize"),
				URI("https://api.dropbox.com/1/oauth/access_token")
			]

DROPBOX_UPLOAD_SERVICE = URI("https://api-content.dropbox.com/1/files_put/dropbox/") 
DROPBOX_SHARES_SERVICE = URI("https://api.dropbox.com/1/shares/dropbox/") 
DROPBOX_PATH = "put/shares/"
webbrowser.open_new("http://example.com/")


def dropbox_authenticate()
	response = RestClient.post(dropbox_upload_url(dest_name))
	
end

def dropbox_authenticate_one()
	
end

def dropbox_authenticate_two()
	dropbox_open_browser(DROPBOX_OAUTH_SERVICE[1])
end

def dropbox_authenticate_three()

end

def dropbox_open_browser(url) 
	if RUBY_PLATFORM.downcase.include?("mswin") then
		system("start", url)
	elsif RUBY_PLATFORM.downcase.include?("darwin") then
		system("open", url)
	else
		puts "Please go to " + url + " to finish authenticating."
	end
end

def dropbox_upload_url(dest_name)
	# max size 150mb, there's a chunked upload for other uploads, but we don't support it
	return (DROPBOX_UPLOAD_SERVICE + DROPBOX_PATH + dest_name + "?overwrite=false")
end

def dropbox_share_url(dest_name)
	return (DROPBOX_SHARES_SERVICE + DROPBOX_PATH + dest_name + "?short_url=true")
end

def dropbox_api_upload(file, dest_name=nil)
	response = RestClient.put(dropbox_upload_url(dest_name))	

	# TODO: this responds with a deletehash, we should store it somewhere
	return JSON.parse(response.to_str)['url']
end

def imgur_upload(file, dest_name=nil)
	return imgur_api_upload(file)
end
