#!/usr/bin/ruby -Ku

require "rubygems"
require 'nokogiri'
require "open3"
require 'json'
require 'zip'

################################################################
# compressing a directory into a zip file
# Usage:
# directoryToZip = "/tmp/input"
# outputFile = "/tmp/out.zip"
# zf = ZipFileGenerator.new(directoryToZip, outputFile)
# zf.write()
################################################################
class ZipFileGenerator
	# Initialize with the directory to zip and the location of the output archive.
	def initialize(inputDir, outputFile)
		@inputDir = inputDir
		@outputFile = outputFile
	end
	# Zip the input directory.
	def write()
		entries = Dir.entries(@inputDir); entries.delete("."); entries.delete("..")
		io = Zip::File.open(@outputFile, Zip::File::CREATE);
		writeEntries(entries, "", io)
		io.close();
	end
	# A helper method to make the recursion work.
	private
	def writeEntries(entries, path, io)
		entries.each { |e|
		zipFilePath = path == "" ? e : File.join(path, e)
		diskFilePath = File.join(@inputDir, zipFilePath)
		if File.directory?(diskFilePath)
			io.mkdir(zipFilePath)
			subdir =Dir.entries(diskFilePath); subdir.delete("."); subdir.delete("..")
			writeEntries(subdir, zipFilePath, io)
		else
			io.get_output_stream(zipFilePath) { |f| f.puts(File.open(diskFilePath, "rb").read())}
		end
		}
	end
end

############################################
# extract information from an url
# property : String content -- information extracted from the website
# method : extract(String url) -- extract information
# method : replace(Array indiv_replaces) -- replace with Array["match" => "pattern" , "with" => "replace"] 
# constracter : css selector , replaces
############################################

class Extractor
	attr_accessor:content
	def initialize (selector,common_replaces)
		@selector = selector
		@common_replaces = common_replaces
		@content = ""
	end
	def extract(url)
		html, err, status = Open3.capture3('curl ' + url)
		doc = Nokogiri.HTML(html)
		description = doc.css(@selector).inner_html
		@content = description
	end
	def replace (indiv_replaces)
		replaces = @common_replaces
		if indiv_replaces != nil then
			indiv_replaces.each{|r|
				replaces << r
			}
		end
		replaces.each{|replace|
			@content = @content.gsub(/#{replace["match"]}/,replace["with"])
		}
	end
end


# initialize
OUTPUT_DIR = "./tmp"
CONFIG_FILE = "config.json"
Open3.capture3("rm " + OUTPUT_DIR + "/*")

# read the configuration file
config = JSON.load(open(CONFIG_FILE))

# extract each sites
extractor = Extractor.new(config["selector"],config["common_replace"])
0.upto(config["magazine"].length - 1){|i|
	extractor.extract( config["magazine"][i]["url"])
	extractor.replace(config["magazine"][i]["replace"] )
	file = File.open(OUTPUT_DIR + "/" + config["magazine"][i]["list_no"] + "_" + config["magazine"][i]["title"] + ".txt" , "w")
	file.puts (extractor.content)
	file.close
	File.chmod(0666,file.path)
}

# compress outouts into a zip file
zf = ZipFileGenerator.new( OUTPUT_DIR, OUTPUT_DIR + "/results.zip")
zf.write()
File.chmod(0666, OUTPUT_DIR + "/results.zip")

# output
print ("content-type: text/html\n\n") 
print ("<p><a href=\"" + OUTPUT_DIR + "/results.zip\">results.zip</a></p>\n\n")


