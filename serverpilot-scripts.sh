#!/bin/bash
# === Variables ===
red="\e[1;31m"
green="\e[32m"
blue="\e[34m"
normal="\e[0m"
error="${red}ERROR: ${normal}"

nginx_conf_url="https://raw.githubusercontent.com/webdna/serverpilot-scripts/master/nginx.app.conf"

run_all=false
# === /Variables ===

# === Functions ===
function show_error()
{
  msg=$1
  printf "%b" "${error}${msg}\n"
  exit 1
}

function show_warning()
{
  msg=$1
  printf "%b" "${red}${msg}${normal}\n"
}

function show_notice()
{
  msg=$1
  printf "%b" "${green}${msg}${normal}\n"
}

function show_info()
{
  msg=$1
  printf "%b" "${blue}${msg}${normal}\n"
}
# === /Functions ===

while [[ "$1" != "" ]]; do
  case $1 in
    -a | --all )
      shift
      run_all=true
      ;;
  esac
done

# Check script is being run as root
if [[ "$USER" != "root" ]]; then
  show_error "This script must be run as root"
fi

# === Get PHP Version ===
echo -n "What verion of PHP are you running? e.g. 5.6, 7.0, 7.1: "
read php_version
if [ -n "$php_version" ]; then
  echo "PHP Version: $php_version"
elif [ ! -n "$php_version" ]; then
  show_error "You must supply a PHP version."
fi
# === /Get PHP Version ===

# === LEMP Stack ===
if [[ $run_all = false ]]; then
  echo -n "Create LEMP Stack (Nginx Only, No Apache)? (y/n) [default: n] : "
  read lemp
fi

if [ "$lemp" = "y" ] || [ $run_all = true ]; then
  show_notice "Creating LEMP Stack..."
  
  echo -n "What is the appname? : "
  read appname
  if [ -n "$appname" ] && [ -e "/etc/nginx-sp/vhosts.d/${appname}.d" ]; then
    
    app_vhost_dir="/etc/nginx-sp/vhosts.d/${appname}.d"
    
    if [[ -e "${app_vhost_dir}/main.custom.conf" ]]; then
      show_warning "${appname} has already been customised. Skipping.."
    else
      show_info "Backing up main conf file..."
      (eval "mv ${app_vhost_dir}/main.conf ${app_vhost_dir}/main.conf.bak")
      
      show_info "Creating new nginx conf..."
      wget -O nginx.app.conf $nginx_conf_url
      (eval "mv nginx.app.conf ${app_vhost_dir}/main.custom.conf")
      
      show_info "Restarting nginx..."
      service nginx-sp restart
    fi
    
  else
    show_error "You must provide a valid appname"
  fi
  
  show_notice "Finished Creating LEMP Stack..."
fi
# === /LEMP Stack ===

# === Imagick ===
if [[ $run_all = false ]]; then
  echo -n "Install Imagick? (y/n) [default: n]: "
  read imagick
fi

if [ "$imagick" = "y" ] || [ $run_all = true ]; then
  show_notice "Installing Imagick..."
  show_info "When asked for a prefix simply press enter."
  
  show_info "Installing Pacakges..."
  apt-get install -y gcc make autoconf libc-dev pkg-config
  apt-get install -y libmagickwand-dev
  
  show_info "Pecl Installing Imagick..."
  (eval "pecl${php_version}-sp install imagick")
  
  show_info "Enabling Imagick Extension..."
  bash -c "echo extension=imagick.so > /etc/phpX.Y-sp/conf.d/imagick.ini"
  
  show_info "Restarting PHP FPM..."
  (eval "service php${php_version}-fpm-sp restart")
  
  show_notice "Finished Installing Imagick..."
fi
# === /Imagick ===

# === AutoMySQLBackup ===
if [[ $run_all = false ]]; then
  echo -n "Install AutoMySQLBackup? (y/n) [default: n]: "
  read automysqlbackup
fi

if [ "$automysqlbackup" = "y" ] || [ $run_all = true ]; then
  show_notice "Installing AutoMySQLBackup..."
  
  apt-get install -y automysqlbackup
  
  show_notice "Finished Installing AutoMySQLBackup..."
fi
# === /AutoMySQLBackup ===

# === Disable MySQL 5.7 Strict Mode ===
if [[ $run_all = false ]]; then
  echo -n "Disable MySQL Strict Mode? (y/n) [default: n]: "
  read mysql_strict
fi

if [ "$mysql_strict" = "y" ] || [ $run_all = true ]; then
  show_notice "Disabling MySQL Strict Mode..."
  
  if [ -e /etc/mysql/conf.d/disable_strict_mode.cnf ]; then
    show_info "Disable strict mode config already exists"
  else
    show_info "Creating file..."
    touch /etc/mysql/conf.d/disable_strict_mode.cnf
    show_info "Adding config..."
    printf "[mysqld]\nsql_mode=IGNORE_SPACE,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\n" > /etc/mysql/conf.d/disable_strict_mode.cnf
    show_info "Restarting MySql..."
    service mysql restart
  fi
  
  show_notice "Finished Disabling MySQL Strict Mode..."
fi
# === /Disable MySQL 5.7 Strict Mode ===

# === Image optimisation libraries ===
if [[ $run_all = false ]]; then
  echo -n "Install image optimisation libraries? (y/n) [default: n]: "
  read imgopt
fi

if [ "$imgopt" = "y" ] || [ $run_all = true ]; then
  show_notice "Installing image optimisation libraries..."
  
  # jpegoptim
  show_notice "Installing jpegoptim..."
  apt-get install -y jpegoptim

  # optipng
  show_notice "Installing optipng..."
  apt-get install -y optipng
  
  # pngquant
  show_notice "Installing pngquant..."
  apt-get install -y pngquant
  
  # pngcrush
  show_notice "Installing pngcrush..."
  apt-get install -y pngcrush
  
  show_notice "FinishedInstalling image optimisation libraries..."
fi
# === /Image optimisation libraries ===
