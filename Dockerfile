# RiakCS
#
# VERSION               0.0.1

FROM      ubuntu
MAINTAINER Jeffery Utter "jeff@jeffutter.com"

# make sure the package repository is up to date
RUN apt-get update

RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl
RUN mkdir /var/run/sshd

RUN apt-get install -y vim wget curl sudo lsb-release logrotate libpopt0 cron openssh-server
RUN curl http://apt.basho.com/gpg/basho.apt.key | apt-key add -
RUN bash -c "echo deb http://apt.basho.com $(lsb_release -sc) main > /etc/apt/sources.list.d/basho.list"
RUN apt-get update

# This bit is a nasty kludge to fix a bug in the Riak .debs that cause them to try to chmod /etc/resolv.conf
# Their build scripts have been patched to fix this but the .debs aren't updated yet
# This will have to stay until they fix it
RUN mkdir -p /debs/orig; mkdir -p /debs/new
RUN cd /debs/orig; apt-get download stanchion riak riak-cs riak-cs-control
ADD ./fix-riak-debs.sh /
RUN sh /fix-riak-debs.sh
RUN dpkg -i /debs/new/riak_*.deb
RUN dpkg -i /debs/new/riak-cs_*.deb
RUN dpkg -i /debs/new/riak-cs-control_*.deb
RUN dpkg -i /debs/new/stanchion_*.deb
#RUN apt-get install stanchion riak riak-cs riak-cs-control

RUN ulimit -n 4096

ADD ./start.sh /
ADD ./set-keys.sh /
ADD ./etc /etc

RUN sh /set-keys.sh

EXPOSE 8000
EXPOSE 8080

#CMD ["/bin/bash"]

CMD ["/bin/bash /start.sh"]
