FROM localhost:5000/gwixoss:mgmt.base.latest

# running deploy script
ADD ./server /tmp/server
RUN bash /tmp/server/run/mgmt/deploy.sh && rm -rf /tmp/server
