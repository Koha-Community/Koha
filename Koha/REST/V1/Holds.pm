package Koha::REST::V1::Holds;

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

use C4::Reserves;

use Koha::Items;
use Koha::Patrons;
use Koha::Holds;
use Koha::DateUtils qw( dt_from_string );

use List::MoreUtils qw( any );
use Try::Tiny qw( catch try );

=head1 API

=head2 Methods

=head3 list

Method that handles listing Koha::Hold objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $holds_set = Koha::Holds->new;
        my $holds     = $c->objects->search( $holds_set );
        return $c->render( status => 200, openapi => $holds );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 add

Method that handles adding a new Koha::Hold object

=cut

sub add {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $body = $c->validation->param('body');

        my $biblio;
        my $item;

        my $biblio_id         = $body->{biblio_id};
        my $item_group_id     = $body->{item_group_id};
        my $pickup_library_id = $body->{pickup_library_id};
        my $item_id           = $body->{item_id};
        my $patron_id         = $body->{patron_id};
        my $item_type         = $body->{item_type};
        my $expiration_date   = $body->{expiration_date};
        my $notes             = $body->{notes};
        my $hold_date         = $body->{hold_date};
        my $non_priority      = $body->{non_priority};

        my $overrides = $c->stash('koha.overrides');
        my $can_override = $overrides->{any} && C4::Context->preference('AllowHoldPolicyOverride');

        if(!C4::Context->preference( 'AllowHoldDateInFuture' ) && $hold_date) {
            return $c->render(
                status  => 400,
                openapi => { error => "Hold date in future not allowed" }
            );
        }

        if ( $item_id and $biblio_id ) {

            # check they are consistent
            unless ( Koha::Items->search( { itemnumber => $item_id, biblionumber => $biblio_id } )
                ->count > 0 )
            {
                return $c->render(
                    status  => 400,
                    openapi => { error => "Item $item_id doesn't belong to biblio $biblio_id" }
                );
            }
            else {
                $biblio = Koha::Biblios->find($biblio_id);
            }
        }
        elsif ($item_id) {
            $item = Koha::Items->find($item_id);

            unless ($item) {
                return $c->render(
                    status  => 404,
                    openapi => { error => "item_id not found." }
                );
            }
            else {
                $biblio = $item->biblio;
            }
        }
        elsif ($biblio_id) {
            $biblio = Koha::Biblios->find($biblio_id);
        }
        else {
            return $c->render(
                status  => 400,
                openapi => { error => "At least one of biblio_id, item_id should be given" }
            );
        }

        unless ($biblio) {
            return $c->render(
                status  => 400,
                openapi => "Biblio not found."
            );
        }

        my $patron = Koha::Patrons->find( $patron_id );
        unless ($patron) {
            return $c->render(
                status  => 400,
                openapi => { error => 'patron_id not found' }
            );
        }

        # If the hold is being forced, no need to validate
        unless( $can_override ){
            # Validate pickup location
            my $valid_pickup_location;
            if ($item) {    # item-level hold
                $valid_pickup_location =
                  any { $_->branchcode eq $pickup_library_id }
                $item->pickup_locations(
                    { patron => $patron } )->as_list;
            }
            else {
                $valid_pickup_location =
                  any { $_->branchcode eq $pickup_library_id }
                $biblio->pickup_locations(
                    { patron => $patron } )->as_list;
            }

            return $c->render(
                status  => 400,
                openapi => {
                    error => 'The supplied pickup location is not valid'
                }
            ) unless $valid_pickup_location;

            my $can_place_hold
                = $item
                ? C4::Reserves::CanItemBeReserved( $patron, $item )
                : C4::Reserves::CanBookBeReserved( $patron_id, $biblio_id );

            if ( C4::Context->preference('maxreserves') && $patron->holds->count + 1 > C4::Context->preference('maxreserves') ) {
                $can_place_hold->{status} = 'tooManyReserves';
            }

            unless ( $can_place_hold->{status} eq 'OK' ) {
                return $c->render(
                    status => 403,
                    openapi =>
                        { error => "Hold cannot be placed. Reason: " . $can_place_hold->{status} }
                );
            }
        }

        my $priority = C4::Reserves::CalculatePriority($biblio_id);

        my $hold_id = C4::Reserves::AddReserve(
            {
                branchcode       => $pickup_library_id,
                borrowernumber   => $patron_id,
                biblionumber     => $biblio->id,
                priority         => $priority,
                reservation_date => $hold_date,
                expiration_date  => $expiration_date,
                notes            => $notes,
                title            => $biblio->title,
                itemnumber       => $item_id,
                found            => undef,                # TODO: Why not?
                itemtype         => $item_type,
                non_priority     => $non_priority,
                item_group_id    => $item_group_id,
            }
        );

        unless ($hold_id) {
            return $c->render(
                status  => 500,
                openapi => 'Error placing the hold. See Koha logs for details.'
            );
        }

        my $hold = Koha::Holds->find($hold_id);

        return $c->render(
            status  => 201,
            openapi => $hold->to_api
        );
    }
    catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions') ) {
            if ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                my $broken_fk = $_->broken_fk;

                if ( grep { $_ eq $broken_fk } keys %{Koha::Holds->new->to_api_mapping} ) {
                    $c->render(
                        status  => 404,
                        openapi => Koha::Holds->new->to_api_mapping->{$broken_fk} . ' not found.'
                    );
                }
            }
        }

        $c->unhandled_exception($_);
    };
}

