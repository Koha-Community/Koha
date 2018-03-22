#!/bin/sh
# Dumprotate V180322 - Simple rotating database dumping using mysqldump
# Written by Pasi Korkalo / Koha-Suomi Oy

# GPL3 on later applies.

# Get configuration, you can place your configs in a directory of your choice.
# /etc/dumpdatabases/ would be a reasonable candidate

expiredumps() {
  IFS='
  '
  for file in $(ls -rt ${1}*.sql* 2> /dev/null); do
    test $(ls ${1}*.sql* | wc -l) -le $2 && echo "$(date) Preserving $2 $1 files, no more files to remove." && break
    echo "$(date) $(rm -v $file)"
  done
  unset IFS
}

# For examples see hourlydump.conf and dailydump.conf.
if test -e "$1"; then
  . "$1"
else
  echo "Enter the name of the configuration file."
  exit 1
fi

# Nag about missing parameters.
if test -z "$databasename" || test -z "$dumpdir"; then
  echo "Some of the required variables are not defined in the configuration file."
  exit 1
fi

# Use database username and password if they're defined
test -n "$databaseuser" && databaseuser="-u$databaseuser"
test -n "$databasepasswd" && databasepasswd="-p$databasepasswd"

# Keep 100000 dumps if nothing defined
test $keepnumber -ge 0 2> /dev/null || keepnumber="100000"

# Ensure that we have the target directory for the dump + restrict permissions for the dir and dumps.
umask 077; mkdir -p $dumpdir

timestamp="$(date +%y%m%d%H%M)"

# Handle dumps.
if test "$getschema" = "1"; then
  expiredumps $dumpdir/${databasename}_schema_ $keepnumber
  echo "$(date) Dumping $databasename schema to $dumpdir/${databasename}_schema_${timestamp}.sql"
  mysqldump $databaseuser $databasepasswd --no-data --skip-lock-tables --single-transaction $databasename | gzip > $dumpdir/${databasename}_schema_${timestamp}.sql.gz
fi

if test "$getdata" = "1"; then
  expiredumps $dumpdir/${databasename}_data_ $keepnumber
  echo "$(date) Dumping $databasename data to $dumpdir/${databasename}_data_${timestamp}.sql"
  mysqldump $databaseuser $databasepasswd --no-create-info --skip-lock-tables --ignore-table=${databasename}.statistics --ignore-table=${databasename}.zebraqueue --ignore-table=${databasename}.action_logs --single-transaction $databasename | gzip > $dumpdir/${databasename}_data_${timestamp}.sql.gz
fi

if test "$getextra" = "1"; then
  expiredumps $dumpdir/${databasename}_extra_ $keepnumber
  echo "$(date) Dumping $databasename extra data to $dumpdir/${databasename}_extra_${timestamp}.sql"
  mysqldump $databaseuser $databasepasswd --no-create-info --skip-lock-tables --single-transaction $databasename statistics zebraqueue action_logs | gzip > $dumpdir/${databasename}_extra_${timestamp}.sql.gz
fi

# All done
echo "$(date) Dumped."

exit 0
