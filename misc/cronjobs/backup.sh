#!/bin/bash
# Script to create daily backups of the Koha database.
# Loosely based on a script by John Pennington

#Systemd-triggered cronjobs cannot source /etc/environment
source /etc/environment

#Piped programs set the $? (exit value) to the one that failed, instead of the last program's exit value
set -o pipefail

ACTION=$1

function help_usage {
    echo "This is the Koha-Suomi Koha backup script"
    echo "It backs up unanonymized and anonymized versions of Koha's DB and Zebra indices to"
    echo "the Kätkölä sftp-service."
    echo ""
    echo "EXAMPLES:"
    echo ""
    echo "  #export to Kätkölä"
    echo "  backup.sh export"
    echo ""
    echo "  #import from Kätkölä. You cannot directly import the same files you export,"
    echo "  #but you need to ask the Ansible koha_deploy_anonymized_test_databases.playbook"
    echo "  #to prepare the exportable backups for you. After that, you can import the correct backups."
    echo "  #If this makes you unhappy, please fix it."
    echo "  backup.sh import"
    echo ""
    exit 1
}

if [ -z $KOHA_CONF ]; then
    echo "\$KOHA_CONF not defined! Check your environment!"
    exit 2
fi

if [ $(whoami) == 'root' ]; then
    echo "Naughty boy breaking stuff with root."
    echo "Run this script as the Koha-user instead."
    exit 3
fi

DATABASE=`xmlstarlet sel -t -v 'yazgfs/config/database' $KOHA_CONF`
HOSTNAME=`xmlstarlet sel -t -v 'yazgfs/config/hostname' $KOHA_CONF`
PORT=`xmlstarlet sel -t -v 'yazgfs/config/port' $KOHA_CONF`
USER=`xmlstarlet sel -t -v 'yazgfs/config/user' $KOHA_CONF`
PASS=`xmlstarlet sel -t -v 'yazgfs/config/pass' $KOHA_CONF`
BACKUPDIR=`xmlstarlet sel -t -v 'yazgfs/config/backupdir' $KOHA_CONF`
ZEBRA_INDICES_DIR=`dirname $(xmlstarlet sel -t -v 'yazgfs/server[@id="biblioserver"]/directory' $KOHA_CONF)`

KOHA_DATE=`date '+%Y%m%d'`
KOHA_BACKUP_FILE=$DATABASE.$KOHA_DATE.sql
KOHA_BACKUP_ARCHIVE=$DATABASE.$KOHA_DATE.sql.gz
KOHA_BACKUP_ANONARCHIVE=$DATABASE.$KOHA_DATE.anon.sql.gz
KOHA_LATEST_BACKUP_ARCHIVE=$DATABASE.latest.sql.gz
KOHA_LATEST_BACKUP_ANONARCHIVE=$DATABASE.latest.anon.sql.gz
ZEBRA_BACKUP_ARCHIVE=$DATABASE.$KOHA_DATE.zebra.tar.gz
ZEBRA_LATEST_BACKUP_ARCHIVE=$DATABASE.latest.zebra.tar.gz

IMPORT_KOHA_BACKUP_ARCHIVE="intransit.latest.anon.sql.gz"
IMPORT_ZEBRA_BACKUP_ARCHIVE="intransit.latest.zebra.tar.gz"

