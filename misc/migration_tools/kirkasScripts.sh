#!/bin/bash

operation=$1

function migrateBulkScripts {
    #Migrate MARC and Items
    ./bulkmarcimport.pl -v --append -l /home/koha/kohaclone/misc/migration_tools/biblionumberConversionTable -m MARCXML -file /home/koha/migration/biblios.migrateme -commit 1000 -b --oplibmatcher /home/koha/migration/marc.manualmatching --oplibmatchlog /home/koha/kohaclone/misc/migration_tools/marc.matchlog &> bulkmarcimport.log
    ./bulkItemImport.pl --file /home/koha/migration/Nide.migrateme --bnConversionTable biblionumberConversionTable &> bulkItemImport.log
    ./bulkItemImport.pl --file /home/koha/migration/Hankinta.migrateme --bnConversionTable biblionumberConversionTable &> bulkAcquisitionImport.log

    ./bulkPatronImport.pl --defaultadmin --file /home/koha/migration/Asiakas.migrateme &> bulkPatronImport.log
    ./bulkCheckoutImport.pl -file /home/koha/migration/Laina.migrateme &> bulkCheckoutImport.log
    ./bulkFinesImport.pl --file /home/koha/migration/Maksu.migrateme &> bulkFinesImport.log
    ./bulkHoldsImport.pl --file /home/koha/migration/Varaus.migrateme &> bulkHoldsImport.log
    ./bulkRotatingCollectionsImport.pl --file /home/koha/migration/Siirtolaina.migrateme &> bulkRotatingCollectionsImport.log
    #./bulkHistoryImport.pl --file /home/koha/pielinen/histories.migrateme &> bulkHistoryImport.log
}

if [ "$operation" == "backup"  ]
then
    ##Run this as root to use the backup
    if [ $(whoami) != "root" ]
    then
        echo "You must run this as root-user"
        exit
    fi
    echo "Packaging MySQL databases and Zebra index. This will take some time."
    ##Run this as root to make a backup of an existing merge target database
    service mysql stop
    service koha-zebra-daemon stop
    time tar -czf mysql.bak.tar.gz -C /var/lib/ mysql
    time tar -czf zebra.bak.tar.gz -C /home/koha/koha-dev/var/lib/ zebradb
    service mysql start
    service koha-zebra-daemon start
    exit

elif [ "$operation" == "restore" ]
then
    ##Run this as root to use the backup
    if [ $(whoami) != "root" ]
    then
        echo "You must run this as root-user"
        exit
    fi
    echo "Restoring MySQL-databases and Zebra-index from backups. Have a cup of something :)"
    service mysql stop
    service koha-zebra-daemon stop
    rm -r /var/lib/mysql
    rm -r /home/koha/koha-dev/var/lib/zebradb
    time tar -xzf mysql.bak.tar.gz -C /var/lib/
    time tar -xzf zebra.bak.tar.gz -C /home/koha/koha-dev/var/lib/
    service mysql start
    service koha-zebra-daemon start
    #  #Reindex zebra as the koha-user, this will take a loong time.
    #  #su -c "$KOHA_PATH/misc/migration_tools/rebuild_zebra.pl -b -a -r -x -v &> $KOHA_PATH/misc/migration_tools/rebuild_zebra.log_from_revertdb" koha
    exit

elif [ "$operation" == "get" ]
then
    ./getMigrationFiles.sh
    exit

elif [ "$operation" == "migrate" ]
then
    ##Run this as koha to not break permissions
    if [ $(whoami) != "koha" ]
    then
        echo "You must run this as koha-user"
        exit
    fi

    echo "Are you OK with having the Koha database and search index destroyed, and migrating a new batch? OK to accept, anything else to abort."
    read confirmation
    if [ $confirmation == "OK"  ]; then
        echo "I AM HAPPY TO HEAR THAT!"
    else
        echo "Try some other option."
        exit 1
    fi
    #Remove traces of existing migrations
    rm biblionumberConversionTable borrowernumberConversionTable itemnumberConversionTable
    rm /home/koha/kohaclone/misc/migration_tools/marc.matchlog /home/koha/migration/marc.manualmatching
    #Kill the search indexes when doing bare migrations. Remember to not kill indexes when merging migrations :)
    rm -r /home/koha/koha-dev/var/lib/zebradb/biblios/*
    rm -r /home/koha/koha-dev/var/lib/zebradb/authorities/*
    #Empty all previously migrated data. You don't want this when merging records :)
    mysql koha < bulkEmptyMigratedTables.sql
    #Add Pielinen-specific configurations
    mysql koha < /home/koha/migration/configuration/branches.sql

    migrateBulkScripts

    #Make a full Zebra reindex.
    $KOHA_PATH/misc/migration_tools/rebuild_zebra.pl -b -a -r -x -v &> $KOHA_PATH/misc/migration_tools/rebuild_zebra.log
    exit

elif [ "$operation" == "merge" ]
then
    ##Run this as root to use the backup
    if [ $(whoami) != "koha" ]
    then
        echo "You must run this as koha-user"
        exit
    fi

    echo "Are you OK with having two databases merged? You should have a Zebra index to merge against. OK to accept, anything else to abort."
    read confirmation
    if [ $confirmation == "OK"  ]; then
        echo "I AM HAPPY TO HEAR THAT!"
    else
        echo "Try some other option."
        exit 1
    fi

    #Remove traces of existing migrations
    rm biblionumberConversionTable borrowernumberConversionTable itemnumberConversionTable
    rm /home/koha/kohaclone/misc/migration_tools/marc.matchlog /home/koha/migration/marc.manualmatching
    #Add Pielinen-specific configurations
    mysql koha < /home/koha/migration/configuration/branches.sql

    migrateBulkScripts

    #Make a full Zebra reindex.
    $KOHA_PATH/misc/migration_tools/rebuild_zebra.pl -b -a -r -x -v &> $KOHA_PATH/misc/migration_tools/rebuild_zebra.log
    exit
fi
