#!/bin/sh

ENV='.env'
PROJECT=''
DETACH=0

if [[ "$1" == '-d' || "$2" == '-d' ]] ; then
  DETACH=1
  echo 'please detach'
fi

# Is a project is specified look in the config folder for an environment file
if [[ ${#1} != 0  && "$1" != '-d' ]] ; then
  ENV="./config/$1.env"
fi


# If the file doesn't exist then exit
if [ ! -f "$ENV" ] ; then
  echo 'Specified Project not found. Look in the config folder for available project .env files.'
  exit
fi

# Extract .env variables
DB_NAME=$(grep DB_NAME $ENV | cut -d '=' -f2)
DB_USER=$(grep DB_USER $ENV | cut -d '=' -f2)
DB_PW=$(grep DB_PW $ENV | cut -d '=' -f2)
#PROJECT=$(grep COMPOSE_PROJECT_NAME $ENV | cut -d '=' -f2 | sed -e 's/^"//' -e 's/"$//')

# find the name of a docker container that contains the project and "_db"
# dbID=$(docker container ls -aq -f name="${PROJECT}_db")

#Start Only the database
docker-compose --env-file="$ENV" up -d db 

INIT_SQL="create database if not exists ${DB_NAME} character set UTF8 collate utf8_general_ci;create user if not exists ${DB_USER} IDENTIFIED BY '${DB_PW}';GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO ${DB_USER};" 

#Test to see of the mysql comand is ready
NEXT_WAIT_TIME=0
until [ $NEXT_WAIT_TIME -eq 5 ] || echo ">>> Check for MYSQL Ready" && docker exec -it $(docker ps -aq -f name=_db) mysql -uroot -pmythic -e "$INIT_SQL"; do
    sleep $(( NEXT_WAIT_TIME++ ))
done
[ $NEXT_WAIT_TIME -lt 5 ]

echo ">>> Setup: database & user"
echo ">>> Starting Docker: docker-compose --env-file=$ENV up"

#Start the rest of the services
if [ "$DETACH" == 1 ] ;then
  docker-compose --env-file="$ENV" -d up
else
  docker-compose --env-file="$ENV" up
fi
