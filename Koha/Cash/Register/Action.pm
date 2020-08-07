package Koha::Cash::Register::Action;

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

use Carp;

use Koha::Database;

use base qw(Koha::Object);

=encoding utf8

=head1 NAME

Koha::Cash::Register::Action - Koha cashregister::action Object class

=head1 API

=head2 Class methods

=cut

=head3 manager

Return the manager linked to this cash register::action

=cut

sub manager {
    my ($self) = @_;
    my $rs = $self->_result->manager;
    return unless $rs;
    return Koha::Patron->_new_from_dbic($rs);
}

=head3 register

Return the register linked to this cash register::action

=cut

sub register {
    my ($self) = @_;
    my $rs = $self->_result->register;
    return unless $rs;
    return Koha::Cash::Register->_new_from_dbic($rs);
}

=head3 cashup_summary

  my $cashup_summary = $action->cashup_summary;

Return a hashref containing a summary of transactions that make up this cashup action.

=cut

sub cashup_summary {
    my ($self) = @_;
    my $summary;
    my $prior_cashup = Koha::Cash::Register::Actions->search(
        {
            'code'      => 'CASHUP',
            'timestamp' => { '<' => $self->timestamp },
            register_id => $self->register_id
        },
        {
            order_by => { '-desc' => [ 'timestamp', 'id' ] },
            rows     => 1
        }
    );

    my $previous = $prior_cashup->single;

    my $conditions =
      $previous
      ? {
        'date' => {
            '-between' =>
              [ $previous->_result->get_column('timestamp'), $self->timestamp ]
        }
      }
      : { 'date' => { '<' => $self->timestamp } };

    my $outgoing_transactions = $self->register->accountlines->search(
        { %{$conditions}, credit_type_code => undef },
        { select => 'accountlines_id' } );
    my $income_transactions = $self->register->accountlines->search(
        { %{$conditions}, debit_type_code => undef },
        { select => 'accountlines_id' } );

    my $income_summary = Koha::Account::Offsets->search(
        {
            'me.credit_id' =>
              { '-in' => $income_transactions->_resultset->as_query },
            'me.debit_id' => { '!=' => undef }
        },
        {
            join     => { 'debit' => 'debit_type_code' },
            group_by => [ 'debit.debit_type_code', 'debit_type_code.description' ],
            'select' => [ { sum => 'me.amount' }, 'debit.debit_type_code', 'debit_type_code.description' ],
            'as'     => [ 'total', 'debit_type_code', 'debit_description' ],
        }
    );

    my $outgoing_summary = Koha::Account::Offsets->search(
        {
            'me.debit_id' =>
              { '-in' => $outgoing_transactions->_resultset->as_query },
            'me.credit_id' => { '!=' => undef }
        },
        {
            join     => { 'credit' => 'credit_type_code' },
            group_by => [ 'credit.credit_type_code', 'credit_type_code.description' ],
            'select' => [ { sum => 'me.amount' }, 'credit.credit_type_code', 'credit_type_code.description' ],
            'as'     => [ 'total', 'credit_type_code', 'credit_description' ],
        }
    );

    my @income = map {
        {
            total           => $_->get_column('total'),
            debit_type_code => $_->get_column('debit_type_code'),
            debit_type      => { description => $_->get_column('debit_description') }
        }
    } $income_summary->as_list;
    my @outgoing = map {
        {
            total            => $_->get_column('total'),
            credit_type_code => $_->get_column('credit_type_code'),
            credit_type      => { description => $_->get_column('credit_description') }
        }
    } $outgoing_summary->as_list;
    $summary = {
        from_date => $previous ? $previous->timestamp : undef,
        to_date   => $self->timestamp,
        income    => \@income,
        outgoing  => \@outgoing,
        total     => ( $outgoing_transactions->total * -1 ) +
          ( $income_transactions->total * -1 ),
        bankable => (
            $outgoing_transactions->search( { payment_type => 'CASH' } )
              ->total * -1
        ) + (
            $income_transactions->search( { payment_type => 'CASH' } )->total *
              -1
        )
    };

    return $summary;
}

=head2 Internal methods

=cut

=head3 _type

=cut

sub _type {
    return 'CashRegisterAction';
}

1;

=head1 AUTHORS

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut
