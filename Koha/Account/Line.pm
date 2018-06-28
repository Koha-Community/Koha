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

use Koha::Account::Offsets;
use Koha::Database;
use Koha::Exceptions::Account;
use Koha::Items;

use base qw(Koha::Object);

=head1 NAME

Koha::Account::Line - Koha accountline Object class

=head1 API

=head2 Class methods

=cut

=head3 item

Return the item linked to this account line if exists

=cut

sub item {
    my ( $self ) = @_;
    my $rs = $self->_result->itemnumber;
    return Koha::Item->_new_from_dbic( $rs );
}

=head3 void

$payment_accountline->void();

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
                            accounttype       => $self->accounttype,
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
                    accounttype       => 'VOID',
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
    my $outstanding_amount = $credit->apply({ debits =>  $debits, [ offset_type => $offset_type ] });

=cut

sub apply {
    my ( $self, $params ) = @_;

    my $debits      = $params->{debits};
    my $offset_type = $params->{offset_type} // 'credit_applied';

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
        while ( my $debit = $debits->next ) {

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
                    amount    => $amount_to_cancel,
                    type      => $offset_type,
                }
            )->store();

            $available_credit -= $amount_to_cancel;

            $self->amountoutstanding( $available_credit * -1 )->store;
            $debit->amountoutstanding( $owed - $amount_to_cancel )->store;
        }
    });

    return $available_credit;
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

=head2 Internal methods

=cut

=head3 _type

=cut

sub _type {
    return 'Accountline';
}

1;
