#!/usr/bin/perl

#written 18/1/2000 by chris@katipo.co.nz
#script to renew items from the web

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.
use strict;
use warnings;
use CGI;
use C4::Circulation;
use C4::Context;
use C4::Items;
use C4::Auth;
use URI::Escape;
use Koha::DateUtils;
my $input = new CGI;

#Set Up User_env
# And assures user is loggedin  and has correct accreditations.

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "members/moremember.tt",
        query           => $input,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { circulate => 'circulate_remaining_permissions' },
        debug           => 0,
    }
);

#
# find items to renew, all items or a selection of items
#

my @data;
if ( $input->param('renew_all') ) {
    @data = $input->param('all_items[]');
}
else {
    @data = $input->param('items[]');
}

my @barcodes;
if ( $input->param('return_all') ) {
    @barcodes = $input->param('all_barcodes[]');
}
else {
    @barcodes = $input->param('barcodes[]');
}

my $branch = $input->param('branch');
my $datedue;
if ( $input->param('newduedate') ) {
    $datedue = dt_from_string( $input->param('newduedate') );
    $datedue->set_hour(23);
    $datedue->set_minute(59);
}

# warn "barcodes : @barcodes";
#
# renew items
#
my $cardnumber     = $input->param("cardnumber");
my $borrowernumber = $input->param("borrowernumber");
my $exemptfine     = $input->param("exemptfine") || 0;
my $override_limit = $input->param("override_limit") || 0;
my $failedrenews   = q{};
foreach my $itemno (@data) {

    # check status before renewing issue
    my ( $renewokay, $error ) =
      CanBookBeRenewed( $borrowernumber, $itemno, $override_limit );
    if ($renewokay) {
        AddRenewal( $borrowernumber, $itemno, $branch, $datedue );
    }
    else {
        $failedrenews .= "&failedrenew=$itemno";
    }
}
my $failedreturn = q{};
foreach my $barcode (@barcodes) {

    # check status before returning issue

    #System Preference Handling During Check-in In Patron Module
    my $itemnumber;
    $itemnumber = GetItemnumberFromBarcode($barcode);
    if ($itemnumber) {
        if ( C4::Context->preference("InProcessingToShelvingCart") ) {
            my $item = GetItem($itemnumber);
            if ( $item->{'location'} eq 'PROC' ) {
                $item->{'location'} = 'CART';
                ModItem( $item, $item->{'biblionumber'},
                    $item->{'itemnumber'} );
            }
        }

        if ( C4::Context->preference("ReturnToShelvingCart") ) {
            my $item = GetItem($itemnumber);
            $item->{'location'} = 'CART';
            ModItem( $item, $item->{'biblionumber'}, $item->{'itemnumber'} );
        }
    }

    my ( $returned, $messages, $issueinformation, $borrower ) =
      AddReturn( $barcode, $branch, $exemptfine );
    $failedreturn .= "&failedreturn=$barcode" unless ($returned);
}

#
# redirection to the referrer page
#
if ( $input->param('destination') eq "circ" ) {
    $cardnumber = uri_escape($cardnumber);
    print $input->redirect( '/cgi-bin/koha/circ/circulation.pl?findborrower='
          . $cardnumber
          . $failedrenews
          . $failedreturn );
}
else {
    print $input->redirect(
            '/cgi-bin/koha/members/moremember.pl?borrowernumber='
          . $borrowernumber
          . $failedrenews
          . $failedreturn );
}
