#!/bin/bash

./recover.exe $1 2> recover-errors.txt > recovered.csv

cp all-sorted.csv all-sorted-recovered.csv
cat recovered.csv >> all-sorted-recovered.csv

sort -u all-sorted-recovered.csv > all-sorted-recovered-temp.csv
tail -n 1 all-sorted-recovered-temp.csv > csv-header.txt
sed -i '' -e '$ d' all-sorted-recovered-temp.csv

# cat header and then rest of file except header at bottom
cat csv-header.txt > all-sorted-recovered.csv
cat all-sorted-recovered-temp.csv >> all-sorted-recovered.csv
rm csv-header.txt all-sorted-recovered-temp.csv recovered.csv

diff -u all-sorted.csv all-sorted-recovered.csv > recovered.patch

echo 'see recovered.patch for changes'
