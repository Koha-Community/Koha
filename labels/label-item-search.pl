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
use CGI;
use C4::Auth;
use HTML::Template::Pro;
use C4::Context;
use C4::Search;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Acquisition;
use C4::Search;
use C4::Dates;
use C4::Koha;    # XXX subfield_is_koha_internal_p
use C4::Debug;
use List::Util qw( max min );
#use Smart::Comments;

BEGIN {
    $debug = $debug || $cgi_debug;
    if ($debug) {
        require Data::Dumper;
        import Data::Dumper qw(Dumper);
    }
}

# Creates a scrolling list with the associated default value.
# Using more than one scrolling list in a CGI assigns the same default value to all the
# scrolling lists on the page !?!? That's why this function was written.

my $query           = new CGI;
my $type            = $query->param('type');
my $op              = $query->param('op');
my $batch_id        = $query->param('batch_id');
my $dateaccessioned = $query->param('dateaccessioned');

my $dbh = C4::Context->dbh;

my $startfrom = $query->param('startfrom') || 0;
my ( $template, $loggedinuser, $cookie );
my $total_hits;
my (@marclist,@and_or,@excluding,@operator,@value,$orderby,@tags,$results,$total,$error,$marcresults);
# XXX should this be maxItemsInSearchResults or numSearchResults preference instead of 19?
my $resultsperpage = $query->param('resultsperpage') || 19;

my $show_results = 0;
if ( $op eq "do_search" ) {
    @marclist  = $query->param('marclist');
    @and_or    = $query->param('and_or');
    @excluding = $query->param('excluding');
    @operator  = $query->param('operator');
    @value     = $query->param('value');
    $orderby   = $query->param('orderby');
	if (scalar @marclist) {
      #catalogsearch( $dbh, \@tags, \@and_or, \@excluding, \@operator, \@value,
      #  $startfrom * $resultsperpage,
      #  $resultsperpage, $orderby );
		( $error, $marcresults, $total_hits ) = SimpleSearch( $marclist[0], $startfrom, $resultsperpage );
		if ($marcresults) {
			$show_results = scalar @$marcresults;
		} else {
			warn "ERROR label-item-search: no results from SimpleSearch";
			# leave $show_results undef
		}
	}
}

if ( $show_results ) {
	my $hits = $show_results;
        my (@results, @items);
        # This code needs to be refactored using these subs...
        #my @items = &GetItemsInfo( $biblio->{biblionumber}, 'intra' );
        #my $dat = &GetBiblioData( $biblio->{biblionumber} );
	for(my $i=0; $i<$hits; $i++) {
        #DEBUG Notes: Decode the MARC record from each resulting MARC record...
	my $marcrecord = MARC::File::USMARC::decode($marcresults->[$i]);
        #DEBUG Notes: Transform it to Koha form...
	my $biblio = TransformMarcToKoha(C4::Context->dbh,$marcrecord,'');
	# Begin building the hash for the template...
        # I don't think we need this with the current template design, but I'm leaving it in place. -fbcit
	#$biblio->{highlight}       = ($i % 2)?(1):(0);
        #DEBUG Notes: Stuff the bib into @results...
        push @results, $biblio;
	my $biblionumber = $biblio->{'biblionumber'};
        #DEBUG Notes: Grab the item numbers associated with this MARC record...
        my $itemnums = get_itemnumbers_of($biblionumber);
        #DEBUG Notes: Retrieve the item data for each number... 
        my $iii = $itemnums->{$biblionumber};
	    if ($iii) {
	        my $item_results =  GetItemInfosOf( @$iii );
                foreach my $item (keys %$item_results) {
                    #DEBUG Notes: Build an array element 'item' of the correct bib (results) hash which contains item-specific data...
                    if ($item_results->{$item}->{'biblionumber'} eq $results[$i]->{'biblionumber'}) {
                        # NOTE: The order of the elements in this array must be preserved or the table dependent on it will be incorrectly rendered.
                        # This is a real hack, but I can't think of a better way right now. -fbcit
                        # It is conceivable that itemcallnumber and/or barcode fields might be empty so the trinaries cover this possibility.
                        push @{$results[$i]->{'item'}}, { i_itemnumber1         => $item_results->{$item}->{'itemnumber'} };
                        push @{$results[$i]->{'item'}}, { i_itemcallnumber      => ($item_results->{$item}->{'itemcallnumber'} ? $item_results->{$item}->{'itemcallnumber'} : 'NA') };
                        push @{$results[$i]->{'item'}}, { i_dateaccessioned     => $item_results->{$item}->{'dateaccessioned'} };
                        push @{$results[$i]->{'item'}}, { i_barcode             => ($item_results->{$item}->{'barcode'} ? $item_results->{$item}->{'barcode'} : 'NA')};
                        push @{$results[$i]->{'item'}}, { i_itemnumber2         => $item_results->{$item}->{'itemnumber'} };
                    }
                }
	    }
        }
        $debug and warn "**********\@results**********\n";
        $debug and warn Dumper(@results);
  
  ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "labels/result.tmpl",
            query           => $query,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { borrowers => 1 },
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );

    my @field_data = ();

	# FIXME: this relies on symmetric order of CGI params that IS NOT GUARANTEED by spec.

    for ( my $i = 0 ; $i <= $#marclist ; $i++ ) {
        push @field_data, { term => "marclist",  val => $marclist[$i] };
        push @field_data, { term => "and_or",    val => $and_or[$i] };
        push @field_data, { term => "excluding", val => $excluding[$i] };
        push @field_data, { term => "operator",  val => $operator[$i] };
        push @field_data, { term => "value",     val => $value[$i] };
    }

    my @numbers = ();
    $total = $total_hits;
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

    # multi page display gestion
    my $displaynext = 0;
    my $displayprev = $startfrom;
    # XXX Kludge. We show the "next" link if we retrieved the max number of results. There could be 0 more.
    if ( scalar @results == $resultsperpage ) {
        $displaynext = 1;
    }

    $template->param(
        result         => \@results,
        startfrom      => $startfrom,
        displaynext    => $displaynext,
        displayprev    => $displayprev,
        resultsperpage => $resultsperpage,
        startfromnext  => $startfrom + min( $resultsperpage, scalar @results ),
        startfromprev  => max( $startfrom - $resultsperpage, 0 ),
        searchdata     => \@field_data,
        total          => $total_hits,
        from           => $startfrom + 1,
        to             => $startfrom + min( $resultsperpage, scalar @results ),
        numbers        => \@numbers,
        batch_id       => $batch_id,
        type           => $type,
    );
}

#
#   search section
#

else {
    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "labels/search.tmpl",
            query           => $query,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { catalogue => 1 },
            debug           => 1,
        }
    );
    my $itemtypes = GetItemTypes;
    my @itemtypeloop;
    foreach my $thisitemtype (keys %$itemtypes) {
            my %row =(value => $thisitemtype,
                           description => $itemtypes->{$thisitemtype}->{'description'},
                            );  
            push @itemtypeloop, \%row;
    }  
    $template->param(
    itemtypeloop =>\@itemtypeloop,
    batch_id     => $batch_id,
    type         => $type,
    );

}
# Print the page
$template->param(
    DHTMLcalendar_dateformat => C4::Dates->DHTMLcalendar(),
);
output_html_with_http_headers $query, $cookie, $template->output;

# Local Variables:
# tab-width: 4
# End:
