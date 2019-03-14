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
rm /tmp/ttt 2> /dev/null
touch /tmp/ttt

# dates for which only null values exist out of the number of missing dates for which we could not recover anything
for date in `cat missing-dates.txt`; do
  RES=`cat all-sorted-recovered-sanitized.csv | grep "${date}" |  tr ' ' '.' | tr ',' ' ' | awk '{$1 = ""; $2 = ""; $3 = ""; print $0}' | tr ' ' ',' | grep -v ",,,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null" | wc -l`
  if [ "$RES" -eq "0" ]; then
    echo "  No values for $date";
    echo "x" >> /tmp/ttt
  fi
done

RES=`cat /tmp/ttt | wc -l`
echo "No data for $RES dates"
