#!/usr/bin/perl

# $Id$

#script to recieve orders
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
use strict;
use CGI;
use C4::Context;
use C4::Acquisition;
use C4::Biblio;
use C4::Output;
use C4::Search;
use C4::Auth;
use C4::Interface::CGI::Output;
use C4::Database;
use HTML::Template;
use C4::Date;

use Data::Dumper;

my $input      = new CGI;
my $supplierid = $input->param('supplierid');
my $dbh        = C4::Context->dbh;

my $search      = $input->param('recieve');
my $invoice     = $input->param('invoice');
my $freight     = $input->param('freight');
my $biblio      = $input->param('biblio');
my $biblioitem  = $input->param('bibitem');       # added my mason 20060324
my $catview     = $input->param('catview');
my $gst         = $input->param('gst');
my $noitems     = $input->param('items');
my $set_barcode = $input->param('set_barcode');
my $library_name = C4::Context->preference("LibraryName");

my ( $count, @results ) =
  ordersearch( $search, $supplierid, $biblio, $catview );

if ( $library_name eq "Horowhenua Library Trust" && $count > 1 ) {
    ( $count, @results ) = ordersearch( $search, $biblio, $catview );

}

#warn "COUNT = $count";
#warn "C:$count for ordersearch($search,$supplierid,$biblio,$catview);";

my ( $count2, @booksellers );
if ( $count == 1 ) {
    ( $count2, @booksellers ) = bookseller( $results[0]->{'booksellerid'} );
}
else {
    ( $count2, @booksellers ) = bookseller($supplierid);
}

#warn Dumper @results;

my $date     = $results[0]->{'entrydate'};
my $exchange = getcurrency( $booksellers[0]->{'listprice'} );

my $no_multi = $input->param('no_multi');

#-------------------------

# bugzilla: http://bugzilla.katipo.co.nz/show_bug.cgi?id=3916 , mason.
# ok lets do a lookup to see how many orders exist for a bibitem, if there are >1,
# then we need to display them  to the user so they can choose, because the system cant
# work it out, as there are no itemnumbers stored in the aqorders records :(

my @results2;

#warn "MASON BIBITEM=  $biblioitem";
my $query2 = " select * from aqorders where biblioitemnumber =?";
my $sth2   = $dbh->prepare($query2);
$sth2->execute($biblioitem);
while ( my $data2 = $sth2->fetchrow_hashref ) {

    #warn $data2;

    #warn Dumper "DATA2:", $data2->{'basketno'};
    my $query3 = " select * from aqbasket where basketno =?";
    my $sth3   = $dbh->prepare($query3);
    $sth3->execute( $data2->{'basketno'} );
    my $data3 = $sth3->fetchrow_hashref;

    #warn Dumper $data3;
    $data2->{'booksellerid'} = $data3->{'booksellerid'};
    push( @results2, $data2 );
}
$sth2->finish;

#warn Dumper @results2;

my @loop;
my $result_count = scalar(@results2);

#warn "MULTI REESULT $result_count";
#warn "NO_MULTI =  $no_multi";
my  ( $template, $loggedinuser, $cookie );

