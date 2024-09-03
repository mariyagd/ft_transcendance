#!/bin/bash

mkdir -p /etc/ssl/certs/

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
	-keyout /etc/ssl/certs/auth.key \
	-out /etc/ssl/certs/auth.crt \
	-subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=${DOMAIN_NAME}"

chown $USERNAME:$GROUPNAME /etc/ssl/certs/
chown $USERNAME:$GROUPNAME /etc/ssl/certs/auth.key
chown $USERNAME:$GROUPNAME /etc/ssl/certs/auth.crt