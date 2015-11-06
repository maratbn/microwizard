FROM microwizard/base
MAINTAINER datawire.io <hello@datawire.io>

ENV HOME /root
COPY . /img_build

CMD ["/sbin/my_init"]
EXPOSE 3000

RUN cp /img_build/conf/datawire.conf /etc/datawire/datawire.conf

RUN cp /img_build/init/11_lobsters.sh /etc/my_init.d/11_lobsters.sh
RUN chmod +x /etc/my_init.d/11_lobsters.sh

RUN mkdir /etc/service/lobsters
RUN cp /img_build/service/lobsters.sh /etc/service/lobsters/run
RUN chmod +x /etc/service/lobsters/run

RUN mkdir /etc/service/sherlock
RUN cp /img_build/service/sherlock.sh /etc/service/sherlock/run
RUN chmod +x /etc/service/sherlock/run

RUN rm -rf /img_build

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*