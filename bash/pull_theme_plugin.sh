#!/bin/bash

#Tell git to skip asking yes/no questions for RSA Fingerprints
mkdir -p ~/.ssh
touch ~/.ssh/config
echo -e "Host github.com\n\tStrictHostKeyChecking no\n" >> ~/.ssh/config

#Setup ssh key for git
eval `ssh-agent -s`
chmod 0600 /bash/adamtgit 
ssh-add /bash/adamtgit 

#ADD THEME

#$1 should be a git ssh path to a theme
if [ ${#1} != 0 ] ; then
  #Get theme name and branch
  theme="$(echo "$1" | awk -F"/" '{print $NF}')";
  theme=${theme%.*}
  themeBR="$(echo "$1" | awk -F"::" '{print $NF}')";

  cd /var/www/html/wp-content/themes/

  #Check to see if the Theme folder is there
  echo  "THEME: LOOKING FOR: ${theme}"
  if [ ! -d "./${theme}" ]; then
    git clone "${1%.*}.git"
    wp theme enable $theme --allow-root --network
    wp theme activate $theme --allow-root
  else
    echo "THEME FOUND: ${theme}"
  fi

  pushd "./${theme}" >/dev/null

  #Change the branch of the theme if specified 
  if [ ${#themeBR} != 0 ] && [ "${themeBR}" != "${1}" ]; then
    echo "THEME: USE BRANCH: ${themeBR}"
    git checkout "${themeBR}"
  fi
  
  if test -f _sass; then
      bash _sass
  fi

  popd >/dev/null
  
else
  echo 'THEME: No theme Specified'
fi


#ADD PLUGINS
#$2 should be a comma seperated list of plugin slugs
if [ ${#2} != 0 ] ; then
  pushd /var/www/html/wp-content/plugins/ >/dev/null
  IFS=',' read -r -a pluginlist <<< $2
  for slug in "${pluginlist[@]}"
  do
    plname=${slug}

    #Format a git plugin name
    if [[ "$slug" =~ ^git* || "$slug" =~ ^http* ]] ; then
      plname="$(echo "$slug" | awk -F"/" '{print $NF}')";
      plname=${plname%.*}
    #rmove a key or branch
    elif [[ "$slug" == *"::"* ]] ; then
      plname=${plname%::*}
    fi

    branch="$(echo "$slug" | awk -F"::" '{print $NF}')";

      #Check if plugin has already been installed
      #echo  "PLUGIN: LOOKING FOR: ${plname}"
      if  ! wp plugin is-installed $plname --allow-root ; then
        echo "PLUGIN: NOT FOUND: ${plname}, Installing...."
        
        #Clone github plugin
        if [[ "$slug" =~ ^git* ]] ; then
          git clone "${slug%.*}.git"
          wp plugin activate $plname --allow-root
          if [ ${#branch} != 0 ] && [ "${branch}" != "${slug}" ]; then
            echo "PLUGIN: USE BRANCH: ${branch}"
            cd "./${plname}"
            git checkout "${branch}"
            cd ../
          fi

        #Download zip from live url
        elif [[ "$slug" =~ ^http* ]] ; then
          zipname="$(echo "$slug" | awk -F"/" '{print $NF}')";
          curl -Ok "$slug"
          wp plugin install "$zipname" --allow-root
          wp plugin activate $plname --allow-root
          rm "$zipname"

        #Download ACF-PRO with key
        elif [[ "$slug" =~ ^advanced-custom-fields-pro* ]] ; then
          #get Advanced Custom Fields Pro
          #the branch is the acf key
          acfzip=/var/www/html/wp-content/plugins/advanced-custom-fields-pro.zip
          wget -O ${acfzip} "http://connect.advancedcustomfields.com/index.php?p=pro&a=download&k=${branch}"
          wp plugin install ${acfzip} --allow-root
          wp plugin activate advanced-custom-fields-pro --allow-root
          rm ${acfzip}

        #Download from the WP plugin repository
        else
          echo "DOWNLOAD: https://downloads.wordpress.org/plugin/${plname}.latest-stable.zip"
          curl -Ok "https://downloads.wordpress.org/plugin/${plname}.latest-stable.zip"
          wp plugin install "${plname}.latest-stable.zip" --allow-root
          wp plugin activate $plname --allow-root
          rm "${plname}.latest-stable.zip"
        fi
      else
        echo "PLUGIN: FOUND: ${plname}"
      fi

      
  done
  popd >/dev/null
else
  echo 'PLUGIN: No plugin list set'
fi
