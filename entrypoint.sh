#!/bin/sh

set -e

if [ -z "$(ls -A /var/spool/postfix 2> /dev/null)" ] ; then
	echo "Postfix spool empty, regenerating files..."
	cp -rp /spool-postfix-default/* /var/spool/postfix/
fi

if [ -z "$DKIM_HOST" ] 
then
	echo "No dkim"
else
	DKIM_IP=$(nslookup dkim | grep Address |  tail -1 | cut -d ' ' -f2)
	DKIM_MILTER="milter_protocol = 6
milter_default_action = accept 
receive_override_options=no_address_mappings
milter_mail_macros = i {auth_type}
smtpd_milters = inet:${DKIM_IP}:8892 
non_smtpd_milters = inet:${DKIM_IP}:8892"
fi


# Generates the main.cf
TEMPLATE=$(cat /conftemplates/main.cf.templ)
eval echo "\"${TEMPLATE}\"" > /etc/postfix/main.cf

# Generates the aliases
TEMPLATE=$(cat /conftemplates/aliases.templ)
eval echo "\"${TEMPLATE}\"" > /etc/aliases

newaliases

# Generate certificates

mkdir -p /etc/postfix/ssl

if [ -z "$(ls -A /etc/postfix/ssl 2> /dev/null)" ] ; then
	echo "No certificates, generating..."
	openssl genrsa -out /etc/postfix/ssl/cert.key 2048 > /dev/null
	openssl req -new -batch -sha256 -key /etc/postfix/ssl/cert.key -out /etc/postfix/ssl/cert.csr > /dev/null
	openssl req -x509 -sha256 -key /etc/postfix/ssl/cert.key -in /etc/postfix/ssl/cert.csr -out /etc/postfix/ssl/cert.pem > /dev/null
fi

cp /etc/services /var/spool/postfix/etc/
cp /etc/resolv.conf /var/spool/postfix/etc/

service rsyslog start

postfix start-fg

