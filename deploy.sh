#!/bin/bash

RELEASE_TARGET=docs
DATE=`basename $1`

# unzip
cd $1
tar xf dats.tar.gz
cd ../..

mkdir -p $RELEASE_TARGET/$DATE

# create aggs
./crunch.exe show | xargs -L 1 -I % ./crunch.exe aggregate % -dir $1
# generate main pages
./site_html_generator.exe -dir $1
# generate currency pages
./crunch.exe show | xargs -L 1 -I % ./site_html_generator.exe -dir $1 -cryptos % 

mv *.html $RELEASE_TARGET/$DATE
mv currency $RELEASE_TARGET/$DATE

cd $RELEASE_TARGET/$DATE/currency
ls * | xargs -L 1 -I % mv %{,.html}
cd ../../../

cp -r site/static $RELEASE_TARGET/$DATE/

# delete .dat, .agg
cd $1
rm *.dat *.agg 2> /dev/null
cd ../..
