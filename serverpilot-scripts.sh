#!/bin/bash
# === Variables ===
red="\e[1;31m"
green="\e[32m"
blue="\e[34m"
normal="\e[0m"
error="${red}ERROR: ${normal}"

nginx_conf_url="https://raw.githubusercontent.com/webdna/serverpilot-scripts/master/nginx.app.conf"
nginx_expires_conf_url="https://raw.githubusercontent.com/webdna/serverpilot-scripts/master/nginx.expires.conf"

certbot_bash_url="https://raw.githubusercontent.com/webdna/serverpilot-scripts/master/certbot.sh"

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
echo -n "What verion of PHP are you running? e.g. X.X: "
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
  show_notice "Creating LEMP Stack…"

  echo -n "What is the appname? : "
  read appname

  sysuser_default="serverpilot"
  echo -n "What is the system user (normally serverpilot)? [default: serverpilot] : "
  read sysuser
  system_user="${sysuser:-$sysuser_default}"
  if [ -n "$appname" ] && [ -n "$system_user" ] && [ -e "/etc/nginx-sp/vhosts.d/${appname}.d" ]; then

    app_vhost_dir="/etc/nginx-sp/vhosts.d/${appname}.d"

    if [[ -e "${app_vhost_dir}/main.custom.conf" ]]; then
      show_warning "${appname} has already been customised. Skipping.."
    else
      show_info "Backing up main conf file…"
      (eval "mv ${app_vhost_dir}/main.conf ${app_vhost_dir}/main.conf.bak")

      show_info "Creating new nginx conf…"
      (eval "wget --no-cache -O ${app_vhost_dir}/main.custom.conf ${nginx_conf_url}")

      show_info "Inserting system user and appanme"
      (eval "sed -i -e 's/SYSUSER/${system_user}/g' ${app_vhost_dir}/main.custom.conf")
      (eval "sed -i -e 's/APPNAME/${appname}/g' ${app_vhost_dir}/main.custom.conf")

      show_info "Restarting nginx…"
      service nginx-sp restart
    fi

  else
    show_error "You must provide a valid appname"
  fi

  show_notice "Finished Creating LEMP Stack…"
fi
# === /LEMP Stack ===
#
# === Install Certbot ===
if [[ $run_all = false ]]; then
  echo -n "Install Certbot (for Lets Encrypt)? (y/n) [default: n] : "
  read certbotrun
fi

if [ "$certbotrun" = "y" ] || [ $run_all = true ]; then
  show_notice "Installing Certbot…"

  show_info "Updating packages…"
  apt-get update

  show_info "Installing software-properties-common…"
  apt-get install -y software-properties-common

  show_info "Add Certbot repository…"
  add-apt-repository -y ppa:certbot/certbot

  show_info "Updating packages…"
  apt-get update

  show_info "Installing Certbot cli…"
  apt-get install -y certbot

  show_info "Adding certbot renew to dail cron…"
  (eval "wget --no-cache -O /etc/cron.daily/certbot ${certbot_bash_url}")

  show_info "Making certbot cron is executable…"
  (eval "chmod +x /etc/cron.daily/certbot")

  show_notice "Finished Installing Certbox…"
fi
# === /Install Certbot ===

# === Imagick ===
if [[ $run_all = false ]]; then
  echo -n "Install Imagick? (y/n) [default: n]: "
  read imagick
fi

if [ "$imagick" = "y" ] || [ $run_all = true ]; then
  show_notice "Installing Imagick…"
  show_info "When asked for a prefix simply press enter."

  show_info "Installing Pacakges…"
  apt-get install -y gcc make autoconf libc-dev pkg-config
  apt-get install -y libmagickwand-dev

  show_info "Pecl Installing Imagick…"
  (eval "pecl${php_version}-sp install imagick")

  show_info "Enabling Imagick Extension…"
  bash -c "echo extension=imagick.so > /etc/php${php_version}-sp/conf.d/imagick.ini"

  show_info "Restarting PHP FPM…"
  (eval "service php${php_version}-fpm-sp restart")

  show_notice "Finished Installing Imagick…"
fi
# === /Imagick ===

# === AutoMySQLBackup ===
if [[ $run_all = false ]]; then
  echo -n "Install AutoMySQLBackup? (y/n) [default: n]: "
  read automysqlbackup
fi

if [ "$automysqlbackup" = "y" ] || [ $run_all = true ]; then
  show_notice "Installing AutoMySQLBackup…"

  apt-get install -y automysqlbackup

  show_notice "Finished Installing AutoMySQLBackup…"
fi
# === /AutoMySQLBackup ===

# === Disable MySQL 5.7 Strict Mode ===
if [[ $run_all = false ]]; then
  echo -n "Disable MySQL Strict Mode? (y/n) [default: n]: "
  read mysql_strict
fi

