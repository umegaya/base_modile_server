#!/bin/bash
CWD=`dirname $0`

if [ $# -le 2 ]; then
DBUSER=root
else
DBUSER=$2
fi

if [ $# -le 3 ]; then
DBNAME=$1
else
DBNAME=$3
fi

ruby $CWD/$1/run.rb $1 $DBNAME $DBUSER
