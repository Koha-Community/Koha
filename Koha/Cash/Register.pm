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
use DateTime;
use Scalar::Util qw( looks_like_number );
use Try::Tiny    qw( catch try );

use Koha::Account;
use Koha::Account::Line;
use Koha::Account::Lines;
use Koha::Account::Offset;
use Koha::Account::Offsets;
use Koha::AuthorisedValues;
use Koha::Cash::Register::Actions;
use Koha::Cash::Register::Cashups;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

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

    # Find the start timestamp for the current "open" session
    my $start_timestamp = $self->_get_session_start_timestamp;

    my $local_conditions =
        $start_timestamp
        ? { 'date' => { '>' => $start_timestamp } }
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

=head3 cashup_in_progress

Check if there is currently a cashup in progress (CASHUP_START without
corresponding CASHUP). Returns a L<Koha::Cash::Register::Cashup> wrapping the
CASHUP_START action if in progress, undef otherwise. Cashup ISA Action, so all
Action attributes (id, timestamp, manager_id, amount, ...) remain available;
the richer Cashup interface (e.g. C<accountlines>, C<summary>) lets callers
work with the in-progress session as a first-class object.

=cut

sub cashup_in_progress {
    my ($self) = @_;

    my $last_start = $self->_result->search_related(
        'cash_register_actions',
        { 'code'   => 'CASHUP_START' },
        { order_by => { '-desc' => [ 'timestamp', 'id' ] }, rows => 1 }
    )->single;

    return unless $last_start;

    my $last_completion = $self->cashups(
        {},
        { order_by => { '-desc' => [ 'timestamp', 'id' ] }, rows => 1 }
    )->single;

    # If we have a start but no completion, or the start is more recent than completion
    if ( !$last_completion
        || DateTime->compare( dt_from_string( $last_start->timestamp ), dt_from_string( $last_completion->timestamp ) )
        > 0 )
    {
        return Koha::Cash::Register::Cashup->_new_from_dbic($last_start);
    }

    return;
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

=head3 start_cashup

    my $cashup_start = $cash_register->start_cashup(
        {
            manager_id => $logged_in_user->id,
        }
    );

Start a new cashup period. This marks the beginning of the cash counting process
and creates a snapshot point for calculating outstanding amounts. Returns the
CASHUP_START action.

=cut

sub start_cashup {
    my ( $self, $params ) = @_;

    # check for mandatory params
    my @mandatory = ('manager_id');
    for my $param (@mandatory) {
        unless ( defined( $params->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw( error => "The $param parameter is mandatory" );
        }
    }
    my $manager_id = $params->{manager_id};

    # Check if there's already a cashup in progress
    my $last_cashup_start_rs = $self->_result->search_related(
        'cash_register_actions',
        { 'code'   => 'CASHUP_START' },
        { order_by => { '-desc' => [ 'timestamp', 'id' ] }, rows => 1 }
    )->single;

    my $last_cashup_completed = $self->cashups(
        {},
        { order_by => { '-desc' => [ 'timestamp', 'id' ] }, rows => 1 }
    )->single;

    # If we have a CASHUP_START that's more recent than the last CASHUP, there's already an active cashup
    if (
        $last_cashup_start_rs
        && (
            !$last_cashup_completed || DateTime->compare(
                dt_from_string( $last_cashup_start_rs->timestamp ),
                dt_from_string( $last_cashup_completed->timestamp )
            ) > 0
        )
        )
    {
        Koha::Exceptions::Object::DuplicateID->throw( error => "A cashup is already in progress for this register" );
    }

    my $expected_amount =
        $self->outstanding_accountlines->total( { payment_type => $self->cashup_payment_types } ) * -1;

    # Prevent starting a cashup when there are no transactions at all
    my $total_transactions = $self->outstanding_accountlines->total() * -1;
    unless ( $total_transactions != 0 ) {
        Koha::Exceptions::Object::BadValue->throw(
            error => "Cannot start cashup with no transactions",
            type  => 'amount',
            value => $total_transactions
        );
    }

    # Create the CASHUP_START action, translating raw DBIC exceptions
    my $schema = $self->_result->result_source->schema;
    my $rs;
    try {
        $rs = $self->_result->add_to_cash_register_actions(
            {
                code       => 'CASHUP_START',
                manager_id => $manager_id,
                amount     => $expected_amount
            }
        )->discard_changes;
    } catch {
        $schema->translate_exception($_) if ref($_) eq 'DBIx::Class::Exception';
        $_->rethrow();
    };

    return Koha::Cash::Register::Cashup->_new_from_dbic($rs);
}

=head3 cashup_payment_types

    my $payment_types = $cash_register->cashup_payment_types;

Returns an arrayref of PAYMENT_TYPE authorised value codes that participate
in the cashup reconciliation workflow, in the order listed by the
CashupPaymentTypes system preference. Falls back to ['CASH', 'SIP00'] (the
previously hardcoded set) if the preference is empty or missing.

=cut

sub cashup_payment_types {
    my ($self) = @_;

    my $pref  = C4::Context->preference('CashupPaymentTypes') // '';
    my @types = grep { length $_ } split /\s*,\s*/, $pref;
    return @types ? \@types : [ 'CASH', 'SIP00' ];
}

=head3 cashup_payment_types_breakdown

    my $rows = $cash_register->cashup_payment_types_breakdown;

Returns an arrayref of C<{ payment_type => ..., label => ..., expected => ... }>
hashes, one per type listed in CashupPaymentTypes, in that order. The expected
amount is taken from the in-progress cashup if one exists, otherwise from the
register's outstanding accountlines. Labels come from the PAYMENT_TYPE
authorised value category, falling back to the code itself if no label is
defined.

=cut

sub cashup_payment_types_breakdown {
    my ($self) = @_;

    my $configured = $self->cashup_payment_types;

    # When a two-phase cashup is in progress, scope to that session's
    # accountlines explicitly. Otherwise fall back to the register's
    # outstanding accountlines (everything since the last completed CASHUP).
    my $in_progress = $self->cashup_in_progress;
    my $source =
          $in_progress
        ? $in_progress->accountlines
        : $self->outstanding_accountlines;

    my $av_labels = { map { $_->authorised_value => $_->lib }
            Koha::AuthorisedValues->search( { category => 'PAYMENT_TYPE' } )->as_list };

    return [
        map {
            my $code = $_;
            {
                payment_type => $code,
                label        => $av_labels->{$code} // $code,
                expected     => $source->total( { payment_type => $code } ) * -1,
            }
        } @$configured
    ];
}

=head3 add_cashup

    my $cashup = $cash_register->add_cashup(
        {
            manager_id      => $logged_in_user->id,
            reconciliations => [
                { payment_type => 'CASH',   actual_amount => 102.00 },
                { payment_type => 'CHEQUE', actual_amount =>  20.00, note => 'Drawer short' },
            ],
        }
    );

Complete a cashup period started with start_cashup(). Each entry in
B<reconciliations> is reconciled against the expected total for that payment
type alone. A non-zero discrepancy creates a CASHUP_SURPLUS or CASHUP_DEFICIT
accountline tagged with the relevant C<payment_type>. Balanced types create
no reconciliation line. Each entry may carry its own C<note>, which is stored
on that discrepancy's accountline.

Returns the completed CASHUP action.

=cut

sub add_cashup {
    my ( $self, $params ) = @_;

    # check for mandatory params
    unless ( defined $params->{manager_id} ) {
        Koha::Exceptions::MissingParameter->throw( error => "The manager_id parameter is mandatory" );
    }
    unless ( ref( $params->{reconciliations} ) eq 'ARRAY' && @{ $params->{reconciliations} } ) {
        Koha::Exceptions::MissingParameter->throw(
            error => "The 'reconciliations' parameter is mandatory and must be a non-empty arrayref" );
    }
    my $manager_id = $params->{manager_id};

    my $payment_types = $self->cashup_payment_types;
    my %valid_pt      = map { $_ => 1 } @$payment_types;

    my @reconciliations;
    for my $entry ( @{ $params->{reconciliations} } ) {
        unless ( defined $entry->{payment_type} && defined $entry->{actual_amount} ) {
            Koha::Exceptions::MissingParameter->throw(
                error => "Each reconciliation entry requires payment_type and actual_amount" );
        }
        unless ( looks_like_number( $entry->{actual_amount} ) ) {
            Koha::Exceptions::Account::AmountNotPositive->throw(
                error => "actual_amount for $entry->{payment_type} must be a valid number" );
        }
        unless ( $valid_pt{ $entry->{payment_type} } ) {
            Koha::Exceptions::Object::BadValue->throw(
                error => "Payment type '$entry->{payment_type}' is not in CashupPaymentTypes" );
        }
        push @reconciliations, {
            payment_type  => $entry->{payment_type},
            actual_amount => $entry->{actual_amount} + 0,
            note          => _sanitize_note( $entry->{note} ),
        };
    }

    # Find the most recent CASHUP_START to determine if we're in two-phase mode
    my $cashup_start;
    my $cashup_start_rs = $self->_result->search_related(
        'cash_register_actions',
        { 'code'   => 'CASHUP_START' },
        { order_by => { '-desc' => [ 'timestamp', 'id' ] }, rows => 1 }
    )->single;

    if ($cashup_start_rs) {

        # Two-phase mode: Check if this CASHUP_START has already been completed
        my $existing_completion = $self->_result->search_related(
            'cash_register_actions',
            {
                'code'      => 'CASHUP',
                'timestamp' => { '>' => $cashup_start_rs->timestamp }
            },
            { rows => 1 }
        )->single;

        if ( !$existing_completion ) {
            $cashup_start = Koha::Cash::Register::Cashup->_new_from_dbic($cashup_start_rs);
        }

    }

    # Compute expected and difference per reconciliation entry
    for my $r (@reconciliations) {
        my $filter = { payment_type => $r->{payment_type} };

        my $expected = (
              $cashup_start
            ? $cashup_start->accountlines->total($filter)
            : $self->outstanding_accountlines->total($filter)
        ) * -1;

        $r->{expected_amount} = $expected;
        $r->{difference}      = $r->{actual_amount} - $expected;
    }

    # Validate reconciliation note requirement: every discrepant row must have
    # its own note when the preference is enabled.
    my $note_required = C4::Context->preference('CashupReconciliationNoteRequired') // 0;
    if ($note_required) {
        for my $r (@reconciliations) {
            next if $r->{difference} == 0;
            next if defined $r->{note};
            Koha::Exceptions::MissingParameter->throw(
                error => "Reconciliation note is required when cashup amount differs from expected amount" );
        }

        # If notes are restricted to an authorised value category, reject anything
        # that isn't one of the allowed values (the UI only offers a matching
        # select, but the API/form param isn't otherwise constrained server-side)
        my $note_av_category = C4::Context->preference('CashupReconciliationNoteAuthorisedValue');
        if ($note_av_category) {
            require Koha::AuthorisedValues;
            for my $r (@reconciliations) {
                next unless defined $r->{note};
                my $valid = Koha::AuthorisedValues->search(
                    {
                        category         => $note_av_category,
                        authorised_value => $r->{note},
                    }
                )->count;
                unless ($valid) {
                    Koha::Exceptions::BadParameter->throw(
                        error     => "Reconciliation note is not a valid authorised value for this category",
                        parameter => 'reconciliation_note',
                    );
                }
            }
        }
    }

    # Total amount across all reconciliations — stored on the CASHUP action row
    my $total_amount = 0;
    $total_amount += $_->{actual_amount} for @reconciliations;

    # Use database transaction to ensure consistency
    my $schema = $self->_result->result_source->schema;
    my $cashup;

    $schema->txn_do(
        sub {
            try {
                # Create the cashup action (raw DBIC call; Koha::Object stores below are already translated)
                my $rs = $self->_result->add_to_cash_register_actions(
                    {
                        code       => 'CASHUP',
                        manager_id => $manager_id,
                        amount     => $total_amount
                    }
                )->discard_changes;
                $cashup = Koha::Cash::Register::Cashup->_new_from_dbic($rs);

                # Determine reconciliation date once — applies to all surplus/deficit lines
                my $reconciliation_date;
                if ($cashup_start) {

                    # Two-phase mode: Backdate reconciliation lines to just before the CASHUP_START timestamp
                    # This ensures they belong to the previous session, not the current one
                    $reconciliation_date = \[ 'DATE_SUB(?, INTERVAL 1 SECOND)', $cashup_start->timestamp ];
                } else {

                    # Legacy mode: Use the original backdating approach
                    $reconciliation_date = \'DATE_SUB(NOW(), INTERVAL 1 SECOND)';
                }

                # Create per-type reconciliation accountlines for non-zero discrepancies
                for my $r (@reconciliations) {
                    next if $r->{difference} == 0;

                    if ( $r->{difference} > 0 ) {

                        # Surplus: more found than expected (credits are negative amounts)
                        my $surplus = Koha::Account::Line->new(
                            {
                                date              => $reconciliation_date,
                                amount            => -abs( $r->{difference} ),
                                amountoutstanding => 0,
                                credit_type_code  => 'CASHUP_SURPLUS',
                                manager_id        => $manager_id,
                                interface         => 'intranet',
                                branchcode        => $self->branch,
                                register_id       => $self->id,
                                payment_type      => $r->{payment_type},
                                note              => $r->{note}
                            }
                        )->store();

                        Koha::Account::Offset->new(
                            {
                                credit_id => $surplus->id,
                                type      => 'CREATE',
                                amount    => -abs( $r->{difference} )
                            }
                        )->store();

                    } else {

                        # Deficit: less found than expected
                        my $deficit = Koha::Account::Line->new(
                            {
                                date              => $reconciliation_date,
                                amount            => abs( $r->{difference} ),
                                amountoutstanding => 0,
                                debit_type_code   => 'CASHUP_DEFICIT',
                                manager_id        => $manager_id,
                                interface         => 'intranet',
                                branchcode        => $self->branch,
                                register_id       => $self->id,
                                payment_type      => $r->{payment_type},
                                note              => $r->{note}
                            }
                        )->store();

                        Koha::Account::Offset->new(
                            {
                                debit_id => $deficit->id,
                                type     => 'CREATE',
                                amount   => abs( $r->{difference} )
                            }
                        )->store();
                    }
                }
            } catch {
                $schema->translate_exception($_) if ref($_) eq 'DBIx::Class::Exception';
                $_->rethrow();
            };
        }
    );

    return $cashup;
}

=head3 _get_session_start_timestamp

Internal method to determine the start timestamp for the current "open" session.
This handles the following cashup scenarios:

=over 4

=item 1. No cashups ever → undef (returns all accountlines)

=item 2. Quick cashup completed → Uses CASHUP timestamp

=item 3. Two-phase started → Uses CASHUP_START timestamp

=item 4. Two-phase completed → Uses the CASHUP_START timestamp that led to the last CASHUP

=item 5. Mixed workflows → Correctly distinguishes between quick and two-phase cashups

=back

=cut

sub _get_session_start_timestamp {
    my ($self) = @_;

    # Check if there's a cashup in progress (CASHUP_START without corresponding CASHUP)
    my $cashup_in_progress = $self->cashup_in_progress;

    if ($cashup_in_progress) {

        # Scenario 3: Two-phase cashup started - return accountlines since CASHUP_START
        return $cashup_in_progress->timestamp;
    }

    # No cashup in progress - find the most recent cashup completion
    my $last_cashup = $self->cashups(
        {},
        {
            order_by => { '-desc' => [ 'timestamp', 'id' ] },
            rows     => 1
        }
    )->single;

    if ( !$last_cashup ) {

        # Scenario 1: No cashups have ever taken place - return all accountlines
        return;
    }

    # Find if this CASHUP was part of a two-phase workflow
    my $corresponding_start = $self->_result->search_related(
        'cash_register_actions',
        {
            'code'      => 'CASHUP_START',
            'timestamp' => { '<' => $last_cashup->timestamp }
        },
        {
            order_by => { '-desc' => [ 'timestamp', 'id' ] },
            rows     => 1
        }
    )->single;

    if ($corresponding_start) {

        # Check if this CASHUP_START was completed by this CASHUP
        # (no other CASHUP between them)
        my $intervening_cashup = $self->_result->search_related(
            'cash_register_actions',
            {
                'code'      => 'CASHUP',
                'timestamp' => {
                    '>' => $corresponding_start->timestamp,
                    '<' => $last_cashup->timestamp
                }
            },
            { rows => 1 }
        )->single;

        if ( !$intervening_cashup ) {

            # Scenario 4: Two-phase cashup completed - return accountlines since the CASHUP_START
            return $corresponding_start->timestamp;
        }
    }

    # Scenarios 2 & 5: Quick cashup (or orphaned CASHUP) - return accountlines since CASHUP
    return $last_cashup->timestamp;
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

=head3 _sanitize_note

    my $clean = Koha::Cash::Register::_sanitize_note($note);

Trim whitespace, cap at 1000 characters, and treat an empty result as
undef. Used internally by C<add_cashup> for both the cashup-wide note
and per-row notes.

=cut

sub _sanitize_note {
    my ($note) = @_;

    # Explicit `undef` (not bare `return`) so that the value remains a
    # single element when the helper is interpolated into a hash literal.
    return undef unless defined $note;      ## no critic (Subroutines::ProhibitExplicitReturnUndef)
    $note = substr( $note, 0, 1000 );
    $note =~ s/^\s+|\s+$//g;
    return length $note ? $note : undef;    ## no critic (Subroutines::ProhibitExplicitReturnUndef)
}

1;

=head1 AUTHORS

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut
