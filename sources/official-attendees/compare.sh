#!/bin/bash

cd $(dirname $0)

bundle exec ruby scraper.rb > scraped.csv
# No comparison yet: scraping just to track diffs

cd ~-
