#!/bin/bash

WORD=$1
LOG=$2
DATE=`date`

if grep $WORD $LOG &> /dev/null
then
  logger "$DATE: I found word, Master!"
else
  logger "$DATE: I didn't find word, Master!"
  exit 0
fi
