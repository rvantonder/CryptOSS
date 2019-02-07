#!/bin/bash

# unzip

mkdir -p release-site/`basename $1`

# create aggs
./crunch.exe show | xargs -L 1 -I % ./crunch.exe aggregate % -dir $1
# generate main pages
./site_html_generator.exe -dir $1
# generate currency pages
./crunch.exe show | xargs -L 1 -I % ./site_html_generator.exe -dir $1 -cryptos % 

mv *.html release-site/`basename $1`
mv currency release-site/`basename $1`
cp -r site/static release-site/`basename $1`/

# delete .dat, .agg
