# Requirements 

- **bash** 4.0 or higher
- **curl**
- Only macOS users, **gsed**: `brew install gnu-sed`

# Install

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
