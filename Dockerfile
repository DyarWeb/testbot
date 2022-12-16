FROM php:apache

#add firefox ppa
RUN apt-get update && apt-get install -y gnupg software-properties-common
RUN apt-get update && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys A6DCF7707EBC211F
RUN apt-add-repository "deb http://ppa.launchpad.net/ubuntu-mozilla-security/ppa/ubuntu bionic main"

# Install packages and update os
RUN apt-get update && apt-get upgrade -y && apt-get install -y build-essential libssl-dev libffi-dev python-dev sudo \
    zip libzip-dev libpng-dev libonig-dev cron curl libmcrypt-dev mediainfo firefox python3 python3-pip

# Install php extentions
RUN docker-php-ext-install pdo pdo_mysql mysqli mbstring zip gd

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable rewrite apache mode
RUN a2enmod rewrite

# Copy src files in /var/www/html/
COPY . /var/www/
COPY ./public /var/www/html/

#change workdir
WORKDIR /var/www/

# install composer packages
RUN rm -rf /var/www/vendor
RUN composer i

# copy cronjob file to cron.d dir
COPY cronjob_cpnb /etc/cron.d/cronjob_cpnb

# Give right permission to cronjob_cpnb file
RUN chmod 0644 /etc/cron.d/cronjob_cpnb

# Apply cron job
RUN crontab /etc/cron.d/cronjob_cpnb

# setwebhook
RUN php artisan telebot:webhook -S &> /dev/null && sleep 2

# Give right permission to storage dir
RUN chmod -R 0777 /var/www/storage

# Give apache user sudo permission without assword
RUN echo 'www-data ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# migrate the database and Run the command on container startup
CMD php artisan migrate && ( cron -f -l 8 & ) && apache2-foreground

# Expose 80 port
EXPOSE 80
