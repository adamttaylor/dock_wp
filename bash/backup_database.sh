#!/bin/bash
mysqlid=$(docker container ls -f name=_db_ -q)

DB_NAME=$(grep DB_NAME ../../.env | cut -d '=' -f2)
DB_USER=$(grep DB_USER ../../.env | cut -d '=' -f2)
DB_PW=$(grep DB_PW ../../.env | cut -d '=' -f2)

if [ "${mysqlid}" ]; then
  DBFILE="../.dump/${DB_NAME}.sql"
  #echo "container: ${mysqlid}, DB: ${DB_NAME} -u${DB_USER}  -p${DB_PW}"
  mkdir -p ../.dump
  if [ -s  "${DBFILE}" ]; then
    mv  "${DBFILE}"  "../.dump/prev_${DB_NAME}.sql"
  fi
  echo 'working......'
  docker exec -it ${mysqlid} mysqldump -u"${DB_USER}" -p"${DB_PW}" "${DB_NAME}" > "${DBFILE}"
else
  echo "Error: could not find running docker mysql container"
fi