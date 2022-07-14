#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class Korean < WikipediaDate
  def to_s
    return if date_str.to_s.empty?

    date_str.gsub('일','').split(/[년월]/).map { |num| num.tidy.rjust(2, "0") }.join('-')
  end
end

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    '정부'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[gov _ name dates].freeze
    end

    def combo_date
      (raw_combo_date.tidy.split('~') + ['']).take(2)
    end

    def date_class
      Korean
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
