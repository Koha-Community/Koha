#!/usr/bin/perl

# Copyright 2010 BibLibre
# Copyright 2011 Equinox Software, Inc.
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
use warnings;

use C4::Context;
use C4::Biblio;
use Getopt::Long;

my ($wherestring, $run, $want_help);
my $result = GetOptions(
    'where:s'      => \$wherestring,
    '--run'        => \$run,
    'help|h'       => \$want_help,
);

if ( not $result or not $run or $want_help ) {
    print_usage();
    exit 0;
}

my $dbh = C4::Context->dbh;
my $querysth =  qq{SELECT biblionumber from biblioitems };
$querysth    .= " WHERE $wherestring " if ($wherestring);
my $query = $dbh->prepare($querysth);
$query->execute;
while (my $biblionumber = $query->fetchrow){
    my $record = GetMarcBiblio($biblionumber);
    
    if ($record) {
        ModBiblio($record, $biblionumber, GetFrameworkCode($biblionumber)) ;
    }
    else {
        print "error in $biblionumber : can't parse biblio";
    }
}

sub print_usage {
    print <<_USAGE_;
$0: removes items from selected biblios

This utility is meant to be run as part of the upgrade to
Koha 3.4.  It removes the 9XX fields in the bib records that
store a (now) duplicate copy of the item record information.  After
running this utility, a full reindexing of the bibliographic records
should be run using rebuild_zebra.pl -b -r.

Parameters:
    -where                  use this to limit modifications to selected biblios
    --run                   perform the update
    --help or -h            show this message
_USAGE_
}
