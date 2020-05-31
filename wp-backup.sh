#!/bin/bash

#### Settings ####
NOW=$(date +"%Y-%m-%d-%H%M")
FULL_PATH=$(pwd)
BACKUP_PATH=$NOW

#### Site-specific Info ####
DB_NAME=`cat wp-config.php | grep DB_NAME | cut -d \' -f 4`
DB_USER=`cat wp-config.php | grep DB_USER | cut -d \' -f 4`
DB_PASS=`cat wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`
DB_HOST=`cat wp-config.php | grep DB_HOST | cut -d \' -f 4`

#### Database Backup ####
function database_backup {
    # Backup database
    mysqldump -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME > $DB_NAME.sql
    # Replace SITE_URL `by localhost`
    SITE_URL=`cat wordpress.sql | grep siteurl | cut -d \' -f 4`
    NEW_SITE_URL='http://localhost'
    sed -Ei "s,$SITE_URL,$NEW_SITE_URL,g" $DB_NAME.sql
}

#### Files Backup ####
function files_backup {
    # Compress
    zip -r $NOW.zip $BACKUP_PATH $DB_NAME.sql wp-content
    # Remove backup database
    rm $DB_NAME.sql
}

#### Runner ####
database_backup
files_backup
