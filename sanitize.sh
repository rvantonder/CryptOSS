#!/bin/bash

./sanitize.exe $1

sort -u all-sorted-recovered-sanitized.csv > all-sorted-recovered-sanitized-temp.csv
tail -n 1 all-sorted-recovered-sanitized-temp.csv > csv-header.txt
sed -i '' -e '$ d' all-sorted-recovered-sanitized-temp.csv

# cat header and then rest of file except header at bottom
cat csv-header.txt > all-sorted-recovered-sanitized.csv
cat all-sorted-recovered-sanitized-temp.csv >> all-sorted-recovered-sanitized.csv
rm csv-header.txt all-sorted-recovered-sanitized-temp.csv

diff -u all-sorted-recovered-sanitized.csv all-sorted.csv > recovered-sanitized.patch 

echo 'see recovered-sanitized.patch for changes'
