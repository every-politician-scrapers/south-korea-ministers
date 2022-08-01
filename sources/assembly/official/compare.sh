#!/bin/bash

cd $(dirname $0)

bundle exec ruby scraper.rb | qsv select name,url | qsv rename itemLabel,url > scraped.csv
wd sparql -f csv wikidata.js | sed -e 's/T00:00:00Z//g' -e 's#http://www.wikidata.org/entity/##g' | qsv dedup -s psid | qsv sort -s itemLabel,startDate > wikidata.csv
bundle exec ruby diff.rb | qsv sort -s itemlabel | tee diff.csv

cd ~-
