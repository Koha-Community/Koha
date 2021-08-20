package Koha::REST::V1::ArticleRequests;

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

use Koha::Database;
use Koha::ArticleRequests;

use Scalar::Util qw( blessed );
use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::ArticleRequests

=head1 API

=head2 Methods

=head3 cancel

Controller function that handles cancelling a Koha::ArticleRequest object

=cut

sub cancel {
    my $c = shift->openapi->valid_input or return;

    my $ar = Koha::ArticleRequests->find( $c->validation->param('ar_id') );

    unless ( $ar ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Article request not found" }
        );
    }

    my $reason = $c->validation->param('cancellation_reason');
    my $notes = $c->validation->param('notes');

    return try {

        $ar->cancel($reason, $notes);
        return $c->render(
            status  => 204,
            openapi => q{}
        );
    } catch {
        if ( blessed $_ && $_->isa('Koha::Exceptions::ArticleRequests::FailedCancel') ) {
            return $c->render(
                status  => 403,
                openapi => { error => "Article request cannot be canceled" }
            );
        }

        $c->unhandled_exception($_);
    };
}

1;