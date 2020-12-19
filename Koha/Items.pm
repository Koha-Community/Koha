package Koha::Items;

# Copyright ByWater Solutions 2014
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

use Modern::Perl;

use Carp;

use Koha::Database;

use Koha::Item;

use base qw(Koha::Objects);

=head1 NAME

Koha::Items - Koha Item object set class

=head1 API

=head2 Class methods

=cut

=head3 filter_by_visible_in_opac

    my $filered_items = $items->filter_by_visible_in_opac;

Returns a new resultset, containing those items that are not expected to be hidden in OPAC.
The I<OpacHiddenItems> and I<hidelostitems> system preferences are honoured.

=cut

sub filter_by_visible_in_opac {
    my ($self, $params) = @_;

    my $rules = C4::Context->yaml_preference('OpacHiddenItems') // {};

    my $rules_params;
    foreach my $field (keys %$rules){
        $rules_params->{$field}->{'-not_in'} = $rules->{$field};
    }

    my $itemlost_params;
    $itemlost_params = { itemlost => 0 }
        if C4::Context->preference('hidelostitems');

    my $search_params;
    if ( $rules_params and $itemlost_params ) {
        $search_params = {
            '-and' => [ $rules_params, $itemlost_params ]
        };
    }
    else {
        $search_params = $rules_params // $itemlost_params;
    }

    return $self->search( $search_params );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Item';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Item';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
