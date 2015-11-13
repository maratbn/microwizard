FROM phusion/passenger-ruby22
MAINTAINER datawire.io <hello@datawire.io>

COPY . /img_build

RUN curl -s $(cat /img_build/datawire-repository) | bash
RUN apt-get install -y\
 datawire-directory\
 datawire-sherlock\
 datawire-watson\
 python-pip

RUN yes | pip install docopt docker-py

RUN cp /img_build/bin/bakerconf.py /bin/bakerconf
RUN cp /img_build/init/10_bakerconf.sh /etc/my_init.d/10_bakerconf.sh
RUN chmod +x /bin/bakerconf
RUN chmod +x /etc/my_init.d/10_bakerconf.sh

RUN rm -rf /img_build