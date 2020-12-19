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

wp core multisite-install --admin_user="$1" --admin_password="$2" --admin_email=webteam@gsma.com --url="$3" --title="$4" --allow-root; 

if $(wp core is-installed --allow-root); then

    SITESLUG="$(echo "$3" | awk -F/ '{print $3}')";
    
    wp config set MEMCACHED_HOST cache --allow-root
    wp config set WP_HOME $3 --allow-root
    wp config set WP_SITEURL $3 --allow-root

    #Multisites need extra htacces configuration
    rm /var/www/html/.htaccess
    cp /bash/htaccess_multisite.txt /var/www/html/.htaccess
    
    wp config set WP_ALLOW_MULTISITE true --raw --allow-root
    wp config set MULTISITE true  --raw --allow-root
    wp config set SUBDOMAIN_INSTALL false  --raw --allow-root
    wp config set DOMAIN_CURRENT_SITE $SITESLUG --allow-root
    wp config set PATH_CURRENT_SITE /  --allow-root
    wp config set SITE_ID_CURRENT_SITE  1  --raw  --allow-root
    wp config set BLOG_ID_CURRENT_SITE 1  --raw  --allow-root
    
    bash /bash/pull_theme_plugin.sh $5 $6
else 
  #Force docker to try the command again
  exit 123
fi