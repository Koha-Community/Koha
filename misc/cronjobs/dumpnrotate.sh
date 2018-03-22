#!/bin/sh
# Dumprotate V180322 - Simple rotating database dumping using mysqldump
# Written by Pasi Korkalo / Koha-Suomi Oy

# GPL3 on later applies.

# The dumping is done in three parts so that schema, data and "extra" will
# be separated. You can also make "partial" dumps that do not contain all
# three. See the configuration files (dailydump.conf and hourlydump.conf)
# for how.

# When building new databases from dumps, follow this:

# 1) Run schema into a new database

# 2) Drop triggers from the database if you plan on inserting actual data.
#    The triggers will be included in data as well as schema, so inserting
#    data will fail if the triggers from the schema are already in place.
#    Unfortunately I know of no way to exclude them from one or another.

# 3) Run data into a new database

# 4) Run extra into a new database if you want statistical information and
#    such to be included also.

expiredumps() {
  IFS='
'
  for file in $(ls -rt ${1}*.sql* 2> /dev/null); do
    test $(ls ${1}*.sql* | wc -l) -le $2 && echo "$(date) Preserving $2 $1 files, no more files to remove." && break
    echo "$(date) $(rm -v $file)"
  done
  unset IFS
}

# Get the config here. For examples see hourlydump.conf and dailydump.conf.
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
