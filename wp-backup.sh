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
BACKUP_DATABASE_NAME="database.sql"

# COLORS
COLOR_RED=`tput setaf 1`
COLOR_GREEN=`tput setaf 2`
COLOR_RESET=`tput sgr0`

# Site-specific Info
DB_NAME=$(cat wp-config.php | grep DB_NAME | cut -d \' -f 4)
DB_USER=$(cat wp-config.php | grep DB_USER | cut -d \' -f 4)
DB_PASS=$(cat wp-config.php | grep DB_PASSWORD | cut -d \' -f 4)
DB_HOST=$(cat wp-config.php | grep DB_HOST | cut -d \' -f 4)
TABLE_PREFIX=$(cat wp-config.php | grep "\$table_prefix" | cut -d \' -f 2)

# Domain
NEW_SITE_URL='http://localhost'
NEW_SITE_DOMAIN=$(echo $NEW_SITE_URL | custom-sed -nr "s/^https?:\/\/(.*)$/\1/p")
SITE_URL=$(mysql -e "SELECT option_value FROM ${TABLE_PREFIX}options WHERE option_name = 'siteurl'" -ss -u $DB_USER --password=$DB_PASS $DB_NAME)
SITE_DOMAIN=$(echo $SITE_URL | custom-sed -nr "s/^https?:\/\/(.*)\/?/\1/p")

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
  --help                             Display this usage message.
EOF

    exit 1
}

# Database Backup
database_backup() {
    # Remove old backup database
    rm -f $DB_NAME.sql
    # Backup database
    mysqldump -h $DB_HOST -u$DB_USER -p$DB_PASS $DB_NAME > $BACKUP_DATABASE_NAME
    # Replace SITE_URL (`http://example.com`) by `http://localhost`
    custom-sed -Ei "s,$SITE_URL,$NEW_SITE_URL,g" $BACKUP_DATABASE_NAME
    # Replace SITE_DOMAIN (`example.com`) by `localhost`: Fix multisite
    custom-sed -Ei "s,$SITE_DOMAIN,$NEW_SITE_DOMAIN,g" $BACKUP_DATABASE_NAME
}

# Files Backup
files_backup() {
    # Compress
    zip -r $NOW.zip $BACKUP_PATH $BACKUP_DATABASE_NAME wp-content
}

# Database Restore
database_restore() {
    # Replace `http://localhost` by SITE_URL (`http://example.com`)
    custom-sed -Ei "s,$NEW_SITE_URL,$SITE_URL,g" $BACKUP_DATABASE_NAME
    # Replace `localhost` by SITE_DOMAIN (`example.com`): Fix multisite
    custom-sed -Ei "s,$NEW_SITE_DOMAIN,$SITE_DOMAIN,g" $BACKUP_DATABASE_NAME
    # Restore tables
    cat $BACKUP_DATABASE_NAME | /usr/bin/mysql -u $DB_USER --password=$DB_PASS $DB_NAME
}

# Files Restore
files_restore() {
    # Remove folder `wp-content`
    rm -rf wp-content
    # Unzip backup
    unzip $1
    # Fix owner
    chown -R --reference=wp-config.php wp-content
    # Fix permissons
    find wp-content -type d -exec chmod 750 {} \;
    find wp-content -type f -exec chmod 640 {} \;
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
            
            echo "Working..."
            database_backup
            files_backup

            echo "${COLOR_GREEN}New backup:${COLOR_RESET} $NOW.zip"
            echo "${COLOR_GREEN}Happy DevOps!${COLOR_RESET}"
            ;;
        backup-database)
            isArg="1"
            
            echo "Working..."
            database_backup
            
            echo "${COLOR_GREEN}New Database backup:${COLOR_RESET} $BACKUP_DATABASE_NAME"
            echo "${COLOR_GREEN}Happy DevOps!${COLOR_RESET}"
            ;;
        restore-database)
            isArg="1"
            
            echo "Restoring database..."
            database_restore
            
            echo "${COLOR_GREEN}Database restored.${COLOR_RESET}"
            echo "${COLOR_GREEN}Happy DevOps!${COLOR_RESET}"
            ;;
        restore-all)
            isArg="1"
            
            echo "Restoring files..."
            files_restore
            echo "${COLOR_GREEN}Files restored.${COLOR_RESET}"
            
            echo "Restoring database..."
            database_restore
            echo "${COLOR_GREEN}Database restored.${COLOR_RESET}"

            echo "${COLOR_GREEN}All restored.${COLOR_RESET}"
            echo "${COLOR_GREEN}Happy DevOps!${COLOR_RESET}"
            ;;
        *)
    esac
    shift
done

if [ -z $isArg ] ; then
    usage "Not enough arguments"
fi
