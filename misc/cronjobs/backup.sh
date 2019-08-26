#!/bin/bash
# Script to create daily backups of the Koha database.
# Loosely based on a script by John Pennington

#Systemd-triggered cronjobs cannot source /etc/environment
test -z "$KOHA_CONF" && echo "\$KOHA_CONF not set so sourcing the default environment" && source /etc/environment

#Piped programs set the $? (exit value) to the one that failed, instead of the last program's exit value
set -o pipefail

function help_usage {
  echo "This is the Koha-Suomi Koha backup script"
  echo "It backs up unanonymized and anonymized versions of Koha's DB, logs, files and"
  echo "Zebra indices to a local directory."
  echo "These can be forwarded to another server such as Kätkölä sftp-service."
  echo ""
  echo "EXAMPLES:"
  echo ""
  echo "  backup.sh --db --zebra --koha-conf $KOHA_CONF"
  echo ""
  echo "USAGE:"
  echo ""
  echo "  Parameters, getopt and $ENV:"
  echo ""
  echo "  --koha-conf  From which koha-conf.xml -file to pick the master configuration"
  echo "  $KOHA_CONF   for the Koha instance to backup"
  echo "               Defaults to \$KOHA_CONF='$KOHA_CONF'"
  echo ""
  echo "  --backup-dir Where to place all the archived backup targets?"
  echo "  BACKUP_DIR   Defaults to \$KOHA_CONF->backupdir"
  echo ""
  echo "  Export targets:"
  echo ""
  echo "  --cleanup    Removes all backup files and archives from the local backup dir"
  echo "  $CLEANUP"
  echo ""
  echo "  --db         Dumps the koha-database-name.sql.gz to backup dir"
  echo "  $ARCHIVE_DB"
  echo ""
  echo "  --zebra      Dumps the koha-database-name.zebra.tar.gz to backup dir"
  echo "  $ARCHIVE_ZEBRA"
  echo ""
  echo "  --logs       Dumps the Koha logs to backup dir"
  echo "  $ARCHIVE_LOGS"
  echo ""
  echo "  --syslogs    Dumps the system logs to backup dir"
  echo "  $ARCHIVE_SYSLOGS"
  echo ""
  echo "  --files      Dumps the Koha plugin files to backup dir"
  echo "  $ARCHIVE_FILES"
  echo ""
  echo "  Export modifiers:"
  echo ""
  echo "  --anonymize  Anonymize the exported database dump"
  echo "  $ANONYMIZE"
  echo ""
  echo "  --verbose    Verbose output"
  echo "  $VERBOSE"
  echo ""
  echo "  --help       This fancy help"
  echo "  $HELP"
  echo ""
  exit 0
}

OPTS=`getopt --longoptions koha-conf:,backup-dir:,cleanup,db,zebra,logs,syslogs,files,anonymize,verbose,help \
       --options     k:,b:,c,d,z,l,s,f,a,v,h -- "$@"`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi


while true; do
  case "$1" in
    -k | --koha-conf )   KOHA_CONF="$2";                    shift; shift ;;
    -b | --backup-dir )  BACKUP_DIR="$2";                   shift; shift ;;
    -c | --cleanup )     CLEANUP="CLEANUP";                 shift ;;
    -d | --db )          ARCHIVE_DB="ARCHIVE_DB";           shift ;;
    -z | --zebra )       ARCHIVE_ZEBRA="ARCHIVE_ZEBRA";     shift ;;
    -l | --logs )        ARCHIVE_LOGS="ARCHIVE_LOGS";       shift ;;
    -s | --syslogs )     ARCHIVE_SYSLOGS="ARCHIVE_SYSLOGS"; shift ;;
    -f | --files )       ARCHIVE_FILES="ARCHIVE_FILES";     shift ;;
    -a | --anonymize )   ANONYMIZE="ANONYMIZE";             shift ;;
    -v | --verbose )     VERBOSE=true;                      shift ;;
    -h | --help )        HELP=true;                         shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

test -z "$KOHA_CONF" && echo "\$KOHA_CONF not defined! Check your environment!" && exit 2
test -z "$BACKUP_DIR" && BACKUP_DIR="$( xmlstarlet sel -t -v 'yazgfs/config/backupdir' $KOHA_CONF )"

KOHA_LOG_DIR="$( xmlstarlet sel -t -v 'yazgfs/config/logdir' $KOHA_CONF )"
SYSTEM_LOG_DIR="/var/log"
PLUGINS_DIR="$( xmlstarlet sel -t -v 'yazgfs/config/pluginsdir' $KOHA_CONF )"

