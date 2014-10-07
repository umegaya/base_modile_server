#!/bin/bash
CWD=`dirname $0`
SRC=$CWD/../../src

pushd $SRC
javac -encoding UTF-8 echoServer.java
mkdir -p /usr/sbin/java
cp echoServer.class /usr/sbin/java/
popd