if ( $result_count > 1 && $no_multi != 1 ) {

    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {
            template_name   => "acqui/acquire-multi-order.tmpl",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { acquisition => 1 },
            debug           => 1,
        }
    );

    #warn "IN MULTI IF \n";

    # cool, now lets shove the results into a loop
    for ( my $i = 0 ; $i < $result_count ; $i++ ) {
        my %line;

        $line{booksellerid}            = $results2[$i]->{'booksellerid'};
        $line{biblionumber}            = $results2[$i]->{'biblionumber'};
        $line{biblioitemnumber}        = $results2[$i]->{'biblioitemnumber'};
        $line{ordernumber}             = $results2[$i]->{'ordernumber'};
        $line{title}                   = $results2[$i]->{'title'};
        $line{booksellerinvoicenumber} =
          $results[$i]->{'booksellerinvoicenumber'};
        $line{datereceived}        = $results2[$i]->{'datereceived'};
        $line{entrydate}           = $results2[$i]->{'entrydate'};
        $line{quantity}            = $results2[$i]->{'quantity'};
        $line{listprice}           = $results2[$i]->{'listprice'};
        $line{freight}             = $results2[$i]->{'freight'};
        $line{unitprice}           = $results2[$i]->{'unitprice'};
        $line{quantityreceived}    = $results2[$i]->{'quantityreceived'};
        $line{supplierreference}   = $results2[$i]->{'supplierreference'};
        $line{purchaseordernumber} = $results2[$i]->{'purchaseordernumber'};
        $line{basketno}            = $results2[$i]->{'basketno'};
        $line{timestamp}           = $results2[$i]->{'timestamp'};
        $line{rrp}                 = $results2[$i]->{'rrp'};
        $line{budgetdate}          = $results2[$i]->{'budgetdate'};
        push @loop, \%line;

        #warn "LOOPING", $results2[$i]->{'ordernumber'};
    }

    $template->param(
        loop       => \@loop,
        multi      => 1,
        biblio     => $biblio,
        biblioitem => $biblioitem,
    );

}
elsif ( $count == 1 ) {

    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {

                    template_name   => "acqui/acquire.tmpl",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { acquisition => 1 },
            debug           => 1,
        }
    );

    #warn "NO MULTI\n";

    my $itemtype2 = $results[0]->{'itemtype'};
    my $freightperitem;
    if ( $results[0]->{'freight'} > 0 ) {
        $freightperitem = $results[0]->{'freight'};
    }
    else {
        if ( $noitems > 0 ) {
            $freightperitem = $freight / $noitems;
        }
    }
    $freightperitem = sprintf( "%.2f", $freightperitem );
    my $sth;
    my $sth =
      $dbh->prepare(
        "Select itemtype,description from itemtypes order by description");
    $sth->execute;
    my @itemtype;
    my %itemtypes;
    push @itemtype, "";
    $itemtypes{''} = "Please choose";

    while ( my ( $value, $lib ) = $sth->fetchrow_array ) {
        push @itemtype, $value;
        $itemtypes{$value} = $lib;
    }

    my $CGIitemtype = CGI::scrolling_list(
        -name     => 'format',
        -values   => \@itemtype,
        -default  => $results[0]->{'itemtype'},
        -labels   => \%itemtypes,
        -size     => 1,
        -multiple => 0
    );
    $sth->finish;

    my @branches;
    my @select_branch;
    my %select_branches;
    my ( $count2, @branches ) = branches();
    for ( my $i = 0 ; $i < $count2 ; $i++ ) {
        push @select_branch, $branches[$i]->{'branchcode'};    #
        $select_branches{ $branches[$i]->{'branchcode'} } =
          $branches[$i]->{'branchname'};
    }
    my $CGIbranch = CGI::scrolling_list(
        -name     => 'branch',
        -values   => \@select_branch,
        -default  => $results[0]->{'branchcode'},
        -labels   => \%select_branches,
        -size     => 1,
        -multiple => 0
    );

    my $auto_barcode = C4::Context->boolean_preference("autoBarcode") || 0;
    #warn "ACQIRE AUTO BARCODE = $auto_barcode";

    # See whether barcodes should be automatically allocated.
    # Defaults to 0, meaning "no".
    my $barcode;
    if ( $auto_barcode eq '1' ) {
        $sth = $dbh->prepare("Select max(barcode) barcode from items");
        $sth->execute;
        my @data_results;
        while ( my $data = $sth->fetchrow_hashref ) {
            push( @data_results, $data );
        }
        $barcode = @data_results[0]->{'barcode'} + 1;
        #warn 'moo', @data_results[0]->{'barcode'};
        #warn "auto Barcode = $barcode";

        #$barcode = sprintf( "%.0f", $barcode );
        #warn "auto Barcode = $barcode";
        $sth->finish;

        my $moo = 'TEST777';
        $moo = $moo + 1;
        #warn $moo;
    }

    my @bookfund;
    my @select_bookfund;
    my %select_bookfunds;
    ( $count2, @bookfund ) = bookfunds();
    for ( my $i = 0 ; $i < $count2 ; $i++ ) {
        push @select_bookfund, $bookfund[$i]->{'bookfundid'};
        $select_bookfunds{ $bookfund[$i]->{'bookfundid'} } =
          $bookfund[$i]->{'bookfundname'};
    }
    my $CGIbookfund = CGI::scrolling_list(
        -name     => 'bookfund',
        -values   => \@select_bookfund,
        -default  => $results[0]->{'bookfundid'},
        -labels   => \%select_bookfunds,
        -size     => 1,
        -multiple => 0
    );

    if ( $results[0]->{'quantityreceived'} == 0 ) {
        $results[0]->{'quantityreceived'} = '';
    }
    if ( $results[0]->{'unitprice'} == 0 ) {
        $results[0]->{'unitprice'} = '';
    }

    #warn Dumper( $results[0] );
    $template->param(
        count            => 1,
        biblionumber     => $results[0]->{'biblionumber'},
        ordernumber      => $results[0]->{'ordernumber'},
        biblioitemnumber => $results[0]->{'biblioitemnumber'},
        supplierid       => $results[0]->{'booksellerid'},
        freight          => $freight,
        gst              => $gst,
        noitems          => $noitems,

        #		catview => ($catview ne 'yes'?1:0),
        catview       => $catview,
        name          => $booksellers[0]->{'name'},
        date          => format_date($date),
        title         => $results[0]->{'title'},
        author        => $results[0]->{'author'},
        copyrightdate => $results[0]->{'copyrightdate'},

        #       	copyrightdate => format_date($results[0]->{'copyrightdate'}),
        #		itemtype => $results[0]->{'itemtype'},
        CGIbranch   => $CGIbranch,
        CGIbookfund => $CGIbookfund,
        CGIitemtype => $CGIitemtype,
        isbn        => $results[0]->{'isbn'},
        seriestitle => $results[0]->{'seriestitle'},
        volinf      => $results[0]->{'volumeddesc'},
        barcode     => $barcode,
        set_barcode => $set_barcode,

        #		bookfund => $results[0]->{'bookfundid'},
        quantity         => $results[0]->{'quantity'},
        quantityreceived => $results[0]->{'quantityreceived'},
        rrp              => $results[0]->{'rrp'},
        ecost            => $results[0]->{'ecost'},
        unitprice        => $results[0]->{'unitprice'},
        invoice          => $invoice,
        notes            => $results[0]->{'notes'},
        freightperitem   => $freightperitem,
        nocalc           => $booksellers[0]->{'nocalc'},
        invoicedisc      => $booksellers[0]->{'invoicedisc'},
        invoiceinc       => $booksellers[0]->{'invoiceincgst'},
        applygst         => $booksellers[0]->{'gstreg'},
        discount         => $booksellers[0]->{'discount'},

        supplierid => $booksellers[0]->{'id'},

        currency                => $exchange->{'rate'},
        basketno                => $results[0]->{'basketno'},
        booksellerinvoicenumber => $results[0]->{'booksellerinvoicenumber'},
        itemtype2 => $itemtype2,    #added by mason BGZLA:3823

    );

    #warn Dumper $booksellers[0];
    #warn Dumper $results[0];

