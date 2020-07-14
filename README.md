# versandgigant-php-fpm-opcache
Versandgigant php-fpm Opcache for Ubuntu Linux and nginx

# Overview
This script configures a php-fpm installation to use opcache and set the configuration based on your local environment and resources.

The configuration is optimized to create a high performance, secure PHP-FPM configuration.

# Run
Here is a simple run command:

    bash <(curl -f -L -sS https://raw.githubusercontent.com/p-w/versandgigant-php-fpm-opcache/master/setup.sh)

# References

PHP
* https://github.com/openbridge/ob_php-fpm/
* https://www.kinamo.be/en/support/faq/determining-the-correct-number-of-child-processes-for-php-fpm-on-nginx
* https://www.if-not-true-then-false.com/2011/nginx-and-php-fpm-configuration-and-optimizing-tips-and-tricks/
* https://www.tecklyfe.com/adjusting-child-processes-php-fpm-nginx-fix-server-reached-pm-max_children-setting/
* https://serversforhackers.com/video/php-fpm-process-management
* https://devcenter.heroku.com/articles/php-concurrency
and using plugins like
* https://de.wordpress.org/plugins/nginx-helper/


## License

This plugin is Free Software, released and licensed under the **GPL-V3.0** - see the [LICENSE](LICENSE) file for details
