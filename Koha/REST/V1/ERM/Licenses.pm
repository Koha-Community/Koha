package Koha::REST::V1::ERM::Licenses;

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

use Koha::ERM::Licenses;

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $licenses = $c->objects->search( Koha::ERM::Licenses->new );
        return $c->render( status => 200, openapi => $licenses );
    }
    catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

Controller function that handles retrieving a single Koha::ERM::License object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $license = $c->objects->find( Koha::ERM::Licenses->search, $c->param('license_id') );

        return $c->render_resource_not_found("License")
            unless $license;

        return $c->render(
            status  => 200,
            openapi => $license
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::ERM::License object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $user_roles          = delete $body->{user_roles}          // [];
                my $documents           = delete $body->{documents}           // [];
                my $extended_attributes = delete $body->{extended_attributes} // [];

                my $license = Koha::ERM::License->new_from_api($body)->store;
                $license->user_roles($user_roles);
                $license->documents($documents);

                my @extended_attributes =
                    map { { 'id' => $_->{field_id}, 'value' => $_->{value} } } @{$extended_attributes};
                $license->extended_attributes( \@extended_attributes );

                $c->res->headers->location($c->req->url->to_string . '/' . $license->license_id);
                return $c->render(
                    status  => 201,
                    openapi => $c->objects->to_api($license),
                );
            }
        );
    }
    catch {

        my $to_api_mapping = Koha::ERM::License->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->broken_fk }
                            . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->parameter }
                            . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::PayloadTooLarge') ) {
                return $c->render(
                    status  => 413,
                    openapi => { error => $_->error }
                );
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::ERM::License object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $license = Koha::ERM::Licenses->find( $c->param('license_id') );

    return $c->render_resource_not_found("License")
        unless $license;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $user_roles          = delete $body->{user_roles}          // [];
                my $documents           = delete $body->{documents}           // [];
                my $extended_attributes = delete $body->{extended_attributes} // [];

                $license->set_from_api($body)->store;
                $license->user_roles($user_roles);
                $license->documents($documents);

                my @extended_attributes =
                    map { { 'id' => $_->{field_id}, 'value' => $_->{value} } } @{$extended_attributes};
                $license->extended_attributes( \@extended_attributes );

                return $c->render(
                    status  => 200,
                    openapi => $c->objects->to_api($license),
                );
            }
        );
    }
    catch {
        my $to_api_mapping = Koha::ERM::License->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->broken_fk }
                            . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->parameter }
                            . " does not exist"
                    }
                );
            }
            elsif ( $_->isa('Koha::Exceptions::PayloadTooLarge') ) {
                return $c->render(
                    status  => 413,
                    openapi => { error => $_->error }
                );
            }
        }

        $c->unhandled_exception($_);
    };
};

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $license = Koha::ERM::Licenses->find( $c->param('license_id') );

    return $c->render_resource_not_found("License")
        unless $license;

    return try {
        $license->delete;
        return $c->render_resource_deleted;
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
