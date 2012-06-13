#!/usr/bin/perl

# Copyright 2012 BibLibre SARL
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

use Modern::Perl;
use Data::Dumper;
use Getopt::Long;
use LWP::Simple;
use XML::Simple;

use C4::Context;
use C4::Search;
use Koha::SearchEngine::Index;

$|=1; # flushes output

if ( C4::Context->preference("SearchEngine") ne 'Solr' ) {
    warn "System preference 'SearchEngine' not equal 'Solr'.";
    warn "We can not indexing";
    exit(1);
}

#Setup

my ( $reset, $number, $recordtype, $biblionumbers, $optimize, $info, $want_help );
GetOptions(
    'r'   => \$reset,
    'n:s' => \$number,
    't:s' => \$recordtype,
    'w:s' => \$biblionumbers,
    'o'   => \$optimize,
    'i'   => \$info,
    'h|help' => \$want_help,
);
my $debug = C4::Context->preference("DebugLevel");
my $index_service = Koha::SearchEngine::Index->new;
my $solrurl = $index_service->searchengine->config->SolrAPI;

my $ping = &ping_command;
if (!defined $ping) {
    print "SolrAPI = $solrurl\n";
    print "Solr is Down\n";
    exit(1);
}

#Script

&print_help if ($want_help);
&print_info if ($info);
if ($reset){
  if ($recordtype){
      &reset_index("recordtype:".$recordtype);
  } else {
      &reset_index("*:*");
  }
}

if (defined $biblionumbers){
    if (not defined $recordtype) { print "You must specify a recordtype\n"; exit 1;}
    &index_biblio($_) for split ',', $biblionumbers;
} elsif  (defined $recordtype) {
    &index_data;
    &optimise_index;
}

if ($optimize) {
    &optimise_index;
}

#Functions

sub index_biblio {
    my ($biblionumber) = @_;
    $index_service->index_record($recordtype, [ $biblionumber ] );
}

sub index_data {
    my $dbh = C4::Context->dbh;
        $dbh->do('SET NAMES UTF8;');

    my $query;
    if ( $recordtype eq 'biblio' ) {
      $query = "SELECT biblionumber FROM biblio ORDER BY biblionumber";
    } elsif ( $recordtype eq 'authority' ) {
      $query = "SELECT authid FROM auth_header ORDER BY authid";
    }
    $query .= " LIMIT $number" if $number;

    my $sth = $dbh->prepare( $query );
    $sth->execute();

    $index_service->index_record($recordtype, [ map { $_->[0] } @{ $sth->fetchall_arrayref } ] );

    $sth->finish;
}

sub reset_index {
    &reset_command;
    &commit_command;
    $debug eq '2' && &count_all_docs eq 0 && warn  "Index cleaned!"
}

sub commit_command {
    my $commiturl = "/update?stream.body=%3Ccommit/%3E";
    my $urlreturns = get $solrurl.$commiturl;
}

sub ping_command {
    my $pingurl = "/admin/ping";
    my $urlreturns = get $solrurl.$pingurl;
}

sub reset_command {
    my ($query) = @_;
    my $deleteurl = "/update?stream.body=%3Cdelete%3E%3Cquery%3E".$query."%3C/query%3E%3C/delete%3E";
    my $urlreturns = get $solrurl.$deleteurl;
}

sub optimise_index {
    $index_service->optimize;
}

sub count_all_docs {
    my $queryurl = "/select/?q=*:*";
    my $urlreturns = get $solrurl.$queryurl;
    my $xmlsimple = XML::Simple->new();
    my $data = $xmlsimple->XMLin($urlreturns);
    return $data->{result}->{numFound};
}

sub print_info {
    my $count = &count_all_docs;
    print <<_USAGE_;
SolrAPI = $solrurl
How many indexed documents = $count;
_USAGE_
}

sub print_help {
    print <<_USAGE_;
$0: reindex biblios and/or authorities in Solr.

Use this batch job to reindex all biblio or authority records in your Koha database.  This job is useful only if you are using Solr search engine.

Parameters:
    -t biblio               index bibliographic records

    -t authority            index authority records

    -r                      clear Solr index before adding records to index - use this option carefully!

    -n 100                  index 100 first records

    -n "100,2"              index 2 records after 100th (101 and 102)

    -w 101                  index biblio with biblionumber equals 101

    -o                      launch optimize command at the end of indexing

    -i                      gives solr install information: SolrAPI value and count all documents indexed

    --help or -h            show this message.
_USAGE_
}
