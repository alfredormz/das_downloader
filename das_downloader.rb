#! /usr/bin/env ruby
require 'mechanize'
#usage das_dowloader.rb [destination_path]


path  = ARGV[0] || "."

class DASDownloader

  URL = "https://www.dropbox.com/sh/cy20e9npok91qc4/FxNKaTDdqE/das?lst"

  attr_reader   :screencast_urls
  attr_accessor :destination_path

  def initialize(destination_path=nil)
    @agent            = Mechanize.new
    @destination_path = destination_path || "."
    @screencast_urls  = fetch_urls
  end

  def run
    screencast_urls.each do |screencast_url|
      download_screencast(screencast_url)
    end
  end

  def download_screencast(screencast_url)
    Downloader.new(screencast_url, destination_path).save_file
  end

  private

  def fetch_urls
   @agent.get URL
   @agent.page.search("a.filename-link").map { |l| l['href'] }
  end

end

class Downloader

  attr_accessor :screencast_url, :destination_path

  def initialize(screencast_url, destination_path)
    @screencast_url   = screencast_url
    @destination_path = destination_path
    @agent            = Mechanize.new
  end

  def save_file
    unless already_downloaded?
      puts "Downloading #{screencast_filename} ..."
      fetch_and_save_file
    else
      puts "#{screencast_filename} already downloaded"
    end
  end

  def fetch_and_save_file
    @agent.get screencast_url
    @agent.get(download_button).save target_filename
  end

  private

  def download_button
    @agent.page.search("#download_button_link").first["href"]
  end

  def screencast_filename
    "#{screencast_url.split("/").last}"
  end

  def target_filename
    "#{destination_path}/#{screencast_filename}"
  end

  def already_downloaded?
    File.exists? target_filename
  end
end

DASDownloader.new(path).run
