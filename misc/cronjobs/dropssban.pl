#!/usr/bin/perl
# DropSSBAN.pl - Written by Pasi Korkalo
# Copyright (C)2017 Koha-Suomi Oy
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# This cronjob will drop self service ban on patrons birthday (i.e.
# when they become adults).

# The cronjob will need run every night for the bans to be dropped
# correctly, something like this in crontab should do the trick:

# 01 00 * * * $KOHA_PATH/misc/cronjobs/DropSSBAN.pl --confirm 16

# That would drop the ban when the patron turns 16.

use utf8;
use strict;
use C4::Context;

my $confirm;

if ($ARGV[0] eq "-c" || $ARGV[0] eq "--confirm") {
  $confirm=1;
  shift
}

if (! defined $ARGV[0]) {
  print "You need to provide age as an argument.\n";
  exit 0;
}

my @lt=localtime();
my $year=$lt[5] + 1900;
my $birthyear=$year - $ARGV[0];
my $month=sprintf("%02d", $lt[4] + 1);
my $day=sprintf("%02d", $lt[3]);

my $dbh=C4::Context->dbh();
my $sth=$dbh->prepare("SELECT borrowernumber FROM borrower_attributes WHERE borrowernumber in (SELECT borrowernumber FROM borrowers WHERE dateofbirth<? AND (code='OMATO' OR code='SSBAN') AND (attribute='HUOLTAJA' OR attribute='GUARANTOR'));");
$sth->execute("$birthyear-$month-$day");

while (my @borrowernumber = $sth->fetchrow_array) {
  print "$year-$month-$day: Dropping Self-service ban from patron: $borrowernumber[0]\n";
  if (defined $confirm) {
    my $sth=$dbh->do("DELETE FROM borrower_attributes WHERE borrowernumber='$borrowernumber[0]' AND (code='OMATO' OR code='SSBAN') AND (attribute='HUOLTAJA' OR attribute='GUARANTOR');");
  }
}
