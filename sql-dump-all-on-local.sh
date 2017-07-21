#!/bin/bash

USER="root"
PASSWORD="rootpasswd"
#OUTPUT="/Users/rabino/DBs"

#rm "$OUTPUTDIR/*gz" > /dev/null 2>&1

databases=$(mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
        echo "Dumping database: $db"
        mysqldump --skip-lock-tables --user=$USER --password=$PASSWORD --databases $db > $(date +%Y%m%d)".${db}.sql"
       # gzip $OUTPUT/$(date +%Y%m%d).$db.sql
    fi
done
