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

use Modern::Perl;

use Koha::Script;
use C4::Context;
use C4::AuthoritiesMarc;
use Getopt::Long;

use Koha::SearchEngine::Search;

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
    print "*** Testing only, authorities will not be deleted. ***\n";
}
if (@authtypes) {
    print "Restricted to authority type(s) : ".join(',', @authtypes).".\n";
}

my $errZebraConnection = C4::Context->Zconn("biblioserver",0)->errcode();
if ( $errZebraConnection == 10000 ) {
    die "Zebra server seems not to be available. This script needs Zebra runs.";
} elsif ( $errZebraConnection ) {
    die "Error from Zebra: $errZebraConnection";
}

my $dbh=C4::Context->dbh;
my @results;
# prepare the request to retrieve all authorities of the requested types
my $rqsql = q{ SELECT authid,authtypecode FROM auth_header };
$rqsql .= q{ WHERE authtypecode IN (}.join(',',map{ '?' }@authtypes).')' if @authtypes;
my $rqselect = $dbh->prepare($rqsql);
$|=1;

$rqselect->execute(@authtypes);
my $counter=0;
my $totdeleted=0;
my $totundeleted=0;
my $searcher = Koha::SearchEngine::Search->new({index => 'biblios'});
while (my $data=$rqselect->fetchrow_hashref){
    $counter++;
    print 'authid='.$data->{'authid'};
    print ' type='.$data->{'authtypecode'};
    my $bibliosearch = 'an:'.$data->{'authid'};
    # search for biblios mapped
    my ($err,$res,$used) = $searcher->simple_search_compat($bibliosearch,0,10);
    if (defined $err) {
        print "\n";
        warn "Error: $err on search for biblios $bibliosearch\n";
        next;
    }
    unless ($used > 0){
        unless ($test) {
            DelAuthority({ authid => $data->{'authid'} });
            print " : deleted";
        } else {
            print " : can be deleted";
        }
        $totdeleted++;
    } else {
        $totundeleted++;
        print " : used $used time(s)";
    }
    print "\n";
}

print "$counter authorities parsed\n";
unless ($test) {
    print "$totdeleted deleted because unused\n";
} else {
    print "$totdeleted can be deleted because unused\n";
}
print "$totundeleted unchanged because used\n";

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
