# this is the SFTP destination
require 'URI'

require 'rubygems'
require 'net/ssh'  # net-ssh-2.6.0
require 'net/sftp' # net-sftp-2.0.5

# TODO: move configuration out of these files in to a config. file
# TODO: add a "config. wizard"

SFTP_URL = "ssh://root:password@localhost:22/path/to/destination"
SFTP_RESULT_URL = "http://localhost/path/to/destination"

def basic_upload(file)
	url = SFTP_URL	# load this
	url = URI.parse(url)
	result_url = SFTP_RESULT_URL

	basename = File.basename(file)

	options = {}
	unless url.port.nil?
		options[:port] = url.port
	end

	unless url.password.nil?
		options[:password] = url.password
	end

	sftp = Net::SFTP.start(url.host, url.user, options) 
	test_name = basename
        destination_file = "." + url.path.chomp("/") + "/" + test_name + "BOG"
	max,min = 9,1	# starting max,min: these increase by a factor of 10 every time they fail.
	begin
		while sftp.stat!(destination_file)
			test_name = (rand(max-min)+min).to_s + "_" + basename
	        	destination_file = "." + url.path.chomp("/") + "/" + test_name
			max *= 10
			min *= 10
		end
	rescue Net::SFTP::StatusException => e
		# eventually, we find a file that doesn't exist.

		sftp.upload!(file, destination_file)
	end

	return result_url + "/" + test_name
end

def sftp_upload(file)
	basic_upload(file)
end
