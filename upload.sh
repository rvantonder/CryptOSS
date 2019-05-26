#!/bin/bash

mkdir -p upload
mv all-sorted.csv upload/all-sorted-2018-01-21-to-2019-02-04.csv
mv all-sorted-recovered-sanitized.csv upload/all-sorted-recovered-sanitized-2018-01-21-to-2019-02-04.csv
mv *.patch upload
