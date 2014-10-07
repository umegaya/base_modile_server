#!/bin/bash
# migrate.sh $service $user $dbname $pass $hostname
CWD=`dirname $0`

if [ $# -le 1 ]; then
DBUSER=root
else
DBUSER=$2
fi

if [ $# -le 2 ]; then
DBNAME=$1
else
DBNAME=$3
fi

if [ $# -le 3 ]; then
DBPASS=
else
DBPASS=$4
fi

if [ $# -le 4 ]; then
DBHOST=
else
DBHOST=$5
fi

echo "$DBNAME $DBUSER $DBPASS $DBHOST"

ruby $CWD/$1/run.rb $DBNAME $DBUSER $DBPASS $DBHOST
