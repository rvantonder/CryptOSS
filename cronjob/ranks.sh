#!/bin/bash

DATE=`date +%Y-%m-%d`

mkdir -p $DATE

curl https://api.coinmarketcap.com/v1/ticker/\?limit\=1500 >> ~/CryptOSS/cronjob/$DATE/ranks.json
