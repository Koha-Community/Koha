package Koha::REST::V1::Holds;

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

use C4::Biblio;
use C4::Reserves;

use Koha::Items;
use Koha::Patrons;
use Koha::Holds;
use Koha::DateUtils;

use Try::Tiny;

=head1 API

=head2 Class methods

=head3 list

Mehtod that handles listing Koha::Hold objects

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $holds_set = Koha::Holds->new;
        my $holds     = $c->objects->search( $holds_set, \&_to_model, \&_to_api );
        return $c->render( status => 200, openapi => $holds );
    }
    catch {
        if ( blessed $_ && $_->isa('Koha::Exceptions') ) {
            return $c->render(
                status  => 500,
                openapi => { error => "$_" }
            );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong, check Koha logs for details." }
            );
        }
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

        my $biblio_id         = $body->{biblio_id};
        my $pickup_library_id = $body->{pickup_library_id};
        my $item_id           = $body->{item_id};
        my $patron_id         = $body->{patron_id};
        my $item_type         = $body->{item_type};
        my $expiration_date   = $body->{expiration_date};
        my $notes             = $body->{notes};

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
            my $item = Koha::Items->find($item_id);

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

        my $can_place_hold
            = $item_id
            ? C4::Reserves::CanItemBeReserved( $patron_id, $item_id )
            : C4::Reserves::CanBookBeReserved( $patron_id, $biblio_id );

        unless ( $can_place_hold->{status} eq 'OK' ) {
            return $c->render(
                status => 403,
                openapi =>
                    { error => "Hold cannot be placed. Reason: " . $can_place_hold->{status} }
            );
        }

        my $priority = C4::Reserves::CalculatePriority($biblio_id);

        # AddReserve expects date to be in syspref format
        if ($expiration_date) {
            $expiration_date = output_pref( dt_from_string( $expiration_date, 'rfc3339' ) );
        }

        my $hold_id = C4::Reserves::AddReserve(
            $pickup_library_id,
            $patron_id,
            $biblio_id,
            undef,    # $bibitems param is unused
            $priority,
            undef,    # hold date, we don't allow it currently
            $expiration_date,
            $notes,
            $biblio->title,
            $item_id,
            undef,    # TODO: Why not?
            $item_type
        );

        unless ($hold_id) {
            return $c->render(
                status  => 500,
                openapi => 'Error placing the hold. See Koha logs for details.'
            );
        }

        my $hold = Koha::Holds->find($hold_id);

        return $c->render( status => 201, openapi => _to_api($hold->TO_JSON) );
    }
    catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions') ) {
            if ( $_->isa('Koha::Exceptions::Object::FKConstraint') ) {
                my $broken_fk = $_->broken_fk;

                if ( grep { $_ eq $broken_fk } keys %{$Koha::REST::V1::Holds::to_api_mapping} ) {
                    $c->render(
                        status  => 404,
                        openapi => $Koha::REST::V1::Holds::to_api_mapping->{$broken_fk} . ' not found.'
                    );
                }
                else {
                    return $c->render(
                        status  => 500,
                        openapi => { error => "Uncaught exception: $_" }
                    );
                }
            }
            else {
                return $c->render(
                    status  => 500,
                    openapi => { error => "$_" }
                );
            }
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong. check the logs." }
            );
        }
    };
}

=head3 edit

Method that handles modifying a Koha::Hold object

=cut

sub edit {
    my $c = shift->openapi->valid_input or return;

    my $hold_id = $c->validation->param('hold_id');
    my $hold = Koha::Holds->find( $hold_id );

    unless ($hold) {
        return $c->render( status  => 404,
                           openapi => {error => "Hold not found"} );
    }

    my $body = $c->req->json;

    my $pickup_library_id = $body->{pickup_library_id};
    my $priority          = $body->{priority};
    my $suspended_until   = $body->{suspended_until};

    if ($suspended_until) {
        $suspended_until = output_pref(dt_from_string($suspended_until, 'rfc3339'));
    }

    my $params = {
        reserve_id    => $hold_id,
        branchcode    => $pickup_library_id,
        rank          => $priority,
        suspend_until => $suspended_until,
        itemnumber    => $hold->itemnumber
    };

    C4::Reserves::ModReserve($params);
    $hold->discard_changes; # refresh

    return $c->render( status => 200, openapi => _to_api( $hold->TO_JSON ) );
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

    $hold->cancel;

    return $c->render( status => 200, openapi => {} );
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
        my $date = ($end_date) ? dt_from_string( $end_date, 'rfc3339' ) : undef;
        $hold->suspend_hold($date);
        $hold->discard_changes;
        $c->res->headers->location( $c->req->url->to_string );
        return $c->render(
            status  => 201,
            openapi => {
                end_date => output_pref(
                    {   dt         => dt_from_string( $hold->suspend_until ),
                        dateformat => 'rfc3339',
                        dateonly   => 1
                    }
                )
            }
        );
    }
    catch {
        if ( blessed $_ and $_->isa('Koha::Exceptions::Hold::CannotSuspendFound') ) {
            return $c->render( status => 400, openapi => { error => "$_" } );
        }
        else {
            return $c->render(
                status  => 500,
                openapi => { error => "Something went wrong. check the logs." }
            );
        }
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
        return $c->render(
            status  => 500,
            openapi => { error => "Something went wrong. check the logs." }
        );
    };
}

