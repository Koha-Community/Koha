#!/usr/bin/perl

# script to search the plucene index of the database
# most of this will be shifted to a module when it moves out of the proof of concept stage

# $Id$

# Copyright 2005 Katipo Communications
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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,

use strict;

use Plucene::Search::IndexSearcher;
use Plucene::Plugin::Analyzer::PorterAnalyzer;
use Plucene::QueryParser;
use Plucene::Search::HitCollector;

use C4::Auth;
use C4::Interface::CGI::Output;

use Data::Dumper;

use CGI;
my $cgi = new CGI;

# get a template, opac-pluceneresults.tmpl is currently an exact copy of
# opac-searchresults.tmpl so just make a copy.
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "opac-pluceneresults.tmpl",
        query           => $cgi,
        type            => "opac",
        authnotrequired => 1,
    }
);

# the script expects an input called query;
my $query = $cgi->param('query');

# tell the script what index to use (change this to match whatever is in indexer.pl)
my $searcher = Plucene::Search::IndexSearcher->new("/tmp/plucene/");

# the important bit here is default=>"title"
# that says if we dont specify what to search, search the title field
my $parser = Plucene::QueryParser->new(
    {
        analyzer => Plucene::Plugin::Analyzer::PorterAnalyzer->new(),
        default  => "title"
    }
);

my $parsed = $parser->parse($query);

my @docs;

# build an array of results,
# we could use the $score to rank them, but its currently not doing that
my $hc = Plucene::Search::HitCollector->new(
    collect => sub {
        my ( $self, $doc, $score ) = @_;
        my $res = eval { $searcher->doc($doc) };
        push @docs, $res if $res;
    }
);

# do the searh
$searcher->search_hc( $parsed, $hc );

# map the results into a format our template is expecting
my @results = map {
    {
        biblionumber => $_->get("filename")->string,
        title        => $_->get("title")->string,
        author       => $_->get("author")->string,
    }
} @docs;

# pass the results to the template
my $num_records = @results;
$template->param(
    search_results => \@results,
    numrecords     => $num_records,
    searchdesc     => $query
);
output_html_with_http_headers $cgi, $cookie, $template->output;
