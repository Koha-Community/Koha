#!/usr/bin/perl

#script to administer Authorities without biblio

# Copyright 2009 BibLibre
# written 2009-05-04 by paul dot poulain at biblibre.com
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use strict;
use warnings;

use C4::Context;
use C4::AuthoritiesMarc;
use Getopt::Long;

my @authtypes;
my $want_help = 0;
my $test = 0;
GetOptions(
    'aut|authtypecode:s' => \@authtypes,
    't|test'             => \$test,
    'h|help'             => \$want_help
);

if ($want_help) {
    print_usage();
    exit 0;
}

if ($test) {
    print "testing only, authorities will not be deleted.\n";
}

my $dbh=C4::Context->dbh;
my $thresholdmin=0;
my $thresholdmax=0;
my @results;
# prepare the request to retrieve all authorities of the requested types
my $rqsql = "SELECT * from auth_header where 1";
$rqsql .= " AND authtypecode IN (".join(",",map{$dbh->quote($_)}@authtypes).")" if @authtypes;
my $rqselect = $dbh->prepare($rqsql);
$|=1;

$rqselect->execute;
my $counter=0;
my $totdeleted=0;
my $totundeleted=0;
while (my $data=$rqselect->fetchrow_hashref){
    my $query;
    $query= "an=".$data->{'authid'};
    # search for biblios mapped
    my ($err,$res,$used) = C4::Search::SimpleSearch($query,0,10);
    if (defined $err) {
        warn "error: $err on search $query\n";
        next;
    }
    print ".";
    print "$counter\n" unless $counter++ % 100;
    # if found, delete, otherwise, just count
    if ($used>=$thresholdmin and $used<=$thresholdmax){
        DelAuthority($data->{'authid'}) unless $test;
        $totdeleted++;
    } else {
        $totundeleted++;
    }
}

print "$counter authorities parsed, $totdeleted deleted and $totundeleted unchanged because used\n";


sub print_usage {
    print <<_USAGE_;
$0: Remove unused authority records

This script removes authority records that do not have any biblio
records attached to them.

If the --aut option is supplied, only authority records of that
particular type will be checked for usage.  --aut can be repeated.

If --aut is not supplied, all authority records will be checked.

Use --test to perform a test run.  This script does not ask the
operator to confirm the deletion of each authority record.

parameters
    --aut|authtypecode TYPE       the list of authtypes to check
    --test or -t                  test mode, don't delete really, just count
    --help or -h                  show this message.

_USAGE_
}
