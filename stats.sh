#!/bin/bash

# unique cryptos
RES=`cat all-sorted-recovered-sanitized.csv | tr ',' ' ' | awk '{print $2}' | sort -u | wc -l`
# subtract 1 for header
echo "Unique projects: "$(($RES - 1))

# unique repos-ish
RES=`cat all-sorted-recovered-sanitized.csv | tr ',' ' ' | awk '{print $2$3}' | sort -u | wc -l`
# subtract 1 for header
echo "Approxmiate unique repos: "$(($RES - 1))

# entries per day
RES=`cat all-sorted-recovered-sanitized.csv| grep "2018-12-04" | wc -l`
echo "Normalized entries (i.e., repos) per day: ${RES}"

echo "Known missing dates:" `cat missing-dates.txt | wc -l`
rm /tmp/nnn 2> /dev/null
rm /tmp/vvv 2> /dev/null
touch /tmp/nnn
touch /tmp/vvv

# dates for which only null values exist out of the number of missing dates for which we could not recover anything
for date in `cat missing-dates.txt`; do
  RESN=`cat all-sorted-recovered-sanitized.csv | grep "${date}" |  tr ' ' '.' | tr ',' ' ' | awk '{$1 = ""; $2 = ""; $3 = ""; print $0}' | tr ' ' ',' | grep -v ",,,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null" | wc -l`
  RESV=`cat all-sorted-recovered-sanitized.csv | grep "${date}" |  tr ' ' '.' | tr ',' ' ' | awk '{$1 = ""; $2 = ""; $3 = ""; print $0}' | tr ' ' ',' | grep -v ",,,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null," | wc -l`
  if [ "$RESN" -eq "0" ]; then
    echo "  No values for $date";
    echo "x" >> /tmp/nnn
  fi
  if [ "$RESV" -eq "0" ]; then
    echo "  No GH values for $date";
    echo "x" >> /tmp/vvv
  fi
done

RES=`cat /tmp/nnn | wc -l`
echo "No data for $RES dates"
RES=`cat /tmp/vvv | wc -l`
echo "No GH data $RES dates"

rm /tmp/nnn /tmp/vvv
