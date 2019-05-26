#!/bin/bash

eval `opam config env`

batch_selector=$1
token=$2

DATE=`date +%Y-%m-%d`

mkdir -p $DATE


s=`date +%s`
../crunch.exe save "`cat batches/batch-${batch_selector}.txt`" -token $token &>> $DATE.log
e=`date +%s`

mv *.dat $DATE

quota=`../crunch.exe limit -token $token`

runtime=$((e-s))

msg="Processed `cat batches/batch-${batch_selector}.txt` in ${runtime} seconds. Quota: ${quota}" 

echo $msg | mutt -s "Batch $batch_selector done @ $(date)" your@email.com
