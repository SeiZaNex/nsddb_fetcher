#!/usr/bin/env ruby

require 'net/http'
require 'open-uri'

file_name = "nsddb_table.txt"
fstream = File.open(file_name, "w")

attr = [ 
        "Formula",
        "Average mass",
        "Monoisotopic mass",
        "InChI",
        "InChI key",
        "SMILES",
        "CAS name",
        "Alternative names",
        "CAS RNs",
        "Legal Status",
        "Appearance",
        "Melting point",
        "Boiling point",
        "Stability"
       ]

for i in attr
  fstream.print "\t"
  fstream.print i
end
fstream.print "\n"

index = if ARGV.empty? then 1 else ARGV[0] end
while (true)

  home = "http://nsddb.eu/substance/"
  path = home + "#{index}/" # setting up url for looping purposes

  #
  # this code checks url's existance with HTTP codes
  #

  url = URI.parse(path)
  req = Net::HTTP.new(url.host, url.port)
  res = req.request_head(url.path) # requests the url's HTTP Header's code

  # WARNING! LOOP BREAK!

  if res.code == "200" # HTTP CODE 200 => OK. Code will exit and close the file if HTTP doesn't answer 200

    puts "Opening #{path}..."

    page = open(path) { |f| f.read }  # open URL path to String

    re = /<("[^"]*"|'[^']*'|[^'">])*>/
    page.gsub!(re, '') # removes the html tags <></>
    page.gsub!("\r", '')
    page.gsub!("\t", '')

    puts "HTML code removed."

    #
    # format string into array for parsing
    #

    puts "Arraying data for parsing."
    
    array = page.split("\n")
    array.reject! { |c| c.empty? }

    puts "Extracting data to file..."

    fstream.print index

    for i in array
      for a in attr
        if i.include? a then
          fstream.print "\t"
          tmp = i.split(":")
          fstream.print tmp[1]
        end
      end
    end
    fstream.print "\n"

    puts " #{index} complete..."
  elsif res.code == "404" then
    puts " #{index} does not exist."
    puts "exiting..."
    break
  else
    puts " #{index} was innaccessible..."
    puts "skipping..."
  end
  index += 1
end

fstream.close
