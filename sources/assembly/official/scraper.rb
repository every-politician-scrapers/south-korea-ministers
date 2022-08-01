#!/bin/env ruby
# frozen_string_literal: true

require 'every_politician_scraper/scraper_data'
require 'pry'

class Legislature
  # details for an individual member
  class Member < Scraped::HTML
    BASEURL="https://korea.assembly.go.kr:447/mem/mem_pro.jsp?mem_code=%s"

    field :name do
      noko.css('a').text.tidy
    end

    field :url do
      BASEURL % id
    end

    private

    def id
      noko.css('a/@onclick').text.split("'")[1]
    end
  end

  # The page listing all the members
  class Members < Scraped::HTML
    field :members do
      noko.css('ul.dotList3 li').map { |mp| fragment(mp => Member).to_h }
    end
  end
end

file = Pathname.new 'official.html'
puts EveryPoliticianScraper::FileData.new(file, klass: Legislature::Members).csv
