#!/usr/bin/perl

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
#

use Modern::Perl;

use C4::Output;
use C4::Auth;
use C4::Context;
use C4::RotatingCollections;
use C4::Items;

use CGI;

my $query = new CGI;

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "rotating_collections/addItems.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'rotating_collections' },
        debug           => 1,
    }
);

if ( $query->param('action') eq 'addItem' ) {
    ## Add the given item to the collection
    my $colId      = $query->param('colId');
    my $barcode    = $query->param('barcode');
    my $removeItem = $query->param('removeItem');
    my $itemnumber = GetItemnumberFromBarcode($barcode);

    my ( $success, $errorCode, $errorMessage );

    $template->param( barcode => $barcode );

    if ( !$removeItem ) {
        ( $success, $errorCode, $errorMessage ) =
          AddItemToCollection( $colId, $itemnumber );

        $template->param(
            previousActionAdd => 1,
        );

        if ($success) {
            $template->param( addSuccess => 1 );
        }
        else {
            $template->param( addFailure     => 1 );
            $template->param( failureMessage => $errorMessage );
        }
    }
    else {
        ## Remove the given item from the collection
        ( $success, $errorCode, $errorMessage ) =
          RemoveItemFromCollection( $colId, $itemnumber );

        $template->param(
            previousActionRemove => 1,
            removeChecked        => 1,
        );

        if ($success) {
            $template->param( removeSuccess => 1 );
        }
        else {
            $template->param( removeFailure  => 1 );
            $template->param( failureMessage => $errorMessage );
        }

    }
}

my ( $colId, $colTitle, $colDescription, $colBranchcode ) =
  GetCollection( $query->param('colId') );
my $collectionItems = GetItemsInCollection($colId);
if ($collectionItems) {
    $template->param( collectionItemsLoop => $collectionItems );
}

$template->param(
    colId          => $colId,
    colTitle       => $colTitle,
    colDescription => $colDescription,
    colBranchcode  => $colBranchcode,
);

output_html_with_http_headers $query, $cookie, $template->output;
