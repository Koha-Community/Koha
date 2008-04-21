#!/usr/bin/perl

# Copyright 2007 Paul POULAIN
#
# This file is part of Koha
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;    # always use

use XML::RSS;
use Digest::MD5 qw(md5_base64);
# use POSIX qw(ceil floor);
use Date::Calc qw(Today_and_Now Delta_YMDHMS);
use C4::Context;
use C4::Search;
use C4::Koha;
use C4::Biblio;
use Cwd;

=head1 NAME

opac-rss.pl : script to have RSS feeds automatically on each OPAC search

=head1 SYNOPSIS

on each query (on OPAC), a link to this script is automatically added. The user can save it's queries as RSS feeds.
This script :

=over 4

  - build the RDF file from the query
  - save the RDF file in a opac/rss directory for caching : the RDF is calculated only once every 30mn, and the cache file name is calculated by a md5_base64 of the query (each user registering the same query will use the same cache : speed improvement)
  - let the user specify it's query (q parameter : opac-rss.pl?q=ti:hugo)
  - let the user specify the number of results returned (by default 20, but there are no limits : opac-rss.pl?q=ti:hugo&size=9999)

This script auto calculates the website URL

the RDF contains : 

=over 4

  - Koha: $query as RSS title
  - Koha as subject
  - LibraryName systempreference as RDF description and creator
  - copyright currentyear
  - biblio title as RSS "title" and biblio author as RSS description

=cut

# create a new CGI object
# not sure undef_params option is working, need to test
use CGI qw('-no_undef_params');
my $cgi = new CGI;

# the query to use
my $query = $cgi->param('q');
$query =~ s/:/=/g;

# the number of lines to retrieve
my $size = $cgi->param('size') || 50;

# the filename of the cached rdf file.
my $filename = md5_base64($query);
$filename =~ s/\///g;
my $rss = new XML::RSS(
		version  => '1.0',
		encoding => C4::Context->preference("TemplateEncoding"),
		output   => C4::Context->preference("TemplateEncoding"),
		language => C4::Context->preference('opaclanguages')
);

# the site URL
my $url = $cgi->url();
$url =~ s/opac-rss\.pl.*//;
$url =~ /(http:\/\/.*?)\//;
my $short_url = $1;

my $RDF_update_needed = 1;
my ( $year, $month, $day, $hour, $min, $sec ) = Today_and_Now();

if ( -e "rss/$filename" ) {
    $rss->parsefile("rss/$filename");

# check if we have to rebuild the RSS feed (once every 30mn), or just return the actual rdf
    my $rdf_stamp = $rss->{'channel'}->{'dc'}->{'date'};
    my ( $stamp_year, $stamp_month, $stamp_day, $stamp_hour, $stamp_min, $stamp_sec ) =
       ( $rdf_stamp =~ /(.*)-(.*)-(.*):(.*):(.*):(.*)/ );

# if more than 30 mn since the last RDF update, rebuild the RDF. Otherwise, just return it
    unless(( $year  - $stamp_year  >  0 )
        or ( $month - $stamp_month >  0 )
        or ( $day   - $stamp_day   >  0 )
        or ( $hour  - $stamp_hour  >  0 )
        or ( $min   - $stamp_min   > 30 ))
    {
        $RDF_update_needed = 0;
    }
}

if ($RDF_update_needed) {

    #     warn "RDF update in progress";
    utf8::decode($query);
    my $libname = C4::Context->preference("LibraryName");
    $rss->channel(
        title       => "Koha: $query",
        description => $libname,
        link        => $short_url,
        dc          => {
            date     => "$year-$month-$day:$hour:$min:$sec",
            subject  => "Koha",
            creator  => $libname,
            rights   => "Copyright $year",
            language => C4::Context->preference("opaclanguages"),
        },
    );

    warn "fetching $size results for $query";
    my ( $error, $marcresults, $total_hits ) = SimpleSearch( $query, 0, $size );  # FIXME: Simple Search should die!

    my $hits = scalar @$marcresults;
    my @results;
    for ( my $i = 0 ; $i < $hits ; $i++ ) {
        my %resultsloop;
        my $marcrecord = MARC::File::USMARC::decode( $marcresults->[$i] );
        my $biblio = TransformMarcToKoha( C4::Context->dbh, $marcrecord, '' );

# check if the entry is already in the feed. Otherwise, pop the $line th line and add this new one.
        my $already_in_feed = 0;
        foreach ( @{ $rss->{'items'} } ) {
            if ( $_->{'link'} =~ /biblionumber=$biblio->{'biblionumber'}/ ) {
                $already_in_feed = 1;
            }
        }
        unless ($already_in_feed) {
            pop( @{ $rss->{'items'} } ) if ( @{ $rss->{'items'} } >= $size );
            utf8::decode($biblio->{'title'});
            utf8::decode($biblio->{'author'});
            $rss->add_item(
                title       => $biblio->{'title'},
                description => $biblio->{'author'},
                link        => "$url/opac-detail.pl?biblionumber="
                  . $biblio->{'biblionumber'},
                mode => 'insert',
            );
        }
    }

    # save the rss feed.
	# (-w "rss/$filename") or die "Cannot write " . cwd() . "/rss/$filename";
    # $rss->save("rss/$filename");
}
print $cgi->header( -type => "application/rss+xml" );
print $rss->as_string;
