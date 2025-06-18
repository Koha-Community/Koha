package Koha::Cash::Register::Cashup;

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

use Koha::Database;

use base qw(Koha::Cash::Register::Action);

=head1 NAME

Koha::Cash::Register::Actions - Koha Cash Register Action Object set class

=head1 API

=head2 Class methods

=head3 search

    my $cashup = Koha::Cash::Register::Actions::Cashup->search( $where, $attr );

Returns a list of cash register cashup.

=cut

sub search {
    my ( $self, $where, $attr ) = @_;

    $where->{code} = 'CASHUP';

    unless ( exists $attr->{order_by} ) {
        $attr->{order_by} =
            [ { '-asc' => 'register_id' }, { '-desc' => 'timestamp' } ];
    }

    return $self->SUPER::search( $where, $attr );
}

=head3 summary

  my $summary = $cashup->summary;

Return a hashref containing a summary of transactions that make up this cashup.

=cut

sub summary {
    my ($self) = @_;
    my $summary;
    my $prior_cashup = Koha::Cash::Register::Cashups->search(
        {
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
        ? { 'date' => { '-between' => [ $previous->_result->get_column('timestamp'), $self->timestamp ] } }
        : { 'date' => { '<'        => $self->timestamp } };

    my $payout_transactions = $self->register->accountlines->search(
        { %{$conditions}, credit_type_code => undef },
    );
    my $income_transactions = $self->register->accountlines->search(
        { %{$conditions}, debit_type_code => undef },
    );

    my $income_summary = Koha::Account::Offsets->search(
        {
            'me.credit_id' => { '-in' => $income_transactions->_resultset->get_column('accountlines_id')->as_query },
            'me.debit_id'  => { '!='  => undef }
        },
        {
            join     => { 'debit' => 'debit_type_code' },
            group_by => [ 'debit.debit_type_code', 'debit_type_code.description' ],
            'select' => [
                { sum => 'me.amount' }, 'debit.debit_type_code',
                'debit_type_code.description'
            ],
            'as'     => [ 'total', 'debit_type_code', 'debit_description' ],
            order_by => { '-asc' => 'debit_type_code.description' },
        }
    );

    my $payout_summary = Koha::Account::Offsets->search(
        {
            'me.debit_id'  => { '-in' => $payout_transactions->_resultset->get_column('accountlines_id')->as_query },
            'me.credit_id' => { '!='  => undef },
            'account_offsets_credits.debit_id' =>
                { '-not_in' => $payout_transactions->_resultset->get_column('accountlines_id')->as_query }
        },
        {
            join => {
                'credit' => [
                    'credit_type_code',
                    { 'account_offsets_credits' => { 'debit' => 'debit_type_code' } }
                ]
            },
            group_by => [
                'credit.credit_type_code', 'credit_type_code.description',
                'debit.debit_type_code',   'debit_type_code.description'
            ],
            'select' => [
                { sum => 'me.amount' },         'credit.credit_type_code',
                'credit_type_code.description', 'debit.debit_type_code',
                'debit_type_code.description'
            ],
            'as' => [
                'total',              'credit_type_code',
                'credit_description', 'debit_type_code',
                'debit_description'
            ],
            order_by => { '-asc' => [ 'credit_type_code.description', 'debit_type_code.description' ] },
        }
    );

    my @income = map {
        {
            total           => $_->get_column('total') * -1,
            debit_type_code => $_->get_column('debit_type_code'),
            debit_type      => { description => $_->get_column('debit_description') }
        }
    } $income_summary->as_list;
    my @payout = map {
        {
            total            => $_->get_column('total') * -1,
            credit_type_code => $_->get_column('credit_type_code'),
            credit_type      => { description => $_->get_column('credit_description') },
            related_debit    => {
                debit_type_code => $_->get_column('debit_type_code'),
                debit_type      => { description => $_->get_column('debit_description') }
            }
        }
    } $payout_summary->as_list;

    my $income_total = $income_transactions->total;
    my $payout_total = $payout_transactions->total;
    my $total        = ( $income_total + $payout_total );

    my $payment_types = Koha::AuthorisedValues->search(
        { category => 'PAYMENT_TYPE' },
        {
            order_by => ['lib'],
        }
    );

    my @total_grouped;
    for my $type ( $payment_types->as_list ) {
        my $typed_income = $income_transactions->total( { payment_type => $type->authorised_value } );
        my $typed_payout = $payout_transactions->total( { payment_type => $type->authorised_value } );
        my $typed_total  = ( $typed_income + $typed_payout );
        push @total_grouped, { payment_type => $type->lib, total => $typed_total };
    }

    $summary = {
        from_date      => $previous ? $previous->timestamp : undef,
        to_date        => $self->timestamp,
        income_grouped => \@income,
        income_total   => abs($income_total),
        payout_grouped => \@payout,
        payout_total   => abs($payout_total),
        total          => $total * -1,
        total_grouped  => \@total_grouped
    };

    return $summary;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Cash::Register::Cashup object
on the API.

=cut

sub to_api_mapping {
    return {
        id          => 'cashup_id',
        register_id => 'cash_register_id',
        code        => undef
    };
}

1;

=head1 AUTHORS

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut
