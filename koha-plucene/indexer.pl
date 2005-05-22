#!/usr/bin/perl -w

# This script will build an index of all the biblios in a koha database
# Its using english stemming at the moment. But that can be changed and is only
# indexing author and title

# Combine this with the search.cgi script to search Koha using Plucene
# This is still a work in progress, use with caution

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
# Suite 330, Boston, MA  02111-1307 USA

use lib '/usr/local/koha/intranet/modules';
use strict;
use C4::Context;
use Plucene::Index::Writer;
use Plucene::Plugin::Analyzer::PorterAnalyzer;
use Plucene::Document;

# connect to the database and fetch all the biblios
my $dbh = C4::Context->dbh();

my $query = "SELECT * FROM biblio";
my $sth   = $dbh->prepare($query);

$sth->execute();

# create an index writer
# currently it makes the index in /tmp/plucene
# PLEASE change this if you want to use the script in production
my $writer = Plucene::Index::Writer->new(
    "/tmp/plucene",
    Plucene::Plugin::Analyzer::PorterAnalyzer->new(),
    1    # Create the index from scratch
);

# For each biblio, add its information to the index

while ( my $data = $sth->fetchrow_hashref() ) {
    my $doc = Plucene::Document->new();
    $doc->add(
        Plucene::Document::Field->Keyword( filename => $data->{biblionumber} )
    );
    $doc->add( Plucene::Document::Field->Text( title  => $data->{'title'} ) );
    $doc->add( Plucene::Document::Field->Text( author => $data->{'author'} ) );
    $writer->add_document($doc);
}

