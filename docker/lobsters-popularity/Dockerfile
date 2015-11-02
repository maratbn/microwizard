FROM microwizard/base
MAINTAINER datawire.io <hello@datawire.io>

ENV HOME /root

CMD ["/sbin/my_init"]
EXPOSE 3000

RUN mkdir /etc/service/lobsters
RUN cp /img_build/service/lobsters.sh /etc/service/lobsters/run

RUN mkdir /etc/service/watson
RUN cp /img_build/service/watson.sh /etc/service/watson/run

RUN mkdir /etc/service/sherlock
RUN cp /img_build/service/sherlock.sh /etc/service/sherlock/run

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*