package Koha::REST::V1::SIP2::Institutions;

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

use Koha::SIP2::Institution;
use Koha::SIP2::Institutions;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $institutions = $c->objects->search( Koha::SIP2::Institutions->new );
        return $c->render( status => 200, openapi => $institutions );
    }
    catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

Controller function that handles retrieving a single Koha::SIP2::Institution object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $institution = $c->objects->find( Koha::SIP2::Institutions->search, $c->param('sip_institution_id') );

        return $c->render_resource_not_found("Institution")
            unless $institution;

        return $c->render(
            status  => 200,
            openapi => $institution
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller function that handles adding a new Koha::SIP2::Institution object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                my $institution = Koha::SIP2::Institution->new_from_api($body)->store;

                $c->res->headers->location($c->req->url->to_string . '/' . $institution->sip_institution_id);
                return $c->render(
                    status  => 201,
                    openapi => $c->objects->to_api($institution),
                );
            }
        );
    }
    catch {

        my $to_api_mapping = Koha::SIP2::Institution->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Object::DuplicateID') ) {
                return $c->render(
                    status  => 409,
                    openapi => { error => $_->error, conflict => $_->duplicate_id }
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
        }

        $c->unhandled_exception($_);
    };
}

=head3 update

Controller function that handles updating a Koha::SIP2::Institution object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $institution = Koha::SIP2::Institutions->find( $c->param('sip_institution_id') );

    return $c->render_resource_not_found("Institution")
        unless $institution;

    return try {
        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;

                $institution->set_from_api($body)->store;

                $c->res->headers->location($c->req->url->to_string . '/' . $institution->sip_institution_id);
                return $c->render(
                    status  => 200,
                    openapi => $c->objects->to_api($institution),
                );
            }
        );
    }
    catch {
        my $to_api_mapping = Koha::SIP2::Institution->new->to_api_mapping;

        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::BadParameter') ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                            error => "Given "
                            . $to_api_mapping->{ $_->parameter }
                            . " does not exist"
                    }
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

    my $institution = Koha::SIP2::Institutions->find( $c->param('sip_institution_id') );

    return $c->render_resource_not_found("Institution")
        unless $institution;

    return try {
        $institution->delete;
        return $c->render_resource_deleted;
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
