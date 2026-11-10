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

use C4::Circulation qw( AddReturn barcodedecode );
use C4::Context;
use DateTime;
use Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue;
use Koha::Checkins;
use Koha::Checkouts;
use Koha::DateUtils qw( dt_from_string );
use Koha::Items;
use Koha::Libraries;
use Koha::Logger;

use Scalar::Util qw( blessed );
use Try::Tiny    qw( catch try );

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

    # Default to the logged in library, same fallback AddReturn itself
    # applies, so the dry-run answers the same question the real checkin will.
    my $library_id = $c->param(q{library_id}) // C4::Context->userenv->{branch};

    return unless $c->_validate_library( { library_id => $library_id, path => q{/query/library_id} } );

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

    my $body        = $c->req->json;
    my $item_id     = $body->{item_id};
    my $barcode     = $body->{external_id};
    my $library_id  = $body->{library_id} // C4::Context->userenv->{branch};
    my $exemptfine  = $body->{exempt_fine};
    my $return_date = $body->{return_date};
    my $dropboxmode = $body->{dropbox_mode};

    return try {

        return unless $c->_validate_library( { library_id => $library_id, path => q{/body/library_id} } );

        # Enforce writeoff permission for exempt_fine
        if ($exemptfine) {
            unless ( $user->has_permission( { updatecharges => 'writeoff' } ) ) {
                return $c->render(
                    status  => 403,
                    openapi => {
                        error      => 'Fine exemption requires updatecharges.writeoff permission',
                        error_code => 'no_permission_for_exempt_fine',
                        policy     => $c->module_policy( 'Checkin', { library => $library_id } ),
                    }
                );
            }
        }

        # Enforce SpecifyReturnDate preference for return_date
        if ($return_date) {
            unless ( C4::Context->preference('SpecifyReturnDate') ) {
                return $c->render(
                    status  => 403,
                    openapi => {
                        error      => 'Return date override is not enabled',
                        error_code => 'return_date_not_allowed',
                        policy     => $c->module_policy( 'Checkin', { library => $library_id } ),
                    }
                );
            }

            # Validated as date-time by the spec, the offset is optional. Some
            # valid date-times are not parsed (e.g. with fractions of a second)
            $return_date = try { dt_from_string( $return_date, q{iso} ) };
            return $c->render_invalid_parameter_value( { path => q{/body/return_date} } )
                unless $return_date;

            if ( DateTime->compare( $return_date, dt_from_string() ) > 0 ) {
                return $c->render(
                    status  => 400,
                    openapi => {
                        error      => 'The return date cannot be in the future',
                        error_code => 'return_date_in_future',
                    }
                );
            }
        }

        unless ( $item_id or $barcode ) {
            return $c->render(
                status  => 400,
                openapi => {
                    error      => 'Missing item_id or external_id',
                    error_code => 'missing_item_identifier',
                }
            );
        }

        if ( $item_id and $barcode ) {
            return $c->render(
                status  => 400,
                openapi => {
                    error      => 'item_id and external_id are mutually exclusive',
                    error_code => 'mutually_exclusive_parameters',
                }
            );
        }

        my $item;
        if ($item_id) {
            $item = Koha::Items->find($item_id);
        } else {

            # Apply itemBarcodeInputFilter and the item_barcode_transform plugin hook
            $barcode = barcodedecode($barcode);
            $item    = Koha::Items->find( { barcode => $barcode } );
        }

        return $c->render_resource_not_found("Item")
            unless $item;

        # AddReturn works on barcodes, an item without one cannot be checked in
        unless ( defined $item->barcode && length $item->barcode ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error      => q{The item has no barcode},
                    error_code => q{item_without_barcode},
                }
            );
        }

        my $availability = $item->checkin_availability(
            {
                library          => $library_id,
                no_short_circuit => 1,
            }
        );

        if ( !$availability->available ) {

            # The item is not returned, but AddReturn is still called, as the
            # legacy returns page did: it handles the blockers itself, and
            # records the check-in, the local use, the date last seen and the
            # location and not for loan updates
            my ( undef, undef, undef, undef, $checkin ) = AddReturn( $item->barcode, $library_id );

            return $c->render(
                status  => 403,
                openapi => {
                    error      => 'Checkin blocked',
                    error_code => 'checkin_blocked',
                    blockers   => $availability->blockers,
                    item       => $item->to_api( { embed => { biblio => {} } } ),
                    checkin_id => $checkin ? $checkin->id : undef,
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

            # A caller may opt out of specific confirmations via x-koha-override.
            # The 'not_issued' confirmation (item was not checked out) can be
            # overridden so the check-in is recorded directly - matching the
            # legacy returns page, which never prompts for a not-issued item.
            #
            # NOTE: overrides are handled here in the controller, consistent
            # with the other REST endpoints (checkouts, holds, ...). Once a
            # Koha::Circulation->checkin business-logic method exists, the
            # overrides should be passed down to it so the domain layer owns
            # this decision instead of the controller.
            unless ($confirmed) {
                my $overrides     = $c->stash('koha.overrides') // {};
                my @confirmations = keys %{ $availability->confirmations };
                if (   $overrides->{not_issued}
                    && scalar(@confirmations) == 1
                    && $confirmations[0] eq 'not_issued' )
                {
                    $confirmed = 1;
                }
            }

            unless ($confirmed) {
                return $c->render(
                    status  => 412,
                    openapi => {
                        error      => 'Confirmation required',
                        error_code => 'confirmation_required',
                        item       => $item->to_api( { embed => { biblio => {} } } ),
                        %{ $availability->to_api },
                    }
                );
            }
        }

        # TODO: Move date calculation into Koha::Circulation->checkin when it exists.
        # The controller should pass intent (dropbox => 1, return_date => $string)
        # and the domain layer should handle the calculation internally.
        my $effective_return_date;
        if ($dropboxmode) {
            $effective_return_date = Koha::Checkouts->calculate_dropbox_date();
        } elsif ($return_date) {
            $effective_return_date = $return_date;
        }

        # Cancel the waiting holds for which cancellation has been requested, as
        # the legacy returns page did, so the return does not set them aside again
        my $holds_to_cancel = $item->holds->waiting->filter_by_has_cancellation_requests;
        while ( my $hold = $holds_to_cancel->next ) {
            $hold->cancel;
        }

        my ( $doreturn, $messages, $issue, $borrower, $checkin ) = AddReturn(
            $item->barcode,
            $library_id,
            $exemptfine,
            $effective_return_date,
        );

        # AddReturn could not return the item (e.g. a data problem). Report the
        # failure without the internal error, which is logged, and skip the
        # post-return processing
        if ( $messages->{DataCorrupted} ) {
            Koha::Logger->get->error(
                sprintf( "Check-in of item %s failed: %s", $item->itemnumber, $messages->{DataCorrupted} ) );
            return $c->render(
                status  => 500,
                openapi => {
                          error => 'The item has not been checked in due to an issue in your system.'
                        . ' An administrator may find further details in the logs, and in the'
                        . ' "System information" tab of the About page',
                    error_code => 'checkin_failed',
                }
            );
        }

        # TODO: Move the post-return processing below into Koha::Circulation->checkin
        # when it exists, as with the date calculation above.

        # Wrong transfer: replace the transfer so it starts from where the item really is
        if ( $messages->{WrongTransfer} && !$messages->{WasTransfered} ) {
            $checkin->replace_wrong_transfer;
        }

        # HoldsAutoFill: fill the hold that was found instead of asking for confirmation
        my $hold_found = $messages->{ResFound};
        if (   $hold_found
            && $hold_found->{ResFound} ne 'Waiting'
            && C4::Context->preference('HoldsAutoFill') )
        {
            # The item has already been returned: if the hold cannot be
            # filled, report it on the checkin instead of failing the request
            try {
                $checkin->confirm_hold;
                $checkin->add_message(
                    {
                        message => 'hold_auto_filled',
                        type    => 'info',
                        payload => {
                            reserve_id => $hold_found->{reserve_id},
                            library_id => $hold_found->{branchcode},
                        },
                    }
                );
            } catch {
                my $error_code;
                if ( blessed $_ && $_->isa('Koha::Exceptions::Checkin::HoldNotFound') ) {
                    $error_code = 'hold_not_found';
                } elsif ( blessed $_ && $_->isa('Koha::Exceptions::Checkin::ItemCheckedOut') ) {
                    $error_code = 'item_checked_out';
                } else {
                    die $_;
                }
                $checkin->add_message(
                    {
                        message => 'hold_auto_fill_failed',
                        type    => 'warning',
                        payload => {
                            reserve_id => $hold_found->{reserve_id},
                            error_code => $error_code,
                        },
                    }
                );
            };
        }

        # AddReturn skips the holds queue update: refresh it as the legacy
        # returns page did. When a hold was found, the staff may dismiss it
        # client-side without calling the API, so update the queue in that
        # case too (the legacy page did it on 'Ignore').
        Koha::BackgroundJob::BatchUpdateBiblioHoldsQueue->new->enqueue( { biblio_ids => [ $item->biblionumber ] } )
            if ( $doreturn || $hold_found )
            && C4::Context->preference('RealTimeHoldsQueue');

        # Bundle verification: mark missing items as lost, remove unexpected ones
        if ( $item->is_bundle && defined $body->{verified_bundle_barcodes} ) {
            my $result = $checkin->verify_bundle(
                {
                    verified_barcodes => $body->{verified_bundle_barcodes},
                    patron_id         => $borrower ? $borrower->{borrowernumber} : undef,
                }
            );
            my %bundle_messages = (
                bundle_missing_items    => $result->{missing},
                bundle_unexpected_items => $result->{unexpected},
            );
            for my $message ( sort keys %bundle_messages ) {
                my @items = @{ $bundle_messages{$message} };
                next unless @items;
                $checkin->add_message(
                    {
                        message => $message,
                        type    => 'warning',
                        payload => {
                            items => [
                                map {
                                    {
                                        item_id     => $_->itemnumber,
                                        external_id => $_->barcode,
                                        title       => $_->biblio->title,
                                    }
                                } @items
                            ],
                        },
                    }
                );
            }
        }

        # Serialize outcome messages from the checkin object so API consumers
        # see the full result, not just the subset with a dedicated FK column
        my @messages = map {
            my $msg = { message => $_->message, type => $_->type };
            $msg->{payload} = $_->payload if defined $_->payload;
            $msg;
        } @{ $checkin->object_messages };

        my $response = $c->objects->find( Koha::Checkins->new, $checkin->id );
        $response->{messages} = \@messages if @messages;

        # Tokens the follow-up actions offered for this checkin require
        $response->{action_tokens} = $checkin->action_tokens( { user => $user } );

        return $c->render(
            status  => 200,
            openapi => $response,
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 hold_confirmation

POST /checkins/{checkin_id}/hold_confirmation

=cut

sub hold_confirmation {
    my $c = shift->openapi->valid_input or return;

    my $checkin = $c->_get_actionable_checkin('hold_confirmation') or return;

    return $c->render(
        status  => 400,
        openapi => { error => q{No hold associated with this checkin}, error_code => q{no_hold_associated} }
    ) unless $checkin->hold_id;

    return try {
        $checkin->confirm_hold;
        return $c->_render_checkin_response($checkin);
    } catch {
        if ( blessed $_ && $_->isa('Koha::Exceptions::Checkin::HoldNotFound') ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error      => 'The hold no longer exists',
                    error_code => 'hold_not_found',
                }
            );
        }
        if ( blessed $_ && $_->isa('Koha::Exceptions::Checkin::ItemCheckedOut') ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error =>
                        'The item has been checked out in the meantime: the hold has not been set aside and remains pending',
                    error_code => 'item_checked_out',
                }
            );
        }
        $c->unhandled_exception($_);
    };
}