# MASON: this is a little fix, to ensure that the 'create new biblio group' checkbox        # ONLY appears in acquire.tmpl for biblioitems that already have 1 OR MORE items
# attached to them.
    my $biblioitemnumber = $results[0]->{'biblioitemnumber'};
    my $error            = &countitems($biblioitemnumber);

    #warn "MASON: number of items for $biblioitemnumber = $error";
    if ( $error > 0 ) {
        $template->param( createbibitem => 'YES' );
    }

}
else {    # whats this loop for ??? mason
          # why this loop when acqui

    ( $template, $loggedinuser, $cookie ) = get_template_and_user(
        {

            template_name   => "acqui/searchresult.tmpl",
            query           => $input,
            type            => "intranet",
            authnotrequired => 0,
            flagsrequired   => { acquisition => 1 },
            debug           => 1,
        }
    );

    my @loop;
    for ( my $i = 0 ; $i < $count ; $i++ ) {
        my %line;
        $line{isbn}             = $results[$i]->{'isbn'};
        $line{basketno}         = $results[$i]->{'basketno'};
        $line{quantity}         = $results[$i]->{'quantity'};
        $line{quantityrecieved} = $results[$i]->{'quantityreceived'};
        $line{ordernumber}      = $results[$i]->{'ordernumber'};
        $line{biblionumber}     = $results[$i]->{'biblionumber'};
        $line{invoice}          = $invoice;
        $line{freight}          = $freight;
        $line{gst}              = $gst;
        $line{title}            = $results[$i]->{'title'};
        $line{author}           = $results[$i]->{'author'};
        $line{vol}              = $results[$i]->{'volume'};
        $line{volinf}           = $results[$i]->{'volumeddesc'};
        $line{supplierid}       = $supplierid;
        $line{noitems}          = $noitems;
        push @loop, \%line;
    }
    $template->param(
        loop       => \@loop,
        date       => format_date($date),
        name       => $booksellers[0]->{'name'},
        supplierid => $supplierid,
        invoice    => $invoice,
        search     => $search
    );
    warn "MASON: search= $search";

}

output_html_with_http_headers $input, $cookie, $template->output;Chris
