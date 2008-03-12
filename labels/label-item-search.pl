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
use C4::Dates qw( DHTMLcalendar );
use C4::Koha;    # XXX subfield_is_koha_internal_p

#use Smart::Comments;
use Data::Dumper;

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
my (@marclist,@and_or,@excluding,@operator,@value,$orderby,@tags,$results,$total,$error,$marcresults);
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
		($error, $marcresults) = SimpleSearch($marclist[0]);
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
	my (@results,@results2);
        # This code needs to be refactored using these subs...
        #my @items = &GetItemsInfo( $biblio->{biblionumber}, 'intra' );
        #my $dat = &GetBiblioData( $biblio->{biblionumber} );
	for(my $i=0; $i<$hits; $i++) {
            #DEBUG Notes: Decode the MARC record from each resulting MARC record...
	    my $marcrecord = MARC::File::USMARC::decode($marcresults->[$i]);
            #DEBUG Notes: Transform it to Koha form...
	    my $biblio = TransformMarcToKoha(C4::Context->dbh,$marcrecord,'');
	    #build the hash for the template.
	    $biblio->{highlight}       = ($i % 2)?(1):(0);
            #DEBUG Notes: Stuff it into @results... (used below to supply fields not existing in the item data)
            push @results, $biblio;
	    my $biblionumber = $biblio->{'biblionumber'};
            #DEBUG Notes: Grab the item numbers associated with this MARC record...
            my $itemnums = get_itemnumbers_of($biblionumber);
            #DEBUG Notes: Retrieve the item data for each number... 
            my $iii = $itemnums->{$biblionumber};
	    if ($iii) {
                my @titem_results = GetItemsInfo( $itemnums->{$biblionumber}, 'intra' );
	        my $item_results =  GetItemInfosOf( @$iii );
        	foreach my $item (keys %$item_results) {
		    for my $bibdata (keys %{$results[$i]}) {
			if ( !$item_results->{$item}{$bibdata} ) {      #Only add the data from the bibliodata if the data does not already exit in itemdata.
                                                                        #Otherwise we just build duplicate records rather than unique records per item.
                            $item_results->{$item}{$bibdata} = $results[$i]->{$bibdata};
                        }
                    }
                    #DEBUG Notes: After merging the bib and item data, stuff the results into $results2...
            	    push @results2, $item_results->{$item};
		}
                #warn Dumper(@results2);
	    }
    }
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

    # multi page display gestion
    my $displaynext = 0;
    my $displayprev = $startfrom;
    if ( ( $total - ( ( $startfrom + 1 ) * ($resultsperpage) ) ) > 0 ) {
        $displaynext = 1;
    }

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
	my $temp = ( $startfrom + 1 ) * $resultsperpage;
    my $to   = ($total < $temp) ? $total : $temp;

    # this gets the results of the search (which are bibs)
    # and then does a lookup on all items that exist for that bib
    # then pushes the items onto a new array, as we really want the
    # items attached to the bibs not thew bibs themselves

   # my @results2;
    # for (my $i = 0 ; $i < $total ; $i++ )
    # {
        #warn $i;
        #warn Dumper $results->[$i]{'bibid'};
    #     my $type = 'intra';
    #     my @item_results = &ItemInfo( 0, $results->[$i]{'biblionumber'}, $type );
			# FIXME: ItemInfo doesn't exist !!
# 		push @results2,\@item_results;
        # foreach my $item (@item_results) {
        #	warn Dumper $item;
        #	push @results2, $item;
        # }
#     }
# 
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
        batch_id       => $batch_id,
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

   #using old rel2.2 getitemtypes for testing!!!!, not devweek's GetItemTypes()

    my $itemtypes = GetItemTypes;
    my @itemtypeloop;
    my ($thisitemtype );
    foreach my $thisitemtype (keys %$itemtypes) {
            my %row =(value => $thisitemtype,
                           description => $itemtypes->{$thisitemtype}->{'description'},
                            );  
            push @itemtypeloop, \%row;
    }  
    $template->param(
    itemtypeloop =>\@itemtypeloop,
        batch_id     => $batch_id,
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
