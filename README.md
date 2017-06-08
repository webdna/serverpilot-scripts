# Serverpilot Scripts
A collection of scripts for setting up various items / running tasks on serverpilot provisioned servers

**THIS SCRIPT IS TO BE RUN ENTIRELY AT YOUR OWN RISK**

**WE ARE NOT RESPONSIBLE FOR LOSS OF DATA OR ANY OTHER BAD THINGS THAT MAY HAPPEN AS A RESULT OF RUNNING THIS SCRIPT**

### Installation & Usage

1. ssh into your serverpilot server e.g. `ssh serverpilot@YOUR.SERVER.IP.ADDRESS`
1. Login as **root** `su` (important: do not skip)
1. Run script from GitHub `bash <(curl -s https://raw.githubusercontent.com/webdna/serverpilot-scripts/master/serverpilot-scripts.sh)`
1. The script will prompt asking you if you would like to run each part as listed below.

### Available Scripts

- [LEMP Stack (Nginx Only, No Apache)](#lemp-stack-nginx-only-no-apache)
- [AutoMySQLBackup](#automysqlbackup)
- [Imagick](#imagick)
- [Disable MySQL (5.7) Strict Mode](#disable-mysql-57-strict-mode)
- [Image Optimisation Libraries](#image-optimisation-libraries)
- [Password Protect](#password-protect)
- [Nginx Expires Config](#nginx-expires-config)

#### LEMP Stack (Nginx Only, No Apache)
If your app doesn't utilize .htaccess files, it is possible to have Nginx interact directly with PHP-FPM and bypass Apache entirely.

https://serverpilot.io/community/articles/how-to-create-a-lemp-stack-only-nginx-no-apache.html

#### AutoMySQLBackup
MySQL provides a command line utility, mysqldump, for exporting databases as raw SQL. Instead of running mysqldump manually, you can install a script that will automatically run mysqldump every day on all of your databases. One of the most popular of these scripts is automysqlbackup.

https://serverpilot.io/community/articles/how-to-back-up-mysql-databases-with-automysqlbackup.html

#### Imagick
The ImageMagick extension supports PHP 5.4, 5.5, 5.6, 7.0, and 7.1.

https://serverpilot.io/community/articles/how-to-install-the-php-imagemagick-extension.html

#### Disable MySQL (5.7) Strict Mode
If your app was written for older versions of MySQL and is not compatible with strict SQL mode in MySQL 5.7, you can disable strict SQL mode. For example, apps such as WHMCS 6 and Craft 2 do not support strict SQL mode.

https://serverpilot.io/community/articles/how-to-disable-strict-mode-in-mysql-5-7.html

#### Image Optimisation Libraries
Installation of the following image optimisation libraries:

- gifsicle
- jpegoptim
- optipng
- pngcrush
- pngquant

#### Password Protect
Ability to add Auth Basic to apps with in serverpilot. This is setup within the nginx app config so will work with both people using nginx + apache and nginx only

#### Nginx Expires Config
Adds in an Nginx config containing expires headers. The [config file](https://github.com/webdna/serverpilot-scripts/blob/master/nginx.expires.conf) is based on the [HTML 5 boilerplate nginx configs](https://github.com/h5bp/server-configs-nginx)

### Roadmap

- [ ] [nginx bad bots](https://github.com/mariusv/nginx-badbot-blocker)
- [ ] Image optimisation libraries
  - [x] jpegoptim
  - [ ] mozjpeg
  - [x] optipng
  - [x] pngcrush
  - [x] pngquant
  - [x] gisicle
- [ ] MariaDB Installation
- [x] Password protect apps
- [x] Nginx expires config
