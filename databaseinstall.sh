#!/bin/sh

if [ $# = 4 ]; then
  echo Setting up database
  mysqladmin -uroot -p$1 create $2
  echo creating tables
  mysql -uroot -p$1 $2 < koha.mysql
  echo creating mysql permissions
  mysql -uroot -p$1 mysql -e "insert into user (Host,User,Password) values ('localhost','$3',password('$4'))";
  mysql -uroot -p$1 mysql -e "insert into db (Host,Db,User,Select_priv,Insert_priv,Update_priv,Delete_priv) values ('%','$2','$3','Y','Y','Y','Y')";
  mysqladmin -uroot -p$1 reload
  echo 
  echo If no errors were reported, the database will be set up
  echo You can check by typing mysql -u$3 -p$4 $2
  echo then show tables;
  echo
  echo You will need to Edit C4/Database.pm to reflect the username,database and password you have chosen
  
else
  echo This scripts needs four inputs, 
  echo The root password for mysql, the database for use with koha, the username for use with koha and the password
  echo For example databaseinstall.sh fish koha kohauser tuna
fi
