#!/bin/bash

# find . -name "*.tar.gz"  | xargs -L 1 -I % -P 4 dirname % | xargs -L 1 -I % -P 4 bash -c "./msr.sh %"

cd $1
DATE=`basename $1`
rm *.csv
tar xf dats.tar.gz

NUM_DATS=`ls *.dat | wc -l`
echo "dat files: ${NUM_DATS}" > log.txt

# generate CSV
IFS=$'\n' # IFS in for loop, because dat files can contain spaces
for FILE in `find . -name "*.dat"`; do
  CRYPTO_ID=`echo $FILE | sed "s/\.dat//"`
  # echo "processing $1/${CRYPTO_ID}"
  ../../crunch.exe load -no-forks -csv -with-ranks ranks.json -with-date "${DATE}" "${CRYPTO_ID}.dat" > "${CRYPTO_ID}.csv" 2>> log.txt
  retVal=$?
  if [ $retVal -ne 0 ]; then
      CMD="cd $1 && ../../crunch.exe load -no-forks -csv ${CRYPTO_ID}.dat"
      echo "Error for ${CRYPTO_ID}. Extract and reproduce with ${CMD}" >> log.txt
  fi
done

NUM_CSV=`ls *.csv | wc -l`
echo "csv files: ${NUM_CSV}" >> log.txt

cat *.csv > for-day-${DATE}.csv

# delete raw files
rm *.dat

# Collate everything with fin data
