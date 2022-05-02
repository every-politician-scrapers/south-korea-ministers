#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def name
      noko.css('dt').text.tidy
    end

    def position
      noko.css('dd.text').text.split(/, (?=Minister)/).map(&:tidy)
    end
  end

  class Members
    def member_container
      noko.css('.cabinet dl')
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv
