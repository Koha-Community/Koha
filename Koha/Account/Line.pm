package Koha::Account::Line;

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

use Data::Dumper qw( Dumper );

use C4::Log qw( logaction );

use Koha::Account::CreditType;
use Koha::Account::DebitType;
use Koha::Account::Offsets;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions::Account;
use Koha::Items;

use base qw(Koha::Object Koha::Object::Mixin::AdditionalFields);

=encoding utf8

=head1 NAME

Koha::Account::Line - Koha accountline Object class

=head1 API

=head2 Class methods

=cut

=head3 patron

Return the patron linked to this account line

=cut

sub patron {
    my ( $self ) = @_;
    my $rs = $self->_result->borrowernumber;
    return unless $rs;
    return Koha::Patron->_new_from_dbic( $rs );
}

=head3 manager

Return the manager linked to this account line

=cut

sub manager {
    my ( $self ) = @_;
    my $rs = $self->_result->manager;
    return unless $rs;
    return Koha::Patron->_new_from_dbic( $rs );
}

=head3 item

Return the item linked to this account line if exists

=cut

sub item {
    my ( $self ) = @_;
    my $rs = $self->_result->itemnumber;
    return unless $rs;
    return Koha::Item->_new_from_dbic( $rs );
}

=head3 checkout

Return the checkout linked to this account line if exists

=cut

sub checkout {
    my ( $self ) = @_;
    return unless $self->issue_id ;

    $self->{_checkout} ||= Koha::Checkouts->find( $self->issue_id );
    $self->{_checkout} ||= Koha::Old::Checkouts->find( $self->issue_id );
    return $self->{_checkout};
}

=head3 library

Returns a Koha::Library object representing where the accountline was recorded

=cut

sub library {
    my ( $self ) = @_;
    my $rs = $self->_result->library;
    return unless $rs;
    return Koha::Library->_new_from_dbic($rs);
}

=head3 credit_type

Return the credit_type linked to this account line

=cut

sub credit_type {
    my ( $self ) = @_;
    my $rs = $self->_result->credit_type_code;
    return unless $rs;
    return Koha::Account::CreditType->_new_from_dbic( $rs );
}

=head3 debit_type

Return the debit_type linked to this account line

=cut

sub debit_type {
    my ( $self ) = @_;
    my $rs = $self->_result->debit_type_code;
    return unless $rs;
    return Koha::Account::DebitType->_new_from_dbic( $rs );
}

=head3 credit_offsets

Return the credit_offsets linked to this account line if some exist

=cut

sub credit_offsets {
    my ( $self, $cond, $attr ) = @_;

    unless ( $self->is_credit ) {
        Koha::Exceptions::Account::IsNotCredit->throw(
            error => 'Account line ' . $self->id . ' is not a credit'
        );
    }

    my $rs = $self->_result->search_related( 'account_offsets_credits', $cond, $attr);
    return unless $rs;
    return Koha::Account::Offsets->_new_from_dbic($rs);
}

=head3 debit_offsets

Return the debit_offsets linked to this account line if some exist

=cut

sub debit_offsets {
    my ( $self, $cond, $attr ) = @_;

    unless ( $self->is_debit ) {
        Koha::Exceptions::Account::IsNotDebit->throw(
            error => 'Account line ' . $self->id . ' is not a debit'
        );
    }

    my $rs = $self->_result->search_related( 'account_offsets_debits', $cond, $attr);
    return unless $rs;
    return Koha::Account::Offsets->_new_from_dbic($rs);
}

=head3 credits

  my $credits = $accountline->credits;
  my $credits = $accountline->credits( $cond, $attr );

Return the credits linked to this account line if some exist.
Search conditions and attributes may be passed if you wish to filter
the resultant resultant resultset.

=cut

sub credits {
    my ( $self, $cond, $attr ) = @_;

    unless ( $self->is_debit ) {
        Koha::Exceptions::Account::IsNotDebit->throw(
            error => 'Account line ' . $self->id . ' is not a debit'
        );
    }

    my $cond_m = { map { "credit.".$_ => $cond->{$_} } keys %{$cond}};
    my $rs =
      $self->_result->search_related('account_offsets_debits')
      ->search_related( 'credit', $cond_m, $attr );
    return unless $rs;
    return Koha::Account::Lines->_new_from_dbic($rs);
}

=head3 debits

  my $debits = $accountline->debits;
  my $debits = $accountline->debits( $cond, $attr );

Return the debits linked to this account line if some exist.
Search conditions and attributes may be passed if you wish to filter
the resultant resultant resultset.

=cut

sub debits {
    my ( $self, $cond, $attr ) = @_;

    unless ( $self->is_credit ) {
        Koha::Exceptions::Account::IsNotCredit->throw(
            error => 'Account line ' . $self->id . ' is not a credit'
        );
    }

    my $cond_m = { map { "debit.".$_ => $cond->{$_} } keys %{$cond}};
    my $rs =
      $self->_result->search_related('account_offsets_credits')
      ->search_related( 'debit', $cond_m, $attr );
    return unless $rs;
    return Koha::Account::Lines->_new_from_dbic($rs);
}

=head3 void

  $payment_accountline->void({
      interface => $interface,
      [ staff_id => $staff_id, branch => $branchcode ]
  });

Used to 'void' (or reverse) a payment/credit. It will roll back any offsets
created by the application of this credit upon any debits and mark the credit
as 'void' by updating it's status to "VOID".

=cut

sub void {
    my ($self, $params) = @_;

    # Make sure it is a credit we are voiding
    unless ( $self->is_credit ) {
        Koha::Exceptions::Account::IsNotCredit->throw(
            error => 'Account line ' . $self->id . 'is not a credit' );
    }

    # Make sure it is not already voided
    if ( $self->status && $self->status eq 'VOID' ) {
        Koha::Exceptions::Account->throw(
            error => 'Account line ' . $self->id . 'is already void' );
    }

    # Check for mandatory parameters
    my @mandatory = ( 'interface' );
    for my $param (@mandatory) {
        unless ( defined( $params->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw(
                error => "The $param parameter is mandatory" );
        }
    }

    # More mandatory parameters
    if ( $params->{interface} eq 'intranet' ) {
        my @optional = ( 'staff_id', 'branch' );
        for my $param (@optional) {
            unless ( defined( $params->{$param} ) ) {
                Koha::Exceptions::MissingParameter->throw( error =>
"The $param parameter is mandatory when interface is set to 'intranet'"
                );
            }
        }
    }

    # Find any applied offsets for the credit so we may reverse them
    my @account_offsets =
      Koha::Account::Offsets->search(
        { credit_id => $self->id, amount => { '<' => 0 }  } )->as_list;

    my $void;
    $self->_result->result_source->schema->txn_do(
        sub {

            # A 'void' is a 'debit'
            $void = Koha::Account::Line->new(
                {
                    borrowernumber    => $self->borrowernumber,
                    date              => \'NOW()',
                    debit_type_code   => 'VOID',
                    amount            => $self->amount * -1,
                    amountoutstanding => $self->amount * -1,
                    manager_id        => $params->{staff_id},
                    interface         => $params->{interface},
                    branchcode        => $params->{branch},
                }
            )->store();

            # Record the creation offset
            Koha::Account::Offset->new(
                {
                    debit_id => $void->id,
                    type     => 'CREATE',
                    amount   => $self->amount * -1
                }
            )->store();

            # Link void to payment
            $self->set({
                amountoutstanding => $self->amount,
                status => 'VOID'
            })->store();
            $self->apply( { debits => [$void] } );

            # Reverse any applied payments
            foreach my $account_offset (@account_offsets) {
                my $fee_paid =
                  Koha::Account::Lines->find( $account_offset->debit_id );

                next unless $fee_paid;

                my $amount_paid = $account_offset->amount * -1; # amount paid is stored as a negative amount
                my $new_amount = $fee_paid->amountoutstanding + $amount_paid;
                $fee_paid->amountoutstanding($new_amount);
                $fee_paid->store();

                Koha::Account::Offset->new(
                    {
                        credit_id => $self->id,
                        debit_id  => $fee_paid->id,
                        amount    => $amount_paid,
                        type      => 'VOID',
                    }
                )->store();
            }

            if ( C4::Context->preference("FinesLog") ) {
                logaction(
                    "FINES", 'VOID',
                    $self->borrowernumber,
                    Dumper(
                        {
                            action         => 'void_payment',
                            borrowernumber => $self->borrowernumber,
                            amount            => $self->amount,
                            amountoutstanding => $self->amountoutstanding,
                            description       => $self->description,
                            credit_type_code  => $self->credit_type_code,
                            payment_type      => $self->payment_type,
                            note              => $self->note,
                            itemnumber        => $self->itemnumber,
                            manager_id        => $self->manager_id,
                            offsets =>
                              [ map { $_->unblessed } @account_offsets ],
                        }
                    )
                );
            }
        }
    );

    $void->discard_changes;
    return $void;
}

=head3 cancel

  $debit_accountline->cancel();

Cancel a charge. It will mark the debit as 'cancelled' by updating its
status to 'CANCELLED'.

Charges that have been fully or partially paid cannot be cancelled.

Returns the cancellation accountline.

=cut

sub cancel {
    my ( $self, $params ) = @_;

    # Make sure it is a charge we are reducing
    unless ( $self->is_debit ) {
        Koha::Exceptions::Account::IsNotDebit->throw(
            error => 'Account line ' . $self->id . 'is not a debit' );
    }
    if ( $self->debit_type_code eq 'PAYOUT' ) {
        Koha::Exceptions::Account::IsNotDebit->throw(
            error => 'Account line ' . $self->id . 'is a payout' );
    }

    # Make sure it is not already cancelled
    if ( $self->status && $self->status eq 'CANCELLED' ) {
        Koha::Exceptions::Account->throw(
            error => 'Account line ' . $self->id . 'is already cancelled' );
    }

    # Make sure it has not be paid yet
    if ( $self->amount != $self->amountoutstanding ) {
        Koha::Exceptions::Account->throw(
            error => 'Account line ' . $self->id . 'is already offset' );
    }

    # Check for mandatory parameters
    my @mandatory = ( 'staff_id', 'branch' );
    for my $param (@mandatory) {
        unless ( defined( $params->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw(
                error => "The $param parameter is mandatory" );
        }
    }

    my $cancellation;
    $self->_result->result_source->schema->txn_do(
        sub {

            # A 'cancellation' is a 'credit'
            $cancellation = Koha::Account::Line->new(
                {
                    date              => \'NOW()',
                    amount            => 0 - $self->amount,
                    credit_type_code  => 'CANCELLATION',
                    status            => 'ADDED',
                    amountoutstanding => 0 - $self->amount,
                    manager_id        => $params->{staff_id},
                    borrowernumber    => $self->borrowernumber,
                    interface         => 'intranet',
                    branchcode        => $params->{branch},
                }
            )->store();

            my $cancellation_offset = Koha::Account::Offset->new(
                {
                    credit_id => $cancellation->accountlines_id,
                    type      => 'CREATE',
                    amount    => 0 - $self->amount
                }
            )->store();

            # Link cancellation to charge
            $cancellation->apply( { debits => [$self] } );
            $cancellation->status('APPLIED')->store();

            # Update status of original debit
            $self->status('CANCELLED')->store;
        }
    );

    $cancellation->discard_changes;
    return $cancellation;
}

=head3 reduce

  $charge_accountline->reduce({
      reduction_type => $reduction_type
  });

Used to 'reduce' a charge/debit by adding a credit to offset against the amount
outstanding.

May be used to apply a discount whilst retaining the original debit amounts or
to apply a full or partial refund for example when a lost item is found and
returned.

It will immediately be applied to the given debit unless the debit has already
been paid, in which case a 'zero' offset will be added to maintain a link to
the debit but the outstanding credit will be left so it may be applied to other
debts.

Reduction type may be one of:

* REFUND
* DISCOUNT

Returns the reduction accountline (which will be a credit)

=cut

sub reduce {
    my ( $self, $params ) = @_;

    # Make sure it is a charge we are reducing
    unless ( $self->is_debit ) {
        Koha::Exceptions::Account::IsNotDebit->throw(
            error => 'Account line ' . $self->id . 'is not a debit' );
    }
    if ( $self->debit_type_code eq 'PAYOUT' ) {
        Koha::Exceptions::Account::IsNotDebit->throw(
            error => 'Account line ' . $self->id . 'is a payout' );
    }

    # Check for mandatory parameters
    my @mandatory = ( 'interface', 'reduction_type', 'amount' );
    for my $param (@mandatory) {
        unless ( defined( $params->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw(
                error => "The $param parameter is mandatory" );
        }
    }

    # More mandatory parameters
    if ( $params->{interface} eq 'intranet' ) {
        my @optional = ( 'staff_id', 'branch' );
        for my $param (@optional) {
            unless ( defined( $params->{$param} ) ) {
                Koha::Exceptions::MissingParameter->throw( error =>
"The $param parameter is mandatory when interface is set to 'intranet'"
                );
            }
        }
    }

    # Make sure the reduction isn't more than the original
    my $original = $self->amount;
    Koha::Exceptions::Account::AmountNotPositive->throw(
        error => 'Reduce amount passed is not positive' )
      unless ( $params->{amount} > 0 );
    Koha::Exceptions::ParameterTooHigh->throw( error =>
"Amount to reduce ($params->{amount}) is higher than original amount ($original)"
    ) unless ( $original >= $params->{amount} );
    my $reduced =
      $self->credits( { credit_type_code => [ 'DISCOUNT', 'REFUND' ] } )->total;
    Koha::Exceptions::ParameterTooHigh->throw( error =>
"Combined reduction ($params->{amount} + $reduced) is higher than original amount ("
          . abs($original)
          . ")" )
      unless ( $original >= ( $params->{amount} + abs($reduced) ) );

    my $status = { 'REFUND' => 'REFUNDED', 'DISCOUNT' => 'DISCOUNTED' };

    my $reduction;
    $self->_result->result_source->schema->txn_do(
        sub {

            # A 'reduction' is a 'credit'
            $reduction = Koha::Account::Line->new(
                {
                    date              => \'NOW()',
                    amount            => 0 - $params->{amount},
                    credit_type_code  => $params->{reduction_type},
                    status            => 'ADDED',
                    amountoutstanding => 0 - $params->{amount},
                    manager_id        => $params->{staff_id},
                    borrowernumber    => $self->borrowernumber,
                    interface         => $params->{interface},
                    branchcode        => $params->{branch},
                }
            )->store();

            my $reduction_offset = Koha::Account::Offset->new(
                {
                    credit_id => $reduction->accountlines_id,
                    type      => 'CREATE',
                    amount    => 0 - $params->{amount}
                }
            )->store();

            # Link reduction to charge (and apply as required)
            my $debit_outstanding = $self->amountoutstanding;
            if ( $debit_outstanding >= $params->{amount} ) {

                $reduction->apply( { debits => [$self] } );
                $reduction->status('APPLIED')->store();
            }
            else {

                # Zero amount offset used to link original 'debit' to
                # reduction 'credit'
                my $link_reduction_offset = Koha::Account::Offset->new(
                    {
                        credit_id => $reduction->accountlines_id,
                        debit_id  => $self->accountlines_id,
                        type      => 'APPLY',
                        amount    => 0
                    }
                )->store();
            }

            # Update status of original debit
            $self->status( $status->{ $params->{reduction_type} } )->store;
        }
    );

    $reduction->discard_changes;
    return $reduction;
}

=head3 apply

    my $debits = $account->outstanding_debits;
    my $credit = $credit->apply( { debits => $debits } );

Applies the credit to a given debits array reference.

=head4 arguments hashref

=over 4

=item debits - Koha::Account::Lines object set of debits

=back

=cut

sub apply {
    my ( $self, $params ) = @_;

    my $debits      = $params->{debits};

    unless ( $self->is_credit ) {
        Koha::Exceptions::Account::IsNotCredit->throw(
            error => 'Account line ' . $self->id . ' is not a credit'
        );
    }

    my $available_credit = $self->amountoutstanding * -1;

    unless ( $available_credit > 0 ) {
        Koha::Exceptions::Account::NoAvailableCredit->throw(
            error => 'Outstanding credit is ' . $available_credit . ' and cannot be applied'
        );
    }

    my $schema = Koha::Database->new->schema;

    $schema->txn_do( sub {
        for my $debit ( @{$debits} ) {

            unless ( $debit->is_debit ) {
                Koha::Exceptions::Account::IsNotDebit->throw(
                    error => 'Account line ' . $debit->id . 'is not a debit'
                );
            }
            my $amount_to_cancel;
            my $owed = $debit->amountoutstanding;

            if ( $available_credit >= $owed ) {
                $amount_to_cancel = $owed;
            }
            else {    # $available_credit < $debit->amountoutstanding
                $amount_to_cancel = $available_credit;
            }

            # record the account offset
            Koha::Account::Offset->new(
                {   credit_id => $self->id,
                    debit_id  => $debit->id,
                    amount    => $amount_to_cancel * -1,
                    type      => 'APPLY'
                }
            )->store();

            $available_credit -= $amount_to_cancel;

            $self->amountoutstanding( $available_credit * -1 )->store;
            $debit->amountoutstanding( $owed - $amount_to_cancel )->store;

            # Attempt to renew the item associated with this debit if
            # appropriate
            if ( $self->credit_type_code ne 'FORGIVEN' && $debit->is_renewable ) {
                my $outcome = $debit->renew_item( { interface => $params->{interface} } );
                $self->add_message(
                    {
                        type    => 'info',
                        message => 'renewal',
                        payload => $outcome
                    }
                ) if $outcome;
            }
            $debit->discard_changes; # Refresh values from DB to clear floating point remainders

            # Same logic exists in Koha::Account::pay
            if (
                C4::Context->preference('MarkLostItemsAsReturned') =~
                m|onpayment|
                && $debit->debit_type_code
                && $debit->debit_type_code eq 'LOST'
                && $debit->amountoutstanding == 0
                && $debit->itemnumber
                && !(
                       $self->credit_type_code eq 'LOST_FOUND'
                    && $self->itemnumber == $debit->itemnumber
                )
              )
            {
                C4::Circulation::ReturnLostItem( $self->borrowernumber,
                    $debit->itemnumber );
            }

            last if $available_credit == 0;
        }
    });

    return $self;
}

=head3 payout

  $credit_accountline->payout(
    {
        payout_type => $payout_type,
        register_id => $register_id,
        staff_id    => $staff_id,
        interface   => 'intranet',
        amount      => $amount
    }
  );

Used to 'pay out' a credit to a user.

Payout type may be one of any existing payment types

Returns the payout debit line that is created via this transaction.

=cut

sub payout {
    my ( $self, $params ) = @_;

    # Make sure it is a credit we are paying out
    unless ( $self->is_credit ) {
        Koha::Exceptions::Account::IsNotCredit->throw(
            error => 'Account line ' . $self->id . ' is not a credit' );
    }

    # Check for mandatory parameters
    my @mandatory =
      ( 'interface', 'staff_id', 'branch', 'payout_type', 'amount' );
    for my $param (@mandatory) {
        unless ( defined( $params->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw(
                error => "The $param parameter is mandatory" );
        }
    }

    # Make sure there is outstanding credit to pay out
    my $outstanding = -1 * $self->amountoutstanding;
    my $amount =
      $params->{amount} ? $params->{amount} : $outstanding;
    Koha::Exceptions::Account::AmountNotPositive->throw(
        error => 'Payout amount passed is not positive' )
      unless ( $amount > 0 );
    Koha::Exceptions::ParameterTooHigh->throw(
        error => "Amount to payout ($amount) is higher than amountoutstanding ($outstanding)" )
      unless ($outstanding >= $amount );

    # Make sure we record the cash register for cash transactions
    Koha::Exceptions::Account::RegisterRequired->throw()
      if ( C4::Context->preference("UseCashRegisters")
        && defined( $params->{payout_type} )
        && ( $params->{payout_type} eq 'CASH' || $params->{payout_type} eq 'SIP00' )
        && !defined( $params->{cash_register} ) );

    my $payout;
    $self->_result->result_source->schema->txn_do(
        sub {

            # A 'payout' is a 'debit'
            $payout = Koha::Account::Line->new(
                {
                    date              => \'NOW()',
                    amount            => $amount,
                    debit_type_code   => 'PAYOUT',
                    payment_type      => $params->{payout_type},
                    amountoutstanding => $amount,
                    manager_id        => $params->{staff_id},
                    borrowernumber    => $self->borrowernumber,
                    interface         => $params->{interface},
                    branchcode        => $params->{branch},
                    register_id       => $params->{cash_register}
                }
            )->store();

            my $payout_offset = Koha::Account::Offset->new(
                {
                    debit_id => $payout->accountlines_id,
                    type     => 'CREATE',
                    amount   => $amount
                }
            )->store();

            $self->apply( { debits => [$payout] } );
            $self->status('PAID')->store;
        }
    );

    $payout->discard_changes;
    return $payout;
}

=head3 adjust

This method allows updating a debit or credit on a patron's account

    $account_line->adjust(
        {
            amount    => $amount,
            type      => $update_type,
            interface => $interface
        }
    );

$update_type can be any of:
  - overdue_update

Authors Note: The intention here is that this method is only used
to adjust accountlines where the final amount is not yet known/fixed.
Incrementing fines are the only existing case at the time of writing,
all other forms of 'adjustment' should be recorded as distinct credits
or debits and applied, via an offset, to the corresponding debit or credit.

=cut

sub adjust {
    my ( $self, $params ) = @_;

    my $amount       = $params->{amount};
    my $update_type  = $params->{type};
    my $interface    = $params->{interface};

    unless ( exists($Koha::Account::Line::allowed_update->{$update_type}) ) {
        Koha::Exceptions::Account::UnrecognisedType->throw(
            error => 'Update type not recognised'
        );
    }

    my $debit_type_code = $self->debit_type_code;
    my $account_status  = $self->status;
    unless (
        (
            exists(
                $Koha::Account::Line::allowed_update->{$update_type}
                  ->{$debit_type_code}
            )
            && ( $Koha::Account::Line::allowed_update->{$update_type}
                ->{$debit_type_code} eq $account_status )
        )
      )
    {
        Koha::Exceptions::Account::UnrecognisedType->throw(
            error => 'Update type not allowed on this debit_type' );
    }

    my $schema = Koha::Database->new->schema;

    $schema->txn_do(
        sub {

            my $amount_before             = $self->amount;
            my $amount_outstanding_before = $self->amountoutstanding;
            my $difference                = $amount - $amount_before;
            my $new_outstanding           = $amount_outstanding_before + $difference;

            my $offset_type = $debit_type_code;
            $offset_type .= ( $difference > 0 ) ? "_INCREASE" : "_DECREASE";

            # Catch cases that require patron refunds
            if ( $new_outstanding < 0 ) {
                my $account =
                  Koha::Patrons->find( $self->borrowernumber )->account;
                my $credit = $account->add_credit(
                    {
                        amount      => $new_outstanding * -1,
                        type        => 'OVERPAYMENT',
                        interface   => $interface,
                        ( $update_type eq 'overdue_update' ? ( item_id => $self->itemnumber ) : ()),
                    }
                );
                $new_outstanding = 0;
            }

            # Update the account line
            $self->set(
                {
                    date              => \'NOW()',
                    amount            => $amount,
                    amountoutstanding => $new_outstanding,
                }
            )->store();

            # Record the account offset
            my $account_offset = Koha::Account::Offset->new(
                {
                    debit_id => $self->id,
                    type     => $offset_type,
                    amount   => $difference
                }
            )->store();

            if ( C4::Context->preference("FinesLog") ) {
                logaction(
                    "FINES", 'UPDATE', #undef becomes UPDATE in UpdateFine
                    $self->borrowernumber,
                    Dumper(
                        {   action            => $update_type,
                            borrowernumber    => $self->borrowernumber,
                            amount            => $amount,
                            description       => undef,
                            amountoutstanding => $new_outstanding,
                            debit_type_code   => $self->debit_type_code,
                            note              => undef,
                            itemnumber        => $self->itemnumber,
                            manager_id        => undef,
                        }
                    )
                ) if ( $update_type eq 'overdue_update' );
            }
        }
    );

    return $self;
}

=head3 is_credit

    my $bool = $line->is_credit;

=cut

sub is_credit {
    my ($self) = @_;

    return defined $self->credit_type_code;
}

=head3 is_debit

    my $bool = $line->is_debit;

=cut

sub is_debit {
    my ($self) = @_;

    return !$self->is_credit;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Account::Line object
on the API.

=cut

sub to_api_mapping {
    return {
        accountlines_id   => 'account_line_id',
        credit_type_code  => 'credit_type',
        debit_type_code   => 'debit_type',
        amountoutstanding => 'amount_outstanding',
        borrowernumber    => 'patron_id',
        branchcode        => 'library_id',
        issue_id          => 'checkout_id',
        itemnumber        => 'item_id',
        manager_id        => 'user_id',
        note              => 'internal_note',
        register_id       => 'cash_register_id',
    };

}

=head3 is_renewable

    my $bool = $line->is_renewable;

=cut

sub is_renewable {
    my ($self) = @_;

    return (
        $self->amountoutstanding == 0 &&
        $self->debit_type_code &&
        $self->debit_type_code eq 'OVERDUE' &&
        $self->status &&
        $self->status eq 'UNRETURNED' &&
        $self->item &&
        $self->patron
    ) ? 1 : 0;
}

=head3 renew_item

    my $renew_result = $line->renew_item;

Conditionally attempt to renew an item and return the outcome. This is
as a consequence of the fine on an item being fully paid off.
Caller must call is_renewable before.

=cut

sub renew_item {
    my ($self, $params) = @_;

    my $outcome = {};

    # We want to reject the call to renew if:
    # - The RenewAccruingItemWhenPaid syspref is off
    # OR
    # - The RenewAccruingItemInOpac syspref is off
    # - There is an interface param passed and it's value is 'opac'

    if (
        !C4::Context->preference('RenewAccruingItemWhenPaid') ||
        (
            !C4::Context->preference('RenewAccruingItemInOpac') &&
            $params->{interface} &&
            $params->{interface} eq 'opac'
        )
    ) {
        return;
    }

    my $itemnumber = $self->item->itemnumber;
    my ( $can_renew, $error ) = C4::Circulation::CanBookBeRenewed(
        $self->patron,
        $self->item->checkout
    );
    if ( $can_renew ) {
        my $borrowernumber = $self->patron->borrowernumber;
        my $due_date = C4::Circulation::AddRenewal(
            $borrowernumber,
            $itemnumber,
            $self->{branchcode},
            undef,
            undef,
            undef,
            0
        );
        return {
            itemnumber => $itemnumber,
            due_date   => $due_date,
            success    => 1
        };
    } else {
        return {
            itemnumber => $itemnumber,
            error      => $error,
            success    => 0
        };
    }

}

=head3 store

Specific store method to generate credit number before saving

=cut

sub store {
    my ($self) = @_;

    my $AutoCreditNumber = C4::Context->preference('AutoCreditNumber');
    my $credit_number_enabled = $self->is_credit && $self->credit_type->credit_number_enabled;

    if ($AutoCreditNumber && $credit_number_enabled && !$self->in_storage) {
        if (defined $self->credit_number) {
            Koha::Exceptions::Account->throw('AutoCreditNumber is enabled but credit_number is already defined');
        }

        my $rs = Koha::Database->new->schema->resultset($self->_type);

        if ($AutoCreditNumber eq 'incremental') {
            my $max = $rs->search({
                credit_number => { -regexp => '^[0-9]+$' }
            }, {
                select => \'CAST(credit_number AS UNSIGNED)',
                as => ['credit_number'],
            })->get_column('credit_number')->max;
            $max //= 0;
            $self->credit_number($max + 1);
        } elsif ($AutoCreditNumber eq 'annual') {
            my $now = dt_from_string;
            my $prefix = sprintf('%d-', $now->year);
            my $max = $rs->search({
                -and => [
                    credit_number => { -regexp => '[0-9]{4}$' },
                    credit_number => { -like => "$prefix%" },
                ],
            })->get_column('credit_number')->max;
            $max //= $prefix . '0000';
            my $incr = substr($max, length $prefix);
            $self->credit_number(sprintf('%s%04d', $prefix, $incr + 1));
        } elsif ($AutoCreditNumber eq 'branchyyyymmincr') {
            my $userenv = C4::Context->userenv;
            if ($userenv) {
                my $branch = $userenv->{branch};
                my $now = dt_from_string;
                my $prefix = sprintf('%s%d%02d', $branch, $now->year, $now->month);
                my $pattern = $prefix;
                $pattern =~ s/([\?%_])/\\$1/g;
                my $max = $rs->search({
                    -and => [
                        credit_number => { -regexp => '[0-9]{4}$' },
                        credit_number => { -like => "$pattern%" },
                    ],
                })->get_column('credit_number')->max;
                $max //= $prefix . '0000';
                my $incr = substr($max, length $prefix);
                $self->credit_number(sprintf('%s%04d', $prefix, $incr + 1));
            }
        }
    }

    return $self->SUPER::store();
}

=head2 Internal methods

=cut

=head3 _type

=cut

sub _type {
    return 'Accountline';
}

1;

=head2 Name mappings

=head3 $allowed_update

=cut

our $allowed_update = { 'overdue_update' => { 'OVERDUE' => 'UNRETURNED' } };

=head1 AUTHORS

Kyle M Hall <kyle@bywatersolutions.com >
Tomás Cohen Arazi <tomascohen@theke.io>
Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut
