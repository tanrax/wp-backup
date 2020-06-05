Create backups or restore on your WordPress using a simple script so as not to depend on plugins or WP-CLI. Bash's power is enough. Multi-site compatible.

## Use

### Backup

Create a zip file with important files and backup of the database.

``` shell
./wp-backup.sh backup-all
```

### Backup only database

``` shell
./wp-backup.sh backup-database
```

### Restore

The `site url` variable is the domain to use.

``` shell
./wp-backup.sh restore-all [{backup}.zip] [site url]
```

### Restore the database

Only restore database. The `site url` variable is the domain to use

``` shell
./wp-backup.sh restore-database [{database}.sql] [site url]
```

## Requirements 

- **bash** 4.0 or higher
- **curl**
- Only macOS users, **gsed**: `brew install gnu-sed`

## Install

Go to the WordPress directory (Where are all the files and folders like wp-admin, wp-config, wp-content ...).

``` shell
cd wordpress-folder
```

Download script.

``` shell
curl -o wp-backup.sh https://raw.githubusercontent.com/tanrax/wp-backup/master/wp-backup.sh
```

Grant execute permissions.

``` shell
sudo chmod +x wp-backup.sh
```

Run.

``` shell
./wp-backup.sh
```
