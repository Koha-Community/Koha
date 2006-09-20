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

=item C<gst>

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
use C4::Auth;
use C4::Acquisition;
use C4::Suggestions;
use C4::Biblio;
use C4::Interface::CGI::Output;

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
my $ordnum       = $input->param('ordnum');
my $basketno     = $input->param('basketno');
my $booksellerid = $input->param('booksellerid');
my $existing     = $input->param('existing');    # existing biblio, (not basket or order)
my $title         = $input->param('title');
my $author        = $input->param('author');
my $copyrightdate = $input->param('copyrightdate');
my $isbn          = $input->param('ISBN');
my $itemtype      = $input->param('format');
my $quantity      = $input->param('quantity');
my $listprice     = $input->param('list_price');
my $branch        = $input->param('branch');
my $discount=$input->param('discount');
if ( $listprice eq '' ) {
    $listprice = 0;
}
my $series = $input->param('series');
my $notes         = $input->param('notes');
my $bookfundid      = $input->param('bookfundid');
my $sort1         = $input->param('sort1');
my $sort2         = $input->param('sort2');
my $rrp           = $input->param('rrp');
my $ecost         = $input->param('ecost');
my $gst           = $input->param('gstrate');
my $budget        = $input->param('budget');
my $unitprice         = $input->param('unitprice');
my $sub           = $input->param('sub');
my $purchaseordernumber       = $input->param('purchaseordernumber');
my $publishercode = $input->param('publishercode');
my $suggestionid  = $input->param('suggestionid');
my $donation      = $input->param('donation');
my $user          = $input->remote_user;
my $biblionumber=$input->param('biblionumber');
my $createbibitem = $input->param('createbibitem');

# create, modify or delete biblio
# create if $quantity>=0 and $existing='no'
# modify if $quantity>=0 and $existing='yes'
# delete if $quantity has been se to 0 by the librarian
my $dbh=C4::Context->dbh;

if ($quantity ne '0'){
    #check to see if biblio exists
    if ( $existing eq 'no' ) {
        #if it doesnt its created on template
        # change suggestion status if applicable
        if ($suggestionid) {
my $data=GetSuggestion($suggestionid);

 my $biblio={title=>$data->{title},author=>$data->{author},publishercode=>$data->{publishercode},copyrightdate=>$data->{copyrightdate},isbn=>$data->{isbn},place=>$data->{place},};
my $xmlhash=XMLkoha2marc($dbh,$biblio,"biblios");
$biblionumber = NEWnewbiblio($dbh,$xmlhash,"");

            ModStatus( $suggestionid, 'ORDERED', '', $biblionumber,$input );
warn "modstatus";
        }
    }## biblio didnot exist now created

    

   
    if ($ordnum) {

        # 		warn "MODORDER $title / $ordnum / $quantity / $bookfund";
        ModOrder(
            $title,   $ordnum,   $quantity,     $listprice,
            $biblionumber,  $basketno, $booksellerid, $loggedinuser,
            $notes,   $bookfundid,    $rrp,
            $ecost,   $gst,      $budget,       $unitprice,
            $purchaseordernumber, $sort1,    $sort2,$discount,$branch
        );
    }
    else {
        ( $basketno, $ordnum ) = NewOrder(
            $basketno,  $biblionumber,       $title,        $quantity,
            $listprice, $booksellerid, $loggedinuser, $notes,
            $bookfundid,    $rrp,          $ecost,
            $gst,       $budget,       $unitprice,         $sub,
            $purchaseordernumber,   $sort1,        $sort2, $discount,$branch
        );
    }

}
else {
#    $biblionumber = $input->param('biblionumber');
    DelOrder( $biblionumber, $ordnum,$loggedinuser );
}
warn "goingout";
print $input->redirect("basket.pl?basketno=$basketno");
