#!/usr/bin/perl

#script to show display basket of orders
#written by chris@katipo.co.nz 24/2/2000

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


=head1 NAME

neworderempty.pl

=head1 DESCRIPTION
this script allows to create a new record to order it. This record shouldn't exist
on database.

=head1 CGI PARAMETERS

=over 4

=item booksellerid
the bookseller the librarian has to buy a new book.

=item title
the title of this new record.

=item author
the author of this new record.

=item copyright
the copyright of this new record.

=item ordnum
the number of this order.

=item biblio

=item basketno
the basket number for this new order.

=item suggestionid
if this order comes from a suggestion.

=item close

=back

=cut

use strict;
use CGI;
use C4::Context;
use C4::Input;

use C4::Auth;
use C4::Bookfund;
use C4::Bookseller;		# GetBookSellerFromId
use C4::Acquisition;
use C4::Suggestions;	# GetSuggestion
use C4::Biblio;			# GetBiblioData
use C4::Output;
use C4::Input;
use C4::Koha;
use C4::Branch;			# GetBranches
use C4::Members;

my $input        = new CGI;
my $booksellerid = $input->param('booksellerid');	# FIXME: else ERROR!
my $title        = $input->param('title');
my $author       = $input->param('author');
my $copyright    = $input->param('copyright');
my $bookseller   = GetBookSellerFromId($booksellerid);	# FIXME: else ERROR!
my $ordnum       = $input->param('ordnum');
my $biblionumber = $input->param('biblionumber');
my $basketno     = $input->param('basketno');
my $purchaseorder= $input->param('purchaseordernumber');
my $suggestionid = $input->param('suggestionid');
# my $donation     = $input->param('donation');
my $close        = $input->param('close');
my $data;
my $new;
my $dbh = C4::Context->dbh;

if ( $ordnum eq '' ) {    # create order
    $new = 'yes';

    # 	$ordnum=newordernum;
    if ( $biblionumber && !$suggestionid ) {
        $data = GetBiblioData($biblionumber);
    }

# get suggestion fields if applicable. If it's a subscription renewal, then the biblio already exists
# otherwise, retrieve suggestion information.
    if ($suggestionid) {
		$data = ($biblionumber) ? GetBiblioData($biblionumber) : GetSuggestion($suggestionid);
    }
}
else {    #modify order
    $data   = GetOrder($ordnum);
    $biblionumber = $data->{'biblionumber'};
    #get basketno and supplierno. too!
    my $data2 = GetBasket( $data->{'basketno'} );
    $basketno     = $data2->{'basketno'};
    $booksellerid = $data2->{'booksellerid'};
}

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/neworderempty.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 1 },
        debug           => 1,
    }
);

# get currencies (for change rates calcs if needed)
my @rates = GetCurrencies();
my $count = scalar @rates;

my @loop_currency = ();
for ( my $i = 0 ; $i < $count ; $i++ ) {
    my %line;
    $line{currency} = $rates[$i]->{'currency'};
    $line{rate}     = $rates[$i]->{'rate'};
    push @loop_currency, \%line;
}

# build itemtype list
my $itemtypes = GetItemTypes;

my @itemtypesloop;
foreach my $thisitemtype (sort keys %$itemtypes) {
    push @itemtypesloop, { itemtype => $itemtypes->{$thisitemtype}->{'itemtype'} , desc =>  $itemtypes->{$thisitemtype}->{'description'} } ;
}

# build branches list
my $onlymine=C4::Context->preference('IndependantBranches') && 
             C4::Context->userenv && 
             C4::Context->userenv->{flags}!=1 && 
             C4::Context->userenv->{branch};
my $branches = GetBranches($onlymine);
my @branchloop;
foreach my $thisbranch ( sort keys %$branches ) {
     my %row = (
        value      => $thisbranch,
        branchname => $branches->{$thisbranch}->{'branchname'},
    );
	$row{'selected'} = 1 if( $thisbranch eq $data->{branchcode}) ;
    push @branchloop, \%row;
}
$template->param( branchloop => \@branchloop , itypeloop => \@itemtypesloop );

# build bookfund list
my $borrower= GetMember($loggedinuser);
my ( $flags, $homebranch )= ($borrower->{'flags'},$borrower->{'branchcode'});

my @select_bookfund;
my %select_bookfunds;

my @bookfund = GetBookFunds($homebranch);
my $count2 = scalar @bookfund;

