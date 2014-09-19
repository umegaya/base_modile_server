FROM phusion/baseimage:0.9.13

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# add TD repo
RUN curl http://packages.treasuredata.com/GPG-KEY-td-agent | apt-key add -
RUN echo "deb [arch=amd64] http://packages.treasuredata.com/2/ubuntu/trusty/ trusty contrib" > /etc/apt/sources.list.d/treasure-data.list

# install java7
RUN apt-get update && \
	apt-get install -y openjdk-7-jdk && \
	apt-get install -y ruby2.0

# install newrelic java
RUN apt-get install -y wget && \
	apt-get install -y unzip 
RUN wget http://download.newrelic.com/newrelic/java-agent/newrelic-agent/3.10.0/newrelic-java.zip -O /tmp/newrelic.zip && \
	unzip /tmp/newrelic.zip -d /var/lib/ && \ 
	sed -i s/\<%=\ license_key\ %\>/%YOUR LICENSE KEY%/g /var/lib/newrelic/newrelic.yml && \
	sed -i s/My\ Application/%YOUR APP NAME%/g /var/lib/newrelic/newrelic.yml && \
	rm -f /tmp/newrelic.zip

# install and run td-agent
RUN apt-get install -y --force-yes td-agent
RUN cat /dev/null > /var/log/td-agent/td-agent.log && chown td-agent:td-agent /var/log/td-agent/td-agent.log && \
	/etc/init.d/td-agent stop
RUN	mkdir -p /etc/service/td-agent/ && \
	echo "#!/bin/bash" >> /etc/service/td-agent/run && \
	echo "/etc/init.d/td-agent start while : do sleep 60 done" >> /etc/service/td-agent/run && \
	chmod 755 /etc/service/td-agent/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
