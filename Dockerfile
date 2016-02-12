#  This container needs to run with a mongodb instance!!! Use the docker-compose.yml to save your time

FROM centos:7
MAINTAINER Knifehands

ENV container docker
ENV DOMAIN example.com
USER root

#### Install the Basics ####

RUN echo 'Update the image and get the basics' && \
    yum -y install deltarpm && \
    yum -y update && \
    yum -y install wget
WORKDIR /tmp
RUN echo 'Grabbing EPEL, RpmForge, CERT Forensics Repos' && \
    rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt && \
 #   rpm -i http://pkgs.repoforge.org/rpmforge-release/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm && \
    yum -y install epel-release && \
    wget https://forensics.cert.org/cert-forensics-tools-release-el7.rpm && \
    rpm -i cert-forensics-tools-release-el7.rpm && \
    rm cert-forensics-tools-release-el7.rpm
RUN echo 'Installing Packages' && yum clean all && yum -y install make \
    git \
    openssh \
    vim \
    gcc \
    gcc-c++ \
    kernel-devel \
    openldap \
    openldap-devel \
    python-devel \
    python-pip \
    python-ldap \
    python-pillow \
    python-lxml \
    yara-python\
    pcre \
    curl \
    libpcap \
    libxml2-devel \
    libxslt-devel \
    libyaml-devel \
    install numactl \
    ssdeep \
    ssdeep-devel \
    openssl \
    zip \
    unzip \
    gzip \
    bzip2 \
    swig \
    m2crypto \
    p7zip \
    p7zip-plugins \
    libffi \
    libyaml \
    upx \
    yara \
    httpd \
    mod_wsgi \
    mod_ssl

#### Fetch the CRITs Codebase, drop into /data, and set up users ####

RUN mkdir /data && \
    mkdir /data/certs && \
    cd /data && \
    useradd -r -s /bin/false crits && \
    chown -R crits /data && \
    chmod -R -v 0755 /data &&\
    usermod apache -G crits
ADD config_application.sh /data/
USER crits
RUN cd /data && \
    git clone -b 4_fts https://github.com/akniffe1/crits.git && \
    git clone https://github.com/crits/crits_services.git && \
    touch /data/crits/logs/crits.log
USER root
RUN chgrp -R crits /data/crits/logs && \
    chmod 0644 /data/crits/logs/crits.log

#### Install Python Dependencies and Prep the Webserver####

WORKDIR /data/crits
RUN echo 'Installing Python Dependencies' && \
    pip install --upgrade pip && \
    pip install -r requirements.txt
RUN echo 'Prep the HTTPD Environment' && \
    cp extras/httpd24.conf /etc/httpd/conf/httpd.conf && \
    cp extras/httpd24_ssl.conf /etc/httpd/conf.d/ssl.conf && \
    echo 'Generate a Self Signed Cert. Replace this on next run!' && \
    cd /data/certs && \
    openssl req -nodes -newkey rsa:2048 -keyout /data/certs/new.cert.key -out /data/certs/new.cert.csr -subj "/C=US/ST=Arizona/L=Anytown/O=Awesome/OU=Awesomer/CN=crits.${DOMAIN}" && \
    openssl x509 -in new.cert.csr -out /data/certs/new.cert.cert -req -signkey /data/certs/new.cert.key -days 1825 && \
    ln -s /data/certs/new.cert.cert /etc/pki/tls/certs/crits.crt && \
    ln -s /data/certs/new.cert.key /etc/pki/tls/private/crits.plain.key
VOLUME /data/certs
#### Prepare the Database ####

RUN cp crits/config/database_example.py crits/config/database.py && \
    SC=$(cat /dev/urandom | LC_CTYPE=C tr -dc 'abcdefghijklmnopqrstuvwxyz0123456789!@#%^&*(-_=+)' | fold -w 50 | head -n 1) && \
    SE=$(echo ${SC} | sed -e 's/\\/\\\\/g' | sed -e 's/\//\\\//g' | sed -e 's/&/\\\&/g') && \
    sed -i -e "s/^\(SECRET_KEY = \).*$/\1\'${SE}\'/1" crits/config/database.py && \
    sed -i -e "s/^\(MONGO_HOST = \).*$/\1\os.environ['MONGODB_PORT_27017_TCP_ADDR']/1" crits/config/database.py

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]  # http://linoxide.com/linux-how-to/configure-apache-containers-docker-fedora-22/
EXPOSE 443