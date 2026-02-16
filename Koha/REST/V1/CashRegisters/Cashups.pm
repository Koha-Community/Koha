package Koha::REST::V1::CashRegisters::Cashups;

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

use Try::Tiny qw( catch try );

use Koha::Cash::Registers;

=head1 NAME

Koha::REST::V1::CashRegisters::Cashups

=head1 API

=head2 Methods

=head3 list

Controller function that handles retrieving a cash registers cashup actions

=cut

sub list {
    my $c = shift->openapi->valid_input or return;

    my $register = Koha::Cash::Registers->find( $c->param('cash_register_id') );

    return $c->render_resource_not_found("Register")
        unless $register;

    return try {
        my $cashups = $c->objects->search( $register->cashups );
        return $c->render( status => 200, openapi => $cashups );
    } catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a cash register cashup

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {

        # Try to find as a completed cashup first. find() looks up
        # cash_register_actions by primary key directly, bypassing the
        # code = 'CASHUP' condition search() applies, so it can return any
        # action type here -- check explicitly rather than trusting it.
        my $cashup = Koha::Cash::Register::Cashups->find( $c->param('cashup_id') );
        undef $cashup if $cashup && $cashup->code ne 'CASHUP';

        # If not found, try as a CASHUP_START action (for preview)
        unless ($cashup) {
            require Koha::Cash::Register::Actions;
            my $action = Koha::Cash::Register::Actions->find( $c->param('cashup_id') );

            # Only allow CASHUP_START actions for preview
            if ( $action && $action->code eq 'CASHUP_START' ) {

                # Wrap as Cashup object for summary generation
                require Koha::Cash::Register::Cashup;
                $cashup = Koha::Cash::Register::Cashup->_new_from_dbic( $action->_result );
            }
        }

        return $c->render_resource_not_found("Cashup")
            unless $cashup;

        return $c->render(
            status  => 200,
            openapi => $c->objects->to_api($cashup),
        );
    } catch {
        $c->unhandled_exception($_);
    }
}

1;
