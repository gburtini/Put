require 'rubygems'
#require 'dropbox-api' # 0.3.2
require 'dropbox' # 1.3.0
 
DROPBOX_APP_KEY = "1oridgvbovz6xom"
DROPBOX_APP_SECRET = "oub93xuguv5jdrh"

def dropbox_api_upload(file, dest_name=nil)
	session = Dropbox::Session.new(DROPBOX_APP_KEY, DROPBOX_APP_SECRET)
	puts "Visit #{session.authorize_url} to log in to Dropbox. Hit enter when you have done this."
	gets
	session.authorize
	session.sandbox = true

	# STEP 2: Play!
	session.upload('testfile.txt')
	uploaded_file = session.file('testfile.txt')
	puts uploaded_file.metadata.size

	uploaded_file.move 'new_name.txt'
	uploaded_file.delete
end

def dropbox_upload(file, dest_name=nil)
	return dropbox_api_upload(file, dest_name)
end
