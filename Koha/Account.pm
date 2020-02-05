package Koha::Account;

# Copyright 2016 ByWater Solutions
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

use Carp;
use Data::Dumper;
use List::MoreUtils qw( uniq );
use Try::Tiny;

use C4::Circulation qw( ReturnLostItem );
use C4::Letters;
use C4::Log qw( logaction );
use C4::Stats qw( UpdateStats );

use Koha::Patrons;
use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::Account::DebitTypes;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions;
use Koha::Exceptions::Account;

=head1 NAME

Koha::Accounts - Module for managing payments and fees for patrons

=cut

sub new {
    my ( $class, $params ) = @_;

    Carp::croak("No patron id passed in!") unless $params->{patron_id};

    return bless( $params, $class );
}

=head2 pay

This method allows payments to be made against fees/fines

Koha::Account->new( { patron_id => $borrowernumber } )->pay(
    {
        amount      => $amount,
        note        => $note,
        description => $description,
        library_id  => $branchcode,
        lines       => $lines, # Arrayref of Koha::Account::Line objects to pay
        credit_type => $type,  # credit_type_code code
        offset_type => $offset_type,    # offset type code
    }
);

=cut

sub pay {
    my ( $self, $params ) = @_;

    my $amount        = $params->{amount};
    my $description   = $params->{description};
    my $note          = $params->{note} || q{};
    my $library_id    = $params->{library_id};
    my $lines         = $params->{lines};
    my $type          = $params->{type} || 'PAYMENT';
    my $payment_type  = $params->{payment_type} || undef;
    my $credit_type   = $params->{credit_type};
    my $offset_type   = $params->{offset_type} || $type eq 'WRITEOFF' ? 'Writeoff' : 'Payment';
    my $cash_register = $params->{cash_register};

    my $userenv = C4::Context->userenv;

    my $patron = Koha::Patrons->find( $self->{patron_id} );

    my $manager_id = $userenv ? $userenv->{number} : 0;
    my $interface = $params ? ( $params->{interface} || C4::Context->interface ) : C4::Context->interface;
    Koha::Exceptions::Account::RegisterRequired->throw()
      if ( C4::Context->preference("UseCashRegisters")
        && defined($payment_type)
        && ( $payment_type eq 'CASH' )
        && !defined($cash_register) );

    my @fines_paid; # List of account lines paid on with this payment

    my $balance_remaining = $amount; # Set it now so we can adjust the amount if necessary
    $balance_remaining ||= 0;

    my @account_offsets;

    # We were passed a specific line to pay
    foreach my $fine ( @$lines ) {
        my $amount_to_pay =
            $fine->amountoutstanding > $balance_remaining
          ? $balance_remaining
          : $fine->amountoutstanding;

        my $old_amountoutstanding = $fine->amountoutstanding;
        my $new_amountoutstanding = $old_amountoutstanding - $amount_to_pay;
        $fine->amountoutstanding($new_amountoutstanding)->store();
        $balance_remaining = $balance_remaining - $amount_to_pay;

        # Same logic exists in Koha::Account::Line::apply
        if (   $new_amountoutstanding == 0
            && $fine->itemnumber
            && $fine->debit_type_code
            && ( $fine->debit_type_code eq 'LOST' ) )
        {
            C4::Circulation::ReturnLostItem( $self->{patron_id}, $fine->itemnumber );
        }

        my $account_offset = Koha::Account::Offset->new(
            {
                debit_id => $fine->id,
                type     => $offset_type,
                amount   => $amount_to_pay * -1,
            }
        );
        push( @account_offsets, $account_offset );

        if ( C4::Context->preference("FinesLog") ) {
            logaction(
                "FINES", 'MODIFY',
                $self->{patron_id},
                Dumper(
                    {
                        action                => 'fee_payment',
                        borrowernumber        => $fine->borrowernumber,
                        old_amountoutstanding => $old_amountoutstanding,
                        new_amountoutstanding => 0,
                        amount_paid           => $old_amountoutstanding,
                        accountlines_id       => $fine->id,
                        manager_id            => $manager_id,
                        note                  => $note,
                    }
                ),
                $interface
            );
            push( @fines_paid, $fine->id );
        }
    }

    # Were not passed a specific line to pay, or the payment was for more
    # than the what was owed on the given line. In that case pay down other
    # lines with remaining balance.
    my @outstanding_fines;
    @outstanding_fines = $self->lines->search(
        {
            amountoutstanding => { '>' => 0 },
        }
    ) if $balance_remaining > 0;

    foreach my $fine (@outstanding_fines) {
        my $amount_to_pay =
            $fine->amountoutstanding > $balance_remaining
          ? $balance_remaining
          : $fine->amountoutstanding;

        my $old_amountoutstanding = $fine->amountoutstanding;
        $fine->amountoutstanding( $old_amountoutstanding - $amount_to_pay );
        $fine->store();

        if (   $fine->amountoutstanding == 0
            && $fine->itemnumber
            && $fine->debit_type_code
            && ( $fine->debit_type_code eq 'LOST' ) )
        {
            C4::Circulation::ReturnLostItem( $self->{patron_id}, $fine->itemnumber );
        }

        my $account_offset = Koha::Account::Offset->new(
            {
                debit_id => $fine->id,
                type     => $offset_type,
                amount   => $amount_to_pay * -1,
            }
        );
        push( @account_offsets, $account_offset );

        if ( C4::Context->preference("FinesLog") ) {
            logaction(
                "FINES", 'MODIFY',
                $self->{patron_id},
                Dumper(
                    {
                        action                => "fee_$type",
                        borrowernumber        => $fine->borrowernumber,
                        old_amountoutstanding => $old_amountoutstanding,
                        new_amountoutstanding => $fine->amountoutstanding,
                        amount_paid           => $amount_to_pay,
                        accountlines_id       => $fine->id,
                        manager_id            => $manager_id,
                        note                  => $note,
                    }
                ),
                $interface
            );
            push( @fines_paid, $fine->id );
        }

        $balance_remaining = $balance_remaining - $amount_to_pay;
        last unless $balance_remaining > 0;
    }

    $credit_type ||=
      $type eq 'WRITEOFF'
      ? 'WRITEOFF'
      : 'PAYMENT';

    $description ||= $type eq 'WRITEOFF' ? 'Writeoff' : q{};

    my $payment = Koha::Account::Line->new(
        {
            borrowernumber    => $self->{patron_id},
            date              => dt_from_string(),
            amount            => 0 - $amount,
            description       => $description,
            credit_type_code  => $credit_type,
            payment_type      => $payment_type,
            amountoutstanding => 0 - $balance_remaining,
            manager_id        => $manager_id,
            interface         => $interface,
            branchcode        => $library_id,
            register_id       => $cash_register,
            note              => $note,
        }
    )->store();

    foreach my $o ( @account_offsets ) {
        $o->credit_id( $payment->id() );
        $o->store();
    }

    UpdateStats(
        {
            branch         => $library_id,
            type           => lc($type),
            amount         => $amount,
            borrowernumber => $self->{patron_id},
        }
    );

    if ( C4::Context->preference("FinesLog") ) {
        logaction(
            "FINES", 'CREATE',
            $self->{patron_id},
            Dumper(
                {
                    action            => "create_$type",
                    borrowernumber    => $self->{patron_id},
                    amount            => 0 - $amount,
                    amountoutstanding => 0 - $balance_remaining,
                    credit_type_code  => $credit_type,
                    accountlines_paid => \@fines_paid,
                    manager_id        => $manager_id,
                }
            ),
            $interface
        );
    }

    if ( C4::Context->preference('UseEmailReceipts') ) {
        if (
            my $letter = C4::Letters::GetPreparedLetter(
                module                 => 'circulation',
                letter_code            => uc("ACCOUNT_$type"),
                message_transport_type => 'email',
                lang    => $patron->lang,
                tables => {
                    borrowers       => $self->{patron_id},
                    branches        => $library_id,
                },
                substitute => {
                    credit => $payment,
                    offsets => \@account_offsets,
                },
              )
          )
        {
            C4::Letters::EnqueueLetter(
                {
                    letter                 => $letter,
                    borrowernumber         => $self->{patron_id},
                    message_transport_type => 'email',
                }
            ) or warn "can't enqueue letter $letter";
        }
    }

    return $payment->id;
}

