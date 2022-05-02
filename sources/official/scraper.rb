#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Member
    def name
      noko.css('.tit').text.tidy
    end

    def position
      noko.css('.txt').text.split(/, (?=Minister)/).map(&:tidy)
    end
  end

  class Members
    def member_container
      noko.css('.person-list .person-detail')
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file).csv