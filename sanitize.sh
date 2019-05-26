#!/bin/bash

./sanitize.exe $1

./sort.sh all-sorted-recovered-sanitized.csv all-sorted-recovered-sanitized.csv

diff -u all-sorted-recovered-sanitized.csv all-sorted.csv > recovered-sanitized.patch 

echo 'see recovered-sanitized.patch for changes'
