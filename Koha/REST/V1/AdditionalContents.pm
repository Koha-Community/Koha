package Koha::REST::V1::AdditionalContents;

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

use Mojo::Base 'Mojolicious::Controller';

use Koha::AdditionalContents;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list_public

Controller function that handles retrieving a list of additional contents

=cut

sub list_public {
    my $c = shift->openapi->valid_input or return;

    return try {

        my @public_locations = (
            @{ Koha::AdditionalContents::get_html_customizations_options('opac') },
            'staff_and_opac',
            'opac_only'
        );

        my $public_additional_contents_query =
            Koha::AdditionalContents::get_public_query_search_params( { location => { '-in' => \@public_locations } } );

        my $additional_contents =
            $c->objects->search( Koha::AdditionalContents->search($public_additional_contents_query) );

        return $c->render( status => 200, openapi => $additional_contents );
    } catch {
        $c->unhandled_exception($_);
    };

}

1;
