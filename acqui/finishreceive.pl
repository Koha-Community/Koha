#!/usr/bin/perl

#script to add a new item and to mark orders as received
#written 1/3/00 by chris@katipo.co.nz

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

# this script makes the items, addorder.pl has already made the biblio and biblioitem records: MASON


=head1 NAME

finishreceive.pl

=head1 DESCRIPTION
TODO

=head1 CGI PARAMETERS

=over 4

TODO

=back

=cut

use strict;
use C4::Output;
use C4::Acquisition;
use C4::Biblio;
use CGI;
use C4::Search;
use C4::Circulation::Circ2;
use C4::Reserves2;
use C4::Interface::CGI::Output;
use C4::Auth;
use HTML::Template;

#use Data::Dumper;

my $input = new CGI;
my $dbh   = C4::Context->dbh;

my ( $template, $borrowernumber, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/finishreceive.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { editcatalogue => 1 },
        debug           => 1,
    }
);

my $user             = $input->remote_user;
my $biblionumber     = $input->param('biblio');
my $biblioitemnumber = $input->param('biblioitemnum');
my $ordnum           = $input->param('ordnum');
my $cost             = $input->param('cost');
my $invoiceno        = $input->param('invoice');
my $replacement    = $input->param('rrp');
my $gst            = $input->param('gst');
my $freight        = $input->param('freight');
my $freightperitem = $input->param('freightperitem');
my $supplierid     = $input->param('supplierid');
my $title         = $input->param('title');
my $author        = $input->param('author');
my $copyrightdate = $input->param('copyrightdate');
my $itemtype      = $input->param('format');
my $isbn          = $input->param('ISBN');
my $seriestitle   = $input->param('series');
my $branch        = $input->param('branch');
my $holdingbranch = $branch;
my $barcode       = $input->param('barcode');
my $bookfund      = $input->param('bookfund');
my $quantity      = $input->param('quantity');
my $quantrec      = $input->param('quantityrec');
my $ecost         = $input->param('ecost');
my $unitprice     = $input->param('unitprice');
my $notes         = $input->param('notes');
my $booksellers   = $input->param('booksellers');
my $foo           = $input->param('foo');
my $volinf        = $input->param('volinf');
my $catview = $input->param('catview');    # for editing from moredetail.tmpl
my $barcodeexists = $input->param('barcodeexists');  # if barcode exists
my $newitemfailed = $input->param('newitemfailed');  # if create new item failed
my $createbibitem =
  $input->param('createbibitem');    # user wants to create a new bibitem

#get additional info on bib and bibitem from dbase for additional needed fields before modbiblio.
( my $bibliocount,     my @biblios )     = &getbiblio($biblionumber);
my @biblioitems = &GetBiblioItemByBiblioNumber($biblionumber);
my $biblioitemcount = scalar @biblioitems;

( my $itemscount, my @items ) = &getitemsbybiblioitem($biblioitemnumber);

my $bibliohash = {
    biblionumber  => $biblionumber,
    title         => $title,
    author        => $author,
    abstract      => $biblios[0]->{'abstract'},
    copyrightdate => $copyrightdate,
    seriestitle   => $seriestitle,
    serial        => $biblios[0]->{'serial'},
    unititle      => $biblios[0]->{'unititle'},
    notes         => $biblios[0]->{'notes'}
};

my $biblioitemhash = {
    illus            => $biblioitems[0]->{'illus'},
    number           => $biblioitems[0]->{'number'},
    itemtype         => $itemtype,
    place            => $biblioitems[0]->{'place'},
    biblioitemnumber => $biblioitemnumber,
    issn             => $biblioitems[0]->{'issn'},
    size             => $biblioitems[0]->{'size'},
    marc             => $biblioitems[0]->{'marc'},
    timestamp        => $biblioitems[0]->{'timestamp'},
    biblionumber     => $biblionumber,
    url              => $biblioitems[0]->{'url'},
    dewey            => $biblioitems[0]->{'dewey'},
    isbn             => $isbn,
    publishercode    => $biblioitems[0]->{'publishercode'},
    lccn             => $biblioitems[0]->{'iccn'},
    volume           => $biblioitems[0]->{'volume'},
    subclass         => $biblioitems[0]->{'subclass'},
    notes            => $biblioitems[0]->{'notes'},
    classification   => $biblioitems[0]->{'classification'},
    volumeddesc      => $volinf,
    publicationyear  => $biblioitems[0]->{'publicationyear'},
    volumedate       => $biblioitems[0]->{'volumedate'},
    pages            => $biblioitems[0]->{'pages'}
};

