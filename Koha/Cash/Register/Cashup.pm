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

    # Get the session boundaries for this cashup
    my ( $session_start, $session_end ) = $self->_get_session_boundaries;

    my $conditions;
    if ( $session_start && $session_end ) {

        # Complete session: between start and end (exclusive)
        $conditions = {
            'date' => {
                '>' => $session_start,
                '<' => $session_end
            }
        };
    } elsif ($session_end) {

        # Session from beginning to end
        $conditions = { 'date' => { '<' => $session_end } };
    } else {

        # Shouldn't happen for a completed cashup, but fallback
        $conditions = { 'date' => { '<' => $self->timestamp } };
    }

    my $payout_transactions = $self->register->accountlines->search(
        {
            %{$conditions},
            credit_type_code => undef,
            debit_type_code  => { '!=' => 'CASHUP_DEFICIT' }
        },
    );
    my $income_transactions = $self->register->accountlines->search(
        {
            %{$conditions},
            debit_type_code  => undef,
            credit_type_code => { '!=' => 'CASHUP_SURPLUS' }
        },
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

        # Flip sign to match the convention used for `total` above:
        # positive = net amount collected (i.e. removed from register at cashup),
        # negative = net amount paid out (i.e. needed to be added to register).
        push @total_grouped, { payment_type => $type->lib, total => $typed_total * -1 };
    }

    # Check for reconciliation lines separately (for footer display only)
    my $surplus_lines =
        $self->register->accountlines->search( { %{$conditions}, credit_type_code => 'CASHUP_SURPLUS' } );
    my $deficit_lines =
        $self->register->accountlines->search( { %{$conditions}, debit_type_code => 'CASHUP_DEFICIT' } );

    my $surplus_total = $surplus_lines->count ? $surplus_lines->total : undef;
    my $deficit_total = $deficit_lines->count ? $deficit_lines->total : undef;

    # Extract notes from reconciliation lines
    my ($surplus_record) = $surplus_lines->_resultset->search( {}, { rows => 1 } )->all;
    my $surplus_note = $surplus_record ? $surplus_record->note : undef;

    my ($deficit_record) = $deficit_lines->_resultset->search( {}, { rows => 1 } )->all;
    my $deficit_note = $deficit_record ? $deficit_record->note : undef;

    $summary = {
        from_date      => $session_start,
        to_date        => $session_end,
        income_grouped => \@income,
        income_total   => abs($income_total),
        payout_grouped => \@payout,
        payout_total   => abs($payout_total),
        total          => $total * -1,
        total_grouped  => \@total_grouped,

        # Reconciliation data for footer display
        surplus_total => $surplus_total ? $surplus_total * 1 : undef,
        deficit_total => $deficit_total ? $deficit_total * 1 : undef,
        surplus_note  => $surplus_note,
        deficit_note  => $deficit_note
    };

    return $summary;
}

=head3 accountlines

Fetch the accountlines associated with this cashup

=cut

sub accountlines {
    my ($self) = @_;

    # Get the session boundaries for this cashup
    my ( $session_start, $session_end ) = $self->_get_session_boundaries;

    my $conditions;
    if ( $session_start && $session_end ) {

        # Complete session: between start and end (exclusive)
        $conditions = {
            'date' => {
                '>' => $session_start,
                '<' => $session_end
            }
        };
    } elsif ($session_end) {

        # Session from beginning to end
        $conditions = { 'date' => { '<' => $session_end } };
    } else {

        # Shouldn't happen for a completed cashup, but fallback
        $conditions = { 'date' => { '<' => $self->timestamp } };
    }

    return $self->register->accountlines->search($conditions);
}

=head3 _get_session_boundaries

Internal method to determine the session boundaries for this cashup.
Returns ($session_start, $session_end) timestamps.

=cut

sub _get_session_boundaries {
    my ($self) = @_;

    my $session_end = $self->_get_session_end;

    # Find the previous CASHUP
    my $session_start;
    my $previous_cashup = $self->register->cashups(
        { 'timestamp' => { '<' => $session_end } },
        {
            order_by => { '-desc' => [ 'timestamp', 'id' ] },
            rows     => 1
        }
    )->single;

    $session_start = $previous_cashup ? $previous_cashup->_get_session_end : undef;

    return ( $session_start, $session_end );
}

=head3 _get_session_end

Internal method to determine the effective end timestamp of the session
this cashup closes.

For a one-phase cashup, the session ends at C<< $self->timestamp >>.
For a two-phase workflow (a preceding C<CASHUP_START> with no intervening
C<CASHUP>), the session ends at the C<CASHUP_START> timestamp so that
transactions made between C<CASHUP_START> and C<CASHUP> are excluded
from this cashup's summary.

Returns the session end timestamp.

=cut

sub _get_session_end {
    my ($self) = @_;

    my $session_end = $self->timestamp;

    # Find if this CASHUP was part of a two-phase workflow
    my $nearest_start = $self->register->_result->search_related(
        'cash_register_actions',
        {
            'code'      => 'CASHUP_START',
            'timestamp' => { '<' => $session_end }
        },
        {
            order_by => { '-desc' => [ 'timestamp', 'id' ] },
            rows     => 1
        }
    )->single;

    if ($nearest_start) {

        # Check if this CASHUP_START was completed by this CASHUP
        # (no other CASHUP between them)
        my $intervening_cashup = $self->register->cashups(
            {
                'timestamp' => {
                    '>' => $nearest_start->timestamp,
                    '<' => $session_end
                }
            },
            { rows => 1 }
        )->single;

        if ( !$intervening_cashup ) {

            # Two-phase workflow: session runs to CASHUP_START
            $session_end = $nearest_start->timestamp;
        }
    }

    return $session_end;
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
