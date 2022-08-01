#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class MemberList
  class Members
    decorator RemoveReferences
    decorator UnspanAllTables
    decorator WikidataIdsDecorator::Links

    def member_items
      noko.css('#참고_문헌').xpath('following::*').remove
      noko.xpath('//table[.//tr[contains(., "관할구역")]]//tr[td]').map { |tr| fragment(tr => ConstMember) } +
        noko.css('table.navbox-inner table td a').map { |link| fragment(link => PRMember) }
    end
  end

  class PRMember < Scraped::HTML
    field :item do
      noko.attr('wikidata')
    end

    field :name do
      noko.text.tidy
    end
  end

  class ConstMember < Scraped::HTML
    field :item do
      tds[1].css('a').first.attr('wikidata')
    end

    field :name do
      tds[1].css('a').map(&:text).map(&:tidy).first
    end

    private

    def tds
      noko.css('td')
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url).csv
