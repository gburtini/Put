#!/usr/bin/env ruby

require 'optparse'
class DestinationNotFoundException < IOError
end

# tries to pipe the URLs in to each of these binaries in order to put them on a clipboard.
CLIPBOARD_BINARIES = ['pbcopy', 'xclip', 'clip']

DEFAULT_RANDOM_SIZE = 24

# TODO: autocompression flag

def generateRandomString(size = 24)
	charset = %w{ 2 3 4 6 7 9 A C D E F G H J K M N P Q R T V W X Y Z}
	return (0...size).map do
		charset.to_a[rand(charset.size)] 
	end.join
end

def command?(cmd)
	exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']	# Windows only AFAICT
	ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
		exts.each do |ext|
			exe = "#{path}/#{cmd}#{ext}"
			return exe if File.executable? exe
		end
	end
	return nil
end

def addToClipboard(paste_string) 
	paste_string.chomp!
	CLIPBOARD_BINARIES.each do |binary|
		if command?(binary) then
			# TODO: check to make sure this works
			`echo "#{paste_string}" | #{binary}`
		end
	end
end

def uploadFiles(files, destination)
	files.each do |file|
		destination_file = File.basename(file)
		if $options[:randomize_name] then 	# randomize the file name.
			destination_file = generateRandomString($options[:randomize_name]) + File.extname(file)
		end

		paste_string = ""

		file = File.expand_path(file)
		if File.exist?(file) then
			directory = false
			if File.directory?(file) then
				# This is really awful. There's gotta be a nicer way to do this.

				directory = true
				destination_file = destination_file + ".tar.gz"
				file_path = File.dirname(file)
				file_base = File.basename(file)
				`tar -C #{file_path}  -czf /tmp/#{destination_file} ./#{file_base}`
				file = File.expand_path("/tmp/" + destination_file)
			end

			paste_string += destination.call(file, destination_file) + "\n"

			if directory == true then
				`rm -f #{file}`	
			end
		else
			puts "Skipping " + file + " because it doesn't exist."
		end

		if !paste_string.empty? then
			addToClipboard(paste_string)
			puts paste_string
		end
	end
end

def getDestinationResource(request)
	# do we really need this, or can resources just be single functions (upload)
	if request.nil? then
		request = "basic"
	end

	if File.exist?("/usr/bin/destinations/" + request + ".rb" ) then
		require("/usr/bin/destinations/" + request)
		return method((request + "_upload").to_sym)
	else
		raise DestinationNotFoundException, "Destination not found."
		return nil
	end
end

$options = {}
opts = OptionParser.new do |opts|
	opts.banner = "Usage: put [-d destination] filename"

        $options[:verbose] = false;
        $options[:extra_verbose] = false;
        opts.on('-v', '--verbose', "Output more information.") do
                $options[:verbose] = true
        end
        opts.on('-w', '--extra-verbose', "Output even more information.") do
                $options[:extra_verbose] = true
        end

	$options[:destination] = nil
	opts.on("-d", "--destination D", "Specify a destination. By default, picks your primary destination.") do |val|
		# TODO: validate destination is a valid resource
		$options[:destination] = val
	end

	$options[:randomize_name] = false
	opts.on("-r", "--randomize [N]", Integer, "Randomize the filename before uploading. Randomize to length N if specified.") do |size|
		$options[:randomize_name] = size || DEFAULT_RANDOM_SIZE
	end

	$options[:mode] = :upload
end
opts.parse!

# catch the ON case and parse ARGV accordingly
if ARGV.length == 3 then
	if ARGV[1].downcase == "on" then
		$options[:destination] = ARGV[2]
		ARGV.delete_at(1)	# remove the ON flag
		ARGV.delete_at(1)	# remove the destination
	end
end


begin
	destination = getDestinationResource($options[:destination])
	case $options[:mode]
		when :upload
			uploadFiles(ARGV, destination)
	end

rescue DestinationNotFoundException => e
	unless $options[:destination].nil? 
		print "Your requested destination " + $options[:destination] + " does not exist. "
	end

	puts "Please check all files required for put exist."
	puts e.backtrace.inspect
rescue Exception => e
	puts e.message  
	puts e.backtrace.inspect  
end

