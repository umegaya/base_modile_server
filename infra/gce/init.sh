#!/bin/bash
CWD=`dirname $0`
GCLOUD_VER=`gcloud version`
if [ "$?" != "0" ]; then
	curl https://sdk.cloud.google.com | bash
	source ~/.bash_profile
fi
ruby $CWD/init.rb $1
