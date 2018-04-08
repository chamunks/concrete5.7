FROM php:7.2.3-apache-stretch

MAINTAINER Chamunks chamunks AT gmail.com


###########################
## Environment Variables ##
###########################
#  DB_SERVER is the host name with the database server (if it's available on a custom port, for instance 3333, simply add :3333)
#  DB_USERNAME is the username to be used to access the database server
#  DB_PASSWORD is the password associated to DB_USERNAME
#  DB_NAME is the name of the database to use (it must exist and it must be empty)
#  CT_SITE_NAME is the name to give to the new concrete5 installation (will be shown for instance in the page titles)
#  C5_STARTING_POINT specify which set of initial data should be installed. By default concrete5 comes with elemental_full and elemental_blank
#  C5_EMAIL is the email to associate to the admin account that will be created on the new concrete5 installation
#  C5_PASSWORD is the password to assign to the admin account that will be created on the new concrete5 installation
#  C5_LOCALE (this is optional) is the code of the default site language (by default it's en_US)

ENV C5_VERSION 8.3.2

ENV MYSQL_SERVER      localhost
ENV MYSQL_USERNAME    default
ENV MYSQL_PASSWORD    default
ENV MYSQL_DATABASE    default
ENV DB_SERVER         $MYSQL_SERVER
ENV DB_USERNAME       $MYSQL_USERNAME
ENV DB_PASSWORD       $MYSQL_PASSWORD
ENV DB_NAME           $MYSQL_DATABASE
ENV CT_SITE_NAME      default
ENV C5_STARTING_POINT elemental_full
ENV C5_EMAIL          default@example.com
ENV C5_PASSWORD       default
ENV C5_LOCALE         en_US
ENV C5_PRESEED           yes


RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    libpng-dev \
    mariadb-client-10.1 \
    wget \
    unzip && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install zip && \
    docker-php-ext-install gd && \
    docker-php-ext-install pdo_mysql && \
    a2enmod rewrite

RUN mkdir -p /usr/local/src && \
    mkdir -p /var/www/html && \
    chown root:www-data /var/www/html
RUN wget -nv --header 'Host: www.concrete5.org' --user-agent 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:52.0) Gecko/20100101 Firefox/52.0' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' --header 'Accept-Language: en-US,en;q=0.5' --header 'Upgrade-Insecure-Requests: 1' 'https://www.concrete5.org/download_file/-/view/100595/8497/' --output-document '/usr/local/src/concrete5-8.3.2.zip'
RUN unzip -qq /usr/local/src/concrete5-${C5_VERSION}.zip -d /usr/local/src/  && \
    ls -lAh /usr/local/src/ && \
    chown root:www-data /usr/local/src/concrete5-${C5_VERSION} && \
    ls -lAh /usr/local/src/concrete5-${C5_VERSION} && \
    rm -v /usr/local/src/concrete5-${C5_VERSION}.zip

ADD config/database.php /var/www/html/config/database.php
ADD /php/docker-php-uploads.ini /usr/local/etc/php/conf.d/docker-php-uploads.ini
ADD docker-entrypoint /bin/docker-entrypoint
ADD start.sh /bin/start-c5

RUN chmod +x /bin/docker-entrypoint /bin/start-c5

# Persist website user data, logs & apache config if you want
VOLUME [ "/var/www/html", "/usr/local/etc/php", "/var/www/html/config" ]

EXPOSE 80

ENTRYPOINT ["docker-entrypoint"]

CMD ["start-c5"]
