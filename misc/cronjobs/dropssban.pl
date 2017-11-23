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

# 01 00 * * * $KOHA_PATH/misc/cronjobs/DropSSBAN.pl --confirm [--not-accepted]

# With --not-accepted parameter the block will be turned into
# "Terms and conditions not accepted" and the borrower will have to
# explicitly agree to self service terms when (s)he becomes an adult.

use utf8;
use strict;
use C4::Context;

my $confirm;
my $notaccepted;

foreach (@ARGV) {
    if ( "$_" eq "-c" || "$_" eq "--confirm" ) {
        $confirm = 1;
      } elsif ( "$_" eq "-n" || "$_" eq "--not-accepted" ) {
        $notaccepted = 1;
      };
}

# Get age from system preference
my $dbh=C4::Context->dbh();
my $sth_ssrules=$dbh->prepare ( "SELECT value FROM systempreferences WHERE variable='SSRules'" );
$sth_ssrules->execute();

my @ssrules = $sth_ssrules->fetchrow_array();
$sth_ssrules->finish();

@ssrules=split (':', $ssrules[0]);
my $age=$ssrules[0];

my @lt        = localtime();
my $year      = $lt[5] + 1900;
my $birthyear = $year - $age;
my $month     = sprintf( "%02d", $lt[4] + 1 );
my $day       = sprintf( "%02d", $lt[3] );

my $sth_modify = $dbh->prepare( "SELECT borrowernumber FROM borrower_attributes WHERE borrowernumber in (SELECT borrowernumber FROM borrowers WHERE dateofbirth<? AND code='SSBAN' AND attribute='NOPERMISSION');" );
$sth_modify->execute("$birthyear-$month-$day");

while ( my @borrowernumber = $sth_modify->fetchrow_array ) {
    print "$year-$month-$day: Modifying Self-service ban of patron: $borrowernumber[0]\n";
    if ( defined $confirm ) {
        if ( defined $notaccepted ) {
            $dbh->do( "UPDATE borrower_attributes WHERE borrowernumber='$borrowernumber[0]' AND code='SSBAN' AND attribute='NOTACCEPTED');" );
        }
        else {
            $dbh->do( "DELETE FROM borrower_attributes WHERE borrowernumber='$borrowernumber[0]' AND code='SSBAN' AND attribute='NOPERMISSION');" );
        }
    }
}
