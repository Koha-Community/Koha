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

Koha::Cash::Register::Cashup - Koha Cash Register Cashup Object class

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

C<total_grouped> splits C<total> by payment type, so its rows always add up to
it. Payment types listed in the CashupPaymentTypes preference come first, in
preference order, with C<cashed_up> set to 1. Any other payment type with
takings follows with C<cashed_up> set to 0.

=cut

sub summary {
    my ($self) = @_;
    my $summary;

    # Get the session boundaries for this cashup
    my ( $session_start, $session_end ) = $self->_get_session_boundaries;

    my $conditions;
    if ( $session_start && $session_end ) {

        # Complete session: between start and end (inclusive). accountlines.date
        # only has second resolution, so a strict > / < comparison here would
        # silently drop transactions recorded in the same second as a cashup
        # boundary.
        $conditions = { 'date' => { '-between' => [ $session_start, $session_end ] } };
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

    # Group by payment_type in a single query per direction, rather than
    # issuing a pair of ->total() queries per configured type.
    my $income_by_type = {
        map { ( $_->get_column('payment_type') // '' ) => $_->get_column('total') + 0 } $income_transactions->search(
            {},
            {
                select   => [ 'payment_type', { sum => 'amount' } ],
                as       => [ 'payment_type', 'total' ],
                group_by => ['payment_type'],
            }
        )->as_list
    };
    my $payout_by_type = {
        map { ( $_->get_column('payment_type') // '' ) => $_->get_column('total') + 0 } $payout_transactions->search(
            {},
            {
                select   => [ 'payment_type', { sum => 'amount' } ],
                as       => [ 'payment_type', 'total' ],
                group_by => ['payment_type'],
            }
        )->as_list
    };

    my $av_labels = { map { $_->authorised_value => $_->lib }
            Koha::AuthorisedValues->search( { category => 'PAYMENT_TYPE' } )->as_list };

    # total_grouped is a complete split of `total` by payment type, so the
    # per-type rows always add up to it. Types listed in CashupPaymentTypes
    # come first, in preference order, and are flagged cashed_up: they are the
    # ones reconciled when completing the cashup. Any other payment type that
    # had takings follows (e.g. card payments that never go through the
    # register), so it is still visible rather than silently missing from the
    # summary while remaining part of `total`.
    my $configured    = $self->register->cashup_payment_types;
    my %is_configured = map { $_ => 1 } @{$configured};
    my @other_codes =
        sort { lc( $av_labels->{$a} // $a ) cmp lc( $av_labels->{$b} // $b ) }
        grep { $_ ne '' && !$is_configured{$_} && ( $income_by_type->{$_} || $payout_by_type->{$_} ) }
        keys %{ { %{$income_by_type}, %{$payout_by_type} } };

    my @total_grouped;
    for my $code ( @{$configured}, @other_codes ) {
        my $typed_total = ( $income_by_type->{$code} // 0 ) + ( $payout_by_type->{$code} // 0 );

        # Flip sign to match the convention used for `total` above:
        # positive = net amount collected (i.e. removed from register at cashup),
        # negative = net amount paid out (i.e. needed to be added to register).
        push @total_grouped,
            {
            payment_type => $code,
            label        => $av_labels->{$code} // $code,
            total        => $typed_total * -1,
            cashed_up    => $is_configured{$code} ? 1 : 0,
            };
    }

    # Check for reconciliation lines separately (for footer display only)
    my $surplus_lines =
        $self->register->accountlines->search( { %{$conditions}, credit_type_code => 'CASHUP_SURPLUS' } );
    my $deficit_lines =
        $self->register->accountlines->search( { %{$conditions}, debit_type_code => 'CASHUP_DEFICIT' } );

    # Per-payment-type reconciliation breakdown, built from the surplus/deficit
    # lines themselves. Each entry carries its own per-row note. Aggregate
    # totals (and "any reconciliation?" boolean checks) are derived by
    # consumers from the grouped breakdown.
    my @reconciliations_grouped;
    my %recon_index;
    for my $line ( $surplus_lines->as_list ) {
        my $pt = $line->payment_type // 'CASH';
        $recon_index{$pt} //= {};
        $recon_index{$pt}->{surplus_total} = ( $recon_index{$pt}->{surplus_total} // 0 ) + ( $line->amount * 1 );
        $recon_index{$pt}->{note} //= $line->note;
    }
    for my $line ( $deficit_lines->as_list ) {
        my $pt = $line->payment_type // 'CASH';
        $recon_index{$pt} //= {};
        $recon_index{$pt}->{deficit_total} = ( $recon_index{$pt}->{deficit_total} // 0 ) + ( $line->amount * 1 );
        $recon_index{$pt}->{note} //= $line->note;
    }
    for my $pt ( sort keys %recon_index ) {
        push @reconciliations_grouped,
            {
            payment_type  => $pt,
            surplus_total => $recon_index{$pt}->{surplus_total},
            deficit_total => $recon_index{$pt}->{deficit_total},
            note          => $recon_index{$pt}->{note},
            };
    }

    $summary = {
        from_date               => $session_start,
        to_date                 => $session_end,
        income_grouped          => \@income,
        income_total            => abs($income_total),
        payout_grouped          => \@payout,
        payout_total            => abs($payout_total),
        total                   => $total * -1,
        total_grouped           => \@total_grouped,
        reconciliations_grouped => \@reconciliations_grouped,
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

        # Complete session: between start and end (inclusive). accountlines.date
        # only has second resolution, so a strict > / < comparison here would
        # silently drop transactions recorded in the same second as a cashup
        # boundary.
        $conditions = { 'date' => { '-between' => [ $session_start, $session_end ] } };
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
