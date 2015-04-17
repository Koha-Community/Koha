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
use C4::Branch;

use CGI;

my $query = new CGI;

my $colId    = $query->param('colId');
my $toBranch = $query->param('toBranch');

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
my ( $success, $errorCode, $errorMessage );
if ($toBranch) {
    ( $success, $errorCode, $errorMessage ) =
      TransferCollection( $colId, $toBranch );

    if ($success) {
        $template->param( transferSuccess => 1 );
    }
    else {
        $template->param(
            transferFailure => 1,
            errorCode       => $errorCode,
            errorMessage    => $errorMessage
        );
    }
}

## Set up the toBranch select options
my $branches = GetBranches();
my @branchoptionloop;
foreach my $br ( keys %$branches ) {
    my %branch;
    $branch{code} = $br;
    $branch{name} = $branches->{$br}->{'branchname'};
    push( @branchoptionloop, \%branch );
}
@branchoptionloop = sort {$a->{name} cmp $b->{name}} @branchoptionloop;

## Get data about collection
my ( $colId, $colTitle, $colDesc, $colBranchcode ) = GetCollection($colId);
$template->param(
    colId            => $colId,
    colTitle         => $colTitle,
    colDesc          => $colDesc,
    colBranchcode    => $colBranchcode,
    branchoptionloop => \@branchoptionloop
);

output_html_with_http_headers $query, $cookie, $template->output;
