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
use POSIX;

#use Smart::Comments;
#use Data::Dumper;

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

my $type      = $query->param('type');
my $op        = $query->param('op');
my $batch_id  = $query->param('batch_id');
my $ccl_query = $query->param('ccl_query');

my $dbh = C4::Context->dbh;

my $startfrom = $query->param('startfrom') || 1;
my ( $template, $loggedinuser, $cookie );
my ($total_hits, $orderby, $results, $total, $error, $marcresults, $idx,	$datefrom, $dateto, $ccl_textbox);

my $resultsperpage = C4::Context->preference('numSearchResults') || '20';

my $show_results = 0;

if ($op eq "do_search") {
	$idx       = $query->param('idx');
	$ccl_textbox = $query->param('ccl_textbox');
     if ($ccl_textbox && $idx) {
    $ccl_query = "$idx=$ccl_textbox" ;
    }

	$datefrom = $query->param('datefrom');
	$dateto   = $query->param('dateto');

	if ($datefrom) {
		$datefrom = C4::Dates->new($datefrom);
        $ccl_query .= ' and ' if $ccl_textbox;
		$ccl_query .= "acqdate,st-date-normalized,ge=" .  $datefrom->output("iso");
	}

	if ($dateto) {
		$dateto = C4::Dates->new($dateto);
        $ccl_query .= ' and ' if ($ccl_textbox || $datefrom) ;
		$ccl_query .= "acqdate,st-date-normalized,le=".  $dateto->output("iso");
	}

    my $offset =    $startfrom > 1 ? $startfrom - 1 : 0;
	($error, $marcresults, $total_hits) =
	  SimpleSearch($ccl_query, $offset, $resultsperpage);

	if ($marcresults) {
		$show_results = scalar @$marcresults;
	} else {
		warn "ERROR label-item-search: no results from SimpleSearch";

		# leave $show_results undef
	}
}

if ($show_results) {
	my $hits = $show_results;
	my (@results, @items);

	# This code needs to be refactored using these subs...
	#my @items = &GetItemsInfo( $biblio->{biblionumber}, 'intra' );
	#my $dat = &GetBiblioData( $biblio->{biblionumber} );
	for (my $i = 0 ; $i < $hits ; $i++) {

		#DEBUG Notes: Decode the MARC record from each resulting MARC record...
		my $marcrecord = MARC::File::USMARC::decode($marcresults->[$i]);

		#DEBUG Notes: Transform it to Koha form...
		my $biblio = TransformMarcToKoha(C4::Context->dbh, $marcrecord, '');

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
			my $item_results = GetItemInfosOf(@$iii);
			foreach my $item (keys %$item_results) {

#DEBUG Notes: Build an array element 'item' of the correct bib (results) hash which contains item-specific data...
				if ($item_results->{$item}->{'biblionumber'} eq
					$results[$i]->{'biblionumber'}) {

# NOTE: The order of the elements in this array must be preserved or the table dependent on it will be incorrectly rendered.
# This is a real hack, but I can't think of a better way right now. -fbcit
# It is conceivable that itemcallnumber and/or barcode fields might be empty so the trinaries cover this possibility.
					push @{ $results[$i]->{'item'} }, { i_itemnumber1 =>
						  $item_results->{$item}->{'itemnumber'} };
					push @{ $results[$i]->{'item'} },
					  { i_itemcallnumber => (
							  $item_results->{$item}->{'itemcallnumber'}
							? $item_results->{$item}->{'itemcallnumber'} : 'NA'
						)
					  };
					push @{ $results[$i]->{'item'} }, { i_dateaccessioned =>
						  $item_results->{$item}->{'dateaccessioned'} };
					push @{ $results[$i]->{'item'} },
					  { i_barcode => (
							  $item_results->{$item}->{'barcode'}
							? $item_results->{$item}->{'barcode'} : 'NA'
						)
					  };
					push @{ $results[$i]->{'item'} }, { i_itemnumber2 =>
						  $item_results->{$item}->{'itemnumber'} };
				}
			}
		}
	}
	$debug and warn "**********\@results**********\n";
	$debug and warn Dumper(@results);

	($template, $loggedinuser, $cookie) = get_template_and_user(
		{   template_name   => "labels/result.tmpl",
			query           => $query,
			type            => "intranet",
			authnotrequired => 0,
			flagsrequired   => { borrowers => 1 },
			flagsrequired   => { catalogue => 1 },
			debug           => 1,
		}
	);

	# build page nav stuff.
	my (@field_data, @numbers);
	$total = $total_hits;

	my ($from, $to, $startfromnext, $startfromprev, $displaynext, $displayprev);

	if ($total > $resultsperpage) {
		my $num_of_pages = ceil($total / $resultsperpage + 1);
		for (my $page = 1 ; $page < $num_of_pages ; $page++) {
			my $startfrm = (($page - 1) * $resultsperpage) + 1;
			push @numbers,
			  { number    => $page,
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

	} else {
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
		result    => \@results,
		batch_id  => $batch_id,
		type      => $type,
		idx       => $idx,
		ccl_query => $ccl_query,
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







