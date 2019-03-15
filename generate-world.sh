#!/bin/bash

JOBS=$1

find datastore -name "*.tar.gz"  | xargs -L 1 -I % dirname % | xargs -L 1 -I % -P $JOBS bash -c "./csv-of-dat.sh %"

echo 'Collating it all...'
rm all.csv
find datastore -name "for-day-*.csv" | xargs -L 1 -I % cat % >> all.csv

./sort.sh all.csv all-sorted.csv
