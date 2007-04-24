#!/usr/bin/perl
# WARNING: 4-character tab stops here

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
require Exporter;
use CGI;
use C4::Koha;
use C4::Auth;

use C4::Context;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Acquisition;
use C4::Koha;    # XXX subfield_is_koha_internal_p

# Creates a scrolling list with the associated default value.
# Using more than one scrolling list in a CGI assigns the same default value to all the
# scrolling lists on the page !?!? That's why this function was written.

my $query = new CGI;
my $type  = $query->param('type');
my $op    = $query->param('op');
my $dbh   = C4::Context->dbh;

my $startfrom = $query->param('startfrom');
$startfrom = 0 if ( !defined $startfrom );
my ( $template, $loggedinuser, $cookie );
my $resultsperpage;

if ( $op eq "do_search" ) {
    my @marclist  = $query->param('marclist');
    my @and_or    = $query->param('and_or');
    my @excluding = $query->param('excluding');
    my @operator  = $query->param('operator');
    my @value     = $query->param('value');

    $resultsperpage = $query->param('resultsperpage');
    $resultsperpage = 19 if ( !defined $resultsperpage );
    my $orderby = $query->param('orderby');

    # builds tag and subfield arrays
    my @tags;

    foreach my $marc (@marclist) {
        if ($marc) {
            my ( $tag, $subfield ) =
              GetMarcFromKohaField( $dbh, $marc );
            if ($tag) {
                push @tags, $dbh->quote("$tag$subfield");
            }
            else {
                push @tags, $dbh->quote( substr( $marc, 0, 4 ) );
            }
        }
        else {
            push @tags, "";
        }
    }
    my ( $results, $total ) =
      catalogsearch( $dbh, \@tags, \@and_or, \@excluding, \@operator, \@value,
        $startfrom * $resultsperpage,
        $resultsperpage, $orderby );

    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "barcodes/result.tmpl",
            query           => $query,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { tools => 1 },
            debug           => 1,
        }
    );

    # multi page display gestion
    my $displaynext = 0;
    my $displayprev = $startfrom;
    if ( ( $total - ( ( $startfrom + 1 ) * ($resultsperpage) ) ) > 0 ) {
        $displaynext = 1;
    }

    my @field_data = ();

    for ( my $i = 0 ; $i <= $#marclist ; $i++ ) {
        push @field_data, { term => "marclist",  val => $marclist[$i] };
        push @field_data, { term => "and_or",    val => $and_or[$i] };
        push @field_data, { term => "excluding", val => $excluding[$i] };
        push @field_data, { term => "operator",  val => $operator[$i] };
        push @field_data, { term => "value",     val => $value[$i] };
    }

    my @numbers = ();

    if ( $total > $resultsperpage ) {
        for ( my $i = 1 ; $i < $total / $resultsperpage + 1 ; $i++ ) {
            if ( $i < 16 ) {
                my $highlight = 0;
                ( $startfrom == ( $i - 1 ) ) && ( $highlight = 1 );
                push @numbers,
                  {
                    number     => $i,
                    highlight  => $highlight,
                    searchdata => \@field_data,
                    startfrom  => ( $i - 1 )
                  };
            }
        }
    }

    my $from = $startfrom * $resultsperpage + 1;
    my $to;

    if ( $total < ( ( $startfrom + 1 ) * $resultsperpage ) ) {
        $to = $total;
    }
    else {
        $to = ( ( $startfrom + 1 ) * $resultsperpage );
    }

    # this gets the results of the search (which are bibs)
    # and then does a lookup on all items that exist for that bib
    # then pushes the items onto a new array, as we really want the
    # items attached to the bibs not thew bibs themselves

    my @results2;
    my $i;
    for ( $i = 0 ; $i <= ( $total - 1 ) ; $i++ )
    {    #total-1 coz the array starts at 0
            #warn $i;

        my $type         = 'intra';
        my @item_results =
          &GetItemsInfo( $results->[$i]{'biblionumber'}, $type );

        foreach my $item (@item_results) {

            #warn Dumper $item;
            push @results2, $item;
        }

    }

    $template->param(
        result         => \@results2,
        startfrom      => $startfrom,
        displaynext    => $displaynext,
        displayprev    => $displayprev,
        resultsperpage => $resultsperpage,
        startfromnext  => $startfrom + 1,
        startfromprev  => $startfrom - 1,
        searchdata     => \@field_data,
        total          => $total,
        from           => $from,
        to             => $to,
        numbers        => \@numbers,
    );
}
else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "barcodes/search.tmpl",
            query           => $query,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { tools => 1 },
            debug           => 1,
        }
    );
    my $sth =
      $dbh->prepare(
        "Select itemtype,description from itemtypes order by description");
    $sth->execute;
    my @itemtype;
    my %itemtypes;
    push @itemtype, "";
    $itemtypes{''} = "";
    while ( my ( $value, $lib ) = $sth->fetchrow_array ) {
        push @itemtype, $value;
        $itemtypes{$value} = $lib;
    }

    my $CGIitemtype = CGI::scrolling_list(
        -name     => 'value',
        -values   => \@itemtype,
        -labels   => \%itemtypes,
        -size     => 1,
        -multiple => 0
    );
    $sth->finish;

    $template->param( CGIitemtype => $CGIitemtype, );
}

# Print the page
$template->param(
    intranetcolorstylesheet =>
      C4::Context->preference("intranetcolorstylesheet"),
    intranetstylesheet => C4::Context->preference("intranetstylesheet"),
    IntranetNav        => C4::Context->preference("IntranetNav"),
);
output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
