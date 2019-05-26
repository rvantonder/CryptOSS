#!/bin/bash

IN=$1
OUT=$2
TMP=sorted-tmp.csv

sort -u $IN > $TMP

tail -n 1 $TMP > csv-header.txt

sed -i '' -e '$ d' $TMP

cat csv-header.txt > $OUT
cat $TMP >> $OUT
rm csv-header.txt $TMP
