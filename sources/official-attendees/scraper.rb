#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Members
    decorator RemoveReferences
    decorator UnspanAllTables
    # decorator WikidataIdsDecorator::Links

    def member_container
      noko.xpath('//h2[contains(.,"Attendees")]/following::table[1]//tr[td]')
    end
  end

  class Member
    field :name do
      tds[2].text.tidy
    end

    field :position do
      tds[0].text.tidy
    end

    field :began do
      tds[3].text.tidy
    end

    field :ended do
      tds[4].text.tidy
    end

    private

    def tds
      noko.css('td')
    end
  end
end

url = 'https://en.wikipedia.org/wiki/Cabinet_of_Moon_Jae-in'
puts EveryPoliticianScraper::ScraperData.new(url).csv

