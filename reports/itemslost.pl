#!/usr/bin/perl

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


=head1 itemslost

This script displays lost items.

=cut

use strict;
use CGI;
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Koha;                  # GetItemTypes
use C4::Branch; # GetBranches

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "reports/itemslost.tmpl",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reportss => 1 },
        debug           => 1,
    }
);

my $params = $query->Vars;

if ( $params->{'get_items'} ) {
    my $orderbyfilter   = $params->{'orderbyfilter'}   || undef;
    my $branchfilter    = $params->{'branchfilter'}    || undef;
    my $barcodefilter   = $params->{'barcodefilter'}   || undef;
    my $itemtypesfilter = $params->{'itemtypesfilter'} || undef;

    my %where;
    $where{homebranch} = $branchfilter    if defined $branchfilter;
    $where{barcode}    = $barcodefilter   if defined $barcodefilter;
    $where{itemtype}   = $itemtypesfilter if defined $itemtypesfilter;

    my $items = GetLostItems( \%where, $orderbyfilter );
    $template->param(
        total     => scalar @$items,
        itemsloop => $items
    );
}

# getting all branches.
my $branches = GetBranches;
my $branch   = C4::Context->userenv->{"branchname"};
my @branchloop;
foreach my $thisbranch ( keys %$branches ) {
    my $selected = 1 if $thisbranch eq $branch;
    my %row = (
        value      => $thisbranch,
        selected   => $selected,
        branchname => $branches->{$thisbranch}->{'branchname'},
    );
    push @branchloop, \%row;
}

# getting all itemtypes
my $itemtypes = &GetItemTypes();
my @itemtypesloop;
foreach my $thisitemtype ( sort keys %$itemtypes ) {
    my %row = (
        value       => $thisitemtype,
        description => $itemtypes->{$thisitemtype}->{'description'},
    );
    push @itemtypesloop, \%row;
}

$template->param(
    branchloop   => \@branchloop,
    itemtypeloop => \@itemtypesloop,
);

# writing the template
output_html_with_http_headers $query, $cookie, $template->output;
