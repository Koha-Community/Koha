package Koha::REST::V1::AdditionalFields;

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

use Koha::AdditionalFields;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $tablename = $c->param('tablename');

    return try {
        my $additional_fields_set = Koha::AdditionalFields->new;
        if ($tablename) {
            $additional_fields_set = $additional_fields_set->search( { tablename => $tablename } );
        }
        my $additional_fields = $c->objects->search($additional_fields_set);
        return $c->render( status => 200, openapi => $additional_fields );
    } catch {
        $c->unhandled_exception($_);
    };

}

1;
