# dock_wp
GSMA Docker Setup
!!Still in Progress
This repo is currently configured to set up the multi m360 site but eventually it will be a springboard to set up other sites.
Ther gitignore file is set up to ignore all wp-contents and the files in /db but eventually the /db files can be set inthe repo to store the databse backups

### Features
- wp install, mysql, memcached, phpmyadmin(local) automatic plugin install, automatic theme install

## Setup
* Requires Docker desktop app installed and running (https://www.docker.com/products/docker-desktop)

### Quickstart
* Go to the folder you cloned this repo to in the command line and type
```
bash dockit.sh
```
The code will be done runnning when you see: `dock_wp_shell_1 exited with code 0`
In the browser go to localhost/wp-admin
 
* The above command will leave your terminal in interactive mode and will continue to output information including php notices. When you close the terminal it will stop php/mysql etc and going to localhost will show empty. If you want to be able to close your terminal and leave it running perpertually use -d for "deteached"
```
bash dockit.sh -d
```

### Setup a Specific site
* Look in the /config folder for files end with ".env" these are site specific configurations specifying db names theme and plugins. Look for the one you need or create you own (steps below) get the name before .env and run the command (with or without -d at the end)
```
bash dockit.sh {filename before .env}
``` 

### Configure a new Site
* To create a new site configuation create a file in the /config folder and name it {site}.env
* Enter value pairs in the following format
```
ALL_CAPS_VARIABLE=value
```  
* Note: there is no space between the variable, =, and value
The following vriables are available:

#### COMPOSE_PROJECT_NAME
- Optional: The name of the project, this is for docker to create different containers. Still testing how this works/what it does. It relates to having multiple sites running at once
- By default no project will be set and containers will have generic names

#### COMPOSE_FILE
- Opional: Name of the docker-compose.yml, this defines which services the site will have. Having different ymls lets us define services by site. Some might need NODE.js or memcache or WP multisite where others don't.
- By default docker-compose.yml will be used

#### SITE_TITLE
- Required: Wordpress needs this for setup. This is the Wordpress site title set in WP options

#### SITE_URL
- In development: This is a placeholder for when we go into production. For now setup is overriding with localhost

#### DB_NAME
- Required: This is the name of the database created in mysql and added to wp-config.php

#### DB_USER & DB_PW
- Required: The username and passowrd are created and the user is granted access to the DB. Also set in wp-config.php

### THEME
- Optional: The github theme. Set as theme_ssh_url::branch (::branch is optional)

### PLUGINS
- Optional: comma seperated list of plugins. 
- For a plugin in the WP online database use the slud (folder name) Double check with WP CLI using 
`wp plugin search <search>`
- For a github plugin use the format  plugin_ssh_url::branch (::branch is optional)
- For ACF Pro specifically use: advanced-custom-fields-pro::licence


## Accessing WP CLI or GIT and Basic command line
```
docker-compose run --rm shell bash
```
## Accessing & Debuging Mysql
```
docker ps
#get the id of the active mysql container
docker exec -it <container id> mysql -uroot -p<MYSQL_ROOT_PASSWORD>
```
Mysql errors do not output into the terminal like php and bash errors do, unless you edit the .yml and comment out the line `logging: driver: "no"`

## Accessing PHPMyadmin
- Visit in the browser at localhost:8080 username and password are set in the .env file as DB_USER and DB_PASS or root and MYSQL_ROOT_PASSWORD set in dokcer-compose.yml

## Debuging PHP
* Running a compose up command without -d (see setup) will run docker in interactive mode and output all php notices and errors to the console

## Backup Database
There is a script that will connect to the docker mysql container and export the database to the wp/.dump folder.
The script is in wp/bash called backup_database.sh
```
sh backup_database.sh
```
the first time it will create {db_name}.sql. If run again it will move the previous .sql file to prev_{db_name}.sql


## Pushing git changes
Use `git config -l` and see if there is info about your user name and email etc
The github repos downloaded use ssh so you have to set up a key in github.
Use this tutorial: https://help.github.com/en/enterprise/2.15/user/articles/adding-a-new-ssh-key-to-your-github-account
I don't know why it says enterprise but whatever.
Also running this command helps debug the connection
```ssh -vT git@github.com```
Then you can navigate in your local file system to the folder and `git push origin`

## Wordprss Multisite
- Wordpress multisite is set up when depending on the .yml file used on docker-compose
- When creating a new site, Use the email webteam@gsma.com 

## Local Files and Data
The database is copied to /db and the wordpress files are copied to /wp this means changes to the database and the php files within will persist even if docker container images or volumes are removed. Docker can be stoped and restarted safely



## Configuration
- There is a .env file in the main directory where you can set variables for the install
- Site Title is required for WP to do a core install
- There are other .env files that can be used for reference

### Plugin Installs
- Use a comma seperated list of plugin slugs for the plugins to be pulled and installed 
- You can set plugins from WP or git repos for github repos the structure is <ssh github url>::<branch>
```
  PLUGINS=underconstruction,batcache,formassembly-web-forms,Jetpack,git@github.com:GSMA/plugin_sf_forms.git::dev
```
* For Advanced Custom Fields pro you must add the key at the end `advanced-custom-fields-pro::<key>`

* Installing WP SEO isn't set up yet but here is a url for later
- https://kb.yoast.com/kb/how-to-install-yoast-plugins-using-composer/

## Troubleshooting

### Could Not Start the Docker Daemon/Not Running
* Turn off other LAMP stacks
* Make sure Docker desktop is running

### Self Signed Certificate Issues
There is a program on gsma work computers (Netskope Client) that prevents self signed certificates from working.
This is necessary for things like WP updates and plugin updates to work locally
this command will disable netskope client:
```
sudo launchctl unload /Library/LaunchDaemons/com.netskope.stagentsvc.plist
```

### Port (X) is busy 
Turn off any running Lamp stack: Wamp, Mamp, Xamp, Ampps etc

### Bind for 0.0.0.0:80 failed: port is already allocated OR
### ERROR: for wp  Cannot start service wp: driver failed programming external connectivity on endpoint
* Stop all the docker containers
```
docker stop $(docker ps -aq)
```

### WP CLI ERROR
```
PHP Parse error:  syntax error, unexpected 'if' (T_IF), expecting identifier (T_STRING) in phar:///usr/local/bin/wp/vendor/wp-cli/wp-cli/php/WP_CLI/Runner.php(1197) : eval()'d code on line 101
```
* Something is wrong with wp-config.php

### Current issues
There are still some things that aren't working the way they should
* I can't get files to copy over in the Dockerfile so instead they are located in the wp/bash folder. It would be more ideal to have the .sh files in the config folder and copy them over to a folder on the volume but not in the WP folder
