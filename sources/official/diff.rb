#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/comparison'

# Not listed on the site
SKIP = [
  ['---', 'Moon Jae-in',   'president of South Korea'],
  ['---', 'Yoon Suk-yeol', 'president of South Korea'],
  ['---', 'Yoon Suk-yeol', 'President of South Korea'],
].freeze

diff = EveryPoliticianScraper::NulllessComparison.new('wikidata.csv', 'scraped.csv').diff
                                                 .reject { |row| SKIP.include? row }
puts diff.sort_by { |r| [r.first, r[1].to_s] }.reverse.map(&:to_csv)
