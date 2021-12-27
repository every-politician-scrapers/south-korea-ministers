#!/bin/bash

bundle exec ruby bin/scraper/cabinet-attendees.rb | ifne tee data/cabinet-attendees.csv
# No comparison yet: scraping just to track diffs
