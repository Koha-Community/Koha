#!/usr/bin/perl

#script to add an order into the system
#written 29/2/00 by chris@katipo.co.nz

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

addorder.pl

=head1 DESCRIPTION

this script allows to add an order.
It is called by :

=item neworderbiblio.pl to add an order from nothing.

=item neworderempty.pl to add an order from an existing biblio.

=item newordersuggestion.pl to add an order from an existing suggestion.

=head1 CGI PARAMETERS

All of the cgi parameters below are related to the new order.

=over 4

=item C<ordnum>
the number of this new order.

=item C<basketno>
the number of this new basket

=item C<booksellerid>
the bookseller the librarian has to pay.

=item C<existing>

=item C<title>
the title of the record ordered.

=item C<author>
the author of the record ordered.

=item C<copyrightdate>
the copyrightdate of the record ordered.

=item C<ISBN>
the ISBN of the record ordered.

=item C<format>

=item C<quantity>
the quantity to order.

=item C<list_price>
the price of this order.

=item C<branch>
the branch where this order will be received.

=item C<series>

=item C<notes>
Notes on this basket.

=item C<bookfund>
bookfund use to pay this order.

=item C<sort1> & C<sort2>

=item C<rrp>

=item C<ecost>

=item C<GST>

=item C<budget>

=item C<cost>

=item C<sub>

=item C<invoice>
the number of the invoice for this order.

=item C<publishercode>

=item C<suggestionid>
if it is an order from an existing suggestion : the id of this suggestion.

=item C<donation>

=back

=cut

use strict;
use CGI;
use C4::Auth;			# get_template_and_user
use C4::Acquisition;	# NewOrder DelOrder ModOrder
use C4::Suggestions;	# ModStatus
use C4::Biblio;			# AddBiblio TransformKohaToMarc
use C4::Output;

# FIXME: This needs to do actual error checking and possibly return user to the same form,
# not just blindly call C4 functions and print a redirect.  

my $input = new CGI;

# get_template_and_user used only to check auth & get user id
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "acqui/booksellers.tmpl",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { acquisition => 1 },
        debug           => 1,
    }
);

# get CGI parameters
my $ordnum        = $input->param('ordnum');
my $basketno      = $input->param('basketno');
my $booksellerid  = $input->param('booksellerid');
my $existing      = $input->param('existing');    # existing biblio, (not basket or order)
my $title         = $input->param('title');
my $author        = $input->param('author');
my $copyrightdate = $input->param('copyrightdate');
my $isbn          = $input->param('ISBN');
my $itemtype      = $input->param('format');
my $quantity      = $input->param('quantity');		# FIXME: else ERROR!
my $listprice     = $input->param('list_price') || 0;
my $branch        = $input->param('branch');
my $series        = $input->param('series');
my $notes         = $input->param('notes');
my $bookfund      = $input->param('bookfund');
my $sort1         = $input->param('sort1');
my $sort2         = $input->param('sort2');
my $rrp           = $input->param('rrp');
my $ecost         = $input->param('ecost');
my $gst           = $input->param('GST');
my $budget        = $input->param('budget');
my $cost          = $input->param('cost');
my $sub           = $input->param('sub');
my $purchaseorder = $input->param('purchaseordernumber');
my $invoice       = $input->param('invoice');
my $publishercode = $input->param('publishercode');
my $suggestionid  = $input->param('suggestionid');
my $user          = $input->remote_user;

#warn "CREATEBIBITEM =  $input->param('createbibitem')";
#warn Dumper $input->param('createbibitem');
my $createbibitem = $input->param('createbibitem');

# create, modify or delete biblio
# create if $quantity>=0 and $existing='no'
# modify if $quantity>=0 and $existing='yes'
# delete if $quantity has been set to 0 by the librarian
my $biblionumber  = $input->param('biblionumber');
my $bibitemnum;
if ( $quantity ne '0' ) {
    #check to see if biblio exists
    if ( $existing eq 'no' ) {

        #if it doesnt create it
        my $record = TransformKohaToMarc(
            {
                "biblio.title"              => "$title",
                "biblio.author"             => "$author",
                "biblio.copyrightdate"      => $copyrightdate ? $copyrightdate : "",
                "biblio.series"             => $series        ? $series        : "",
                "biblioitems.itemtype"      => $itemtype      ? $itemtype      : "",
                "biblioitems.isbn"          => $isbn          ? $isbn          : "",
                "biblioitems.publishercode" => $publishercode ? $publishercode : "",
            });
        # create the record in catalogue, with framework ''
        ($biblionumber,$bibitemnum) = AddBiblio($record,'');

        # change suggestion status if applicable
        if ($suggestionid) {
            ModStatus( $suggestionid, 'ORDERED', '', $biblionumber );
        }
    }
    # if we already have $ordnum, then it's an ordermodif
    if ($ordnum) {
        ModOrder(
            $title,   $ordnum,   $quantity,     $listprice,
            $biblionumber,  $basketno, $booksellerid, $loggedinuser,
            $notes,   $bookfund, $bibitemnum,   $rrp,
            $ecost,   $gst,      $budget,       $cost,
            $invoice, $sort1,    $sort2,		$purchaseorder, $branch
        );
    }
    else { # else, it's a new line
        ( $basketno, $ordnum ) = NewOrder(
            $basketno,  $biblionumber,       $title,        $quantity,
            $listprice, $booksellerid, $loggedinuser, $notes,
            $bookfund,  $bibitemnum,   $rrp,          $ecost,
            $gst,       $budget,       $cost,         $sub,
            $invoice,   $sort1,        $sort2,		$purchaseorder,
			$branch
        );
    }
}
else { # qty=0, delete the line
    $biblionumber = $input->param('biblionumber');
    DelOrder( $biblionumber, $ordnum );
}
print $input->redirect("basket.pl?basketno=$basketno");
