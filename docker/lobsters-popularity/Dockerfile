FROM microwizard/base
MAINTAINER datawire.io <hello@datawire.io>

ENV HOME /root
COPY . /img_build

CMD ["/sbin/my_init"]
EXPOSE 5001

RUN cp /img_build/conf/datawire.conf /etc/datawire/datawire.conf

RUN cp /img_build/init/11_lobsters_popularity.sh /etc/my_init.d/11_lobsters_popularity.sh
RUN chmod +x /etc/my_init.d/11_lobsters_popularity.sh

RUN mkdir /etc/service/lobsters_popularity
RUN cp /img_build/service/lobsters_popularity.sh /etc/service/lobsters_popularity/run
RUN chmod +x /etc/service/lobsters_popularity/run

RUN mkdir /etc/service/watson
RUN cp /img_build/service/watson.sh /etc/service/watson/run
RUN chmod +x /etc/service/watson/run

RUN mkdir /etc/service/sherlock
RUN cp /img_build/service/sherlock.sh /etc/service/sherlock/run
RUN chmod +x /etc/service/sherlock/run

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*