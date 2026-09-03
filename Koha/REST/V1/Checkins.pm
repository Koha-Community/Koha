package Koha::REST::V1::Checkins;

# Copyright 2026 Koha Development Team
#
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use C4::Auth        qw( haspermission );
use C4::Circulation qw( AddReturn );
use C4::Context;
use Koha::Items;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Checkins

=head1 API

=head2 Methods

=head3 get_availability

=cut

sub get_availability {
    my $c    = shift->openapi->valid_input or return;
    my $user = $c->stash('koha.user');

    my $item_id = $c->param('item_id');

    # Default to the logged in user's library, same fallback AddReturn
    # itself applies, so the dry-run answers the same question the real
    # checkin will.
    my $library_id = $c->param('library_id') // C4::Context->userenv->{branch};

    my $item = Koha::Items->find($item_id);

    return $c->render_resource_not_found("Item")
        unless $item;

    return try {
        my $availability = $item->checkin_availability(
            {
                library          => $library_id,
                no_short_circuit => 1,
            }
        );

        $availability->set_context( item => $item );
        $availability->set_context( user => $user );

        return $c->render(
            status  => 200,
            openapi => $availability->to_api,
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

=cut

sub add {
    my $c    = shift->openapi->valid_input or return;
    my $user = $c->stash('koha.user');

    my $body       = $c->req->json;
    my $item_id    = $body->{item_id};
    my $barcode    = $body->{external_id};
    my $exemptfine = $body->{exempt_fine};

    # Default to the logged in user's library, same fallback AddReturn
    # itself applies, so the dry-run availability check and the checkin
    # it precedes agree on where the return is happening.
    my $library_id = $body->{library_id} // C4::Context->userenv->{branch};

    # Mirror circ/returns.pl: only a user holding the 'updatecharges' =>
    # 'writeoff' permission may forgive an outstanding overdue fine on
    # return. Silently drop the flag for anyone else, exactly as the
    # staff interface does, rather than rejecting the whole checkin.
    undef $exemptfine
        if $exemptfine && !haspermission( $user->userid, { updatecharges => 'writeoff' } );

    return try {

        unless ( $item_id or $barcode ) {
            return $c->render(
                status  => 400,
                openapi => {
                    error      => 'Missing item_id or external_id',
                    error_code => 'MISSING_OR_WRONG_PARAMETERS',
                }
            );
        }

        my $item;
        if ($item_id) {
            $item = Koha::Items->find($item_id);
        } else {
            $item = Koha::Items->find( { barcode => $barcode } );
        }

        return $c->render_resource_not_found("Item")
            unless $item;

        my $availability = $item->checkin_availability(
            {
                library          => $library_id,
                no_short_circuit => 1,
            }
        );

        if ( !$availability->available ) {
            return $c->render(
                status  => 403,
                openapi => {
                    error      => 'Checkin not authorized',
                    error_code => 'CHECKIN_NOT_AUTHORIZED',
                    blockers   => $availability->blockers,
                }
            );
        }

        if ( $availability->needs_confirmation ) {

            $availability->set_context( item => $item );
            $availability->set_context( user => $user );

            my $confirmed = 0;

            if ( my $token = $c->param('confirmation') ) {
                $confirmed = $availability->check_token($token);
            }

            unless ($confirmed) {
                return $c->render(
                    status  => 412,
                    openapi => {
                        error      => 'Confirmation required',
                        error_code => 'CONFIRMATION_REQUIRED',
                        %{ $availability->to_api },
                    }
                );
            }
        }

        my ( $doreturn, $messages, $issue, $borrower, $checkin ) = AddReturn(
            $item->barcode,
            $library_id,
            $exemptfine,
        );

        # FIXME (Bug 24401): $doreturn/$messages are not inspected here, so
        # this always renders 200 even when AddReturn didn't actually
        # complete the return (e.g. a Wrongbranch/transfer-limit blocker
        # that the availability pre-check above can't see, since it isn't
        # given a to_library the way AddReturn itself computes one; or the
        # DataCorrupted path).
        #
        # Some outcomes ARE already visible in $checkin->to_api:
        # C4::Circulation::AddReturn (~L2891) copies
        # WasTransfered/ResFound/RecallFound/Debarred/ClaimAutoResolved
        # onto the checkin row's transfer_id/hold_id/recall_id/
        # restriction_id/claim_id columns, which checkin.yaml declares
        # and to_api serialises (embeddable too). But the rest of the
        # ~25 outcome messages _attach_messages_to_checkin builds
        # (needs_transfer, wrong_transfer, transfer_arrived, the
        # lost/processing fee messages, not_issued, local_use, was_lost,
        # withdrawn, was_returned, previously/indefinitely debarred,
        # not_for_loan_status_updated, item_location_updated,
        # wrong_branch, data_corrupted, etc.) have no matching column and
        # never reach the response: they only live in
        # $checkin->object_messages (Koha::Object::add_message), and
        # Koha::Object::to_api serialises TO_JSON only, never
        # object_messages; checkin.yaml also has no `messages` property.
        #
        # Suggested direction: branch on $doreturn to pick the response
        # status, and add a `messages` array to checkin.yaml populated
        # from $checkin->object_messages so API consumers can see the
        # full outcome, not just the subset with a dedicated FK column.
        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($checkin),
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
