package Koha::REST::V1::Quotes;

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

use Koha::Quotes;

use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $quotes = $c->objects->search( Koha::Quotes->new );
        return $c->render( status => 200, openapi => $quotes );
    }
    catch {
        $c->unhandled_exception($_);
    };

}

=head3 get

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $quote = Koha::Quotes->find( $c->param('quote_id') );
        unless ($quote) {
            return $c->render(
                status  => 404,
                openapi => { error => "quote not found" }
            );
        }

        return $c->render( status => 200, openapi => $quote->to_api );
    }
    catch {
        $c->unhandled_exception($_);
    }
}

=head3 add

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $quote = Koha::Quote->new_from_api( $c->req->json );
        $quote->store;
        $c->res->headers->location( $c->req->url->to_string . '/' . $quote->id );
        return $c->render(
            status  => 201,
            openapi => $quote->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 update

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $quote = Koha::Quotes->find( $c->param('quote_id') );

    if ( not defined $quote ) {
        return $c->render( status  => 404,
                           openapi => { error => "Object not found" } );
    }

    return try {
        $quote->set_from_api( $c->req->json );
        $quote->store();
        return $c->render( status => 200, openapi => $quote->to_api );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $quote = Koha::Quotes->find( $c->param('quote_id') );
    if ( not defined $quote ) {
        return $c->render( status  => 404,
                           openapi => { error => "Object not found" } );
    }

    return try {
        $quote->delete;
        return $c->render(
            status  => 204,
            openapi => q{}
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
