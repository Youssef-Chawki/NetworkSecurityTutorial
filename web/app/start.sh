#!/usr/bin/env bash

set -eux

x=$(pwd)
echo "The current working directory : $x"


#install maven
mkdir -p /usr/local/apache-maven; cd /usr/local/apache-maven
curl https://www.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz | tar -xzv
update-alternatives --install /usr/bin/mvn mvn /usr/local/apache-maven/apache-maven-3.3.9/bin/mvn 1
update-alternatives --config mvn

cat << EOF > $HOME/maven.env
export M2_HOME=/usr/local/apache-maven/apache-maven-3.3.9
export MAVEN_OPTS="-Xms256m -Xmx512m" # Very important to put the "m" on the end
export JAVA_HOME=/usr/lib/jvm/java-8-oracle # This matches update-alternatives --config java
EOF

cd /app
wget https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js
wget https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.14.0/jquery.validate.min.js
#mv jquery.min.js /java-server/vuln-webapp-java2/src/main/resources/static/js
#mv jquery.validate.min.js /java-server/vuln-webapp-java2/src/main/resources/static/js



#Installing apr
mkdir /usr/src/apache
chown `whoami` /usr/src/apache
cd /usr/src/apache
wget https://www-eu.apache.org/dist/apr/apr-1.6.5.tar.bz2
#wget https://www.apache.org/dist/apr/apr-1.6.5.tar.bz2.md5
#md5sum --check apr-1.6.5.tar.bz2.md5
tar -xvjf apr-1.6.5.tar.bz2
cd apr-1.6.5
./configure --prefix=/usr/local/apr/
make
make install

#Installing apr-util
cd /usr/src/apache
wget https://www-eu.apache.org/dist/apr/apr-util-1.6.1.tar.bz2
#wget https://www.apache.org/dist/apr/apr-util-1.6.1.tar.bz2.md5
#md5sum --check apr-util-1.6.1.tar.bz2.md5
tar -xvjf apr-util-1.6.1.tar.bz2
cd apr-util-1.6.1
./configure --prefix=/usr/local/apr/ --with-apr=/usr/local/apr/
make
make install

#Installing the webserver httpd
cd /usr/src/apache
wget https://www-eu.apache.org/dist//httpd/httpd-2.4.37.tar.bz2
#wget https://www.apache.org/dist/httpd/httpd-2.4.35.tar.bz2.sha1
#sha1sum --check httpd-2.4.35.tar.bz2.sha1
tar -xvjf httpd-2.4.37.tar.bz2
cd httpd-2.4.37
./configure --prefix=/opt/apache-2.4.37  --with-apr=/usr/local/apr/bin/apr-1-config \
   --with-apr-util=/usr/local/apr/bin/apu-1-config \
   --enable-mpms-shared=event \
   --enable-mods-shared=all \
   --enable-nonportable-atomics=yes

make
make install
chown -R `whoami` /opt/apache-2.4.37
ln -s /opt/apache-2.4.37 /apache
chown `whoami` --no-dereference /apache
cd /apache
#mv /app/httpd.conf /apache/conf/

#Installing modsecurity
mkdir /usr/src/modsecurity
chown `whoami` /usr/src/modsecurity
cd /usr/src/modsecurity
wget https://www.modsecurity.org/tarball/2.9.2/modsecurity-2.9.2.tar.gz
wget https://www.modsecurity.org/tarball/2.9.2/modsecurity-2.9.2.tar.gz.sha256
sha256sum --check modsecurity-2.9.2.tar.gz.sha256

tar -xvzf modsecurity-2.9.2.tar.gz
cd modsecurity-2.9.2
./configure --with-apxs=/apache/bin/apxs \
  --with-apr=/usr/local/apr/bin/apr-1-config \
  --with-pcre=/usr/bin/pcre-config

make
make install
chown `whoami` /apache/modules/mod_security2.so

#Creating the adequate directory for audit-log storage
mkdir /apache/logs/audit
chown www-data:www-data /apache/logs/audit


#Installing OWASP ModSecurity Core Rule Set
cd /apache/conf
wget https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v3.0.2.tar.gz
tar xvzf v3.0.2.tar.gz
ln -s owasp-modsecurity-crs-3.0.2 /apache/conf/crs
cp crs/crs-setup.conf.example crs/crs-setup.conf
rm v3.0.2.tar.gz


#Starting
mkdir /root/bin
mv /app/percent.awk /root/bin
mv /app/httpd.conf /apache/conf/
mv /app/basicstats.awk /root/bin
mv /app/modsec-positive-stats.rb /root/bin
mv /app/bash_aliases.txt ~/.bash_aliases
#source ~/.bashrc

#./bin/httpd -X # -X means that it will work on the foreground





#bash /app/server_start.sh
/bin/bash
