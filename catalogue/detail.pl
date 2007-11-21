#!/usr/bin/perl

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
use C4::Auth;
use C4::Serials;    #uses getsubscriptionfrom biblionumber
use C4::Output;
use C4::Biblio;
use C4::Serials;
use C4::XISBN qw(get_xisbns get_biblio_from_xisbn);
use C4::Amazon;

my $query = new CGI;
my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "catalogue/detail.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { catalogue => 1 },
    }
);

my $biblionumber = $query->param('biblionumber');

# change back when ive fixed request.pl
my @items = &GetItemsInfo( $biblionumber, 'intra' );
my $dat = &GetBiblioData($biblionumber);

if (!$dat) { 
	print $query->redirect("/cgi-bin/koha/koha-tmpl/errors/404.pl");
}

#coping with subscriptions
my $subscriptionsnumber = CountSubscriptionFromBiblionumber($biblionumber);
my @subscriptions       = GetSubscriptions( $dat->{title}, $dat->{issn}, $biblionumber );

my @subs;
foreach my $subscription (@subscriptions) {
    my %cell;
    $cell{subscriptionid}    = $subscription->{subscriptionid};
    $cell{subscriptionnotes} = $subscription->{notes};

    #get the three latest serials.
    $cell{latestserials} =
      GetLatestSerials( $subscription->{subscriptionid}, 3 );
    push @subs, \%cell;
}

$dat->{'count'} = @items;

my $norequests = 1;
foreach my $itm (@items) {
    $norequests = 0
      unless ( ( $itm->{'notforloan'} > 0 )
        || ( $itm->{'itemnotforloan'} > 0 ) );
    $itm->{ $itm->{'publictype'} } = 1;
}

$template->param( norequests => $norequests );

## get notes and subjects from MARC record
    my $dbh              = C4::Context->dbh;
    my $marcflavour      = C4::Context->preference("marcflavour");
    my $record           = GetMarcBiblio($biblionumber);
    my $marcnotesarray   = GetMarcNotes( $record, $marcflavour );
    my $marcauthorsarray = GetMarcAuthors( $record, $marcflavour );
    my $marcsubjctsarray = GetMarcSubjects( $record, $marcflavour );

    $template->param(
        MARCNOTES   => $marcnotesarray,
        MARCSUBJCTS => $marcsubjctsarray,
        MARCAUTHORS => $marcauthorsarray
    );

my @results = ( $dat, );
foreach ( keys %{$dat} ) {
    $template->param( "$_" => $dat->{$_} . "" );
}

$template->param(
    ITEM_RESULTS        => \@items,
    biblionumber        => $biblionumber,
	detailview => 1,
    subscriptions       => \@subs,
    subscriptionsnumber => $subscriptionsnumber,
    subscriptiontitle   => $dat->{title},
);

# XISBN Stuff
my $xisbn=$dat->{'isbn'};
$xisbn =~ s/(p|-| |:)//g;
$template->param(amazonisbn => $xisbn);
if (C4::Context->preference("FRBRizeEditions")==1) {
	eval {
		$template->param(
			xisbn => $xisbn,
			XISBNS => get_xisbns($xisbn)
		);
	};
	if ($@) { warn "XISBN Failed $@"; }
}
if ( C4::Context->preference("AmazonContent") == 1 ) {
    my $amazon_details = &get_amazon_details( $xisbn );
    foreach my $result ( @{ $amazon_details->{Details} } ) {
        $template->param( item_description => $result->{ProductDescription} );
        $template->param( image            => $result->{ImageUrlMedium} );
        $template->param( list_price       => $result->{ListPrice} );
        $template->param( amazon_url       => $result->{url} );
    }

    my @products;
    my @reviews;
    for my $details ( @{ $amazon_details->{Details} } ) {
        next unless $details->{SimilarProducts};
        for my $product ( @{ $details->{SimilarProducts}->{Product} } ) {
			if (C4::Context->preference("AmazonSimilarItems") ) {
				my $xbiblios;
				my @xisbns;

				if (C4::Context->preference("XISBNAmazonSimilarItems") ) {
					my $xbiblio = get_biblio_from_xisbn($product);
					push @xisbns, $xbiblio;
					$xbiblios = \@xisbns;
				}
				else {
					$xbiblios = get_xisbns($product);
				}
            	push @products, +{ product => $xbiblios };
			}
        }
        next unless $details->{Reviews};
        for my $product ( @{ $details->{Reviews}->{AvgCustomerRating} } ) {
            $template->param( rating => $product * 20 );
        }
        for my $reviews ( @{ $details->{Reviews}->{CustomerReview} } ) {
            push @reviews,
              +{
                summary => $reviews->{Summary},
                comment => $reviews->{Comment},
              };
        }
    }
    $template->param( SIMILAR_PRODUCTS => \@products );
    $template->param( AMAZONREVIEWS    => \@reviews );
}

output_html_with_http_headers $query, $cookie, $template->output;
