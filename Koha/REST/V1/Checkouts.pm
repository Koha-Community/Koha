package Koha::REST::V1::Checkouts;

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
use Mojo::JSON;

use C4::Auth qw( haspermission );
use C4::Context;
use C4::Circulation qw( AddIssue AddRenewal CanBookBeRenewed );
use Koha::Checkouts;
use Koha::Old::Checkouts;
use Koha::Token;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::REST::V1::Checkout

=head1 API

=head2 Methods

=head3 list

List Koha::Checkout objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $checked_in = $c->param('checked_in');
    $c->req->params->remove('checked_in');

    try {
        my $checkouts_set;

        if ( $checked_in ) {
            $checkouts_set = Koha::Old::Checkouts->new;
        } else {
            $checkouts_set = Koha::Checkouts->new;
        }

        my $checkouts = $c->objects->search( $checkouts_set );

        return $c->render(
            status  => 200,
            openapi => $checkouts
        );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

get one checkout

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    my $checkout_id = $c->param('checkout_id');
    my $checkout = Koha::Checkouts->find( $checkout_id );
    $checkout = Koha::Old::Checkouts->find( $checkout_id )
        unless ($checkout);

    unless ($checkout) {
        return $c->render(
            status => 404,
            openapi => { error => "Checkout doesn't exist" }
        );
    }

    return try {
        return $c->render(
            status  => 200,
            openapi => $checkout->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 _check_availability

Internal function to call CanBookBeIssued and return an appropriately filtered
set return

=cut

sub _check_availability {
    my ( $c, $patron, $item ) = @_;

    my $inprocess       = 0;                   # What does this do?
    my $ignore_reserves = 0;                   # Don't ignore reserves
    my $params          = { item => $item };

    my ( $impossible, $confirmation, $alerts, $messages ) =
      C4::Circulation::CanBookBeIssued( $patron, undef, undef, $inprocess,
        $ignore_reserves, $params );

    if ( $c->stash('is_public') ) {

        # Upgrade some confirmations to blockers
        my @should_block =
          qw/TOO_MANY ISSUED_TO_ANOTHER RESERVED RESERVED_WAITING TRANSFERRED PROCESSING AGE_RESTRICTION/;
        for my $block (@should_block) {
            if ( exists( $confirmation->{$block} ) ) {
                $impossible->{$block} = $confirmation->{$block};
                delete $confirmation->{$block};
            }
        }

        # Remove any non-public info that's returned by CanBookBeIssued
        my @restricted_keys =
          qw/issued_borrowernumber issued_cardnumber issued_firstname issued_surname resborrowernumber resbranchcode rescardnumber reserve_id resfirstname resreservedate ressurname item_notforloan/;
        for my $key (@restricted_keys) {
            delete $confirmation->{$key};
            delete $impossible->{$key};
            delete $alerts->{$key};
            delete $messages->{$key};
        }
    }

    return ( $impossible, $confirmation, { %{$alerts}, %{$messages} } );
}

=head3 get_availability

Controller function that handles retrieval of Checkout availability

=cut

sub get_availability {
    my $c = shift->openapi->valid_input or return;
    my $user = $c->stash('koha.user');

    my $patron = Koha::Patrons->find( $c->param('patron_id') );
    my $item   = Koha::Items->find( $c->param('item_id') );

    my ( $impossible, $confirmation, $warnings ) =
      $c->_check_availability( $patron, $item );

    my @confirm_keys = sort keys %{$confirmation};
    unshift @confirm_keys, $item->id;
    unshift @confirm_keys, $user->id
      if $user;

    my $token = Koha::Token->new->generate_jwt( { id => join( ':', @confirm_keys ) } );

    my $response = {
        blockers           => $impossible,
        confirms           => $confirmation,
        warnings           => $warnings,
        confirmation_token => $token
    };

    return $c->render( status => 200, openapi => $response );
}

=head3 add

Add a new checkout

=cut

sub add {
    my $c = shift->openapi->valid_input or return;
    my $user = $c->stash('koha.user');

    my $body      = $c->req->json;
    my $item_id   = $body->{item_id};
    my $patron_id = $body->{patron_id};
    my $onsite    = $body->{onsite_checkout};

    if ( $c->stash('is_public')
        && !C4::Context->preference('OpacTrustedCheckout') )
    {
        return $c->render(
            status  => 405,
            openapi => {
                error      => 'Feature disabled',
                error_code => 'FEATURE_DISABLED'
            }
        );
    }

    return try {
        my $item = Koha::Items->find($item_id);
        unless ($item) {
            return $c->render(
                status  => 409,
                openapi => {
                    error      => 'Item not found',
                    error_code => 'ITEM_NOT_FOUND',
                }
            );
        }

        my $patron = Koha::Patrons->find($patron_id);
        unless ($patron) {
            return $c->render(
                status  => 409,
                openapi => {
                    error      => 'Patron not found',
                    error_code => 'PATRON_NOT_FOUND',
                }
            );
        }

        my ( $impossible, $confirmation, $warnings ) =
          $c->_check_availability( $patron, $item );

        # * Fail for blockers - render 403
        if ( keys %{$impossible} ) {
            my @errors = keys %{$impossible};
            return $c->render(
                status  => 403,
                openapi => { error => "Checkout not authorized (@errors)" }
            );
        }

        # * If confirmation required, check variable set above
        #   and render 412 if variable is false
        if ( keys %{$confirmation} ) {
            my $confirmed = 0;

            # Check for existence of confirmation token
            # and if exists check validity
            if ( my $token = $c->param('confirmation') ) {
                my $confirm_keys = join( ":", sort keys %{$confirmation} );
                $confirm_keys = $user->id . ":" . $item->id . ":" . $confirm_keys;
                $confirmed = Koha::Token->new->check_jwt(
                    { id => $confirm_keys, token => $token } );
            }

            unless ($confirmed) {
                return $c->render(
                    status  => 412,
                    openapi => { error => "Confirmation error" }
                );
            }
        }

        # Call 'AddIssue'
        my $checkout = AddIssue( $patron->unblessed, $item->barcode );
        if ($checkout) {
            $c->res->headers->location(
                $c->req->url->to_string . '/' . $checkout->id );
            return $c->render(
                status  => 201,
                openapi => $checkout->to_api
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => 'Unknown error during checkout' }
            );
        }
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 get_renewals

List Koha::Checkout::Renewals

=cut

sub get_renewals {
    my $c = shift->openapi->valid_input or return;

    try {
        my $checkout_id = $c->param('checkout_id');
        my $checkout    = Koha::Checkouts->find($checkout_id);
        $checkout = Koha::Old::Checkouts->find($checkout_id)
          unless ($checkout);

        unless ($checkout) {
            return $c->render(
                status  => 404,
                openapi => { error => "Checkout doesn't exist" }
            );
        }

        my $renewals_rs = $checkout->renewals;
        my $renewals = $c->objects->search( $renewals_rs );

        return $c->render(
            status  => 200,
            openapi => $renewals
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}


=head3 renew

Renew a checkout

=cut

sub renew {
    my $c = shift->openapi->valid_input or return;

    my $checkout_id = $c->param('checkout_id');
    my $seen = $c->param('seen') || 1;
    my $checkout = Koha::Checkouts->find( $checkout_id );

    unless ($checkout) {
        return $c->render(
            status => 404,
            openapi => { error => "Checkout doesn't exist" }
        );
    }

    return try {
        my ($can_renew, $error) = CanBookBeRenewed($checkout->patron, $checkout);

        if (!$can_renew) {
            return $c->render(
                status => 403,
                openapi => { error => "Renewal not authorized ($error)" }
            );
        }

        AddRenewal(
            {
                borrowernumber => $checkout->borrowernumber,
                itemnumber     => $checkout->itemnumber,
                branch         => $checkout->branchcode,
                seen           => $seen
            }
        );
        $checkout = Koha::Checkouts->find($checkout_id);

        $c->res->headers->location( $c->req->url->to_string );
        return $c->render(
            status  => 201,
            openapi => $checkout->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 allows_renewal

Checks if the checkout could be renewed and return the related information.

=cut

sub allows_renewal {
    my $c = shift->openapi->valid_input or return;

    my $checkout_id = $c->param('checkout_id');
    my $checkout = Koha::Checkouts->find( $checkout_id );

    unless ($checkout) {
        return $c->render(
            status => 404,
            openapi => { error => "Checkout doesn't exist" }
        );
    }

    return try {
        my ($can_renew, $error) = CanBookBeRenewed($checkout->patron, $checkout);

        my $renewable = Mojo::JSON->false;
        $renewable = Mojo::JSON->true if $can_renew;

        my $rule = Koha::CirculationRules->get_effective_rule(
            {
                categorycode => $checkout->patron->categorycode,
                itemtype     => $checkout->item->effective_itemtype,
                branchcode   => $checkout->branchcode,
                rule_name    => 'renewalsallowed',
            }
        );
        return $c->render(
            status => 200,
            openapi => {
                allows_renewal => $renewable,
                max_renewals => $rule->rule_value,
                current_renewals => $checkout->renewals_count,
                unseen_renewals => $checkout->unseen_renewals,
                error => $error
            }
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

1;
