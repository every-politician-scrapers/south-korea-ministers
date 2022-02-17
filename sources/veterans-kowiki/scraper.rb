#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'


class Korean < WikipediaDate
  def to_s
    date_str.gsub('일','').split(/[년월]/).map { |num| num.tidy.rjust(2, "0") }.join('-')
  end
end

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    '임기'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[govt term name dates].freeze
    end

    def combo_date
      raw_combo_date.tidy.split('~')
    end

    def empty?
      tds[2].nil?
    end

    def date_class
      Korean
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
