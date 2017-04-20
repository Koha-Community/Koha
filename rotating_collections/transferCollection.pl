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

use CGI qw ( -utf8 );

my $query = new CGI;

my $colId    = $query->param('colId');
my $itemNumber = $query->param('itemNumber');
my $toBranch = $query->param('toBranch');
my $transferAction = $query->param('transferAction');

my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "rotating_collections/transferCollection.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { tools => 'rotating_collections' },
        debug           => 1,
    }
);

## Transfer collection
if ($transferAction eq 'collectionTransfer') {
    my ($success, $errorCode, $problemItems);
    if ($toBranch) {
        ($success, $errorCode, $problemItems) =
          TransferCollection($colId, $toBranch);

        if ($success) {
            $template->param(
                transferSuccess => 1,
                previousAction  => 'collectionTransfer'
            );
        }
        else {
            $template->param(
                transferFailure => 1,
                errorCode       => $errorCode,
                problemItems   => $problemItems,
                previousAction  => 'collectionTransfer'
            );
        }
    }
}

## Transfer an item
if ($transferAction eq 'itemTransfer') {
    my ($success, $errorCode, $errorMessage);
    if ($toBranch && $itemNumber) {
        ($success, $errorCode, $errorMessage) =
            TransferCollectionItem($colId, $itemNumber, $toBranch);
        if ($success) {
            $template->param(
                transferSuccess => 1,
                previousAction  => 'itemTransfer'
            );
        }
        else {
            $template->param(
                transferFailure => 1,
                errorCode       => $errorCode,
                errorMessage    => $errorMessage,
                previousAction  => 'itemTransfer'
            );
        }
    }
}

## Return an item
if ($transferAction eq 'itemReturn') {
    my ($success, $errorCode, $errorMessage);
    if ($colId && $itemNumber) {
        ($success, $errorCode, $errorMessage) =
            ReturnCollectionItemToOrigin($colId, $itemNumber);
        if ($success) {
            $template->param(
                transferSuccess => 1,
                previousAction  => 'itemReturn'
            );
        }
        else {
            $template->param(
                transferFailure => 1,
                errorCode       => $errorCode,
                errorMessage    => $errorMessage,
                previousAction  => 'itemReturn'
            );
        }
    }
}

## Return a collection
if ($transferAction eq 'collectionReturn') {
    my ($success, $errorCode, $errorMessages);
    if ($colId) {
        ($success, $errorCode, $errorMessages) =
            ReturnCollectionToOrigin($colId);
        if ($success) {
            $template->param(
                transferSuccess => 1,
                problemItems    => $errorMessages,
                previousAction  => 'collectionReturn'
            );
        }
        else {
            $template->param(
                transferFailure => 1,
                errorCode       => $errorCode,
                errorMessages    => $errorMessages,
                previousAction  => 'collectionReturn'
            );
        }
    }
}
## Set up the toBranch select options
my $branchoptionloop = Koha::Libraries->search( {}, { order_by => ['branchname'] } )->unblessed;
# my @branchoptionloop;
# foreach my $br ( sort(keys %$branches) ) {
#     my %branch;
#     $branch{code} = $br;
#     $branch{name} = $branches->{$br}->{'branchname'};
#     push( @branchoptionloop, \%branch );
# }


## Get data about collection
my ( $colTitle, $colDesc, $colBranchcode );
( $colId, $colTitle, $colDesc, $colBranchcode ) = GetCollection($colId);
$template->param(
    colId            => $colId,
    colTitle         => $colTitle,
    colDesc          => $colDesc,
    colBranchcode    => $colBranchcode,
    branchoptionloop => $branchoptionloop
);

output_html_with_http_headers $query, $cookie, $template->output;
