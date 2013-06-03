#! /usr/bin/env ruby
require 'mechanize'
#usage das_dowloader.rb [destination_path]


path  = ARGV[0] || "."

class DASDownloader

  URL = "https://www.dropbox.com/sh/cy20e9npok91qc4/FxNKaTDdqE/das?lst"
  attr_reader   :screencast_urls
  attr_accessor :destination_path

  def initialize(destination_path=nil)
    @agent = Mechanize.new
    @destination_path = destination_path || "."
    @screencast_urls = fetch_urls
  end

  def run
    screencast_urls.each do |screencast_url|
      download_screencast(screencast_url)
    end
  end

  def download_screencast(screencast_url)
    unless already_downloaded? screencast_url
      fetch_and_save_file(screencast_url)
     else
      puts "#{screencast_filename(screencast_url)} already downloaded"
    end
  end

  private

  def fetch_urls
   @agent.get URL
   @agent.page.search("a.filename-link").map { |l| l['href'] }
  end

  def fetch_and_save_file(screencast_url)
    @agent.get(screencast_url)
    puts "Downloading #{screencast_filename(screencast_url)}"
    download_button_link = @agent.page.search("#download_button_link").first["href"]
    @agent.get(download_button_link).save target_filename
  end

  def screencast_filename(screencast_url)
    "#{screencast_url.split("/").last}"
  end

  def target_filename(screencast_url)
    "#{destination_path}/#{screencast_filename(screencast_url)}"
  end

  def already_downloaded?(screencast_url)
    File.exists? target_filename(screencast_url)
  end
end


DASDownloader.new(path).run
