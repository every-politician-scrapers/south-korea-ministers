#!/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'pry'
require 'scraped'
require 'table_unspanner'
require 'wikidata_ids_decorator'

require 'open-uri/cached'

class WikiDate
  REMAP = {
    'Incumbent' => '',
  }.freeze

  def initialize(date_str)
    @date_str = date_str
  end

  def to_s
    return if date_en.to_s.empty?

    date_obj.to_s
  end

  private

  attr_reader :date_str

  def date_obj
    @date_obj ||= Date.parse(date_en)
  end

  def date_en
    @date_en ||= date_str.scan(/\d+/).join('-')
  end
end

class RemoveReferences < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('sup.reference').remove
    end.to_s
  end
end

class UnspanAllTables < Scraped::Response::Decorator
  def body
    Nokogiri::HTML(super).tap do |doc|
      doc.css('table.wikitable').each do |table|
        unspanned_table = TableUnspanner::UnspannedTable.new(table)
        table.children = unspanned_table.nokogiri_node.children
      end
    end.to_s
  end
end

class MinistersList < Scraped::HTML
  decorator RemoveReferences
  decorator UnspanAllTables
  decorator WikidataIdsDecorator::Links

  field :ministers do
    member_entries.map { |ul| fragment(ul => Officeholder) }.reject(&:empty?).map(&:to_h).uniq
  end

  private

  def member_entries
    noko.xpath('//table[.//th[contains(.,"대수")]][2]//tr[td]')
  end
end

class Officeholder < Scraped::HTML
  def empty?
    !tds[3] || (dates.count < 2)
  end

  field :item do
    tds[2].css('a/@wikidata').map(&:text).first rescue binding.pry
  end

  field :itemLabel do
    tds[2].css('a').map(&:text).first
  end

  field :startDate do
    WikiDate.new(dates[0]).to_s
  end

  field :endDate do
    WikiDate.new(dates[1]).to_s
  end

  private

  def tds
    noko.css('td')
  end

  def dates
    tds[3].text.split('~').map(&:tidy)
  end
end

url = 'https://ko.wikipedia.org/wiki/%EB%8C%80%ED%95%9C%EB%AF%BC%EA%B5%AD%EC%9D%98_%EA%B8%88%EC%9C%B5%EC%9C%84%EC%9B%90%ED%9A%8C_%EC%9C%84%EC%9B%90%EC%9E%A5'
data = MinistersList.new(response: Scraped::Request.new(url: url).response).ministers

header = data.first.keys.to_csv
rows = data.map { |row| row.values.to_csv }
abort 'No results' if rows.count.zero?

puts header + rows.join
