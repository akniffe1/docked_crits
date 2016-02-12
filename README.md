# docked_crits
docker-compose containers for running a production grade CRITs instance using percona-server-mongodb and crits + HTTPD on CENTOS 7. 

Modify ' ENV DOMAIN ' to your environment on the Dockerfile and the variable 'DOMAIN' on the config_application.sh script to minimize config requirements. You can also drop your SSL Certificates in the CERTs directory for those to get pulled into the image and used ILO the self signed stuff. 

## Start Procedure:
```` docker-compose build ````

```` docker-compose run crits-web sh config_application.sh ````

```` docker-compose up ````


# TODO:

Add Services via another kickstart-esque command, test the import of SSL certs, run the crits_mods fulltext index builder. 
