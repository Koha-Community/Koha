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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

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

    unless ($register) {
        return $c->render(
            status  => 404,
            openapi => {
                error => "Register not found"
            }
        );
    }

    return try {
        my $cashups = $c->objects->search( $register->cashups );
        return $c->render( status => 200, openapi => $cashups );
    }
    catch {
        $c->unhandled_exception($_);
    };
}

=head3 get

Controller function that handles retrieving a cash register cashup

=cut

sub get {
    my $c = shift->openapi->valid_input or return;

    return try {
        my $cashup = Koha::Cash::Register::Cashups->find( $c->param('cashup_id') );
        unless ($cashup) {
            return $c->render(
                status  => 404,
                openapi => { error => "Cashup not found" }
            );
        }

        my $embed = $c->stash('koha.embed');
        return $c->render(
            status  => 200,
            openapi => $cashup->to_api( { embed => $embed } )
        );
    }
    catch {
        $c->unhandled_exception($_);
    }
}

1;
