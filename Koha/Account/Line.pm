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

use Koha::Database;
use Koha::Items;
use Koha::Account::Offsets;

use base qw(Koha::Object);

=head1 NAME

Koha::Account::Lines - Koha accountline Object class

=head1 API

=head2 Class Methods

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
    return unless $self->accounttype =~ /^Pay/;

    my @account_offsets =
      Koha::Account::Offsets->search(
        { credit_id => $self->id, type => 'Payment' } );

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

=head3 _type

=cut

sub _type {
    return 'Accountline';
}

1;
