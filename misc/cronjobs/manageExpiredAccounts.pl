#!/usr/bin/perl
# Written by Pasi Korkalo OUTI Kirjastot / Koha-Suomi Oy
# GNU GPL3 or later applies.

# Prevent patrons from logging in when their accounts
# are expired by blocking the passwords. Upon refreshing
# the account, the passwords will also be re-enabled.

# Enter the categorycode of patrons to manage as a
# parameter (for example STAFF).

# Put something like this in your crontab to have the
# password management happen automatically during library
# opening hours:

# */10 06-20 * * * $KOHA_PATH/misc/cronjobs/manageExpiredAccounts.pl STAFF

use strict;
use warnings;
use utf8;
use C4::Context;

# We need to know who to handle
unless (defined $ARGV[0]) {
  print "Enter patron category as a parameter.\n";
  exit 1;
}

# It just takes two update statements:
my $dbh=C4::Context->dbh();
$dbh->do("update borrowers set password=concat(\'!\', substring(password from 2)) where categorycode=\'$ARGV[0]\' and dateexpiry < now() and password like \'\$%\';");
$dbh->do("update borrowers set password=concat(\'\$\', substring(password from 2)) where categorycode=\'$ARGV[0]\' and dateexpiry >= now() and password like \'!%\';");

exit 0;
