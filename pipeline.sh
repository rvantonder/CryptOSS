#!/bin/bash

./generate-world.sh ${1-1}
./recover.sh all-sorted.csv
./sanitize.sh all-sorted-recovered.csv
