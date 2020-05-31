#!/bin/bash

#### Settings ####
NOW=$(date +"%Y-%m-%d-%H%M")
FULL_PATH=$(pwd)
BACKUP_PATH=$NOW

#### Site-specific Info ####
DB_NAME=`cat $SITE_PATH/wp-config.php | grep DB_NAME | cut -d \' -f 4`
DB_USER=`cat $SITE_PATH/wp-config.php | grep DB_USER | cut -d \' -f 4`
DB_PASS=`cat $SITE_PATH/wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`
DB_HOST=`cat $SITE_PATH/wp-config.php | grep DB_HOST | cut -d \' -f 4`

#### Files Backup ####
function files_backup {
    zip -r wp-content.zip wp-content
}

#### Database Backup ####
function database_backup {
    mysqldump -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME > $DB_NAME.sql
}

#### Zip all Backups ####
function pack_backups {
    # Make folder
    mkdir $BACKUP_PATH
    # Move files to pack folder
    mv wp-content.zip $BACKUP_PATH
    # Move database to pack folder
    mv $DB_NAME.sql $BACKUP_PATH
    # Compress
    zip -r $NOW.zip $BACKUP_PATH
    # Remove temp folder
    rm -r $BACKUP_PATH
}

#### Runner ####
files_backup
database_backup
pack_backups
