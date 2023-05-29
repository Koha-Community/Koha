package Koha::REST::V1::TransferLimits;

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
use Koha::Item::Transfer::Limits;
use Koha::Libraries;

use Koha::Exceptions::TransferLimit;

use Scalar::Util qw( blessed );

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::TransferLimits - Koha REST API for handling libraries (V1)

=head1 API

=head2 Methods

=cut

=head3 list

Controller function that handles listing Koha::Item::Transfer::Limits objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $limits = $c->objects->search( Koha::Item::Transfer::Limits->new );
        return $c->render( status => 200, openapi => $limits );
    }
    catch {
        $c->unhandled_exception( $_ );
    };
}

=head3 add

Controller function that handles adding a new transfer limit

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->json;
        my $transfer_limit = Koha::Item::Transfer::Limit->new_from_api( $params );

        if ( Koha::Item::Transfer::Limits->search( $transfer_limit->attributes_from_api($params) )->count == 0 ) {
            $transfer_limit->store;
        } else {
            Koha::Exceptions::TransferLimit::Duplicate->throw();
        }

        return $c->render(
            status  => 201,
            openapi => $transfer_limit->to_api
        );
    }
    catch {
        if ( blessed $_ && $_->isa('Koha::Exceptions::TransferLimit::Duplicate') ) {
            return $c->render(
                status  => 409,
                openapi => { error => "$_" }
            );
        }

        $c->unhandled_exception($_);
    };
}

=head3 delete

Controller function that handles deleting a transfer limit

=cut

sub delete {

    my $c = shift->openapi->valid_input or return;

    my $transfer_limit = Koha::Item::Transfer::Limits->find( $c->param( 'limit_id' ) );

    if ( not defined $transfer_limit ) {
        return $c->render( status => 404, openapi => { error => "Transfer limit not found" } );
    }

    return try {
        $transfer_limit->delete;
        return $c->render( status => 204, openapi => '');
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 batch_add

Controller function that handles adding a new transfer limit

=cut

sub batch_add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->json;

        my @libraries = Koha::Libraries->search->as_list;

        my @from_branches = $params->{from_library_id} ? $params->{from_library_id} : map { $_->id } @libraries;
        my @to_branches = $params->{to_library_id} ? $params->{to_library_id} : map { $_->id } @libraries;

        my @results;
        foreach my $from ( @from_branches ) {
            foreach my $to ( @to_branches ) {
                my $limit_params = { %$params };

                $limit_params->{from_library_id} = $from;
                $limit_params->{to_library_id} = $to;

                next if $to eq $from;

                my $transfer_limit = Koha::Item::Transfer::Limit->new_from_api( $limit_params );
                my $exists = Koha::Item::Transfer::Limits->search( $transfer_limit->unblessed )->count;
                unless ( $exists ) {
                    $transfer_limit->store;
                    push( @results, $transfer_limit->to_api());
                }
            }
        }
        my $transfer_limit = Koha::Item::Transfer::Limit->new_from_api( $params );

        return $c->render(
            status  => 201,
            openapi => \@results
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 batch_delete

Controller function that handles batch deleting transfer limits

=cut

sub batch_delete {

    my $c = shift->openapi->valid_input or return;

    return try {
        my $params = $c->req->json;
        my $transfer_limit = Koha::Item::Transfer::Limit->new_from_api( $params );
        my $search_params = $transfer_limit->unblessed;

        Koha::Item::Transfer::Limits->search($search_params)->delete;

        return $c->render( status => 204, openapi => '');
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
