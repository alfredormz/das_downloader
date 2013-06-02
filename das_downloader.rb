#! /usr/bin/env ruby
require 'mechanize'
#usage das_dowloader.rb [destination_path]


URL = "https://www.dropbox.com/sh/cy20e9npok91qc4/FxNKaTDdqE/das?lst"
path  = ARGV[0] || "."
agent = Mechanize.new
agent.pluggable_parser.default = Mechanize::Download

agent.get URL
links = agent.page.search("a.filename-link").map { |l| l['href'] }

links.each do |url|

  agent.get(url)
  download_button_link = agent.page.search("#download_button_link").first["href"]
  screencast_filename  = "#{url.split("/").last}"
  target_filename      = "#{path}/#{screencast_filename}"

  unless File.exists? target_filename
    puts "Downloading #{screencast_filename}"
    agent.get(download_button_link).save target_filename
  else
    puts "#{screencast_filename} already downloaded"
  end
end


