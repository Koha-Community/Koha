#!/usr/bin/perl

# Copyright Liblime 2007
# Copyright Biblibre 2009
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


=head1 itemslost

This script displays lost items.

=cut

use strict;
use warnings;

use CGI qw ( -utf8 );
use C4::Auth;
use C4::Output;
use C4::Biblio;
use C4::Items;
use C4::Koha;                  # GetItemTypes
use Koha::DateUtils;

my $query = new CGI;
my ( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name   => "reports/itemslost.tt",
        query           => $query,
        type            => "intranet",
        authnotrequired => 0,
        flagsrequired   => { reports => '*' },
        debug           => 1,
    }
);

my $params = $query->Vars;
my $get_items = $params->{'get_items'};

if ( $get_items ) {
    my $branchfilter     = $params->{'branchfilter'}    || undef;
    my $barcodefilter    = $params->{'barcodefilter'}   || undef;
    my $itemtypesfilter  = $params->{'itemtypesfilter'} || undef;
    my $loststatusfilter = $params->{'loststatusfilter'} || undef;

    my %where;
    $where{'homebranch'}       = $branchfilter    if defined $branchfilter;
    $where{'barcode'}          = $barcodefilter   if defined $barcodefilter;
    $where{'authorised_value'} = $loststatusfilter if defined $loststatusfilter;

    my $itype = C4::Context->preference('item-level_itypes') ? "itype" : "itemtype";
    $where{$itype}            = $itemtypesfilter if defined $itemtypesfilter;

    my $items = GetLostItems( \%where );
    foreach my $it (@$items) {
        $it->{'datelastseen'} = eval { output_pref( { dt => dt_from_string( $it->{'datelastseen'} ), dateonly => 1 }); }
                   if ( $it->{'datelastseen'} );
    }

    $template->param(
                     total       => scalar @$items,
                     itemsloop   => $items,
                     get_items   => $get_items,
                     itype_level => C4::Context->preference('item-level_itypes'),
                 );
}

# getting all itemtypes
my $itemtypes = &GetItemTypes();
my @itemtypesloop;
foreach my $thisitemtype ( sort {$itemtypes->{$a}->{translated_description} cmp $itemtypes->{$b}->{translated_description}} keys %$itemtypes ) {
    my %row = (
        value       => $thisitemtype,
        description => $itemtypes->{$thisitemtype}->{'translated_description'},
    );
    push @itemtypesloop, \%row;
}

# get lost statuses
my $lost_status_loop = C4::Koha::GetAuthorisedValues( 'LOST' );

$template->param(
                  itemtypeloop   => \@itemtypesloop,
                  loststatusloop => $lost_status_loop,
);

# writing the template
output_html_with_http_headers $query, $cookie, $template->output;
