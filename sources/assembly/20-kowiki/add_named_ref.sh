#!/bin/zsh

WIKIDATA_ITEM=item
WIKIDATA_PSID=psid
SCRAPED_NAME=itemLabel

wcheck=$1

wikidata_count=$(qsv search -u -i $wcheck wikidata.csv | qsv count)
if [[ $wikidata_count != 1 ]]
then
  echo "No unique match to wikidata.csv ($wikidata_count):"
  qsv search -u -i $wcheck wikidata.csv | qsv behead
  return
fi
item=$(qsv search -u -i $wcheck wikidata.csv | qsv select $WIKIDATA_ITEM | qsv behead)
statementid=$(qsv search -u -i $wcheck wikidata.csv | qsv select $WIKIDATA_PSID | qsv behead)

[[ -v 2 ]] && scheck=$2 || scheck=$1
scraped_count=$(qsv search -u -i $scheck scraped.csv | qsv count)
if [[ $scraped_count != 1 ]]
then
  echo "No unique match to scraped.csv:"
  qsv search -u -i $scheck scraped.csv | qsv behead
  return
fi

name=$(qsv search -u -i $scheck scraped.csv | qsv select $SCRAPED_NAME | qsv behead)
claims=$(qsv search -u -i $scheck scraped.csv | qsv select $SCRAPED_NAME | qsv behead | qsv fmt --out-delimiter " ")

echo "$statementid $claims"
echo "$statementid $claims" | xargs wd ar --maxlag 20 add-source-name.js > /dev/null

lang=$(jq -r .lang meta.json)
existing=$(wd label $item -l $lang)
if [[ $existing != $name ]]
then
  echo "Add alias: $item -> $name ($existing)"
  wd add-alias --maxlag 20 $item $lang $name > /dev/null
fi
