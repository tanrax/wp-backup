#!/bin/bash

set -e

#### VARIABLES ####
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

#### FUNCTIONS ####

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

## HELP
usage() {
    if [ "$*" != "" ] ; then
        echo "Error: $*"
    fi

    cat << EOF
Usage: $PROGNAME [OPTION]
Backup or restore a WordPress.

Options:
  backup-all                                    Create a zip file with important files and a copy of the database.
  backup-database                               Backup of the database.
  restore-all [{backup}.zip] [site url]         Restore a version.
  restore-database [{database}.sql] [site url]  Restore the database.
  --help                                        Display this usage message and exit
EOF

    exit 1
}

# Database Backup
database_backup() {
    # Remove old backup database
    rm -f $DB_NAME.sql
    # Backup database
    mysqldump -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME > $DB_NAME.sql
    # Replace SITE_URL `by localhost`
    SITE_URL=`cat $DB_NAME.sql | grep siteurl | cut -d \' -f 4`
    NEW_SITE_URL='http://localhost'
    custom-sed -Ei "s,$SITE_URL,$NEW_SITE_URL,g" $DB_NAME.sql
}

# Files Backup
files_backup() {
    # Compress
    zip -r $NOW.zip $BACKUP_PATH $DB_NAME.sql wp-content
}

# Database Restore
database_restore() {
    echo "restore"
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
        restore)
            isArg="1"
            echo 'Working'
            ;;
        *)
    esac
    shift
done

if [ -z $isArg ] ; then
    usage "Not enough arguments"
fi
