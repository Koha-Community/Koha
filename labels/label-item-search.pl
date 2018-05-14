#!/usr/bin/perl
#
# Copyright 2000-2002 Katipo Communications
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
use vars qw($debug $cgi_debug);

use CGI qw ( -utf8 );
use List::Util qw( max min );
use POSIX qw(ceil);

use C4::Auth qw(get_template_and_user);
use C4::Output qw(output_html_with_http_headers);
use C4::Context;
use C4::Search qw(SimpleSearch);
use C4::Biblio qw(TransformMarcToKoha);
use C4::Creators::Lib qw(html_table);
use C4::Debug;

use Koha::DateUtils;
use Koha::Items;
use Koha::ItemTypes;
use Koha::SearchEngine::Search;

BEGIN {
    $debug = $debug || $cgi_debug;
    if ($debug) {
        require Data::Dumper;
        import Data::Dumper qw(Dumper);
    }
}

my $query = new CGI;

my $type      = $query->param('type');
my $op        = $query->param('op') || '';
my $batch_id  = $query->param('batch_id');
my $ccl_query = $query->param('ccl_query');
my $startfrom = $query->param('startfrom') || 1;
my ($template, $loggedinuser, $cookie) = (undef, undef, undef);
my (
    $total_hits,  $total,  $error,
    $marcresults, $idx,     $datefrom, $dateto, $ccl_textbox
);
my $resultsperpage = C4::Context->preference('numSearchResults') || '20';
my $show_results = 0;
my $display_columns = [ {_add                   => {label => "Add Item", link_field => 1}},
                        {_item_call_number      => {label => "Call Number", link_field => 0}},
                        {_date_accessioned      => {label => "Accession Date", link_field => 0}},
                        {_barcode               => {label => "Barcode", link_field => 0}},
                        {select                 => {label => "Select", value => "_item_number"}},
                      ];

if ( $op eq "do_search" ) {
    my $QParser;
    $QParser = C4::Context->queryparser if (C4::Context->preference('UseQueryParser'));
    $idx         = $query->param('idx');
    $ccl_textbox = $query->param('ccl_textbox');
    if ( $ccl_textbox && $idx ) {
        $ccl_query = "$idx:$ccl_textbox";
    }

    $datefrom = $query->param('datefrom');
    $dateto   = $query->param('dateto');

    if ($datefrom) {
        $datefrom = eval { dt_from_string ( $datefrom ) };
        if ($datefrom) {
            $datefrom = output_pref( { dt => $datefrom, dateonly => 1, dateformat => 'iso' } );
            if ($QParser) {
                $ccl_query .= ' && ' if $ccl_textbox;
                $ccl_query .=
                    "acqdate(" . $datefrom . '-)';
            } else {
                $ccl_query .= ' and ' if $ccl_textbox;
                $ccl_query .= "acqdate,ge,st-date-normalized=" . $datefrom;
            }
        }
    }

    if ($dateto) {
        $dateto = eval { dt_from_string ( $dateto ) };
        if ($dateto) {
           $dateto = output_pref( { dt => $dateto, dateonly => 1, dateformat => 'iso' } );
            if ($QParser) {
                $ccl_query .= ' && ' if ( $ccl_textbox || $datefrom );
                $ccl_query .= "acqdate(-" . $dateto . ')';
            } else {
                $ccl_query .= ' and ' if ( $ccl_textbox || $datefrom );
                $ccl_query .= "acqdate,le,st-date-normalized=" . $dateto;
            }
        }
    }

    my $offset = $startfrom > 1 ? $startfrom - 1 : 0;
    my $searcher = Koha::SearchEngine::Search->new({index => 'biblios'});
    ( $error, $marcresults, $total_hits ) = $searcher->simple_search_compat($ccl_query, $offset, $resultsperpage);

    if (!defined $error && @{$marcresults} ) {
        $show_results = @{$marcresults};
    }
    else {
        $debug and warn "ERROR label-item-search: no results from simple_search_compat";

        # leave $show_results undef
    }
}