#
# Extract, anonymize and push backups to Kätkölä
#
function export {
    ### Extract DB dump ###
    #--quick is recommended to be used on big tables
    #--single-transaction does the exporting in a locked-state transaction while the
    #  other operations on the background can keep committing
    echo "mysqldump:in the Koha DB"
    echo "mysqldump will give a warning about \"ignoring option '--databases'\", but don't worry about it."
    mysqldump --quick --single-transaction --user="$USER" --password="$PASS" --port="$PORT" --host="$HOSTNAME" "$DATABASE" > $BACKUPDIR/$KOHA_BACKUP_FILE
    rc=$?; if [[ $rc != 0 ]]; then echo "mysqldump failed" 1>&2; exit $rc; fi

    sqlanonymize --in $BACKUPDIR/$KOHA_BACKUP_FILE --out - | gzip -9 > $BACKUPDIR/$KOHA_BACKUP_ANONARCHIVE
    #Care about exceptions
    ps=(${PIPESTATUS[@]}) #Why is PIPESTATUS emptied when it gets read once?  Copy it as array
    if [[ ${ps[0]} != 0 ]]; then
        echo "sqlanonymize failed" 1>&2; exit ${ps[0]};
    elif [[ ${ps[1]} != 0 ]]; then
        echo "Anonymized DB gzip failed" 1>&2; exit ${ps[1]};
    fi

    gzip -9 $BACKUPDIR/$KOHA_BACKUP_FILE #>becomes> $BACKUPDIR/$KOHA_BACKUP_ARCHIVE
    rc=$?; if [[ $rc != 0 ]]; then echo "gzip of DB backup failed" 1>&2; exit $rc; fi

    #Don't send email, but write to stderr and exit with error value
    if [ ! -f $KOHA_BACKUP ] ; then
        echo "$KOHA_BACKUP was NOT successfully created." 1>&2
        exit 1
    #else
    #    echo "$KOHA_BACKUP was successfully created." | mail $USER -s $KOHA_BACKUP
    fi


    ### Archive Zebra indices ###
    tar -czf $BACKUPDIR/$ZEBRA_BACKUP_ARCHIVE -C $ZEBRA_INDICES_DIR .
    #Care about exceptions
    rc=$?; if [[ $rc != 0 ]]; then echo "gzip of Zebra indices failed" 1>&2; exit $rc; fi


    ### Push to Kätkölä ###
    # Remove latest-link,
    # put to server
    # reinstate latest-link. this link must be a hard link because the file is operated on outside the chroot jail.
    sftp katkola <<EOF
        cd private
        rm $KOHA_LATEST_BACKUP_ARCHIVE
        rm $KOHA_LATEST_BACKUP_ANONARCHIVE
        rm $ZEBRA_LATEST_BACKUP_ARCHIVE
        put $BACKUPDIR/$KOHA_BACKUP_ARCHIVE        $KOHA_BACKUP_ARCHIVE
        put $BACKUPDIR/$KOHA_BACKUP_ANONARCHIVE    $KOHA_BACKUP_ANONARCHIVE
        put $BACKUPDIR/$ZEBRA_BACKUP_ARCHIVE       $ZEBRA_BACKUP_ARCHIVE
        ln $KOHA_BACKUP_ARCHIVE                 $KOHA_LATEST_BACKUP_ARCHIVE
        ln $KOHA_BACKUP_ANONARCHIVE             $KOHA_LATEST_BACKUP_ANONARCHIVE
        ln $ZEBRA_BACKUP_ARCHIVE                $ZEBRA_LATEST_BACKUP_ARCHIVE
EOF
    #Care about exceptions
    rc=$?; if [[ $rc != 0 ]]; then echo "sftp to Kätkölä failed" 1>&2; exit $rc; fi


    ### Cleanup ###
    rm $BACKUPDIR/$KOHA_BACKUP_ARCHIVE $BACKUPDIR/$KOHA_BACKUP_ANONARCHIVE
    rc=$?; if [[ $rc != 0 ]]; then echo "Cleaning DB dump failed" 1>&2; exit $rc; fi
    rm $BACKUPDIR/$ZEBRA_BACKUP_ARCHIVE
    rc=$?; if [[ $rc != 0 ]]; then echo "Cleaning Zebra indices dump failed" 1>&2; exit $rc; fi
}

