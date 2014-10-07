#!/bin/bash

CWD=`dirname $0`

if [ "$1" != "dev" ]; then
	cp $CWD/../../setting.$1.json $CWD/../../setting.json
fi
rake ci:deploy[$1,$2,$3,$4]
