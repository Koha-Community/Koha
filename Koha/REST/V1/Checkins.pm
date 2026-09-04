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

use C4::Circulation qw( AddReturn );
use C4::Context;
use Koha::Checkouts;
use Koha::DateUtils qw( dt_from_string );
use Koha::Items;
use Koha::Libraries;

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
                    }
                );
            }

            # Validated as a string by the spec, unparseable values are rejected here
            $return_date = try { dt_from_string( $return_date, q{iso} ) };
            return $c->render_invalid_parameter_value( { path => q{/body/return_date} } )
                unless $return_date;
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
            $item = Koha::Items->find( { barcode => $barcode } );
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
            return $c->render(
                status  => 403,
                openapi => {
                    error      => 'Checkin blocked',
                    error_code => 'checkin_blocked',
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

        my ( $doreturn, $messages, $issue, $borrower, $checkin ) = AddReturn(
            $item->barcode,
            $library_id,
            $exemptfine,
            $effective_return_date,
        );

        # Serialize outcome messages from the checkin object so API consumers
        # see the full result, not just the subset with a dedicated FK column
        my @messages = map {
            my $msg = { message => $_->message, type => $_->type };
            $msg->{payload} = $_->payload if defined $_->payload;
            $msg;
        } @{ $checkin->object_messages };

        my $response = $c->objects->find( Koha::Checkins->new, $checkin->id );
        $response->{messages} = \@messages if @messages;

        return $c->render(
            status  => 200,
            openapi => $response,
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head2 Internal methods

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
