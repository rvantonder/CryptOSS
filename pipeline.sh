#!/bin/bash

./generate-world.sh
./recover.sh all-sorted.csv
./sanitize.sh all-sorted-recovered.csv
