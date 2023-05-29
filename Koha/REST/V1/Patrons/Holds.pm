package Koha::REST::V1::Patrons::Holds;

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

use Koha::Patrons;

=head1 NAME

Koha::REST::V1::Patrons::Holds

=head1 API

=head2 Methods

=head3 list

Controller function that handles listing Koha::Hold objects for the requested patron

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $patron = Koha::Patrons->find( $c->param('patron_id') );

    unless ( $patron ) {
        return $c->render(
            status  => 404,
            openapi => {
                error => 'Patron not found'
            }
        );
    }

    return try {

        my $holds = $c->objects->search( $patron->holds );

        return $c->render(
            status  => 200,
            openapi => $holds
        );
    }
    catch {
        $c->unhandled_exception($_);
    };
}


=head3 delete_public

Controller function that handles cancelling a hold for the requested patron. Returns
a I<204> if cancelling took place, and I<202> if a cancellation request is recorded
instead.

=cut

sub delete_public {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $hold = $c->objects->find_rs( Koha::Holds->new, $c->param('hold_id') );

        unless ( $hold and $c->param('patron_id') == $hold->borrowernumber ) {
            return $c->render(
                status  => 404,
                openapi => { error => 'Object not found' }
            );
        }

        if ( $hold->is_cancelable_from_opac ) {
            $hold->cancel;
            return $c->render(
                status  => 204,
                openapi => q{},
            );
        } elsif ( $hold->is_waiting and $hold->cancellation_requestable_from_opac ) {
            $hold->add_cancellation_request;
            return $c->render(
                status  => 202,
                openapi => q{},
            );
        } else {    # reject
            return $c->render(
                status  => 403,
                openapi => { error => 'Cancellation forbidden' }
            );
        }
    } catch {
        $c->unhandled_exception($_);
    };
}

1;