for ( my $i = 0 ; $i < $count2 ; $i++ ) {
    push @select_bookfund, $bookfund[$i]->{'bookfundid'};
    $select_bookfunds{ $bookfund[$i]->{'bookfundid'} } =
      $bookfund[$i]->{'bookfundname'};
}
my $CGIbookfund = CGI::scrolling_list(
    -name     => 'bookfund',
	-id       => 'bookfund',
    -values   => \@select_bookfund,
    -default  => ($data->{'bookfundid'} ? $data->{'bookfundid'} : $select_bookfund[0]),
    -labels   => \%select_bookfunds,
	#-size     => 1,
	-tabindex =>'',
    -multiple => 0
);

my $bookfundname;
my $bookfundid;
if ($close) {
    $bookfundid   = $data->{'bookfundid'};
    $bookfundname = $select_bookfunds{$bookfundid};
}

#Build sort lists
my $CGIsort1 = buildCGIsort( "Asort1", "sort1", $data->{'sort1'} );
if ($CGIsort1) {
    $template->param( CGIsort1 => $CGIsort1 );
} else {
    $template->param( sort1 => $data->{'sort1'} );
}

my $CGIsort2 = buildCGIsort( "Asort2", "sort2", $data->{'sort2'} );
if ($CGIsort2) {
    $template->param( CGIsort2 => $CGIsort2 );
} else {
    $template->param( sort2 => $data->{'sort2'} );
}

#do a biblioitems lookup on bib
my @bibitems = GetBiblioItemByBiblioNumber($biblionumber);
my $bibitemscount = scalar @bibitems;

if ( $bibitemscount > 0 ) {
    # warn "NEWBIBLIO: bibitems for $biblio exists\n";
    my @bibitemloop;
    for ( my $i = 0 ; $i < $bibitemscount ; $i++ ) {
        my %line;
        $line{biblioitemnumber} = $bibitems[$i]->{'biblioitemnumber'};
        $line{isbn}             = $bibitems[$i]->{'isbn'};
        $line{itemtype}         = $bibitems[$i]->{'itemtype'};
        $line{volumeddesc}      = $bibitems[$i]->{'volumeddesc'};
        push( @bibitemloop, \%line );

        $template->param( bibitemloop => \@bibitemloop );
    }
    $template->param( bibitemexists => "1" );
}

# fill template
$template->param(
    close        => $close,
    bookfundid   => $bookfundid,
    bookfundname => $bookfundname
  )
  if ($close);

$template->param(
    existing         => $biblionumber,
    ordnum           => $ordnum,
    basketno         => $basketno,
    booksellerid     => $booksellerid,
    suggestionid     => $suggestionid,
    biblionumber     => $biblionumber,
    authorisedbyname => $borrower->{'firstname'} . " " . $borrower->{'surname'},
	biblioitemnumber => $data->{'biblioitemnumber'},
    itemtype         => $data->{'itemtype'},
    itemtype_desc    => $itemtypes->{$data->{'itemtype'}}->{description},
    discount         => $bookseller->{'discount'},
    listincgst       => $bookseller->{'listincgst'},
    listprice        => $bookseller->{'listprice'},
    gstreg           => $bookseller->{'gstreg'},
    invoiceinc       => $bookseller->{'invoiceincgst'},
    invoicedisc      => $bookseller->{'invoicedisc'},
    nocalc           => $bookseller->{'nocalc'},
    name             => $bookseller->{'name'},
    currency         => $bookseller->{'listprice'},
    gstrate          => C4::Context->preference("gist"),
    loop_currencies  => \@loop_currency,
    orderexists      => ( $new eq 'yes' ) ? 0 : 1,
    title            => $data->{'title'},
    author           => $data->{'author'},
    copyrightdate    => $data->{'copyrightdate'},
    CGIbookfund      => $CGIbookfund,
    isbn             => $data->{'isbn'},
    seriestitle      => $data->{'seriestitle'},
    quantity         => $data->{'quantity'},
    listprice        => $data->{'listprice'},
    rrp              => $data->{'rrp'},
    total            => $data->{ecost}*$data->{quantity},
    invoice          => $data->{'booksellerinvoicenumber'},
    ecost            => $data->{'ecost'},
    purchaseordernumber => $data->{'purchaseordernumber'},
    notes            => $data->{'notes'},
    publishercode    => $data->{'publishercode'},
#     donation         => $donation
);

output_html_with_http_headers $input, $cookie, $template->output;