=head3 add_credit

This method allows adding credits to a patron's account

my $credit_line = Koha::Account->new({ patron_id => $patron_id })->add_credit(
    {
        amount       => $amount,
        description  => $description,
        note         => $note,
        user_id      => $user_id,
        interface    => $interface,
        library_id   => $library_id,
        payment_type => $payment_type,
        type         => $credit_type,
        item_id      => $item_id
    }
);

$credit_type can be any of:
  - 'CREDIT'
  - 'PAYMENT'
  - 'FORGIVEN'
  - 'LOST_FOUND'
  - 'WRITEOFF'

=cut

sub add_credit {

    my ( $self, $params ) = @_;

    # check for mandatory params
    my @mandatory = ( 'interface', 'amount' );
    for my $param (@mandatory) {
        unless ( defined( $params->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw(
                error => "The $param parameter is mandatory" );
        }
    }

    # amount should always be passed as a positive value
    my $amount = $params->{amount} * -1;
    unless ( $amount < 0 ) {
        Koha::Exceptions::Account::AmountNotPositive->throw(
            error => 'Debit amount passed is not positive' );
    }

    my $description   = $params->{description} // q{};
    my $note          = $params->{note} // q{};
    my $user_id       = $params->{user_id};
    my $interface     = $params->{interface};
    my $library_id    = $params->{library_id};
    my $cash_register = $params->{cash_register};
    my $payment_type  = $params->{payment_type};
    my $credit_type   = $params->{type} || 'PAYMENT';
    my $item_id       = $params->{item_id};

    Koha::Exceptions::Account::RegisterRequired->throw()
      if ( C4::Context->preference("UseCashRegisters")
        && defined($payment_type)
        && ( $payment_type eq 'CASH' )
        && !defined($cash_register) );

    my $line;
    my $schema = Koha::Database->new->schema;
    try {
        $schema->txn_do(
            sub {

                # Insert the account line
                $line = Koha::Account::Line->new(
                    {
                        borrowernumber    => $self->{patron_id},
                        date              => \'NOW()',
                        amount            => $amount,
                        description       => $description,
                        credit_type_code  => $credit_type,
                        amountoutstanding => $amount,
                        payment_type      => $payment_type,
                        note              => $note,
                        manager_id        => $user_id,
                        interface         => $interface,
                        branchcode        => $library_id,
                        register_id       => $cash_register,
                        itemnumber        => $item_id,
                    }
                )->store();

                # Record the account offset
                my $account_offset = Koha::Account::Offset->new(
                    {
                        credit_id => $line->id,
                        type   => $Koha::Account::offset_type->{$credit_type},
                        amount => $amount
                    }
                )->store();

                UpdateStats(
                    {
                        branch         => $library_id,
                        type           => lc($credit_type),
                        amount         => $amount,
                        borrowernumber => $self->{patron_id},
                    }
                ) if grep { $credit_type eq $_ } ( 'PAYMENT', 'WRITEOFF' );

                if ( C4::Context->preference("FinesLog") ) {
                    logaction(
                        "FINES", 'CREATE',
                        $self->{patron_id},
                        Dumper(
                            {
                                action            => "create_$credit_type",
                                borrowernumber    => $self->{patron_id},
                                amount            => $amount,
                                description       => $description,
                                amountoutstanding => $amount,
                                credit_type_code  => $credit_type,
                                note              => $note,
                                itemnumber        => $item_id,
                                manager_id        => $user_id,
                                branchcode        => $library_id,
                            }
                        ),
                        $interface
                    );
                }
            }
        );
    }
    catch {
        if ( ref($_) eq 'Koha::Exceptions::Object::FKConstraint' ) {
            if ( $_->broken_fk eq 'credit_type_code' ) {
                Koha::Exceptions::Account::UnrecognisedType->throw(
                    error => 'Type of credit not recognised' );
            }
            else {
                $_->rethrow;
            }
        }
    };

    return $line;
}

=head3 add_debit

This method allows adding debits to a patron's account

my $debit_line = Koha::Account->new({ patron_id => $patron_id })->add_debit(
    {
        amount       => $amount,
        description  => $description,
        note         => $note,
        user_id      => $user_id,
        interface    => $interface,
        library_id   => $library_id,
        type         => $debit_type,
        item_id      => $item_id,
        issue_id     => $issue_id
    }
);

$debit_type can be any of:
  - ACCOUNT
  - ACCOUNT_RENEW
  - RESERVE_EXPIRED
  - LOST
  - sundry
  - NEW_CARD
  - OVERDUE
  - PROCESSING
  - RENT
  - RENT_DAILY
  - RENT_RENEW
  - RENT_DAILY_RENEW
  - RESERVE

=cut

sub add_debit {

    my ( $self, $params ) = @_;

    # check for mandatory params
    my @mandatory = ( 'interface', 'type', 'amount' );
    for my $param (@mandatory) {
        unless ( defined( $params->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw(
                error => "The $param parameter is mandatory" );
        }
    }

    # amount should always be a positive value
    my $amount = $params->{amount};
    unless ( $amount > 0 ) {
        Koha::Exceptions::Account::AmountNotPositive->throw(
            error => 'Debit amount passed is not positive' );
    }

    my $description = $params->{description} // q{};
    my $note        = $params->{note} // q{};
    my $user_id     = $params->{user_id};
    my $interface   = $params->{interface};
    my $library_id  = $params->{library_id};
    my $debit_type  = $params->{type};
    my $item_id     = $params->{item_id};
    my $issue_id    = $params->{issue_id};
    my $offset_type = $Koha::Account::offset_type->{$debit_type} // 'Manual Debit';

    my $line;
    my $schema = Koha::Database->new->schema;
    try {
        $schema->txn_do(
            sub {

                # Insert the account line
                $line = Koha::Account::Line->new(
                    {
                        borrowernumber    => $self->{patron_id},
                        date              => \'NOW()',
                        amount            => $amount,
                        description       => $description,
                        debit_type_code   => $debit_type,
                        amountoutstanding => $amount,
                        payment_type      => undef,
                        note              => $note,
                        manager_id        => $user_id,
                        interface         => $interface,
                        itemnumber        => $item_id,
                        issue_id          => $issue_id,
                        branchcode        => $library_id,
                        (
                            $debit_type eq 'OVERDUE'
                            ? ( status => 'UNRETURNED' )
                            : ()
                        ),
                    }
                )->store();

                # Record the account offset
                my $account_offset = Koha::Account::Offset->new(
                    {
                        debit_id => $line->id,
                        type     => $offset_type,
                        amount   => $amount
                    }
                )->store();

                if ( C4::Context->preference("FinesLog") ) {
                    logaction(
                        "FINES", 'CREATE',
                        $self->{patron_id},
                        Dumper(
                            {
                                action            => "create_$debit_type",
                                borrowernumber    => $self->{patron_id},
                                amount            => $amount,
                                description       => $description,
                                amountoutstanding => $amount,
                                debit_type_code   => $debit_type,
                                note              => $note,
                                itemnumber        => $item_id,
                                manager_id        => $user_id,
                            }
                        ),
                        $interface
                    );
                }
            }
        );
    }
    catch {
        if ( ref($_) eq 'Koha::Exceptions::Object::FKConstraint' ) {
            if ( $_->broken_fk eq 'debit_type_code' ) {
                Koha::Exceptions::Account::UnrecognisedType->throw(
                    error => 'Type of debit not recognised' );
            }
            else {
                $_->rethrow;
            }
        }
    };

    return $line;
}

=head3 balance

my $balance = $self->balance

Return the balance (sum of amountoutstanding columns)

=cut

sub balance {
    my ($self) = @_;
    return $self->lines->total_outstanding;
}

=head3 outstanding_debits

my $lines = Koha::Account->new({ patron_id => $patron_id })->outstanding_debits;

It returns the debit lines with outstanding amounts for the patron.

In scalar context, it returns a Koha::Account::Lines iterator. In list context, it will
return a list of Koha::Account::Line objects.

=cut

sub outstanding_debits {
    my ($self) = @_;

    return $self->lines->search(
        {
            amount            => { '>' => 0 },
            amountoutstanding => { '>' => 0 }
        }
    );
}

=head3 outstanding_credits

my $lines = Koha::Account->new({ patron_id => $patron_id })->outstanding_credits;

It returns the credit lines with outstanding amounts for the patron.

In scalar context, it returns a Koha::Account::Lines iterator. In list context, it will
return a list of Koha::Account::Line objects.

=cut

sub outstanding_credits {
    my ($self) = @_;

    return $self->lines->search(
        {
            amount            => { '<' => 0 },
            amountoutstanding => { '<' => 0 }
        }
    );
}

=head3 non_issues_charges

my $non_issues_charges = $self->non_issues_charges

Calculates amount immediately owing by the patron - non-issue charges.

Charges exempt from non-issue are:
* Res (holds) if HoldsInNoissuesCharge syspref is set to false
* Rent (rental) if RentalsInNoissuesCharge syspref is set to false
* Manual invoices if ManInvInNoissuesCharge syspref is set to false

=cut

sub non_issues_charges {
    my ($self) = @_;

    #NOTE: With bug 23049 these preferences could be moved to being attached
    #to individual debit types to give more flexability and specificity.
    my @not_fines;
    push @not_fines, 'RESERVE'
      unless C4::Context->preference('HoldsInNoissuesCharge');
    push @not_fines, ( 'RENT', 'RENT_DAILY', 'RENT_RENEW', 'RENT_DAILY_RENEW' )
      unless C4::Context->preference('RentalsInNoissuesCharge');
    unless ( C4::Context->preference('ManInvInNoissuesCharge') ) {
        my @man_inv = Koha::Account::DebitTypes->search({ is_system => 0 })->get_column('code');
        push @not_fines, @man_inv;
    }

    return $self->lines->search(
        {
            debit_type_code => { -not_in => \@not_fines }
        },
    )->total_outstanding;
}

=head3 lines

my $lines = $self->lines;

Return all credits and debits for the user, outstanding or otherwise

=cut

sub lines {
    my ($self) = @_;

    return Koha::Account::Lines->search(
        {
            borrowernumber => $self->{patron_id},
        }
    );
}

=head3 reconcile_balance

$account->reconcile_balance();

Find outstanding credits and use them to pay outstanding debits.
Currently, this implicitly uses the 'First In First Out' rule for
applying credits against debits.

=cut

sub reconcile_balance {
    my ($self) = @_;

    my $outstanding_debits  = $self->outstanding_debits;
    my $outstanding_credits = $self->outstanding_credits;

    while (     $outstanding_debits->total_outstanding > 0
            and my $credit = $outstanding_credits->next )
    {
        # there's both outstanding debits and credits
        $credit->apply( { debits => [ $outstanding_debits->as_list ] } );    # applying credit, no special offset

        $outstanding_debits = $self->outstanding_debits;

    }

    return $self;
}

1;

=head2 Name mappings

=head3 $offset_type

=cut

our $offset_type = {
    'CREDIT'           => 'Manual Credit',
    'FORGIVEN'         => 'Writeoff',
    'LOST_FOUND'       => 'Lost Item Found',
    'PAYMENT'          => 'Payment',
    'WRITEOFF'         => 'Writeoff',
    'ACCOUNT'          => 'Account Fee',
    'ACCOUNT_RENEW'    => 'Account Fee',
    'RESERVE'          => 'Reserve Fee',
    'PROCESSING'       => 'Processing Fee',
    'LOST'             => 'Lost Item',
    'RENT'             => 'Rental Fee',
    'RENT_DAILY'       => 'Rental Fee',
    'RENT_RENEW'       => 'Rental Fee',
    'RENT_DAILY_RENEW' => 'Rental Fee',
    'OVERDUE'          => 'OVERDUE',
    'RESERVE_EXPIRED'  => 'Hold Expired'
};

=head1 AUTHORS

=encoding utf8

Kyle M Hall <kyle.m.hall@gmail.com>
Tomás Cohen Arazi <tomascohen@gmail.com>
Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut
