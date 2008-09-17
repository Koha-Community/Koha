#!/usr/bin/perl

# Copyright 2000-2002 Katipo Communications
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

use strict;

use C4::Context;
use CGI;
use C4::Auth;
use C4::Biblio;
use C4::Items;
use C4::Output;
use C4::Dates;

my $query = new CGI;
my $type  = $query->param('type');
($type) || ( $type = 'intra' );

my $biblionumber = $query->param('biblionumber');

# change back when ive fixed request.pl
my @items = GetItemsInfo( $biblionumber, $type );
my $norequests = 1;
foreach my $itm (@items) {
    $norequests = 0 unless $itm->{'notforloan'};
}

my $dat         = GetBiblioData($biblionumber);
my $record      = GetMarcBiblio($biblionumber);
my $addauthor   = GetMarcAuthors($record,C4::Context->preference("marcflavour"));
my $authorcount = scalar @$addauthor;

$dat->{'additional'} = "";
foreach (@$addauthor) {
    $dat->{'additional'} .= "|" . $_->{'a'};
}    # for

$dat->{'count'}      = @items;
$dat->{'norequests'} = $norequests;

my @results;

$results[0] = $dat;

my $resultsarray = \@results;
my $itemsarray   = \@items;

my $startfrom = $query->param('startfrom');
($startfrom) || ( $startfrom = 0 );

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => ('catalogue/detailprint.tmpl'),
        query           => $query,
        type            => "intranet",
        authnotrequired => ( $type eq 'opac' ),
        flagsrequired   => { catalogue => 1 },
    }
);

my $count = 1;

# now to get the items into a hash we can use and whack that thru

my $nextstartfrom = ( $startfrom + 20 < $count - 20 ) ? ( $startfrom + 20 ) : ( $count - 20 );
my $prevstartfrom = ( $startfrom - 20 > 0 ) ? ( $startfrom - 20 ) : (0);

$template->param(
    startfrom      => $startfrom + 1,
    endat          => $startfrom + 20,
    numrecords     => $count,
    nextstartfrom  => $nextstartfrom,
    prevstartfrom  => $prevstartfrom,
    BIBLIO_RESULTS => $resultsarray,
    ITEM_RESULTS   => $itemsarray,
    loggedinuser   => $loggedinuser,
    biblionumber   => $biblionumber,
);

output_html_with_http_headers $query, $cookie, $template->output;
