#!/bin/sh
# A Quick and dirty fix for biblionumber/biblioitemnumber mismatch. 
# This will fix the acute problem (hopefully), but it won't fix the cause.
# Written by Pasi Korkalo / Koha-Suomi Oy

# Poetic License (2005) by Alexander E. Genaud

# This work 'as-is' we provide.
# No warranty express or implied.
     # We've done our best,
     # to debug and test.
# Liability for damages denied.
 
# Permission is granted hereby,
# to copy, share, and modify.
     # Use as is fit,
     # free or for profit.
# These rights, on this notice, rely.

# Nag about missing dependencies 
depsfail() { echo "You need xmllint, libxml2 and mysql client."; }

export xmllint="$(which xmllint)"
test -z $xmllint && depsfail && exit 1

export mysql="$(which mysql)"
test -z $mysql && depsfail && exit 1

# Get conf
getconf() { $xmllint --xpath "yazgfs/config/$1/text()" $KOHA_CONF; }

test -z $KOHA_CONF && echo "No KOHA_CONF?" && exit 1

dbscheme="$(getconf db_scheme)"
test "$dbscheme" != "mysql" && echo "Whoa! I don't know how to do queries to ${database}." && exit 1

database="$(getconf database)"
dbhost="$(getconf hostname)"
dbport="$(getconf port)"
dbuser="$(getconf user)"
passwd="$(getconf pass)"

printf "" > do_realignment.sql
test -n "$DEBUG" && printf "" > mismatch.log

# Fix auto_increment if there is a gap

b_auto_increment=$(mysql --host $dbhost -u$dbuser -p$passwd $database -NBe "SELECT auto_increment FROM information_schema.tables WHERE table_schema='$database' AND table_name='biblio';")
bi_auto_increment=$(mysql --host $dbhost -u$dbuser -p$passwd $database -NBe "SELECT auto_increment FROM information_schema.tables WHERE table_schema='$database' AND table_name='biblioitems';")

if test $b_auto_increment -gt $bi_auto_increment; then
  printf "ALTER TABLE biblioitems auto_increment=$b_auto_increment;\n" >> do_realignment.sql
elif test $b_auto_increment -lt $bi_auto_increment; then
  printf "I don't know how to fix this mess.\n"
  exit 1
fi

# Re-align misaligned biblios/biblioitems
printf "Re-aligning for database $database...\n"

foo=$b_auto_increment

IFS='
'
for misalign in $(mysql --host $dbhost -u$dbuser -p$passwd $database -NBe "SELECT biblioitemnumber,biblionumber FROM biblioitems WHERE biblionumber!=biblioitemnumber ORDER BY 1 DESC;"); do
  biblioitemnumber="${misalign%	*}"
  biblionumber="${misalign#*	}"
  test -n "$DEBUG" && printf "$biblionumber $biblioitemnumber $(($biblioitemnumber - $biblionumber))\n"
  if test $(($biblioitemnumber - $biblionumber)) -lt 0; then
    printf "UPDATE biblioitems SET biblioitemnumber=$biblionumber WHERE biblioitemnumber=$biblioitemnumber;\n" >> do_realignment.sql
    printf "UPDATE items SET biblioitemnumber=$biblionumber WHERE biblioitemnumber=$biblioitemnumber;\n" >> do_realignment.sql
  else
    printf "\n# This looks weird\n" >> do_realignment.sql
    printf "UPDATE biblio SET biblionumber=$foo WHERE biblionumber=$biblionumber;\n" >> do_realignment.sql
    printf "UPDATE biblioitems SET biblioitemnumber=$foo,biblionumber=$foo WHERE biblioitemnumber=$biblioitemnumber;\n" >> do_realignment.sql
    printf "UPDATE items SET biblioitemnumber=$foo,biblioitemnumber=$foo WHERE biblioitemnumber=$biblioitemnumber;\n" >> do_realignment.sql
    printf "UPDATE reserves SET biblionumber=$foo WHERE biblionumber=$biblionumber;\n" >> do_realignment.sql
    printf "\n" >> do_realignment.sql
    foo=$(($foo + 1))
   fi
done
unset IFS

printf "Ok, now run do_realignment.sql in your database. Good luck!\n"

exit 0
