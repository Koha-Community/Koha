# this file provides environment variables to use perl Makefile.PL 
# without interactive mode. it can be seen as config file.

# usage from shell:
# source environment_Makefile.PL &&
#     perl Makefile.PL &&
#     make install

# TODO: add explainations from the installer ? 

export PERL_MM_USE_DEFAULT=1 # makes the environment variables work
export KOHA_USER='koha'      # unix account used by zebra  
export KOHA_GROUP='koha'     # unix group used by zebra

# default root to install config files
export DESTDIR=$HOME         # here would be koha configuration, logs and zebra base 

# The installer tries to guess what's your ip address and your hostname
# if you plan to use koha with vhosts strategy or run koha on a recent linux
# guesses won't be appropriate: edit by yourself
# If you plan to use vhosts, you have to edit the koha-httpd.conf file
# anyway :(
export WEBSERVER_HOST=EDITME
export WEBSERVER_IP=EDITME

# from now, commented export directives are alternatives
# uncomment one of them to choose it

#export INSTALL_MODE=dev
#export INSTALL_MODE=single
export INSTALL_MODE=standard

export INSTALL_SRU=no
#export INSTALL_SRU=yes

export INSTALL_ZEBRA=yes
#export INSTALL_ZEBRA=no

export INSTALL_PAZPAR2=no
#export INSTALL_PAZPAR2=yes

export RUN_DATABASE_TESTS=no
#export RUN_DATABASE_TESTS=yes

export PATH_TO_ZEBRA=''

export DB_TYPE=mysql
#export DB_TYPE=Pg

export DB_HOST='localhost'
export DB_NAME='koha'

# /!\ concider changing password if you don't want 
# some script kiddies to crack you koha server
export DB_USER='kohaadmin'
export DB_PASS='katikoan'

export AUTH_INDEX_MODE=grs1
#export AUTH_INDEX_MODE=dom

#export ZEBRA_MARC_FORMAT=unimarc
export ZEBRA_MARC_FORMAT=marc21

#export ZEBRA_LANGUAGE=fr
export ZEBRA_LANGUAGE=en

# /!\ concider changing password if you don't want 
# some script kiddies to crack you koha server
export ZEBRA_USER='kohauser'
export ZEBRA_PASS='zebrastripes'
export ZEBRA_SRU_HOST='localhost'
export ZEBRA_SRU_BIBLIOS_PORT='9998'
export ZEBRA_SRU_AUTHORITIES_PORT='9999'

export MERGE_SERVER_HOST='localhost'
export MERGE_SERVER_PORT='11001'
export PAZPAR2_HOST='localhost'
export PAZPAR2_PORT='11002'
