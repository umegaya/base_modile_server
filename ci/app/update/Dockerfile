FROM localhost:5000/gwixoss:app.base.latest

# running deploy script
ADD ./server /tmp/server
RUN bash /tmp/server/run/app/deploy.sh && rm -rf /tmp/server
