#!/bin/bash

bundle exec ruby bin/scraper/cabinet-attendees.rb > data/cabinet-attendees.csv
# No comparison yet: scraping just to track diffs
