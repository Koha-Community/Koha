package Koha::REST::V1::Suggestion;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use C4::Suggestions;
use Koha::Suggestions;

use Try::Tiny;

sub list {
    my $c = shift->openapi->valid_input or return;

    my $params = $c->req->query_params->to_hash;
    my $suggestions;

    return try {
        if (keys %$params) {
            my @valid_params = Koha::Suggestions->columns;
            foreach my $key (keys %$params) {
                delete $params->{$key} unless grep { $key eq $_ } @valid_params;
            }
            $suggestions = Koha::Suggestions->search($params);
        } else {
            $suggestions = Koha::Suggestions->search;
        }

        return $c->render(status => 200, openapi => $suggestions);
    } catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub get {
    my $c = shift->openapi->valid_input or return;

    my $suggestionid = $c->validation->param('suggestionid');
    my $suggestion = Koha::Suggestions->find($suggestionid);

    return try {
        unless ($suggestion) {
            return $c->render(status => 404, openapi => {
                error => "Suggestion not found."
            });
        }

        return $c->render(status => 200, openapi => $suggestion);
    } catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub add {
    my $c = shift->openapi->valid_input or return;

    my $user = $c->stash('koha.user');
    unless ($user) {
        return $c->render(status => 401, json => {
            error => 'Authentication required'
        });
    }

    my $body = $c->req->json;

    return try {
        my $user = $c->stash('koha.user');
        $body->{suggestedby} = $user->borrowernumber;

        my $suggestion = C4::Suggestions::NewSuggestion($body);
        $suggestion = Koha::Suggestions->find($suggestion);

        return $c->render(status => 201, openapi => $suggestion);
    }
    catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub edit {
    my $c = shift->openapi->valid_input or return;

    my $body = $c->req->json;
    my $suggestionid = $c->validation->param('suggestionid');
    my $suggestion = Koha::Suggestions->find($suggestionid);

    return try {
        unless ($suggestion) {
            return $c->render(status => 404, openapi => {
                error => "Suggestion not found."
            });
        }

        $body->{suggestionid} = $suggestionid;

        my $success = C4::Suggestions::ModSuggestion($body);
        unless ($success) {
            return $c->render(status => 400, openapi => {
                error => "Suggestion could not be updated."
            });
        }

        $suggestion = Koha::Suggestions->find($suggestionid);

        return $c->render( status => 200, openapi => $suggestion);
    }
    catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $suggestionid = $c->validation->param('suggestionid');

    return try {
        my $suggestion = Koha::Suggestions->find($suggestionid);
        unless ($suggestion) {
            return $c->render( status => 404, openapi => {
                error => "Suggestion not found"
            });
        }

        my $res = $suggestion->delete;

        if ($res eq '1') {
            return $c->render( status => 200, openapi => {});
        } elsif ($res eq '-1') {
            return $c->render( status => 404, openapi => {});
        } else {
            return $c->render( status => 400, openapi => {});
        }
    } catch {
        Koha::Exceptions::rethrow_exception($_);
    };
}

1;
