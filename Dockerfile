# Read the README first, there are several configurable attributes available 
# to speed up your build and deploy processes.
FROM centos:latest
MAINTAINER Knifehands

ENV container docker
ENV DOMAIN example.com

#### Install the Basics ####
RUN yum -y install wget
RUN rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt && \
    yum -y install epel-release && \
    wget https://forensics.cert.org/cert-forensics-tools-release-el7.rpm && \
    rpm -i cert-forensics-tools-release-el7.rpm && \
    rm cert-forensics-tools-release-el7.rpm
RUN yum -y install make \
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
    mod_ssl &&\
    yum cleanall

#### Fetch the CRITs Codebase, drop into /data, set up users ####
# for the time being, we'll pull an alternate service bootstrap file that properly identifies CentOS 7. 

RUN mkdir /data && \
    mkdir /data/certs && \
    mkdir /data/crits && \
    cd /data && \
    useradd -r -s /bin/false crits && \
    chown -R crits /data && \
    usermod apache -G crits
ADD ./certs /data/certs
ADD ./crits_mods /data/crits_mods/
ADD ./pubcrits /data/crits
RUN cd /data && \
    chown -R crits /data/crits/ && \
    cp /data/crits_mods/crits.log /data/crits/logs/ && \
    chmod 644 /data/crits/logs/crits.log

#### Install Python Dependencies and Prep the Webserver####

WORKDIR /data/crits
RUN echo 'Installing Python Dependencies' && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    cp /data/crits_mods/httpd24.conf /etc/httpd/conf/httpd.conf && \
    cp /data/crits_mods/httpd24_ssl.conf /etc/httpd/conf.d/ssl.conf && \
    cd /data/certs && \
    openssl req -nodes -newkey rsa:2048 -keyout /etc/pki/tls/private/crits.plain.key -out /data/certs/new.cert.csr -subj "/C=US/ST=Arizona/L=Anytown/O=Awesome/OU=Awesomer/CN=crits.${DOMAIN}" && \
    openssl x509 -in /data/certs/new.cert.csr -out /etc/pki/tls/certs/crits.crt -req -signkey /etc/pki/tls/private/crits.plain.key -days 1825


#### Prepare the Database ####

RUN cp crits/config/database_example.py crits/config/database.py && \
    SC=$(cat /dev/urandom | LC_CTYPE=C tr -dc 'abcdefghijklmnopqrstuvwxyz0123456789!@#%^&*(-_=+)' | fold -w 50 | head -n 1) && \
    SE=$(echo ${SC} | sed -e 's/\\/\\\\/g' | sed -e 's/\//\\\//g' | sed -e 's/&/\\&/g') && \
    sed -i -e "s/^\(SECRET_KEY = \).*$/\1\\'${SE}'/1" crits/config/database.py && \
    sed -i -e "s/^\(MONGO_HOST = \).*$/\1\os.environ['MONGODB_PORT_27017_TCP_ADDR']/1" crits/config/database.py

#### Light the fires and kick the tires ####

# CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"] # todo enable this after dev_work
EXPOSE 443
#ENTRYPOINT python manage.py runserver 0.0.0.0:8080
#EXPOSE 8080
