FROM debian:buster-slim

ENV DEBIAN_FRONTEND=noninteractiv

RUN apt-get update -y && \
	apt-get upgrade -y && \
	apt-get install rsyslog postfix dnsutils -y &&\
	cp -rp /var/spool/postfix /spool-postfix-default &&\
	sed -i 's/\/var\/log\/mail/\/var\/log\/postfix\/mail/' /etc/rsyslog.conf

COPY conftemplates /conftemplates
COPY entrypoint.sh .

EXPOSE 25/tcp

VOLUME /var/spool/postfix
VOLUME /var/log/postfix

ENTRYPOINT ./entrypoint.sh