=head3 _to_api

Helper function that maps unblessed Koha::Hold objects into REST api
attribute names.

=cut

sub _to_api {
    my $hold = shift;

    # Rename attributes
    foreach my $column ( keys %{ $Koha::REST::V1::Holds::to_api_mapping } ) {
        my $mapped_column = $Koha::REST::V1::Holds::to_api_mapping->{$column};
        if (    exists $hold->{ $column }
             && defined $mapped_column )
        {
            # key != undef
            $hold->{ $mapped_column } = delete $hold->{ $column };
        }
        elsif (    exists $hold->{ $column }
                && !defined $mapped_column )
        {
            # key == undef
            delete $hold->{ $column };
        }
    }

    return $hold;
}

=head3 _to_model

Helper function that maps REST api objects into Koha::Hold
attribute names.

=cut

sub _to_model {
    my $hold = shift;

    foreach my $attribute ( keys %{ $Koha::REST::V1::Holds::to_model_mapping } ) {
        my $mapped_attribute = $Koha::REST::V1::Holds::to_model_mapping->{$attribute};
        if (    exists $hold->{ $attribute }
             && defined $mapped_attribute )
        {
            # key => !undef
            $hold->{ $mapped_attribute } = delete $hold->{ $attribute };
        }
        elsif (    exists $hold->{ $attribute }
                && !defined $mapped_attribute )
        {
            # key => undef / to be deleted
            delete $hold->{ $attribute };
        }
    }

    if ( exists $hold->{lowestPriority} ) {
        $hold->{lowestPriority} = ($hold->{lowestPriority}) ? 1 : 0;
    }

    if ( exists $hold->{suspend} ) {
        $hold->{suspend} = ($hold->{suspend}) ? 1 : 0;
    }

    if ( exists $hold->{reservedate} ) {
        $hold->{reservedate} = output_pref({ str => $hold->{reservedate}, dateformat => 'sql' });
    }

    if ( exists $hold->{cancellationdate} ) {
        $hold->{cancellationdate} = output_pref({ str => $hold->{cancellationdate}, dateformat => 'sql' });
    }

    if ( exists $hold->{timestamp} ) {
        $hold->{timestamp} = output_pref({ str => $hold->{timestamp}, dateformat => 'sql' });
    }

    if ( exists $hold->{waitingdate} ) {
        $hold->{waitingdate} = output_pref({ str => $hold->{waitingdate}, dateformat => 'sql' });
    }

    if ( exists $hold->{expirationdate} ) {
        $hold->{expirationdate} = output_pref({ str => $hold->{expirationdate}, dateformat => 'sql' });
    }

    if ( exists $hold->{suspend_until} ) {
        $hold->{suspend_until} = output_pref({ str => $hold->{suspend_until}, dateformat => 'sql' });
    }

    return $hold;
}

=head2 Global variables

=head3 $to_api_mapping

=cut

our $to_api_mapping = {
    reserve_id       => 'hold_id',
    borrowernumber   => 'patron_id',
    reservedate      => 'hold_date',
    biblionumber     => 'biblio_id',
    branchcode       => 'pickup_library_id',
    notificationdate => undef,
    reminderdate     => undef,
    cancellationdate => 'cancelation_date',
    reservenotes     => 'notes',
    found            => 'status',
    itemnumber       => 'item_id',
    waitingdate      => 'waiting_date',
    expirationdate   => 'expiration_date',
    lowestPriority   => 'lowest_priority',
    suspend          => 'suspended',
    suspend_until    => 'suspended_until',
    itemtype         => 'item_type',
};

=head3 $to_model_mapping

=cut

our $to_model_mapping = {
    hold_id           => 'reserve_id',
    patron_id         => 'borrowernumber',
    hold_date         => 'reservedate',
    biblio_id         => 'biblionumber',
    pickup_library_id => 'branchcode',
    cancelation_date  => 'cancellationdate',
    notes             => 'reservenotes',
    status            => 'found',
    item_id           => 'itemnumber',
    waiting_date      => 'waitingdate',
    expiration_date   => 'expirationdate',
    lowest_priority   => 'lowestPriority',
    suspended         => 'suspend',
    suspended_until   => 'suspend_until',
    item_type         => 'itemtype',
};

1;