=head3 edit

Method that handles modifying a Koha::Hold object

=cut

sub edit {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $hold_id = $c->validation->param('hold_id');
        my $hold = Koha::Holds->find( $hold_id );

        unless ($hold) {
            return $c->render(
                status  => 404,
                openapi => { error => "Hold not found" }
            );
        }

        my $overrides = $c->stash('koha.overrides');
        my $can_override = $overrides->{any} && C4::Context->preference('AllowHoldPolicyOverride');

        my $body = $c->validation->output->{body};

        my $pickup_library_id = $body->{pickup_library_id};

        if (
            defined $pickup_library_id
            && ( !$hold->is_pickup_location_valid({ library_id => $pickup_library_id }) && !$can_override )
          )
        {
            return $c->render(
                status  => 400,
                openapi => {
                    error => 'The supplied pickup location is not valid'
                }
            );
        }

        $pickup_library_id //= $hold->branchcode;
        my $priority         = $body->{priority} // $hold->priority;
        # suspended_until can also be set to undef
        my $suspended_until = $body->{suspended_until} || $hold->suspend_until;

        my $params = {
            reserve_id    => $hold_id,
            branchcode    => $pickup_library_id,
            rank          => $priority,
            suspend_until => $suspended_until,
            itemnumber    => $hold->itemnumber,
        };

        C4::Reserves::ModReserve($params);
        $hold->discard_changes; # refresh

        return $c->render(
            status  => 200,
            openapi => $hold->to_api
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 delete

Method that handles deleting a Koha::Hold object

=cut

sub delete {
    my $c = shift->openapi->valid_input or return;

    my $hold_id = $c->validation->param('hold_id');
    my $hold    = Koha::Holds->find($hold_id);

    unless ($hold) {
        return $c->render( status => 404, openapi => { error => "Hold not found." } );
    }

    return try {
        $hold->cancel;

        return $c->render(
            status  => 204,
            openapi => q{}
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 suspend

Method that handles suspending a hold

=cut

sub suspend {
    my $c = shift->openapi->valid_input or return;

    my $hold_id  = $c->validation->param('hold_id');
    my $hold     = Koha::Holds->find($hold_id);
    my $body     = $c->req->json;
    my $end_date = ($body) ? $body->{end_date} : undef;

    unless ($hold) {
        return $c->render( status => 404, openapi => { error => 'Hold not found.' } );
    }

    return try {
        $hold->suspend_hold($end_date);
        $hold->discard_changes;
        $c->res->headers->location( $c->req->url->to_string );

        my $suspend_until = $end_date ? dt_from_string($hold->suspend_until)->ymd : undef;
        return $c->render(
            status  => 201,
            openapi => {
                end_date => $suspend_until,
            }
        );
    }
    catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::Hold::CannotSuspendFound') ) {
            return $c->render( status => 400, openapi => { error => "$_" } );
        }

        $c->unhandled_exception($_);
    };
}

=head3 resume

Method that handles resuming a hold

=cut

sub resume {
    my $c = shift->openapi->valid_input or return;

    my $hold_id = $c->validation->param('hold_id');
    my $hold    = Koha::Holds->find($hold_id);
    my $body    = $c->req->json;

    unless ($hold) {
        return $c->render( status => 404, openapi => { error => 'Hold not found.' } );
    }

    return try {
        $hold->resume;
        return $c->render( status => 204, openapi => {} );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 update_priority

Method that handles modifying a Koha::Hold object

=cut

sub update_priority {
    my $c = shift->openapi->valid_input or return;

    my $hold_id = $c->validation->param('hold_id');
    my $hold = Koha::Holds->find($hold_id);

    unless ($hold) {
        return $c->render(
            status  => 404,
            openapi => { error => "Hold not found" }
        );
    }

    return try {
        my $priority = $c->req->json;
        C4::Reserves::_FixPriority(
            {
                reserve_id => $hold_id,
                rank       => $priority
            }
        );

        return $c->render( status => 200, openapi => $priority );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 pickup_locations

Method that returns the possible pickup_locations for a given hold
used for building the dropdown selector

=cut

sub pickup_locations {
    my $c = shift->openapi->valid_input or return;

    my $hold_id = $c->validation->param('hold_id');
    my $hold = Koha::Holds->find( $hold_id, { prefetch => [ 'patron' ] } );

    unless ($hold) {
        return $c->render(
            status  => 404,
            openapi => { error => "Hold not found" }
        );
    }

    return try {
        my $ps_set;

        if ( $hold->itemnumber ) {
            $ps_set = $hold->item->pickup_locations( { patron => $hold->patron } );
        }
        else {
            $ps_set = $hold->biblio->pickup_locations( { patron => $hold->patron } );
        }

        my $pickup_locations = $c->objects->search( $ps_set );
        my @response = ();

        if ( C4::Context->preference('AllowHoldPolicyOverride') ) {

            my $libraries_rs = Koha::Libraries->search( { pickup_location => 1 } );
            my $libraries    = $c->objects->search($libraries_rs);

            @response = map {
                my $library = $_;
                $library->{needs_override} = (
                    any { $_->{library_id} eq $library->{library_id} }
                    @{$pickup_locations}
                  )
                  ? Mojo::JSON->false
                  : Mojo::JSON->true;
                $library;
            } @{$libraries};

            return $c->render(
                status  => 200,
                openapi => \@response
            );
        }

        @response = map { $_->{needs_override} = Mojo::JSON->false; $_; } @{$pickup_locations};

        return $c->render(
            status  => 200,
            openapi => \@response
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 update_pickup_location

Method that handles modifying the pickup location of a Koha::Hold object

=cut

sub update_pickup_location {
    my $c = shift->openapi->valid_input or return;

    my $hold_id = $c->validation->param('hold_id');
    my $body    = $c->validation->param('body');
    my $pickup_library_id = $body->{pickup_library_id};

    my $hold = Koha::Holds->find($hold_id);

    unless ($hold) {
        return $c->render(
            status  => 404,
            openapi => { error => "Hold not found" }
        );
    }

    return try {

        my $overrides    = $c->stash('koha.overrides');
        my $can_override = $overrides->{any} && C4::Context->preference('AllowHoldPolicyOverride');

        $hold->set_pickup_location(
            {
                library_id => $pickup_library_id,
                force      => $can_override
            }
        );

        return $c->render(
            status  => 200,
            openapi => {
                pickup_library_id => $pickup_library_id
            }
        );
    }
    catch {

        if ( blessed $_ and $_->isa('Koha::Exceptions::Hold::InvalidPickupLocation') ) {
            return $c->render(
                status  => 400,
                openapi => {
                    error => "$_"
                }
            );
        }

        $c->unhandled_exception($_);
    };
}


1;
