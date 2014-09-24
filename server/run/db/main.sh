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
        echo "create database" >> /var/log/mysql_exec.log 2>&1
        /usr/bin/mysql_install_db >> /var/log/mysql_exec.log 2>&1
		/usr/bin/mysqld_safe > /dev/null 2>&1 &
		RET=1
		while [[ RET -ne 0 ]]; do
		    echo "=> Waiting for confirmation of MySQL service startup" >> /var/log/mysql_exec.log 2>&1
		    sleep 5
		    mysql -uroot -e "status" > /dev/null 2>&1
		    RET=$?
		done
        echo "create external root user" >> /var/log/mysql_exec.log 2>&1
        mysql -u root -e "GRANT ALL ON *.* TO root@'%'" >> /var/log/mysql_exec.log 2>&1
        echo "shutdown mysql once" >> /var/log/mysql_exec.log 2>&1
        mysqladmin -uroot shutdown
fi
exec /sbin/setuser $MYSQL_USER /usr/bin/mysqld_safe >>/var/log/mysql_exec.log 2>&1
