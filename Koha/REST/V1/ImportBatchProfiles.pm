package Koha::REST::V1::ImportBatchProfiles;

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

use Koha::ImportBatchProfiles;
use Koha::ImportBatchProfile;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::ImportBatchProfiles - Koha REST API for handling profiles for import batches (V1)

=head1 API

=head2 Methods

=cut

=head3 list

Method that handles listing Koha::ImportBatchProfile objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $profiles = $c->objects->search( Koha::ImportBatchProfiles->new );
        return $c->render(
            status  => 200,
            openapi => $profiles
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Method that handles adding a new Koha::ImportBatchProfile object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    my $body = $c->req->json;

    return try {
        my $profile = Koha::ImportBatchProfile->new_from_api( $body )->store;
        return $c->render(
            status  => 201,
            openapi => $profile->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 edit

Method that handles modifying a Koha::Hold object

=cut

sub edit {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $profile = Koha::ImportBatchProfiles->find( $c->param('import_batch_profile_id') );
        unless ($profile) {
            return $c->render(
                status  => 404,
                openapi => {error => "Import batch profile not found"}
            );
        }

        $profile->set_from_api($c->req->json)->store;

        return $c->render(
            status  => 200,
            openapi => $profile->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Method that handles deleting a Koha::ImportBatchProfile object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $profile = Koha::ImportBatchProfiles->find( $c->param('import_batch_profile_id') );

    unless ($profile) {
        return $c->render( status  => 404,
                        openapi => {error => "Import batch profile not found"} );
    }

    return try {
        $profile->delete;

        return $c->render(
            status => 204,
            openapi => q{}
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