=head3 hold_cancellation

POST /checkins/{checkin_id}/hold_cancellation

=cut

sub hold_cancellation {
    my $c = shift->openapi->valid_input or return;

    my $checkin = $c->_get_actionable_checkin('hold_cancellation') or return;

    return $c->render(
        status  => 400,
        openapi => { error => q{No hold associated with this checkin}, error_code => q{no_hold_associated} }
    ) unless $checkin->hold_id;

    my $body = $c->req->json // {};
    my $user = $c->stash('koha.user');

    # Enforce writeoff permission for forgive_hold_fees
    if ( $body->{forgive_hold_fees} ) {
        unless ( $user->has_permission( { updatecharges => 'writeoff' } ) ) {
            return $c->render(
                status  => 403,
                openapi => {
                    error      => 'Forgiving hold fees requires updatecharges.writeoff permission',
                    error_code => 'no_permission_for_forgive_hold_fees',
                    policy     => $c->module_policy( 'Checkin', { library => $checkin->library_id } ),
                }
            );
        }
    }

    return try {
        $checkin->cancel_hold(
            {
                reason            => $body->{reason},
                forgive_hold_fees => $body->{forgive_hold_fees} ? 1 : 0,
            }
        );
        return $c->_render_checkin_response($checkin);
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 transfer_confirmation

POST /checkins/{checkin_id}/transfer_confirmation

=cut

sub transfer_confirmation {
    my $c = shift->openapi->valid_input or return;

    my $checkin = $c->_get_actionable_checkin('transfer_confirmation') or return;

    my $body = $c->req->json // {};

    # No transfer yet (AutomaticItemReturn disabled): the destination is required
    unless ( $checkin->transfer_id ) {
        return $c->render(
            status  => 400,
            openapi => { error => q{No transfer associated with this checkin}, error_code => q{no_transfer_associated} }
        ) unless $body->{to_library_id};

        return $c->render_invalid_parameter_value( { path => q{/body/to_library_id} } )
            unless Koha::Libraries->find( $body->{to_library_id} );
    }

    return try {
        $checkin->confirm_transfer(
            {
                to_library_id => $body->{to_library_id},
                reason        => $body->{reason},
            }
        );
        return $c->_render_checkin_response($checkin);
    } catch {
        if ( blessed $_ ) {
            if ( $_->isa('Koha::Exceptions::Item::Transfer::Limit') ) {
                return $c->render(
                    status  => 409,
                    openapi => {
                        error      => 'Transfer not allowed by the branch transfer limits',
                        error_code => 'transfer_limit',
                    }
                );
            }
            if ( $_->isa('Koha::Exceptions::Item::Transfer::InQueue') ) {
                return $c->render(
                    status  => 409,
                    openapi => {
                        error      => 'The item already has a pending transfer',
                        error_code => 'transfer_in_queue',
                    }
                );
            }
            return $c->_render_transfer_finished
                if $_->isa('Koha::Exceptions::Checkin::TransferFinished');
        }
        $c->unhandled_exception($_);
    };
}

=head3 transfer_cancellation

POST /checkins/{checkin_id}/transfer_cancellation

=cut

sub transfer_cancellation {
    my $c = shift->openapi->valid_input or return;

    my $checkin = $c->_get_actionable_checkin('transfer_cancellation') or return;

    return $c->render(
        status  => 400,
        openapi => { error => q{No transfer associated with this checkin}, error_code => q{no_transfer_associated} }
    ) unless $checkin->transfer_id;

    return try {
        $checkin->cancel_transfer;
        return $c->_render_checkin_response($checkin);
    } catch {
        return $c->_render_transfer_finished
            if blessed $_ && $_->isa('Koha::Exceptions::Checkin::TransferFinished');
        $c->unhandled_exception($_);
    };
}

=head3 recall_confirmation

POST /checkins/{checkin_id}/recall_confirmation

=cut

sub recall_confirmation {
    my $c = shift->openapi->valid_input or return;

    my $checkin = $c->_get_actionable_checkin('recall_confirmation') or return;

    return $c->render(
        status  => 400,
        openapi => { error => q{No recall associated with this checkin}, error_code => q{no_recall_associated} }
    ) unless $checkin->recall_id;

    return try {
        $checkin->confirm_recall;
        return $c->_render_checkin_response($checkin);
    } catch {
        if ( blessed $_ && $_->isa('Koha::Exceptions::Checkin::TransferNotStarted') ) {
            return $c->render(
                status  => 409,
                openapi => {
                    error      => 'The transfer to the recall pickup library could not be started',
                    error_code => 'transfer_not_started',
                    reasons    => [ sort keys %{ $_->messages // {} } ],
                }
            );
        }
        $c->unhandled_exception($_);
    };
}

=head2 Internal methods

=head3 _get_actionable_checkin

    my $checkin = $c->_get_actionable_checkin($action) or return;

Returns the checkin from the I<checkin_id> path parameter if the follow-up
I<$action> can be performed on it. Otherwise it renders the error response
and returns undef:

=over 4

=item * 404 if the checkin does not exist

=item * 403 (I<invalid_action_token>) if the I<action_token> query parameter
is not a valid token for this checkin, user and action (see
L<Koha::Checkin/action_tokens>), or has expired

=item * 409 (I<stale_checkin>) if the item has been checked in again since

=item * 409 (I<item_checked_out>) if the item has been checked out again since

=back

=cut

sub _get_actionable_checkin {
    my ( $c, $action ) = @_;

    my $checkin = Koha::Checkins->find( $c->param('checkin_id') );

    unless ($checkin) {
        $c->render_resource_not_found("Checkin");
        return;
    }

    unless (
        $checkin->check_action_token(
            {
                action => $action,
                user   => $c->stash('koha.user'),
                token  => $c->param('action_token'),
            }
        )
        )
    {
        $c->render(
            status  => 403,
            openapi => {
                error      => 'Invalid or expired action token',
                error_code => 'invalid_action_token',
            }
        );
        return;
    }

    unless ( $checkin->is_latest ) {
        $c->render(
            status  => 409,
            openapi => {
                error      => 'The item has been checked in again since this checkin',
                error_code => 'stale_checkin',
            }
        );
        return;
    }

    if ( $checkin->item->checkout ) {
        $c->render(
            status  => 409,
            openapi => {
                error      => q{The item has been checked out again since this checkin},
                error_code => q{item_checked_out},
            }
        );
        return;
    }

    return $checkin;
}

=head3 _render_checkin_response

Renders the standard checkin response, with the URI of the action
performed as the Location header. The query string is left out, as it
carries the action token.

=cut

sub _render_checkin_response {
    my ( $c, $checkin ) = @_;

    $checkin->discard_changes;

    my $response = $c->objects->find( Koha::Checkins->new, $checkin->id );

    $c->res->headers->location( $c->req->url->path->to_string );

    return $c->render(
        status  => 201,
        openapi => $response,
    );
}

=head3 _render_transfer_finished

Renders the 409 response for a transfer that has already arrived or has
been cancelled.

=cut

sub _render_transfer_finished {
    my ($c) = @_;

    return $c->render(
        status  => 409,
        openapi => {
            error      => 'The transfer has already arrived or has been cancelled',
            error_code => 'transfer_finished',
        }
    );
}

=head3 _validate_library

    return unless $c->_validate_library( { library_id => $library_id, path => $path } );

Renders an error and returns false if the library does not exist (400), or
if the user cannot act on it (403). The same rule applies to the
I<x-koha-library> header: when I<IndependentBranches> is enabled, only
superlibrarians can act on a library other than their own.

=cut

sub _validate_library {
    my ( $c, $params ) = @_;

    my $library = Koha::Libraries->find( $params->{library_id} );

    unless ($library) {
        $c->render_invalid_parameter_value( { path => $params->{path} } );
        return;
    }

    unless ( $c->stash(q{koha.user})->can_log_into($library) ) {
        $c->render(
            status  => 403,
            openapi => {
                error      => q{Unauthorized attempt to act on library } . $library->branchcode,
                error_code => q{library_not_allowed},
            }
        );
        return;
    }

    return 1;
}

1;
