#!/bin/bash

find datastore -name "*.tar.gz"  | xargs -L 1 -I % dirname % | xargs -L 1 -I % -P 20 bash -c "./csv-of-dat.sh %"

echo 'Collating it all...'
rm all.csv
find datastore -name "for-day-*.csv" | xargs -L 1 -I % cat % >> all.csv

sort -u all.csv > all-sorted-temp.csv

tail -n 1 all-sorted-temp.csv > csv-header.txt

sed -i '' -e '$ d' all-sorted-temp.csv

# cat header and then rest of file except header at bottom
cat csv-header.txt > all-sorted.csv
cat all-sorted-temp.csv >> all-sorted.csv
rm csv-header.txt all-sorted-temp.csv

