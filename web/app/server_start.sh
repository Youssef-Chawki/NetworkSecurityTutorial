#!/usr/bin/env bash

set -eux

cd /java-server/vuln-webapp-java2

mvn --settings settings.xml clean spring-boot:run &
FOO_PID=$!
# do other stuff
sleep 120
kill $FOO_PID

ep_name=h36-8

ip netns exec $ep_name a2enmod proxy
ip netns exec $ep_name a2enmod proxy_http
ip netns exec $ep_name /etc/init.d/apache2 restart

ip netns exec $ep_name rm /etc/apache2/sites-available/000-default.conf
ip netns exec $ep_name mv /tmp/modsecurity.conf /etc/modsecurity
ip netns exec $ep_name mv /tmp/000-default.conf /etc/apache2/sites-available/
ip netns exec $ep_name /etc/init.d/apache2 restart

#ip netns exec $ep_name bash -c " cd /apache/conf ; ./bin/httpd  "

ip netns exec $ep_name bash -c " cd /java-server/vuln-webapp-java2 ; nohup mvn --settings settings.xml clean spring-boot:run > /tmp/http_server.log 2>&1  & "
