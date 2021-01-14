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

    my $filered_items = $items->filter_by_visible_in_opac(
        {
            [ patron => $patron ]
        }
    );

Returns a new resultset, containing those items that are not expected to be hidden in OPAC
for the passed I<Koha::Patron> object that is passed.

The I<OpacHiddenItems>, I<hidelostitems> and I<OpacHiddenItemsExceptions> system preferences
are honoured.

=cut

sub filter_by_visible_in_opac {
    my ($self, $params) = @_;

    my $patron = $params->{patron};

    my $result = $self;

    # Filter out OpacHiddenItems unless disabled by OpacHiddenItemsExceptions
    unless ( $patron and $patron->category->override_hidden_items ) {
        my $rules = C4::Context->yaml_preference('OpacHiddenItems') // {};

        my $rules_params;
        foreach my $field (keys %$rules){
            $rules_params->{$field}->{'-not_in'} = $rules->{$field};
        }

        $result = $result->search( $rules_params );
    }

    if (C4::Context->preference('hidelostitems')) {
        $result = $result->filter_out_lost;
    }

    return $result;
}

=head3 filter_out_lost

    my $filered_items = $items->filter_out_lost;

Returns a new resultset, containing those items that are not marked as lost.

=cut

sub filter_out_lost {
    my ($self) = @_;

    my $params = { itemlost => 0 };

    return $self->search( $params );
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
Tomas Cohen Arazi <tomascohen@theke.io>
Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