DATABASE=`xmlstarlet sel -t -v 'yazgfs/config/database' $KOHA_CONF`
HOSTNAME=`xmlstarlet sel -t -v 'yazgfs/config/hostname' $KOHA_CONF`
PORT=`xmlstarlet sel -t -v 'yazgfs/config/port' $KOHA_CONF`
USER=`xmlstarlet sel -t -v 'yazgfs/config/user' $KOHA_CONF`
PASS=`xmlstarlet sel -t -v 'yazgfs/config/pass' $KOHA_CONF`
ZEBRA_INDICES_DIR=`dirname $(xmlstarlet sel -t -v 'yazgfs/server[@id="biblioserver"]/directory' $KOHA_CONF)`

KOHA_DATE=`date '+%Y%m%d'`
KOHA_BACKUP_ARCHIVE=$DATABASE.$KOHA_DATE.tar.gz
KOHA_LATEST_BACKUP_ARCHIVE=$DATABASE.latest.sql.gz
KOHA_LATEST_BACKUP_ANONARCHIVE=$DATABASE.latest.anon.sql.gz
DB_BACKUP_FILE=$DATABASE.$KOHA_DATE.sql
DB_BACKUP_ARCHIVE=$DATABASE.$KOHA_DATE.sql.gz
DB_BACKUP_ANONFILE=$DATABASE.$KOHA_DATE.anon.sql
DB_BACKUP_ANONARCHIVE=$DATABASE.$KOHA_DATE.anon.sql.gz
LOGS_BACKUP_ARCHIVE=$DATABASE.$KOHA_DATE.logs.tar.gz
SYSLOGS_BACKUP_ARCHIVE=$DATABASE.$KOHA_DATE.syslogs.tar.gz
ZEBRA_BACKUP_ARCHIVE=$DATABASE.$KOHA_DATE.zebra.tar.gz
ZEBRA_LATEST_BACKUP_ARCHIVE=$DATABASE.latest.zebra.tar.gz
FILES_BACKUP_ARCHIVE=$DATABASE.$KOHA_DATE.files.tar.gz

if [ ! $(whoami) == 'root' ]; then
  echo "Run this script as root or with sudo."
  exit 3
fi

## Tar complains
#     tar: Removing leading `/' from member names
# for absolute paths.
# De-absolutize paths to prevent complaining
function tarRootWorkaround {
  path=$1
  if [ `echo "$path" | grep -Pi '^/'` ]; then
    path=`echo "$path" | cut -c 2-` #Strip leading / to de-absolutize path, so tar doesn't need to complain about trimming absolute paths
    TAR_WORKAROUND_DIR="-C / $path"
  else
    TAR_WORKAROUND_DIR=$path
  fi
}

function archive_db {
  test -n "$VERBOSE" && echo "Archiving DB of '$DATABASE'"

  ### Extract DB dump ###
  #--quick is recommended to be used on big tables
  #--single-transaction does the exporting in a locked-state transaction while the
  #  other operations on the background can keep committing
  MYSQLDUMP_CMD="mysqldump --quick --single-transaction --user=$USER --password=$PASS --port=$PORT --host=$HOSTNAME $DATABASE"

  if [ ! -z "$ANONYMIZE" ]; then
    $MYSQLDUMP_CMD > $BACKUP_DIR/$DB_BACKUP_FILE
    rc=$?; if [[ $rc != 0 ]]; then echo "mysqldump failed" 1>&2; exit $rc; fi

    sqlanonymize --in $BACKUP_DIR/$DB_BACKUP_FILE --out - | gzip -9 > $BACKUP_DIR/$DB_BACKUP_ANONARCHIVE
    #Care about exceptions
    ps=(${PIPESTATUS[@]}) #Why is PIPESTATUS emptied when it gets read once?  Copy it as array
    if   [[ ${ps[0]} != 0 ]]; then
        echo "sqlanonymize failed" 1>&2; exit ${ps[0]};
    elif [[ ${ps[1]} != 0 ]]; then
        echo "Anonymized DB gzip failed" 1>&2; exit ${ps[1]};
    fi

    gzip -9 $BACKUP_DIR/$DB_BACKUP_FILE -c > $BACKUP_DIR/$DB_BACKUP_ARCHIVE
    rc=$?; if [[ $rc != 0 ]]; then echo "gzip of DB backup failed" 1>&2; exit $rc; fi

  else
    $MYSQLDUMP_CMD | gzip -9 > $BACKUP_DIR/$DB_BACKUP_ARCHIVE
    #Care about exceptions
    ps=(${PIPESTATUS[@]}) #Why is PIPESTATUS emptied when it gets read once?  Copy it as array
    if   [[ ${ps[0]} != 0 ]]; then
        echo "mysqldump failed" 1>&2; exit ${ps[0]};
    elif [[ ${ps[1]} != 0 ]]; then
        echo "gzip of DB backup failed" 1>&2; exit ${ps[0]};
    fi
  fi

  #Don't send email, but write to stderr and exit with error value
  if [ ! -f $BACKUP_DIR/$DB_BACKUP_ARCHIVE ] ; then
    echo "\DB backup was NOT successfully created." 1>&2
    exit 1
  #else
  #    echo "$KOHA_BACKUP was successfully created." | mail $USER -s $KOHA_BACKUP
  fi
}

function archive_zebra {
  test -n "$VERBOSE" && echo "Archiving Zebra index of '$DATABASE'"

  ### Archive Zebra indices ###
  tarRootWorkaround "$ZEBRA_INDICES_DIR"
  tar -czf "$BACKUP_DIR/$ZEBRA_BACKUP_ARCHIVE" $TAR_WORKAROUND_DIR
  #Care about exceptions
  rc=$?; if [[ $rc != 0 ]]; then echo "tar gzip of Zebra indices failed" 1>&2; exit $rc; fi
}

function archive_logs {
  test -n "$VERBOSE" && echo "Archiving Logs of '$DATABASE'"

  tarRootWorkaround "$KOHA_LOG_DIR"
  tar -czf "$BACKUP_DIR/$LOGS_BACKUP_ARCHIVE" $TAR_WORKAROUND_DIR
  #Care about exceptions
  rc=$?; if [[ $rc != 0 ]]; then echo "tar gzip of Koha logs failed" 1>&2; exit $rc; fi
}

function archive_syslogs {
  test -n "$VERBOSE" && echo "Archiving Syslogs of '$DATABASE'"

  tarRootWorkaround "$SYSTEM_LOG_DIR"
  tar -czf "$BACKUP_DIR/$SYSLOGS_BACKUP_ARCHIVE" $TAR_WORKAROUND_DIR
  #Care about exceptions
  rc=$?; if [[ $rc != 0 ]]; then echo "tar gzip of system logs failed" 1>&2; exit $rc; fi
}

function archive_files {
  test -n "$VERBOSE" && echo "Archiving Files of '$DATABASE'"

  tarRootWorkaround="$PLUGINS_DIR"
  tar -czf "$BACKUP_DIR/$FILES_BACKUP_ARCHIVE" $TAR_WORKAROUND_DIR
  #Care about exceptions
  rc=$?; if [[ $rc != 0 ]]; then echo "tar gzip of Koha users' files failed" 1>&2; exit $rc; fi
}

function backup {
  SUB_ARCHIVES=""
  test ! -z "$ARCHIVE_DB"        && archive_db      && SUB_ARCHIVES="$SUB_ARCHIVES $DB_BACKUP_ARCHIVE"
  test ! -z "$ARCHIVE_ZEBRA"     && archive_zebra   && SUB_ARCHIVES="$SUB_ARCHIVES $ZEBRA_BACKUP_ARCHIVE"
  test ! -z "$ARCHIVE_LOGS"      && archive_logs    && SUB_ARCHIVES="$SUB_ARCHIVES $LOGS_BACKUP_ARCHIVE"
  test ! -z "$ARCHIVE_SYSLOGS"   && archive_syslogs && SUB_ARCHIVES="$SUB_ARCHIVES $SYSLOGS_BACKUP_ARCHIVE"
  test ! -z "$ARCHIVE_FILES"     && archive_files   && SUB_ARCHIVES="$SUB_ARCHIVES $FILES_BACKUP_ARCHIVE"

  if [ ! -z "$SUB_ARCHIVES" ]; then
    test -n "$VERBOSE" && echo "Archiving a complete backups bundle of '$DATABASE'"

    tar -czf $BACKUP_DIR/$KOHA_BACKUP_ARCHIVE -C $BACKUP_DIR $SUB_ARCHIVES
    rc=$?; if [[ $rc != 0 ]]; then echo "tar gzip of collection of backup archives failed" 1>&2; exit $rc; fi

    for ARCHIVE in $SUB_ARCHIVES; do
      rm $BACKUP_DIR/$ARCHIVE
      rc=$?; if [[ $rc != 0 ]]; then echo "rm of archive '$ARCHIVE' failed" 1>&2; exit $rc; fi
    done

    echo "Outputing some information, of the backup run as a stableinterface for external scripts doing backuping of Koha, to parse:"
    echo "- Archived a backup to file \"$BACKUP_DIR/$KOHA_BACKUP_ARCHIVE\""
    echo ""
  fi

}

function cleanup {
  test -n "$VERBOSE" && echo "Cleaning backup dir '$BACKUP_DIR' of Koha instance '$DATABASE' backup archives."

  rm $BACKUP_DIR/$DATABASE.*
}



if [ ! -z "$CLEANUP" ]; then
  cleanup
fi

backup
