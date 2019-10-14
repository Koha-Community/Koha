package Koha::Account::Line;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use Carp;
use Data::Dumper;

use C4::Log qw(logaction);

use Koha::Account::DebitType;
use Koha::Account::Offsets;
use Koha::Database;
use Koha::Exceptions::Account;
use Koha::Items;

use base qw(Koha::Object);

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

=head3 debit_type

Return the debit_type linked to this account line

=cut

sub debit_type {
    my ( $self ) = @_;
    my $rs = $self->_result->debit_type_code;
    return unless $rs;
    return Koha::Account::DebitType->_new_from_dbic( $rs );
}

=head3 void

  $payment_accountline->void();

Used to 'void' (or reverse) a payment/credit. It will roll back any offsets
created by the application of this credit upon any debits and mark the credit
as 'void' by updating it's status to "VOID".

=cut

sub void {
    my ($self) = @_;

    # Make sure it is a payment we are voiding
    return unless $self->amount < 0;

    my @account_offsets =
      Koha::Account::Offsets->search(
        { credit_id => $self->id, amount => { '<' => 0 }  } );

    $self->_result->result_source->schema->txn_do(
        sub {
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
                        type      => 'Void Payment',
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

            $self->set(
                {
                    status            => 'VOID',
                    amountoutstanding => 0,
                    amount            => 0,
                }
            );
            $self->store();
        }
    );

}

=head3 apply

    my $debits = $account->outstanding_debits;
    my $outstanding_amount = $credit->apply( { debits => $debits, [ offset_type => $offset_type ] } );

Applies the credit to a given debits array reference.

=head4 arguments hashref

=over 4

=item debits - Koha::Account::Lines object set of debits

=item offset_type (optional) - a string indicating the offset type (valid values are those from
the 'account_offset_types' table)

=back

=cut

sub apply {
    my ( $self, $params ) = @_;

    my $debits      = $params->{debits};
    my $offset_type = $params->{offset_type} // 'Credit Applied';

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
                    type      => $offset_type,
                }
            )->store();

            $available_credit -= $amount_to_cancel;

            $self->amountoutstanding( $available_credit * -1 )->store;
            $debit->amountoutstanding( $owed - $amount_to_cancel )->store;

            # Same logic exists in Koha::Account::pay
            if (   $debit->amountoutstanding == 0
                && $debit->itemnumber
                && $debit->debit_type_code
                && $debit->debit_type_code eq 'LOST' )
            {
                C4::Circulation::ReturnLostItem( $self->borrowernumber, $debit->itemnumber );
            }

        }
    });

    return $available_credit;
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
                        description => 'Overpayment refund',
                        type        => 'CREDIT',
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

    return ( $self->amount < 0 );
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
        accounttype       => 'account_type',
        amountoutstanding => 'amount_outstanding',
        borrowernumber    => 'patron_id',
        branchcode        => 'library_id',
        issue_id          => 'checkout_id',
        itemnumber        => 'item_id',
        manager_id        => 'user_id',
        note              => 'internal_note',
    };
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
