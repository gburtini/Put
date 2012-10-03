#!/usr/bin/env ruby

require 'optparse'
require 'put-exceptions'

CLIPBOARD_BINARIES = ['pbcopy', 'xclip', 'clip']

# TODO: support directories (tar/zip them)
# TODO: autocompression flag
# TODO: auto copy from CLIPBOARD_BINARIES in order

def uploadFiles(files, destination)
	files.each do |file|
		# TODO: add file anonymization here (rename to random letters)
		file = File.expand_path(file)
		if File.exist?(file) then
			puts destination.call(file)
		else
			puts "Skipping " + file + " because it doesn't exist."
		end
	end
end

def getDestinationResource(request)
	# do we really need this, or can resources just be single functions (upload)
	if request.nil? then
		request = "basic"
	end

	if File.exist?("destinations/" + request + ".rb" ) then
		require("destinations/" + request)
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
	
	$options[:mode] = :upload
end
opts.parse!

# catch the ON case and parse ARGV accordingly
if ARGV.length == 3 then
	if ARGV[1].downcase == "on" then
		$options[:destination] = ARGV[2]
		ARGV.delete_at(1)	# remove the ON flag
		ARGV.delete_at(2)	# remove the destination
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

