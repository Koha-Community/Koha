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
use C4::Database;
use C4::Auth;
use C4::Bookfund;
use C4::Bookseller;
use C4::Acquisition;
use C4::Suggestions;
use C4::Biblio;
use C4::Search;
use C4::Output;
use C4::Input;
use C4::Koha;
use C4::Interface::CGI::Output;
use HTML::Template;
use C4::Members;

my $input        = new CGI;
my $booksellerid = $input->param('booksellerid');
my $title        = $input->param('title');
my $author       = $input->param('author');
my $copyright    = $input->param('copyright');
my @booksellers  = GetBookSeller($booksellerid);
my $count        = scalar @booksellers;
my $ordnum       = $input->param('ordnum');
my $biblio       = $input->param('biblio');
my $basketno     = $input->param('basketno');
my $suggestionid = $input->param('suggestionid');
# my $donation     = $input->param('donation');
my $close        = $input->param('close');
my $data;
my $new;
my $dbh = C4::Context->dbh;

if ( $ordnum eq '' ) {    # create order
    $new = 'yes';

    # 	$ordnum=newordernum;
    if ( $biblio && !$suggestionid ) {
        $data = bibdata($biblio);
    }

# get suggestion fields if applicable. If it's a subscription renewal, then the biblio already exists
# otherwise, retrieve suggestion information.
    if ($suggestionid) {
        if ($biblio) {
            $data = bibdata($biblio);
        }
        else {
            $data = GetSuggestion($suggestionid);
        }
    }
    if ( $data->{'title'} eq '' ) {
        $data->{'title'}         = $title;
        $data->{'author'}        = $author;
        $data->{'copyrightdate'} = $copyright;
    }
}
else {    #modify order
    $data   = GetSingleOrder($ordnum);
    $biblio = $data->{'biblionumber'};
    #get basketno and suppleirno. too!
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
my %itemtypesloop;
foreach my $thisitemtype (sort keys %$itemtypes) {
    push @itemtypesloop, $itemtypes->{$thisitemtype}->{'itemtype'};
    $itemtypesloop{$itemtypes->{$thisitemtype}->{'itemtype'}} =        $itemtypes->{$thisitemtype}->{'description'};
}

my $CGIitemtype = CGI::scrolling_list(
    -name     => 'format',
    -values   => \@itemtypesloop,
    -default  => $data->{'itemtype'},
    -labels   => \%itemtypesloop,
    -size     => 1,
    -multiple => 0
);

# build branches list
my $branches = GetBranches;
my @branchloop;
foreach my $thisbranch ( sort keys %$branches ) {
     my %row = (
        value      => $thisbranch,
        branchname => $branches->{$thisbranch}->{'branchname'},
    );
    push @branchloop, \%row;
}
$template->param( branchloop => \@branchloop );

# build bookfund list
my ($flags, $homebranch) = GetFlagsAndBranchFromBorrower($loggedinuser);

my $count2;
my @bookfund;
my @select_bookfund;
my %select_bookfunds;

@bookfund = GetBookFunds($homebranch);
$count2 = scalar @bookfund;

for ( my $i = 0 ; $i < $count2 ; $i++ ) {
    push @select_bookfund, $bookfund[$i]->{'bookfundid'};
    $select_bookfunds{ $bookfund[$i]->{'bookfundid'} } =
      $bookfund[$i]->{'bookfundname'};
}
my $CGIbookfund = CGI::scrolling_list(
    -name     => 'bookfund',
    -values   => \@select_bookfund,
    -default  => $data->{'bookfundid'},
    -labels   => \%select_bookfunds,
    -size     => 1,
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
}
else {
    $template->param( sort1 => $data->{'sort1'} );
}

my $CGIsort2 = buildCGIsort( "Asort2", "sort2", $data->{'sort2'} );
if ($CGIsort2) {
    $template->param( CGIsort2 => $CGIsort2 );
}
else {
    $template->param( sort2 => $data->{'sort2'} );
}

my $bibitemsexists;

#do a biblioitems lookup on bib
my @bibitems = GetBiblioItemByBiblioNumber($biblio);
my $bibitemscount = scalar @bibitems;

if ( $bibitemscount > 0 ) {
    # warn "NEWBIBLIO: bibitems for $biblio exists\n";
    # warn Dumper $bibitemscount, @bibitems;
    $bibitemsexists = 1;

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
    existing         => $biblio,
    title            => $title,
    ordnum           => $ordnum,
    basketno         => $basketno,
    booksellerid     => $booksellerid,
    suggestionid     => $suggestionid,
    biblio           => $biblio,
    biblioitemnumber => $data->{'biblioitemnumber'},
    itemtype         => $data->{'itemtype'},
    discount         => $booksellers[0]->{'discount'},
    listincgst       => $booksellers[0]->{'listincgst'},
    listprice        => $booksellers[0]->{'listprice'},
    gstreg           => $booksellers[0]->{'gstreg'},
    invoiceinc       => $booksellers[0]->{'invoiceincgst'},
    invoicedisc      => $booksellers[0]->{'invoicedisc'},
    nocalc           => $booksellers[0]->{'nocalc'},
    name             => $booksellers[0]->{'name'},
    currency         => $booksellers[0]->{'listprice'},
    gstrate          => C4::Context->preference("gist"),
    loop_currencies  => \@loop_currency,
    orderexists      => ( $new eq 'yes' ) ? 0 : 1,
    title            => $data->{'title'},
    author           => $data->{'author'},
    copyrightdate    => $data->{'copyrightdate'},
    CGIitemtype      => $CGIitemtype,
    CGIbookfund      => $CGIbookfund,
    isbn             => $data->{'isbn'},
    seriestitle      => $data->{'seriestitle'},
    quantity         => $data->{'quantity'},
    listprice        => $data->{'listprice'},
    rrp              => $data->{'rrp'},
    invoice          => $data->{'booksellerinvoicenumber'},
    ecost            => $data->{'ecost'},
    notes            => $data->{'notes'},
    publishercode    => $data->{'publishercode'},
#     donation         => $donation
);

output_html_with_http_headers $input, $cookie, $template->output;
