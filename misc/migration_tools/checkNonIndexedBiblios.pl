#!/usr/bin/perl

# Copyright 2012 BibLibre
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

# Small script that checks if each biblio in the DB is properly indexed
# if it is not and if you use -z the not-indexed biblios are inserted in zebraqueue
# To test just ommit the -z option you will have the biblionumber of non-indexed biblios and the total

use strict;

BEGIN {

    # find Koha's Perl modules
    # test carefully before changing this
    use FindBin;
    eval { require "$FindBin::Bin/kohalib.pl" };
}

# Koha modules used
use MARC::Record;
use C4::Context;
use C4::Search;
use Getopt::Long;

my ( $help, $confirm, $zebraqueue, $silent,$stealth );

GetOptions(
    'c' => \$confirm,
    'h' => \$help,
    'z' => \$zebraqueue,
    's' => \$silent,
    'st' => \$stealth
);

if ( $help || ( !$confirm ) ) {
    print_usage();
    exit 0;
}

my $dbh = C4::Context->dbh;
my $i = 0;
my $count = 0;

# flushes output
$| = 1;

my $sth = $dbh->prepare("SELECT biblionumber FROM biblio");
my $sth_insert = $dbh->prepare("INSERT INTO zebraqueue (biblio_auth_number,operation,server,done) VALUES (?,'specialUpdate','biblioserver',0)");

# We get all biblios
$sth->execute;
my ($nbhits);

# We check for each biblio
while ( my ($biblionumber) = $sth->fetchrow ) {
    (undef,undef,$nbhits) = SimpleSearch("Local-number=$biblionumber");
    print "biblionumber $biblionumber not indexed\n" unless $nbhits || $stealth;
# If -z option we put the biblio in zebraqueue
    if ($zebraqueue && !$nbhits){
        $sth_insert->execute($biblionumber);
        print "$biblionumber inserted in zebraqueue\n" unless $stealth;
    }
    $i++;
    print "$i done\n" unless $i % 1000 || $silent || $stealth;
    $count++ unless $nbhits;
}

if ($count > 0 && $zebraqueue){
    print "\t$count bibliorecords not indexed and inserted in zebraqueue\n";
}
else{
    print "\t$count bibliorecords not indexed\n";
}

sub print_usage {
    print <<_USAGE_;
$0: This script takes all biblios and checks if they are indexed in zebra using biblionumber search.

parameters:
\th this help screen
\tc confirm (without this parameter, you get the help screen)
\tz inserts a signal in zebraqueue to force indexing of non indexed biblios otherwise you have only the check
\ts silent throws no warnings except for non indexed records. Otherwise throws a warn every 1000 biblios to show progress
\tst stealth do not print warnings for non indexed records and do not warn every 1000

Syntax:
\t./batchCheckNonIndexedBiblios.pl -h (or without arguments => shows this screen)
\t./batchCheckNonIndexedBiblios.pl -c (c like confirm => checks all records (may be long)
\t./batchCheckNonIndexedBiblios.pl -z (z like zebraqueue => inserts in zebraqueue. Without => test only, changes nothing in DB just warns)
\t./batchCheckNonIndexedBiblios.pl -s (s like silent => don't throws a warn every 1000 biblios to show progress)
\t./batchCheckNonIndexedBiblios.pl -st (s like stealth => don't throws a warn every 1000 biblios to show progress and no warn for the non indexed biblionumbers, just the total)
_USAGE_
}