my $itemhash = {
    biblionumber   => $biblionumber,
    itemnum        => $items[0]->{'itemnumber'},
    barcode        => $barcode,
    notes          => $items[0]->{'notes'},
    itemcallnumber => $items[0]->{'itemcallnumber'},
    notforloan     => $items[0]->{'notforloan'},
    location       => $items[0]->{'location'},
    bibitemnum     => $biblioitemnumber,
    homebranch     => $items[0]->{'homebranch'},
    lost           => $items[0]->{'itemlost'},
    withdrawn      => $items[0]->{'withdrawn'},
    holdingbranch  => $items[0]->{'holdingbranch'},
    replacement    => $replacement
};

# check if barcode exists, if so redirect back to orderreceive.pl and give message
my $error = &checkitems( 1, $barcode );
#warn "barcode check for $barcode result = $error";
if ($error) {
    print $input->redirect(
		"/cgi-bin/koha/acqui/orderreceive.pl?recieve=$ordnum&biblio=$biblionumber&invoice=$invoiceno&supplierid=$supplierid&freight=$freight&gst=$gst&barcodeexists=$barcode"
    );
}
# or if barcode is blank
else {

    if ( $createbibitem eq "YES" ) {
        &modbiblio($bibliohash);
        $biblioitemnumber = &newbiblioitem($biblioitemhash);

#lets do a lookup on aqorders, with ordnum, then insert biblioitem fiels with new biblioitem number

        my $query =
          "UPDATE aqorders SET biblioitemnumber = ? where ordernumber = ? 
		and biblionumber =  ?";
        my $sth = $dbh->prepare($query);
        my $error = $sth->execute( $biblioitemnumber, $ordnum, $biblionumber );
        #warn Dumper $error;
        $sth->fetchrow_hashref;
        $sth->finish;
    }
    else {
        &modbiblio($bibliohash);
        &modbibitem($biblioitemhash);
    }

    if ($catview) {
        &moditem($itemhash);
        print $input->redirect(
"/cgi-bin/koha/moredetail.pl?type=$itemtype&bib=$biblionumber&bi=$biblioitemnumber"
        );
    }

    if ( $quantity != 0 ) {
        # save the quantity recieved.
        receiveorder( $biblionumber, $ordnum, $quantrec, $user, $cost,
            $invoiceno, $freightperitem, $bookfund, $replacement );

        # create items if the user has entered barcodes
        my @barcodes = split( /\,| |\|/, $barcode );    #WTF?

        my ($error) = newitems(
            {
                biblioitemnumber => $biblioitemnumber,
                biblionumber     => $biblionumber,
                replacementprice => $replacement,
                price            => $cost,
                booksellerid     => $supplierid,
                homebranch       => $branch,
                loan             => 0
            },
            @barcodes
        );

        if ($error)
        { #if  newitems failes then display error, and send them back to orderreceive.pl????

            print $input->redirect(
			"/cgi-bin/koha/acqui/orderreceive.pl?recieve=$ordnum&biblio=$biblionumber&invoice=$invoiceno&supplierid=$supplierid&freight=$freight&gst=$gst&newitemfailed=1"
            );
        }

        elsif ( $itemtype ne 'P' && $itemtype ne 'PP' ) {   # chris's new if bit
            my %env;
            my $item = getiteminformation( \%env, 0, $barcode );
            my ( $resfound, $resrec ) = CheckReserves( 0, $barcode );

            if ($resfound) {                                # reserves is found
                my ($borrower) =
                  getpatroninformation( \%env, $resrec->{'borrowernumber'}, 0 );
                $template->param(
                    borrowernumber => $borrower->{'borrowernumber'},
                    cardnumber     => $borrower->{'cardnumber'},
                    firstname      => $borrower->{'firstname'},
                    surname        => $borrower->{'surname'},
                    invoice        => $invoiceno,
                    id             => $supplierid,
                    freight        => $freight,
                    gst            => $gst,
                    items          => $quantity,
                    ordnum         => $ordnum,
                    biblionumber   => $biblionumber,
                    barcode        => $barcode,
                );

                output_html_with_http_headers $input, $cookie,
                  $template->output;
            }
            else {    #no reserves found
                $invoiceno =~
                  s/\&/\%26/g;   # swapping pesky & with url friendly hex codes.
                print $input->redirect(
			"/cgi-bin/koha/acqui/receive.pl?invoice=$invoiceno&supplierid=$supplierid&freight=$freight&gst=$gst&quantity=$quantity"
                );
            }
        }
        else {
            print $input->redirect(
                "/cgi-bin/koha/loadmodules.pl?module=acquisitions")
              ;    # chris's new bit
        }    # end of if
    }
    else {

        #        print $input->header;
        DelOrder( $biblionumber, $ordnum );
        print $input->redirect("/acquisitions/");
    }
}
