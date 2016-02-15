#!/usr/bin/env bash
# final config settings-- invoke these from the host with :
# docker-compose run crits-web sh /data/config_application.sh
DOMAIN="example.com"
python /data/crits/manage.py create_default_collections
python /data/crits/manage.py users -a -A -e admin@crits.${DOMAIN} -f admin -l admin -o foo -u admin
python /data/crits/manage.py setconfig allowed_hosts .${DOMAIN}*
python /data/crits/manage.py setconfig debug False
python /data/crits/manage.py setconfig crits_message "Nullius in Verba"
python /data/crits/manage.py setconfig timezone UTC