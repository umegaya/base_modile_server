CWD=`dirname $0`

# Install an SSH of members.
rm -f /root/.ssh/authorized_keys
cat $CWD/../../cert/*.pub >> /root/.ssh/authorized_keys

# copy config
cp -rf $CWD/config/target /root/config
source /root/config/env.sh

# setup cron
cp -rf $CWD/cron/script /root/cron
crontab $CWD/cron/tab

# run app
mkdir -p /etc/service/app
cp -f $CWD/main.sh /etc/service/app/run

# build app
$CWD/build.sh

# copy entry point scripts
cp $CWD/*.sh /root/
