#!/bin/bash

cd $(dirname $0)

bundle exec ruby scraper.rb $(jq -r .reference.P4656 meta.json) |
  qsv select item,name |
  qsv rename item,itemLabel > scraped.csv

wd sparql -f csv wikidata.js |
  sed -e 's/T00:00:00Z//g' -e 's#http://www.wikidata.org/entity/##g' |
  qsv dedup -s psid |
  qsv dedup -s item |
  qsv search -s startDate . > wikidata.csv

bundle exec ruby diff.rb | qsv sort -s itemlabel | tee diff.csv

cd ~-