if ($show_results) {
    my $hits = $show_results;
    my @results_set = ();
    my @items =();
    # This code needs to be refactored using these subs...
    #my @items = &GetItemsInfo( $biblio->{biblionumber}, 'intra' );
    for ( my $i = 0 ; $i < $hits ; $i++ ) {
        my @row_data= ();
        #DEBUG Notes: Decode the MARC record from each resulting MARC record...
        my $marcrecord = C4::Search::new_record_from_zebra( 'biblioserver', $marcresults->[$i] );
        #DEBUG Notes: Transform it to Koha form...
        my $biblio = TransformMarcToKoha( $marcrecord, '' );
        #DEBUG Notes: Stuff the bib into @biblio_data...
        push (@results_set, $biblio);
        my $biblionumber = $biblio->{'biblionumber'};
        #DEBUG Notes: Grab the item numbers associated with this MARC record...
        my $items = Koha::Items->search({ biblionumber => $biblionumber }, { order_by => { -desc => 'itemnumber' }});
        #DEBUG Notes: Retrieve the item data for each number...
        while ( my $item = $items->next ) {
            #DEBUG Notes: Build an array element 'item' of the correct bib (results) hash which contains item-specific data...
            if ( $item->biblionumber eq $results_set[$i]->{'biblionumber'} ) {
                my $item_data;
                $item_data->{'_item_number'}      = $item->itemnumber;
                $item_data->{'_item_call_number'} = ( $item->itemcallnumber || 'NA' );
                $item_data->{'_date_accessioned'} = $item->dateaccessioned;
                $item_data->{'_barcode'}          = ( $item->barcode || 'NA' );
                $item_data->{'_add'}              = $item->itemnumber;
                push @row_data, $item_data;
            }
            $results_set[$i]->{'item_table'} = html_table($display_columns, \@row_data);
        }
    }

    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "labels/result.tt",
            query           => $query,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { borrowers => 'edit_borrowers' },
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );

    # build page nav stuff.
    my @numbers;
    $total = $total_hits;

    my ( $from, $to, $startfromnext, $startfromprev, $displaynext,
        $displayprev );

    if ( $total > $resultsperpage ) {
        my $num_of_pages = ceil( $total / $resultsperpage + 1 );
        for ( my $page = 1 ; $page < $num_of_pages ; $page++ ) {
            my $startfrm = ( ( $page - 1 ) * $resultsperpage ) + 1;
            push @numbers,
              {
                number    => $page,
                startfrom => $startfrm
              };
        }

        $from          = $startfrom;
        $startfromprev = $startfrom - $resultsperpage;
        $startfromnext = $startfrom + $resultsperpage;

        $to =
            $startfrom + $resultsperpage > $total
          ? $total
          : $startfrom + $resultsperpage - 1;

        # multi page display
        $displaynext = 0;
        $displayprev = $startfrom > 1 ? $startfrom : 0;

        $displaynext = 1 if $to < $total_hits;

    }
    else {
        $from = 1;
        $to = $total_hits;
        $displayprev = 0;
        $displaynext = 0;
    }

    $template->param(
        total          => $total_hits,
        from           => $from,
        to             => $to,
        startfromnext  => $startfromnext,
        startfromprev  => $startfromprev,
        startfrom      => $startfrom,
        displaynext    => $displaynext,
        displayprev    => $displayprev,
        resultsperpage => $resultsperpage,
        numbers        => \@numbers,
    );

    $template->param(
        results   => ($show_results ? 1 : 0),
        result_set=> \@results_set,
        batch_id  => $batch_id,
        type      => $type,
        ccl_query => $ccl_query,
    );
}

#
#   search section
#

else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "labels/search.tt",
            query           => $query,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );
    my $itemtypes = Koha::ItemTypes->search;
    my @itemtypeloop;
    while ( my $itemtype = $itemtypes->next ) {
        # FIXME This must be improved:
        # - pass the iterator to the template
        # - display the translated_description
        my %row = (
            value       => $itemtype->itemtype,
            description => $itemtype->description,
        );
        push @itemtypeloop, \%row;
    }
    $template->param(
        itemtypeloop => \@itemtypeloop,
        batch_id     => $batch_id,
        type         => $type,
    );

}

$template->param( idx => $idx );

# Print the page
output_html_with_http_headers $query, $cookie, $template->output;
