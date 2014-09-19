FROM phusion/baseimage:0.9.13

# Set correct environment variables.
ENV HOME /root

# Regenerate SSH host keys. baseimage-docker does not contain any, so you
# have to do that yourself. You may also comment out this instruction; the
# init system will auto-generate one during boot.
RUN /etc/my_init.d/00_regen_ssh_host_keys.sh

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

# install and running mysql
RUN apt-get update && \
	apt-get install -y ruby2.0 && \
	apt-get install -y mysql-server && \
	chown mysql:mysql /var/lib/mysql && mysql_install_db
RUN mkdir -p /etc/service/mysql
ADD ./server/run/db/main.sh /etc/service/mysql/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
	