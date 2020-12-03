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

    my $filered_items = $items->filter_by_visible_in_opac({ rules => $rules });

Returns a new resultset, containing those items that are not expected to be hidden in OPAC.
If no I<rules> are passed, it returns the whole resultset, with the only caveat that the
I<hidelostitems> system preference is honoured.

=cut

sub filter_by_visible_in_opac {
    my ($self, $params) = @_;

    my $rules = $params->{rules} // {};

    my $search_params;
    foreach my $field (keys %$rules){
        $search_params->{$field}->{'-not_in'} = $rules->{$field};
    }

    $search_params->{itemlost}->{'<='} = 0
        if C4::Context->preference('hidelostitems');

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
