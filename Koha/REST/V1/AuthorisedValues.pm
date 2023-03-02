package Koha::REST::V1::AuthorisedValues;

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

use Koha::AuthorisedValueCategories;

use Try::Tiny;

=head1 API

=head2 Methods

=head3 list_av_from_category

This routine returns the authorised values for a given category

=cut

sub list_av_from_category {
    my $c = shift->openapi->valid_input or return;

    my $category_name = $c->validation->param('authorised_value_category_name');

    my $category = Koha::AuthorisedValueCategories->find($category_name);

    unless ($category) {
        return $c->render(
            status  => 404,
            openapi => { error => "Category not found" }
        );
    }

    return try {
        my $av_set = $category->authorised_values->search_with_library_limits;
        my $avs    = $c->objects->search($av_set);
        return $c->render( status => 200, openapi => $avs );
    } catch {
        $c->unhandled_exception($_);
    };

}

1;
