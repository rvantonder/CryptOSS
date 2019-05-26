#!/bin/bash

# generate files to use in cronjobs for pulling

rm batch*
../../crunch.exe show -split 12 -dump batch
