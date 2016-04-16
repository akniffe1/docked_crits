# docked_crits
docker-compose containers for running a production grade CRITs instance using percona-server-mongodb and crits + HTTPD on CENTOS 7. 

Modify ' ENV DOMAIN ' to your environment on the Dockerfile and the variable 'DOMAIN' on the config_application.sh script to minimize config requirements. You can also drop your SSL Certificates in the CERTs directory for those to get pulled into the image and used ILO the self signed stuff. 

## Start Procedure:

Build all the containers
```` docker-compose build ````

Configure CRITs
```` docker-compose run crits-web sh /data/crits_mods/config_application.sh ````

Run the webserver using the Django Runserver (for development only)
```` docker-compose run crits-web python manage.py runserver 0.0.0.0:8080 ````

Run the webserver using HTTPD
```` docker-compose run crits-web /usr/bin/httpd -D FOREGROUND ````

# TODO:

-Test the import of SSL certs
-Run the crits_mods fulltext index builder on the mongodb container