#
#Fetch backups from Kätkölä and start importing them
#
function import {
    ##Download DB backup from Kätkölä. They are prepared there by Ansible or by somebody else
    echo "get /private/$IMPORT_KOHA_BACKUP_ARCHIVE    $BACKUPDIR/" | /usr/bin/sftp katkola
    #Care about exceptions
    ps=(${PIPESTATUS[@]}) #Why is PIPESTATUS emptied when it gets read once?  Copy it as array
    if [[ ${ps[0]} != 0 ]]; then
        echo "echo failed :)" 1>&2; exit ${ps[0]};
    elif [[ ${ps[1]} != 0 ]]; then
        echo "Fetching DB dump from Kätkölä failed" 1>&2; exit ${ps[1]};
    fi
    ##Download Zebra backup from Kätkölä. They are prepared there by Ansible or by somebody else
    echo "get /private/$IMPORT_ZEBRA_BACKUP_ARCHIVE   $BACKUPDIR/" | /usr/bin/sftp katkola
    ps=(${PIPESTATUS[@]}) #Why is PIPESTATUS emptied when it gets read once?  Copy it as array
    if [[ ${ps[0]} != 0 ]]; then
        echo "echo failed :)" 1>&2; exit ${ps[0]};
    elif [[ ${ps[1]} != 0 ]]; then
        echo "Fetching Zebra dump from Kätkölä failed" 1>&2; exit ${ps[1]};
    fi

    #Handling pipestatus with sftp doesn't work nicely, so manually check if fetches work
    if [ ! -e $BACKUPDIR/$IMPORT_KOHA_BACKUP_ARCHIVE ]; then
        echo "Fetching DB dump from Kätkölä failed" 1>&2; exit 2
    fi
    if [ ! -e $BACKUPDIR/$IMPORT_ZEBRA_BACKUP_ARCHIVE ]; then
        echo "Fetching Zebra dump from Kätkölä failed" 1>&2; exit 2
    fi


    ### Import to DB ###
    echo "Recreate MariaDB database"
    /usr/bin/mysql -e "DROP DATABASE $DATABASE; CREATE DATABASE $DATABASE;"
    rc=$?; if [[ $rc != 0 ]]; then echo "DROP CREATE database failed" 1>&2; exit $rc; fi

    echo "Gunzip and migrate backup"
    /bin/gunzip    -c "$BACKUPDIR/$IMPORT_KOHA_BACKUP_ARCHIVE" | /usr/bin/mysql
    ps=(${PIPESTATUS[@]}) #Why is PIPESTATUS emptied when it gets read once?  Copy it as array
    if [[ ${ps[0]} != 0 ]]; then
        echo "Gunzipping Koha DB backup failed" 1>&2; exit ${ps[0]};
    elif [[ ${ps[1]} != 0 ]]; then
        echo "Importing to MariaDB failed" 1>&2; exit ${ps[1]};
    fi


    ### Unpack Zebra indices ###
    echo "Untarring Zebra indices"
    /bin/tar -xzf   "$BACKUPDIR/$IMPORT_ZEBRA_BACKUP_ARCHIVE" -C $ZEBRA_INDICES_DIR
    rc=$?; if [[ $rc != 0 ]]; then echo "Untaring indices failed" 1>&2; exit $rc; fi



    ### Cleanup ###
    echo "Removing DB dump"
    /bin/rm "$BACKUPDIR/$IMPORT_KOHA_BACKUP_ARCHIVE"
    rc=$?; if [[ $rc != 0 ]]; then echo "Cleaning the DB dump failed" 1>&2; exit $rc; fi

    echo "Removing indices dump"
    /bin/rm         "$BACKUPDIR/$IMPORT_ZEBRA_BACKUP_ARCHIVE"
    rc=$?; if [[ $rc != 0 ]]; then echo "Cleaning the indices dump failed" 1>&2; exit $rc; fi

}

case "$ACTION" in
import)
    echo "Importing from Kätkölä"
    import
    ;;
export)
    echo "Exporting to Kätkölä"
    export
    ;;
*)
    echo "Bad \$ACTION, supported [import, export]"
    help_usage
    exit 1
    ;;
esac
