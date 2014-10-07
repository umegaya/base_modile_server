#!/bin/bash
cd /usr/sbin/java/
exec /sbin/setuser root java echoServer 2>&1
