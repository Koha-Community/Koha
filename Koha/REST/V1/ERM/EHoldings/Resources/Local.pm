package Koha::REST::V1::ERM::EHoldings::Resources::Local;

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

use Koha::ERM::EHoldings::Resources;

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $package_id = $c->validation->param('package_id');
        my $resources_set =
          $package_id
          ? Koha::ERM::EHoldings::Resources->search( { package_id => $package_id } )
          : Koha::ERM::EHoldings::Resources->new;
        my $resources = $c->objects->search( $resources_set );
        return $c->render( status => 200, openapi => $resources );
    }
    catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

Controller function that handles retrieving a single Koha::ERM::EHoldings::Resource object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $resource_id = $c->validation->param('resource_id');
        my $resource = $c->objects->find( Koha::ERM::EHoldings::Resources->search, $resource_id );

        unless ($resource ) {
            return $c->render(
                status  => 404,
                openapi => { error => "eHolding resource not found" }
            );
        }

        return $c->render(
            status  => 200,
            openapi => $resource,
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
