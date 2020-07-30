<h2 align="center">
Simple tool to manage WordPress backups in pure Bash
</h2>

![Description](media/wp-backup.png)

Create **backups or restore on your WordPress** using a **simple script in Bash** so as not to depend on plugins or WP-CLI.

- Easy.
- Very fast.
- Multi-site compatible.
- Compatible with cron and any unix utility.
- Maintains settings, plugins and any important elements.
- Compatible with Linux, MacOS and BSD.

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

``` shell
./wp-backup.sh restore-all [{backup}.zip]
```

### Restore the database

``` shell
./wp-backup.sh restore-database [{database}.sql]
```

## Requirements 

- **bash** 4.0 or higher
- **curl**
- **zip**
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

## Disclaimer

The author is not responsible for any loss of information or side effects. Use at your own risk.
