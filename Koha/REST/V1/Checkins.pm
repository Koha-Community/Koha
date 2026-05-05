package Koha::REST::V1::Checkins;

use Modern::Perl;

use Mojo::Base 'Mojolicious::Controller';

use C4::Circulation qw( AddReturn );
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

    my $item_id    = $c->param('item_id');
    my $library_id = $c->param('library_id');

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
    my $library_id = $body->{library_id};
    my $exemptfine = $body->{exempt_fine};

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

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($checkin),
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
