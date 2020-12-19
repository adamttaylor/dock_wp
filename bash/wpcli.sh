#!/bin/sh
#wpcli.sh

#$1=admin_user
#$2=admin_password
#$3=site url
#$4=site title
#$5=git theme url
#$6=plugin list

#Remove standard WP themes except 1
find /var/www/html/wp-content/themes -type d -name "twenty*" | grep -v twentytwenty | while read line 
do 
  rm -r $line 
done 

#Remove hello dolly plugin
find /var/www/html/wp-content/plugins -type f -name "hello.php" | while read line
do 
  rm -r $line 
done 

#Set up WP to skip the install WP screen
wp core install --admin_user="$1" --admin_password="$2" --admin_email=webteam@gsma.com --url="$3" --title="$4" --allow-root; 

#Setup configs themes and plugins
#keep re-running until DB is ready 
if $(wp core is-installed --allow-root); then
  #set memecached constant to the name of the memcached service
    
  wp config set MEMCACHED_HOST cache --allow-root
  wp config set WP_HOME $3 --allow-root
  wp config set WP_SITEURL $3 --allow-root

  #Multisites need extra htacces configuration
  rm /var/www/html/.htaccess
  cp /bash/htaccess.txt /var/www/html/.htaccess
  
  wp config delete WP_ALLOW_MULTISITE --allow-root
  wp config delete MULTISITE --allow-root
  wp config delete SUBDOMAIN_INSTALL --allow-root
  wp config delete DOMAIN_CURRENT_SITE --allow-root
  wp config delete PATH_CURRENT_SITE --allow-root
  wp config delete SITE_ID_CURRENT_SITE --allow-root
  wp config delete BLOG_ID_CURRENT_SITE --allow-root
    
  bash /bash/pull_theme_plugin.sh $5 $6
else 
  #Force docker to try the command again
  exit 123
fi