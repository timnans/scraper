require 'httparty'
require 'nokogiri'
require 'pry'
class Scraper
  def initialize
    @vanguard_links = []
    @response = HTTParty.get('https://www.vanguardngr.com/')
    @document = Nokogiri::HTML(@response.body)
    @links = @document.css('#latest-news-list').css('.rtp-latest-news-title').css('a')
  end

  def append_links
    @links.each do |link|
      url = link.values
      @vanguard_links << url[0]
    end
  end

  def list_size
    @vanguard_links.size
  end

  # for each individual page
  def scrape_appended_links
    @vanguard_links.each do |single_page|
      new_link = HTTParty.get(single_page)
      document = Nokogiri::HTML(new_link.body)
      File.open('Vanguard News.txt', 'a') do |f|
        f.write '*************************' + "\n"
        f.write Time.now.to_s + "\n"
        f.write document.css('.entry-title').first.text + "\n"
        f.write document.css('p').text + "\n"
        f.write '*************************' + "\n"
      end
    end
  end

  # TODO
  # remove vanguard last vanguard last
  # remove vangaurd first links
  # send email?
  def news_title
    document.css('.entry-title').first.text
  end

  def parse_article
    @text = []
    lists = document.css('p')
    lists.each { |list| @text << list.text }
  end

  def join_article
    @text.each { |text| puts text }
  end
end

scraper = Scraper.new
scraper.append_links
puts scraper.list_size
scraper.scrape_appended_links
