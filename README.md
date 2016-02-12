# docked_crits
docker-compose containers for running a production grade CRITs instance using percona-server-mongodb and crits + HTTPD on CENTOS 7.

Start Procedure:
```` docker-compose build ````
```` docker-compose run crits-web sh config_application.sh ````
```` docker-compose up ````


TODO:
Add Services via another kickstart-esque command. 
