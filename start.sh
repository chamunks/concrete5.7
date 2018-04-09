#!/bin/bash
## Documentation for Concrete5 CLI installation
## https://documentation.concrete5.org/developers/appendix/cli-commands
## This start script makes some assumptions:
## * That you're using the default mysql port
## * That you just want C5 running instantly at first.
## * That you can set environment variables in your setup
echo "[Info] Testing connection to MariaDB database"
echo "[RUN] Executing the command: mysqlshow --host=$DB_SERVER --user=$DB_USERNAME --password=$DB_PASSWORD $DB_NAME| grep -v Wildcard | grep -o $DB_NAME"
mysqlshow --host=$DB_SERVER --user=$DB_USERNAME --password=$DB_PASSWORD $DB_NAME| grep -v Wildcard | grep -o $DB_NAME
if [[ "$C5_PRESEED" = yes ]]; then
  DBCHECK=`mysqlshow --host=$DB_SERVER --user=$DB_USERNAME --password=$DB_PASSWORD $DB_NAME| grep -v Wildcard | grep -o $DB_NAME`
  if [[ "$dbcheck" == "$DB_NAME" ]]; then
    die() {
    echo "[FAIL] You already have a database on the specified server."
    echo "please run this container with the environment variable C5_PRESEED set to false if you wish to start it without the database C5_PRESEED."
    1>&2 ; exit 1; }
  else
    echo "[Info] No DB Found at $DB_USERNAME@$DB_SERVER using password $DB_PASSWORD"
    echo "       the current root password is: $MYSQL_ROOT_PASSWORD"
    echo "[Info] Running C5 installation with the following settings"
    echo "[RUN]     /var/www/html/concrete/bin/concrete5 c5:install \
          --db-server=$DB_SERVER \
          --db-username=$DB_USERNAME \
          --db-password=$DB_PASSWORD \
          --db-database=$DB_NAME \
          --site=$C5_SITE_NAME \
          --starting-point=$C5_STARTING_POINT \
          --admin-email=$C5_EMAIL \
          --admin-password=$C5_PASSWORD \
          --site-locale=$C5_LOCALE && \
          apache2-foreground"
    /var/www/html/concrete/bin/concrete5 c5:install \
      --db-server=$DB_SERVER \
      --db-username=$DB_USERNAME \
      --db-password=$DB_PASSWORD \
      --db-database=$DB_NAME \
      --site=$C5_SITE_NAME \
      --starting-point=$C5_STARTING_POINT \
      --admin-email=$C5_EMAIL \
      --admin-password=$C5_PASSWORD \
      --site-locale=$C5_LOCALE && \
      apache2-foreground
  fi
  else
    echo "Starting your Concrete5 installation"
    apache2-foreground
fi
