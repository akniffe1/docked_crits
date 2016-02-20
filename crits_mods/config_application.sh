#!/usr/bin/env bash
# final config settings-- invoke these from the host with :
# docker-compose run crits-web sh /data/crits_mods/config_application.sh
python /data/crits/manage.py create_default_collections
python /data/crits/manage.py setconfig enable_api True 
python /data/crits/manage.py setconfig enable_toasts True 
python /data/crits/manage.py setconfig service_dirs "/data/crits_services/"
python /data/crits/manage.py setconfig service_model process
python /data/crits/manage.py setconfig debug False
python /data/crits/manage.py setconfig crits_message "Nullius in Verba"
python /data/crits/manage.py setconfig timezone UTC
python /data/crits/manage.py users -a -A -e admin@crits.example.com -f admin -l admin -o foo -u admin