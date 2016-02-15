# Read the README first, there are several configurable attributes available 
# to speed up your build and deploy processes.
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
RUN echo 'Grabbing EPEL and CERT Forensics Repos' && \
    rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt && \
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

#### Fetch the CRITs Codebase, drop into /data, set up users ####
# for the time being, we'll pull an alternate service bootstrap file that properly identifies CentOS 7. 

RUN mkdir /data && \
    mkdir /data/certs && \
    cd /data && \
    useradd -r -s /bin/false crits && \
    chown -R crits /data && \
    usermod apache -G crits
ADD ./certs /data/certs
USER crits
ADD crits_mods /data/crits_mods/
RUN cd /data && \
    git clone -b 4_fts https://github.com/akniffe1/crits.git && \
    git clone -b stable_4 https://github.com/crits/crits_services.git && \
    touch /data/crits/logs/crits.log
 # Hanging onto this for the magical day when the services bootstrap works on CentOS 7
 #   /usr/bin/cp /data/crits_mods/service_bootstrap.sh /data/crits_services/bootstrap
RUN chown -R crits /data/crits/logs && \
    chmod 644 /data/crits/logs/crits.log

#### Install Python Dependencies and Prep the Webserver####

USER root
WORKDIR /data/crits
RUN echo 'Installing Python Dependencies' && \
    pip install --upgrade pip && \
    pip install -r requirements.txt
RUN echo 'Prep the HTTPD Environment' && \
    cp extras/httpd24.conf /etc/httpd/conf/httpd.conf && \
    cp extras/httpd24_ssl.conf /etc/httpd/conf.d/ssl.conf && \
    echo 'Generate a Self Signed Cert. You can replace this by loading a host volume containing your proper cert and private key etc...' && \
    cd /data/certs && \
    openssl req -nodes -newkey rsa:2048 -keyout /etc/pki/tls/private/crits.plain.key -out /data/certs/new.cert.csr -subj "/C=US/ST=Arizona/L=Anytown/O=Awesome/OU=Awesomer/CN=crits.${DOMAIN}" && \
    openssl x509 -in /data/certs/new.cert.csr -out /etc/pki/tls/certs/crits.crt -req -signkey /etc/pki/tls/private/crits.plain.key -days 1825

#### Install Service Dependencies ####
#### Not a fan of this approach, but the bootstrap leaves me no choices here #### 

RUN yum -y install pyew \
    python-chm \
    libchm1 \ 
    clamav \ 
    exiftool \
    antiword \
    poppler-utils \
    python-pillow \ 
    m2crypto \
    python-m2ext \
    numpy
RUN pip install oletools \
    bitstring \
    mod_pywebsocket \
    Pyinstaller \
    shodan \ 
 #   stix-validator \
    libtaxii==1.1.102 \
    cybox==2.1.0.11 \
    stix==1.1.1.5 \
    pylzma \
    pythonwhois
RUN cd /data/ && \
    git clone https://github.com/MITRECND/snugglefish.git && \
    cd snugglefish && make && \
    cd python && \
    python setup.py install
RUN cd /data/ && \
    wget http://pefile.googlecode.com/files/pefile-1.2.10-139.tar.gz && \
    tar -xvzf pefile-1.2.10-139.tar.gz && \
    cd pefile-1.2.10-139 && \
    python setup.py build && \
    python setup.py install


#### Prepare the Database ####

RUN cp crits/config/database_example.py crits/config/database.py && \
    SC=$(cat /dev/urandom | LC_CTYPE=C tr -dc 'abcdefghijklmnopqrstuvwxyz0123456789!@#%^&*(-_=+)' | fold -w 50 | head -n 1) && \
    SE=$(echo ${SC} | sed -e 's/\\/\\\\/g' | sed -e 's/\//\\\//g' | sed -e 's/&/\\\&/g') && \
    sed -i -e "s/^\(SECRET_KEY = \).*$/\1\\'${SE}'/1" crits/config/database.py && \
    sed -i -e "s/^\(MONGO_HOST = \).*$/\1\os.environ['MONGODB_PORT_27017_TCP_ADDR']/1" crits/config/database.py

#### Light the fires and kick the tires ####

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"] 
EXPOSE 443