if [ "$mysql_strict" = "y" ] || [ $run_all = true ]; then
  show_notice "Disabling MySQL Strict Mode…"

  if [ -e /etc/mysql/conf.d/disable_strict_mode.cnf ]; then
    show_info "Disable strict mode config already exists"
  else
    show_info "Creating file…"
    touch /etc/mysql/conf.d/disable_strict_mode.cnf
    show_info "Adding config…"
    printf "[mysqld]\nsql_mode=IGNORE_SPACE,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION\n" > /etc/mysql/conf.d/disable_strict_mode.cnf
    show_info "Restarting MySql…"
    service mysql restart
  fi

  show_notice "Finished Disabling MySQL Strict Mode…"
fi
# === /Disable MySQL 5.7 Strict Mode ===

# === Image optimisation libraries ===
if [[ $run_all = false ]]; then
  echo -n "Install image optimisation libraries? (y/n) [default: n]: "
  read imgopt
fi

if [ "$imgopt" = "y" ] || [ $run_all = true ]; then
  show_notice "Installing image optimisation libraries…"

  # jpegoptim
  show_info "Installing jpegoptim…"
  apt-get install -y jpegoptim

  # optipng
  show_info "Installing optipng…"
  apt-get install -y optipng

  # pngquant
  show_info "Installing pngquant…"
  apt-get install -y pngquant

  # pngcrush
  show_info "Installing pngcrush…"
  apt-get install -y pngcrush

  # gifsicle
  show_info "Installing gifsicle…"
  apt-get install -y gifsicle

  # webp
  show_info "Installing webp…"
  apt-get install -y webp

  show_notice "Finished Installing image optimisation libraries…"
fi
# === /Image optimisation libraries ===

# === Password Protect App ===
if [[ $run_all = false ]]; then
  echo -n "Password protect app? (y/n) [default: n]: "
  read pwd_protect
fi

if [ "$pwd_protect" = "y" ] || [ $run_all = true ]; then
  show_notice "Starting Password protect app process…"

  echo -n "What is the appname of the app you would like to password? :"
  read appname

  if [ -n "$appname" ] && [ -e "/etc/nginx-sp/vhosts.d/${appname}.d" ]; then

    # Get System User (normall "severpilot")
    system_user_default="serverpilot"
    echo -n "System user, the user from serverpilot that controls the app: [default: serverpilot]"
    read system_user_input
    system_user="${system_user_input:-$system_user_default}"

    # Get Title
    pwd_title_default="Restricted Content"
    echo -n "Title for password protect? [default: ${pwd_title_default}] "
    read pwd_title_input
    pwd_title="${pwd_title_input:-$pwd_title_default}"

    # Get Username
    echo -n "Username: "
    read pwd_username
    if [[ ! -n "$pwd_username" ]]; then
      show_error "You must supply a username"
    fi

    # Create password file
    show_info "Creating password file…"
    pwd_dir="/srv/users/${system_user}/pwd/${appname}"
    mkdir -p "${pwd_dir}"
    pwd_path="${pwd_dir}/.htpasswd"

    if [[ ! -e "${pwd_path}" ]]; then
      touch "${pwd_path}"
    fi

    # Generate user / pass
    (eval "htpasswd ${pwd_path} ${pwd_username}")

    nginx_pwd_conf="/etc/nginx-sp/vhosts.d/${appname}.d/password.conf"
    if [[ ! -e "${nginx_pwd_conf}" ]]; then
      show_info "Creating nginx password conf file…"

      auth_basic='auth_basic "'"${pwd_title}"'";'
      auth_basic_user_file="auth_basic_user_file ${pwd_path};"

      touch "${nginx_pwd_conf}"
      (echo $auth_basic >> $nginx_pwd_conf)
      (eval "echo \"${auth_basic_user_file}\" >> ${nginx_pwd_conf}")
    fi

    service nginx-sp restart

  else
    show_info "${appname} not found."
  fi

  show_notice "Finished Password protect app process…"
fi
# === /Password Protect App ===

# === Expires Nginx Conf ===
if [[ $run_all = false ]]; then
  echo -n "Add expires Nginx conf? (y/n) [default: n] : "
  read expires_nginx
fi

if [ "$expires_nginx" = "y" ] || [ $run_all = true ]; then
  show_notice "Adding Expires Nginx Conf…"

  echo -n "What is the appname? : "
  read appname
  if [ -n "$appname" ] && [ -e "/etc/nginx-sp/vhosts.d/${appname}.d" ]; then

    app_vhost_dir="/etc/nginx-sp/vhosts.d/${appname}.d"
    expires_conf_file="${app_vhost_dir}/expires.conf"

    if [[ -e "${expires_conf_filre}" ]]; then
      show_warning "${appname} already has expires file. Skipping.."
    else

      show_info "Creating expires nginx conf…"
      (eval "wget --no-cache -O ${expires_conf_file} ${nginx_expires_conf_url}")

      show_info "Restarting nginx…"
      service nginx-sp restart
    fi

  else
    show_error "You must provide a valid appname"
  fi

  show_notice "Finished Adding Expires Nginx Conf…"
fi
# === /Expires Nginx Conf ===
