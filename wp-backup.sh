#!/bin/bash

set -e

#### COMMANDS CROSS SYSTEMS (Linux and MacOS) ####

# Create sed cross system
custom-sed() {
    if [[ $THIS_OS = *$NAME_OSX* ]]; then
        # Check if OSX and install GSED
        if [ -x "$(command -v gsed)" ]; then
            gsed "$@"
        else
            echo "${COLOR_RED}ERROR. You must install gsed if you are using OSX${COLOR_RESET}"
            exit 1
        fi
    else
        # Linux
        sed "$@"
    fi
}
export -f custom-sed

#### VARIABLES ####

# OS
NAME_OSX="Darwin"
THIS_OS=$(uname -mrs)
PROGNAME=$(basename $0)
NOW=$(date +"%Y-%m-%d-%H%M")
FULL_PATH=$(pwd)
BACKUP_PATH=$NOW

# Site-specific Info
DB_NAME=`cat wp-config.php | grep DB_NAME | cut -d \' -f 4`
DB_USER=`cat wp-config.php | grep DB_USER | cut -d \' -f 4`
DB_PASS=`cat wp-config.php | grep DB_PASSWORD | cut -d \' -f 4`
DB_HOST=`cat wp-config.php | grep DB_HOST | cut -d \' -f 4`
TABLE_PREFIX=$(cat wp-config.php | grep "\$table_prefix" | cut -d \' -f 2)

# Domain
NEW_SITE_URL='http://localhost'
NEW_SITE_DOMAIN=$(custom-sed -nr "s/^https?:\/\/(.*)$/\1/p" $NEW_SITE_URL)
SITE_URL=`mysql -e "SELECT option_value FROM $TABLE_PREFIX options WHERE option_name = 'siteurl'" -ss -u $DB_USER --password=$DB_PASS $DB_NAME`
SITE_DOMAIN=$(custom-sed -nr "s/^https?:\/\/(.*)\/?/\1/p" $SITE_URL)

#### FUNCTIONS ####

## HELP
usage() {
    if [ "$*" != "" ] ; then
        echo "Error: $*"
    fi

    cat << EOF
Usage: $PROGNAME [OPTION]
Backup or restore a WordPress. Only Bash.

Options:
  backup-all                         Create a zip file with important files and a copy of the database.
  backup-database                    Backup of the database.
  restore-all [{backup}.zip]         Restore a version.
  restore-database [{database}.sql]  Restore the database.
  --help                             Display this usage message and exit
EOF

    exit 1
}

# Database Backup
database_backup() {
    # Remove old backup database
    rm -f $DB_NAME.sql
    # Backup database
    mysqldump -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME > $DB_NAME.sql
    # Replace SITE_URL (`http://example.com`) by `http://localhost`
    custom-sed -Ei "s,$SITE_URL,$NEW_SITE_URL,g" $DB_NAME.sql
    # Replace SITE_DOMAIN (`example.com`) by `localhost`: Fix multisite
    custom-sed -Ei "s,$SITE_DOMAIN,$NEW_SITE_DOMAIN,g" $DB_NAME.sql
}

# Files Backup
files_backup() {
    # Compress
    zip -r $NOW.zip $BACKUP_PATH $DB_NAME.sql wp-content
}

# Database Restore
database_restore() {
    # Replace `http://localhost` by SITE_URL (`http://example.com`)
    custom-sed -Ei "s,$NEW_SITE_URL,$SITE_URL,g" $1
    # Replace `localhost` by SITE_DOMAIN (`example.com`): Fix multisite
    custom-sed -Ei "s,$NEW_SITE_DOMAIN,$SITE_DOMAIN,g" $1
    # Restore tables
    cat $1 | /usr/bin/mysql -u DB_USER --password=DB_PASS DB_NAME
}

# Files Restore
files_restore() {
    echo "restore"
}

# CONTROLE ARGUMENTS
isArg=""

while [ $# -gt 0 ] ; do
    case "$1" in
        --help)
            usage
            ;;
        backup-all)
            isArg="1"
            database_backup
            files_backup
            #### GOODBYE ###
            echo "New backup: $NOW.zip"
            echo "Happy DevOps!"
            ;;
        backup-database)
            isArg="1"
            database_backup
            #### GOODBYE ###
            echo "New Database backup: $DB_NAME.sql"
            echo "Happy DevOps!"
            ;;
        restore-database)
            isArg="1"
            echo 'Working'
            database_restore
            ;;
        *)
    esac
    shift
done

if [ -z $isArg ] ; then
    usage "Not enough arguments"
fi
