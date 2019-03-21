#!/bin/sh

# Periodically clean zebra's tmp directories (remove files older than 2 days)
# Written by janPasi / Koha-Suomi Oy

die() { echo "$@" && exit 1 ; }

test -z "$KOHA_CONF" && die "No \$KOHA_CONF defined."
test -z $(which xmllint 2> /dev/null) && die "No xmllint. Please install libxml2-utils."

bibliodir="$(xmllint --xpath "yazgfs/server[@id='biblioserver']/directory/text()" $KOHA_CONF)/tmp"
biblioondiskdir=$(echo $bibliodir | sed 's/\/zebradb\/biblios/\/zebradb.ondisk\/biblios/')

authoritydir="$(xmllint --xpath "yazgfs/server[@id='authorityserver']/directory/text()" $KOHA_CONF)/tmp"
authorityondiskdir=$(echo $authoritydir | sed 's/\/zebradb\/authorities/\/zebradb.ondisk\/authorities/')

test "$bibliodir" = "$biblioondiskdir" && die "Can't determine ondisk biblio dir."
test "$authoritydir" = "$authorityondiskdir" && die "Can't determine ondisk authority dir."

dirs="$bibliodir:$biblioondiskdir:$authoritydir:$authorityondiskdir"

IFS=':'

for dir in $dirs; do
  if test -n "$dir" && test -d "$dir"; then 
    echo "\n$(date): Cleaning $dir"
    find $dir/ -name '*' -type f -mtime +2 -exec rm -v {} \;
  else
    echo "\n$(date): Directory $dir does not exist." 
  fi
done

unset IFS
exit 0
