package Koha::Charges::Sales;

# Copyright 2019 PTFS Europe
#
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

use Koha::Account::Lines;
use Koha::Account::DebitTypes;
use Koha::Account::Offsets;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions;

=head1 NAME

Koha::Charges::Sale - Module for collecting sales in Koha

=head1 SYNOPSIS

  use Koha::Charges::Sale;

  my $sale =
    Koha::Charges::Sale->new( { cash_register => $register, staff_id => $staff_id } );
  $sale->add_item($item);
  $sale->purchase( { payment_type => 'CASH' } );

=head2 Class methods

=head3 new

  Koha::Charges::Sale->new(
    {
        cash_register  => $cash_register,
        staff_id        => $staff_id,
        [ payment_type => $payment_type ],
        [ items        => $items ],
        [ patron       => $patron ],
    }
  );

=cut

sub new {
    my ( $class, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw("Missing mandatory parameter: cash_register")
        unless $params->{cash_register};

    Koha::Exceptions::MissingParameter->throw("Missing mandatory parameter: staff_id")
        unless $params->{staff_id};

    Carp::confess("Key 'cash_register' is not a Koha::Cash::Register object!")
        unless $params->{cash_register}->isa('Koha::Cash::Register');

    return bless( $params, $class );
}

=head3 payment_type

  my $payment_type = $sale->payment_type( $payment_type );

A getter/setter for this instances associated payment type.

=cut

sub payment_type {
    my ( $self, $payment_type ) = @_;

    if ($payment_type) {
        Koha::Exceptions::Account::UnrecognisedType->throw( error => 'Type of payment not recognised' )
            unless ( exists( $self->_get_valid_payments->{$payment_type} ) );

        $self->{payment_type} = $payment_type;
    }

    return $self->{payment_type};
}

=head3 _get_valid_payments

  my $valid_payments = $sale->_get_valid_payments;

A getter which returns a hashref whose keys represent valid payment types.

=cut

sub _get_valid_payments {
    my $self = shift;

    $self->{valid_payments} //= {
        map { $_ => 1 } Koha::AuthorisedValues->search_with_library_limits(
            { category => 'PAYMENT_TYPE' },
            {},
            $self->{cash_register}->branch    # filter by cash_register branch
        )->get_column('authorised_value')
    };

    return $self->{valid_payments};
}

=head3 add_item

  my $item = { price => 0.25, quantity => 1, code => 'COPY' };
  $sale->add_item( $item );

=cut

sub add_item {
    my ( $self, $item ) = @_;

    Koha::Exceptions::MissingParameter->throw("Missing mandatory parameter: code")
        unless $item->{code};

    Koha::Exceptions::Account::UnrecognisedType->throw( error => 'Type of debit not recognised' )
        unless ( exists( $self->_get_valid_items->{ $item->{code} } ) );

    Koha::Exceptions::MissingParameter->throw("Missing mandatory parameter: price")
        unless $item->{price};

    Koha::Exceptions::MissingParameter->throw("Missing mandatory parameter: quantity")
        unless $item->{quantity};

    push @{ $self->{items} }, $item;
    return $self;
}

=head3 _get_valid_items

  my $valid_items = $sale->_get_valid_items;

A getter which returns a hashref whose keys represent valid sale items.

=cut

sub _get_valid_items {
    my $self = shift;

    $self->{valid_items} //= {
        map { $_ => 1 } Koha::Account::DebitTypes->search_with_library_limits(
            {}, {},
            $self->{cash_register}->branch
        )->get_column('code')
    };

    return $self->{valid_items};
}

=head3 purchase

  my $credit_line = $sale->purchase;

=cut

sub purchase {
    my ( $self, $params ) = @_;

    if ( $params->{payment_type} ) {
        Koha::Exceptions::Account::UnrecognisedType->throw( error => 'Type of payment not recognised' )
            unless ( exists( $self->_get_valid_payments->{ $params->{payment_type} } ) );

        $self->{payment_type} = $params->{payment_type};
    }

    Koha::Exceptions::MissingParameter->throw("Missing mandatory parameter: payment_type")
        unless $self->{payment_type};

    Koha::Exceptions::NoChanges->throw("Cannot purchase before calling add_item")
        unless $self->{items};

    my $schema     = Koha::Database->new->schema;
    my $dt         = dt_from_string();
    my $total_owed = 0;
    my $payment;

    $schema->txn_do(
        sub {

            # Add accountlines for each item being purchased
            my $debits;
            for my $item ( @{ $self->{items} } ) {

                my $amount = $item->{quantity} * $item->{price};
                $total_owed = $total_owed + $amount;

                # Insert the account line
                my $debit = Koha::Account::Line->new(
                    {
                        amount            => $amount,
                        debit_type_code   => $item->{code},
                        amountoutstanding => $amount,
                        note              => $item->{quantity},
                        manager_id        => $self->{staff_id},
                        interface         => 'intranet',
                        branchcode        => $self->{cash_register}->branch,
                        date              => $dt
                    }
                )->store();
                push @{$debits}, $debit;

                # Record the account offset
                my $account_offset = Koha::Account::Offset->new(
                    {
                        debit_id => $debit->id,
                        type     => 'CREATE',
                        amount   => $amount
                    }
                )->store();
            }

            # Add accountline for payment
            $payment = Koha::Account::Line->new(
                {
                    amount            => 0 - $total_owed,
                    credit_type_code  => 'PURCHASE',
                    payment_type      => $self->{payment_type},
                    amountoutstanding => 0 - $total_owed,
                    manager_id        => $self->{staff_id},
                    interface         => 'intranet',
                    branchcode        => $self->{cash_register}->branch,
                    register_id       => $self->{cash_register}->id,
                    date              => $dt,
                    note              => "POS SALE"
                }
            )->store();

            # Record the account offset
            my $payment_offset = Koha::Account::Offset->new(
                {
                    credit_id => $payment->id,
                    type      => 'CREATE',
                    amount    => $payment->amount
                }
            )->store();

            # Link payment to charges
            $payment->apply( { debits => $debits } );
            $payment->discard_changes;
        }
    );

    return $payment;
}

=head1 AUTHOR

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
