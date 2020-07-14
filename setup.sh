#!/usr/bin/env bash

#---------------------------------------------------------------------
# check if Ubuntu is running and php version is >= 7.4
#---------------------------------------------------------------------
if [ "$(lsb_release -i | awk -F"\t" '{print $2}')" != 'Ubuntu' ];
  then echo "We didn't find a Ubuntu Linux distribution, use with care!"; exit;
fi

# check php version
if [ "$(php -v | awk '/^PHP/{print $2}')" != '7.4.3' ];
  then echo "We didn't find a PHP installation > 7.4, use with care!"; exit;
fi

# Set environment variables for PHP-FPM runtime
CPU=$(grep -c ^processor /proc/cpuinfo);
echo "CPU: ${CPU}";

TOTALMEM=$(free -m | awk '/^Mem:/{print $2}');
echo "RAM: ${TOTALMEM}";


#---------------------------------------------------------------------
# configure php-fpm 7.4
#---------------------------------------------------------------------

# Min limit of CPUs is 2
if [ "$CPU" -le "2" ];
  then TOTALCPU=2;
  else TOTALCPU="${CPU}";
fi

# PHP-FPM settings
if [ -z $PHP_START_SERVERS ];
  then PHP_START_SERVERS=$(($TOTALCPU / 2)) && echo "${PHP_START_SERVERS}";
fi
if [ -z $PHP_MIN_SPARE_SERVERS ];
  then PHP_MIN_SPARE_SERVERS=$(($TOTALCPU / 2)) && echo "${PHP_MIN_SPARE_SERVERS}";
fi
if [ -z $PHP_MAX_SPARE_SERVERS ];
  then PHP_MAX_SPARE_SERVERS="${TOTALCPU}" && echo "${PHP_MAX_SPARE_SERVERS}";
fi
if [ -z $PHP_MEMORY_LIMIT ];
  then PHP_MEMORY_LIMIT=$(($TOTALMEM / 2)) && echo "${PHP_MEMORY_LIMIT}";
fi
if [ -z $PHP_MAX_CHILDREN ];
  then PHP_MAX_CHILDREN=$(($TOTALCPU * 2)) && echo "${PHP_MAX_CHILDREN}";
fi

# PHP Opcache settings
if [ -z $PHP_OPCACHE_ENABLE ];
  then PHP_OPCACHE_ENABLE=1 && echo "${PHP_OPCACHE_ENABLE}";
fi
if [ -z $PHP_OPCACHE_MEMORY_CONSUMPTION ];
  then PHP_OPCACHE_MEMORY_CONSUMPTION=$(($TOTALMEM / 6)) && echo "${PHP_OPCACHE_MEMORY_CONSUMPTION}";
fi

# create php-fpm 7.4 configuration file
{
  echo "[global]"
  echo "pid = /run/php/php7.4-fpm.pid"
  echo "error_log = /var/log/php7.4-fpm.log"
  echo "daemonize = no"
  echo "log_level = error"
  echo
  echo "[www]"
  echo "user = www-data"
  echo "group = www-data"
  echo "listen = /run/php/php7.4-fpm.sock"
  echo "listen.mode = 0666"
  echo "listen.owner = www-data"
  echo "listen.group = www-data"
  echo
  echo "pm = static"
  echo "pm.max_children = $PHP_MAX_CHILDREN"
  echo "pm.max_requests = 1000"
  echo "pm.start_servers = $PHP_START_SERVERS"
  echo "pm.min_spare_servers = $PHP_MIN_SPARE_SERVERS"
  echo "pm.max_spare_servers = $PHP_MAX_SPARE_SERVERS"
  echo "clear_env = no"
  echo "catch_workers_output = yes"
} | tee /etc/php/7.4/fpm/php-fpm.conf

find /etc/php/7.4 -maxdepth 3 -type f -exec sed -ri -e 's/^(memory_limit = )[0-9]+(M.*)$/\1'${PHP_MEMORY_LIMIT}'\2/' {} \;
find /etc/php/7.4 -maxdepth 3 -type f -exec sed -ri -e 's/^(upload_max_filesize = )[0-9]+(M.*)$/\1'512'\2/' {} \;
find /etc/php/7.4 -maxdepth 3 -type f -exec sed -ri -e 's/^(post_max_size = )[0-9]+(M.*)$/\1'512'\2/' {} \;
find /etc/php/7.4 -maxdepth 3 -type f -exec sed -ri -e 's/^(max_execution_time = )[0-9]+$/\1'300'/' {} \;

{
  echo
  echo "user_ini.filename="
  echo "realpath_cache_size=2M"
  echo "cgi.check_shebang_line=0"
  echo "date.timezone=UTC"
  echo
  echo "opcache.enable=$PHP_OPCACHE_ENABLE"
  echo "opcache.enable_cli=0"
  echo "opcache.save_comments=1"
  echo "opcache.interned_strings_buffer=8"
  echo "opcache.fast_shutdown=1"
  echo "opcache.validate_timestamps=2"
  echo "opcache.revalidate_freq=15"
  echo "opcache.use_cwd=1"
  echo "opcache.max_accelerated_files=100000"
  echo "opcache.max_wasted_percentage=5"
  echo "opcache.memory_consumption=${PHP_OPCACHE_MEMORY_CONSUMPTION}}M"
  echo "opcache.consistency_checks=0"
  echo "opcache.huge_code_pages=1"
} >> /etc/php/7.4/fpm/php.ini
