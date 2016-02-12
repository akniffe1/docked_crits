#!/usr/bin/env bash

printf "building Full Text Indexes"
mongo localhost:27017/test make_fulltext.js
printf "deploying API adjustments for fulltext API search"
cp -r handlers.py /data/crits/crits/core/
cp -r api.py /data/crits/crits/core/
rm -f /data/crits/crits/core/*.pyc