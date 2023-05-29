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

    my $article_request = Koha::ArticleRequests->find( $c->param('article_request_id') );

    unless ( $article_request ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Article request not found" }
        );
    }

    my $reason = $c->param('cancellation_reason');
    my $notes  = $c->param('notes');

    return try {

        $article_request->cancel(
            {
                cancellation_reason => $reason,
                notes               => $notes
            }
        );
        return $c->render(
            status  => 204,
            openapi => q{}
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 patron_cancel (public route)

Controller function that handles cancelling a patron's Koha::ArticleRequest object

=cut

sub patron_cancel {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    unless ( $patron ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Patron not found" }
        );
    }

    # patron_id has been validated by the allow-owner check, so the following call to related
    # article requests covers the case of article requests not belonging to the patron
    my $article_request = $patron->article_requests->find( $c->param('article_request_id') );

    unless ( $article_request ) {
        return $c->render(
            status  => 404,
            openapi => { error => "Article request not found" }
        );
    }

    my $reason = $c->param('cancellation_reason');
    my $notes  = $c->param('notes');

    return try {

        $article_request->cancel(
            {
                cancellation_reason => $reason,
                notes               => $notes
            }
        );
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
