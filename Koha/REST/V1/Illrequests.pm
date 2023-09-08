package Koha::REST::V1::Illrequests;

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

use C4::Context;
use Koha::Illrequests;
use Koha::Illrequestattributes;
use Koha::Libraries;
use Koha::Patrons;
use Koha::Libraries;
use Koha::DateUtils qw( format_sqldatetime );

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Illrequests

=head2 Operations

=head3 list

Controller function that handles listing Koha::Illrequest objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $reqs = $c->objects->search(Koha::Illrequests->new->filter_by_visible);

        return $c->render(
            status  => 200,
            openapi => $reqs,
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Adds a new ILL request

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {

        Koha::Database->new->schema->txn_do(
            sub {

                my $body = $c->req->json;
                $body->{backend} = delete $body->{ill_backend_id};
                $body->{borrowernumber} = delete $body->{patron_id};
                $body->{branchcode} = delete $body->{library_id};

                my $request = Koha::Illrequest->new->load_backend( $body->{backend} );

                my $create_api = $request->_backend->capabilities('create_api');

                if (!$create_api) {
                    return $c->render(
                        status  => 405,
                        openapi => {
                            errors => [ 'This backend does not allow request creation via API' ]
                        }
                    );
                }

                my $create_result = &{$create_api}($body, $request);
                my $new_id = $create_result->illrequest_id;

                my $new_req = Koha::Illrequests->find($new_id);

                $c->res->headers->location($c->req->url->to_string . '/' . $new_req->illrequest_id);
                return $c->render(
                    status  => 201,
                    openapi => $new_req->to_api
                );
            }
        );
    }
    catch {

        my $to_api_mapping = Koha::Illrequest->new->to_api_mapping;

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
        }

        $c->unhandled_exception($_);
    };
}

1;
