#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
# require 'wikidata_ids_decorator'

require 'open-uri/cached'

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class MinistersList < Scraped::HTML
  decorator RemoveReferences
  # decorator WikidataIdsDecorator::Links

  field :officeholders do
    member_entries.map { |ul| fragment(ul => Officeholder).to_h }
  end

  private

  def member_entries
    table.flat_map { |table| table.xpath('.//tr[td]') }
  end

  def table
    noko.xpath('//h2[contains(.,"Attendees")]/following::table[.//th[contains(.,"Portfolio")]]')
  end
end

class Officeholder < Scraped::HTML
  field :office do
    tds[0].text.tidy
  end

  field :person do
    tds[1].text.tidy
  end

  private

  def tds
    noko.css('td')
  end
end

url = 'https://en.wikipedia.org/wiki/Cabinet_of_Moon_Jae-in'
data = MinistersList.new(response: Scraped::Request.new(url: url).response).officeholders

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
