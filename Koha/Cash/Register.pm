package Koha::Cash::Register;

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

use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::Cash::Register::Actions;
use Koha::Cash::Register::Cashups;
use Koha::Database;

use base qw(Koha::Object);

=encoding utf8

=head1 NAME

Koha::Cash::Register - Koha cashregister Object class

=head1 API

=head2 Class methods

=cut

=head3 library

Return the library linked to this cash register

=cut

sub library {
    my ($self) = @_;
    return Koha::Library->_new_from_dbic( $self->_result->branch );
}

=head3 cashups

Return a set of cashup actions linked to this cash register

=cut

sub cashups {
    my ( $self, $conditions, $attrs ) = @_;

    my $local_conditions = { code => 'CASHUP' };
    $conditions //= {};
    my $merged_conditions = { %{$conditions}, %{$local_conditions} };

    my $rs = $self->_result->search_related(
        'cash_register_actions',
        $merged_conditions, $attrs
    );

    return Koha::Cash::Register::Cashups->_new_from_dbic($rs);
}

=head3 last_cashup

Return a set of cashup actions linked to this cash register

=cut

sub last_cashup {
    my ( $self, $conditions, $attrs ) = @_;

    my $rs = $self->_result->search_related(
        'cash_register_actions',
        { code     => 'CASHUP' },
        { order_by => { '-desc' => [ 'timestamp', 'id' ] }, rows => 1 }
    )->single;

    return unless $rs;
    return Koha::Cash::Register::Cashup->_new_from_dbic($rs);
}

=head3 accountlines

Return a set of accountlines linked to this cash register

=cut

sub accountlines {
    my ($self) = @_;

    my $rs = $self->_result->accountlines;
    return Koha::Account::Lines->_new_from_dbic($rs);
}

=head3 outstanding_accountlines

  my $lines = Koha::Cash::Registers->find($id)->outstanding_accountlines;

Return a set of accountlines linked to this cash register since the last cashup action

=cut

sub outstanding_accountlines {
    my ( $self, $conditions, $attrs ) = @_;

    my $since = $self->_result->search_related(
        'cash_register_actions',
        { 'code' => 'CASHUP' },
        {
            order_by => { '-desc' => [ 'timestamp', 'id' ] },
            rows     => 1
        }
    );

    my $local_conditions =
        $since->count
        ? { 'date' => { '>' => $since->get_column('timestamp')->as_query } }
        : {};
    my $merged_conditions =
        $conditions
        ? { %{$conditions}, %{$local_conditions} }
        : $local_conditions;

    my $rs = $self->_result->search_related(
        'accountlines', $merged_conditions,
        $attrs
    );

    return Koha::Account::Lines->_new_from_dbic($rs);
}

=head3 store

Local store method to prevent direct manipulation of the 'branch_default' field

=cut

sub store {
    my ($self) = @_;

    $self->_result->result_source->schema->txn_do(
        sub {
            if ( $self->_result->is_column_changed('branch_default') ) {
                Koha::Exceptions::Object::ReadOnlyProperty->throw( property => 'branch_default' );
            } else {
                if (   $self->_result->is_column_changed('branch')
                    && $self->branch_default )
                {
                }
                $self = $self->SUPER::store;
            }
        }
    );

    return $self;
}

=head3 make_default

Set the current cash register as the branch default

=cut

sub make_default {
    my ($self) = @_;

    $self->_result->result_source->schema->txn_do(
        sub {
            my $registers = Koha::Cash::Registers->search( { branch => $self->branch } );
            $registers->update( { branch_default => 0 }, { no_triggers => 1 } );
            $self->set( { branch_default => 1 } );
            $self->SUPER::store;
        }
    );

    return $self;
}

=head3 drop_default

Drop the current cash register as the branch default

=cut

sub drop_default {
    my ($self) = @_;

    $self->_result->result_source->schema->txn_do(
        sub {
            $self->set( { branch_default => 0 } );
            $self->SUPER::store;
        }
    );

    return $self;
}

=head3 add_cashup

    my $cashup = $cash_register->add_cashup(
        {
            manager_id => $logged_in_user->id,
            amount     => $cash_register->outstanding_accountlines->total
        }
    );

Add a new cashup action to the till, returns the added action.

=cut

sub add_cashup {
    my ( $self, $params ) = @_;

    my $rs = $self->_result->add_to_cash_register_actions(
        {
            code       => 'CASHUP',
            manager_id => $params->{manager_id},
            amount     => $params->{amount}
        }
    )->discard_changes;

    return Koha::Cash::Register::Cashup->_new_from_dbic($rs);
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Cash::Register object
on the API.

=cut

sub to_api_mapping {
    return {
        branch         => 'library_id',
        id             => 'cash_register_id',
        branch_default => 'library_default',
    };
}

=head2 Internal methods

=cut

=head3 _type

=cut

sub _type {
    return 'CashRegister';
}

1;

=head1 AUTHORS

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut
