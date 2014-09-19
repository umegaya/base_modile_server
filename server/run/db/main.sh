#!/bin/bash
source /root/config/env.sh
MYSQL_USER=mysql
echo $BUILD_TARGET
if [ "$BUILD_TARGET" = "dev" ]; then
	echo "force set mysql user to root" >> /var/log/mysql_exec.log 2>&1
	MYSQL_USER=root
	sed -i s/=\ mysql/=\ root/g /etc/mysql/my.cnf
fi
if [ ! -e /var/lib/mysql/mysql ]; then
	exec /sbin/setuser $MYSQL_USER /usr/bin/mysql_install_db >> /var/log/mysql_exec.log 2>&1
fi
exec /sbin/setuser $MYSQL_USER /usr/bin/mysqld_safe >>/var/log/mysql_exec.log 2>&1

