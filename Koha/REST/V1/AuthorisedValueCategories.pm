package Koha::REST::V1::AuthorisedValueCategories;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::AuthorisedValues;
use Koha::AuthorisedValueCategories;

use Try::Tiny;

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $authorised_value_categories_set = Koha::AuthorisedValueCategories->new;
        my $authorised_value_categories = $c->objects->search( $authorised_value_categories_set );
        return $c->render( status => 200, openapi => $authorised_value_categories );
    }
    catch {
        $c->unhandled_exception($_);
    };

}

1;
