package Koha::Item::Templates;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Database;

use Koha::Item::Template;

use base qw(Koha::Objects);

=head1 NAME

Koha::Item::Templates - Koha Item Template Object set class

=head2 METHODS

=head3 get_available

Returns a hashref with keys 'owned' and 'shared' pointing to Koha::Item::Templats objects
representing templates owned by the user or shared to the user respectivetly.

=cut

sub get_available {
    my ( $class, $patron_id ) = @_;

    my $params = {
        order_by => 'name',
        columns  => [ 'id', 'patron_id', 'name', 'is_shared' ],
    };

    return {
        owned => Koha::Item::Templates->search(
            { patron_id => $patron_id },
            $params
        ),
        shared => Koha::Item::Templates->search(
            {
                patron_id => { "!=" => $patron_id },
                is_shared => 1
            },
            $params
        ),
    };
}

=head3 _type

=cut

sub _type {
    return 'ItemEditorTemplate';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Item::Template';
}

1;
