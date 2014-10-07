#!/bin/bash

CWD=`dirname $0`

if [ "$1" != "dev" ]; then
	cp $CWD/../../setting.$1.json $CWD/../../setting.json
	rake ci:init
fi
OUT=`gcloud version`
if [ -z "$OUT" ]; then
	echo "OUT:[$OUT]"
	source ~/.bash_profile # load gcloud path
fi
pushd $CWD/../../infra/kubernetes > /dev/null
	GOVER=`go version`
	if [ -z "$GOVER" ]; then
		echo "PATH=/usr/local/go/bin:$PATH" >> ~/.bash_profile
		source ~/.bash_profile
	fi
	sudo hack/build-go.sh
popd > /dev/null
rake infra:auth
if [ "$1" != "dev" ]; then
	rake infra:init
fi
