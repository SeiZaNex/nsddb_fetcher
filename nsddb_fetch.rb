#!/usr/bin/env ruby

require 'net/http'
require 'open-uri'

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

av = []
if !ARGV.empty? then
  for i in ARGV
    av << i.to_i
  end

  file_name = "nsddb_reqst.txt"
  fstream = File.open(file_name, "a+")

  for i in attr
    fstream.print "\t"
    fstream.print i
  end
  fstream.print "\n"

  for index in av

    home = "http://nsddb.eu/substance/"
    path = home + "#{index}/"

    #
    # check if url exists
    #

    url = URI.parse(path)
    req = Net::HTTP.new(url.host, url.port)
    res = req.request_head(url.path)

    if res.code == "200"

      #
      # open url path to string
      #

      puts "Opening #{path}..."

      page = open(path) { |f| f.read }  # page.class => String

      re = /<("[^"]*"|'[^']*'|[^'">])*>/
      page.gsub!(re, '')
      page.gsub!("\r", '')
      page.gsub!("\t", '')

      puts "HTML code removed."
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
    else
      puts " #{index} was unreachable..."
      puts "skipping..."
    end
  end

  fstream.close

else
  puts "usage: ./nsddb_fecht.rb index [+index...]"
  puts "\t -index has to be a valid numeric value for http://nsddb.eu/substance/"
end
