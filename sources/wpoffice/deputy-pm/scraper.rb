#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class OfficeholderList < OfficeholderListBase
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  def header_column
    'Portfolio'
  end

  class Officeholder < OfficeholderBase
    def columns
      %w[name _ start end].freeze
    end

    def raw_start
      start_cell.children.map(&:text).map(&:tidy).reject(&:empty?).join(' ').tidy
    end

    def raw_end
      end_cell.children.map(&:text).map(&:tidy).reject(&:empty?).join(' ').tidy
    end

    def empty?
      super || itemLabel.include?('Office not in use')
    end
  end
end

url = ARGV.first
puts EveryPoliticianScraper::ScraperData.new(url, klass: OfficeholderList).csv
