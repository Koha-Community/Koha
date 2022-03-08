package Koha::REST::V1::Suggestions;

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
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http:°www.gnu.org/licenses>.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use Koha::Suggestions;

use Try::Tiny;

=head1 NAME

Koha::REST::V1::Suggestion

=head1 API

=head2 Methods

=head3 list

Controller method that handles listing Koha::Suggestion objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $suggestions = $c->objects->search( Koha::Suggestions->new );

        return $c->render(
            status  => 200,
            openapi => $suggestions
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller method that handles retrieving a single Koha::Suggestion object

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $suggestion_id = $c->validation->param('suggestion_id');
        my $suggestion = $c->objects->find( Koha::Suggestions->new, $suggestion_id );

        unless ($suggestion) {
            return $c->render(
                status  => 404,
                openapi => { error => "Suggestion not found." }
            );
        }

        return $c->render(
            status  => 200,
            openapi => $suggestion
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Controller method that handles adding a new Koha::Suggestion object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    my $body = $c->validation->param('body');

    # FIXME: This should be handled in Koha::Suggestion->store
    $body->{'status'} = 'ASKED'
        unless defined $body->{'status'};

    my $overrides = $c->stash('koha.overrides');

    unless ( $overrides->{any} ) {

        unless ( $overrides->{max_total} ) {

            if (   C4::Context->preference('MaxTotalSuggestions') ne ''
                && C4::Context->preference('NumberOfSuggestionDays') ne '' )
            {
                my $max_total = C4::Context->preference('MaxTotalSuggestions');
                my $days_range = C4::Context->preference('NumberOfSuggestionDays');

                if ( $max_total and $days_range ) {

                    my $total = Koha::Suggestions->search({ suggestedby => $body->{suggested_by} })
                                                 ->filter_by_suggested_days_range( $days_range )
                                                 ->count;

                    if ( $total >= $max_total ) {
                        return $c->render(
                            status  => 400,
                            openapi => {
                                error       => "Reached the maximum suggestions limit",
                                error_code  => 'max_total_reached'
                            }
                        );
                    }
                }
            }
        }

        unless ( $overrides->{max_pending} ) {
            if ( C4::Context->preference('MaxOpenSuggestions') ne '' ) {
                my $total_pending = Koha::Suggestions->search({ suggestedby => $body->{suggested_by} })
                                                  ->filter_by_pending
                                                  ->count;
                if ( $total_pending >= C4::Context->preference('MaxOpenSuggestions') ) {
                    return $c->render(
                        status  => 400,
                        openapi => {
                            error       => "Reached the maximum pending suggestions limit",
                            error_code  => 'max_pending_reached'
                        }
                    );
                }
            }
        }
    }

    return try {
        my $suggestion = Koha::Suggestion->new_from_api( $body )->store;
        $suggestion->discard_changes;
        $c->res->headers->location( $c->req->url->to_string . '/' . $suggestion->suggestionid );

        return $c->render(
            status  => 201,
            openapi => $suggestion->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 update

Controller method that handles modifying Koha::Suggestion object

=cut

sub update {
    my $c = shift->openapi->valid_input or return;

    my $suggestion_id = $c->validation->param('suggestion_id');
    my $suggestion = Koha::Suggestions->find( $suggestion_id );

    return $c->render(
        status  => 404,
        openapi => { error => 'Suggestion not found.' }
    ) unless $suggestion;

    return try {

        my $body = $c->validation->param('body');

        $suggestion->set_from_api( $body )->store;
        $suggestion->discard_changes;

        return $c->render(
            status  => 200,
            openapi => $suggestion->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };

}

=head3 delete

Controller method that handles removing a Koha::Suggestion object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $suggestion_id = $c->validation->param('suggestion_id');
    my $suggestion = Koha::Suggestions->find( $suggestion_id );

    return $c->render(
        status  => 404,
        openapi => { error => 'Suggestion not found.' }
    ) unless $suggestion;

    return try {
        $suggestion->delete;
        return $c->render(
            status  => 204,
            openapi => q{}
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 list_managers

Return the list of possible suggestions' managers

=cut

sub list_managers {
    my $c = shift->openapi->valid_input or return;

    return try {

        my $patrons_rs = Koha::Patrons->search->filter_by_have_permission('suggestions.suggestions_manage');
        my $patrons    = $c->objects->search( $patrons_rs );

        return $c->render(
            status  => 200,
            openapi => $patrons
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
