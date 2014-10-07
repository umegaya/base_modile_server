FROM jpetazzo/dind

# stop asking from apt-get
ENV DEBIAN_FRONTEND noninteractive

# gcloud CLI; including python/go/java
RUN sed -i '1i deb     http://gce_debian_mirror.storage.googleapis.com/ wheezy         main' /etc/apt/sources.list
RUN apt-get update && apt-get install -y --force-yes -qq --no-install-recommends wget unzip python php5-mysql php5-cli php5-cgi openjdk-7-jre-headless openssh-client && apt-get clean
RUN wget https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip && unzip google-cloud-sdk.zip && rm google-cloud-sdk.zip
RUN google-cloud-sdk/install.sh --usage-reporting=true --path-update=true --bash-completion=true --rc-path=/.bashrc --disable-installation-options
RUN yes | google-cloud-sdk/bin/gcloud components update pkg-go pkg-python pkg-java
RUN mkdir /.ssh
ENV PATH /google-cloud-sdk/bin:$PATH
# export config directory for external use
VOLUME ["/.config"]

# ruby & go & docker
RUN apt-get install -y ruby2.0
RUN apt-get install -y golang
RUN apt-get install -y rake

# copy startup script
ADD ./util/shipbuild /usr/bin/shipbuild
RUN chmod 755 /usr/bin/shipbuild
