FROM dokyogames/gwixoss:db.base.latest

# running deploy script
ADD ./server /tmp/server
RUN bash /tmp/server/run/db/deploy.sh && rm -rf /tmp/server
