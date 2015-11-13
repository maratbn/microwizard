FROM microwizard/base
MAINTAINER datawire.io <hello@datawire.io>

ENV HOME /root
COPY . /img_build

CMD ["/sbin/my_init"]
EXPOSE 5001

RUN cp /img_build/init/09_mw_init.sh /etc/my_init.d/09_mw_init.sh
RUN chmod +x /etc/my_init.d/09_mw_init.sh

RUN mkdir /etc/service/generic
RUN cp /img_build/service/generic_service.sh /etc/service/generic/run
RUN chmod +x /etc/service/generic/run

RUN mkdir /etc/service/watson
RUN cp /img_build/service/watson.sh /etc/service/watson/run
RUN chmod +x /etc/service/watson/run

RUN mkdir /etc/service/sherlock
RUN cp /img_build/service/sherlock.sh /etc/service/sherlock/run
RUN chmod +x /etc/service/sherlock/run

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*