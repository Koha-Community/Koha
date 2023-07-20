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
use Data::Dumper qw( Dumper );
use Try::Tiny qw( catch try );

use C4::Circulation qw( ReturnLostItem CanBookBeRenewed AddRenewal );
use C4::Letters;
use C4::Log qw( logaction );
use C4::Stats qw( UpdateStats );
use C4::Overdues qw(GetFine);

use Koha::Patrons;
use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::Account::DebitTypes;
use Koha::Exceptions;
use Koha::Exceptions::Account;
use Koha::Plugins;

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
        item_id     => $itemnumber,     # pass the itemnumber if this is a credit pertianing to a specific item (i.e LOST_FOUND)
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
    my $cash_register = $params->{cash_register};
    my $item_id       = $params->{item_id};

    my $userenv = C4::Context->userenv;

    Koha::Exceptions::Account::PaymentTypeRequired->throw()
      if ( C4::Context->preference("RequirePaymentType")
        && !defined($payment_type) );

    my $av = Koha::AuthorisedValues->search_with_library_limits({ category => 'PAYMENT_TYPE', authorised_value => $payment_type });

    if ( !$av->count && C4::Context->preference("RequirePaymentType")) {
        Koha::Exceptions::Account::InvalidPaymentType->throw(
            error => 'Invalid payment type'
        );
    }

    my $manager_id = $userenv ? $userenv->{number} : undef;
    my $interface = $params ? ( $params->{interface} || C4::Context->interface ) : C4::Context->interface;
    my $payment = $self->payin_amount(
        {
            interface     => $interface,
            type          => $type,
            amount        => $amount,
            payment_type  => $payment_type,
            cash_register => $cash_register,
            user_id       => $manager_id,
            library_id    => $library_id,
            item_id       => $item_id,
            description   => $description,
            note          => $note,
            debits        => $lines
        }
    );

    # NOTE: Pay historically always applied as much credit as it could to all
    # existing outstanding debits, whether passed specific debits or otherwise.
    if ( $payment->amountoutstanding ) {
        $payment =
          $payment->apply(
            { debits => [ $self->outstanding_debits->as_list ] } );
    }

    my $patron = Koha::Patrons->find( $self->{patron_id} );
    my @account_offsets = $payment->credit_offsets({ type => 'APPLY' })->as_list;
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

    my $renew_outcomes = [];
    for my $message ( @{$payment->object_messages} ) {
        push @{$renew_outcomes}, $message->payload;
    }

    return { payment_id => $payment->id, renew_result => $renew_outcomes };
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
  - 'OVERPAYMENT'
  - 'PAYMENT'
  - 'WRITEOFF'
  - 'PROCESSING_FOUND'

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
        && ( $payment_type eq 'CASH' || $payment_type eq 'SIP00' )
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
                        type      => 'CREATE',
                        amount    => $amount * -1
                    }
                )->store();

                C4::Stats::UpdateStats(
                    {
                        branch         => $library_id,
                        type           => lc($credit_type),
                        amount         => $amount,
                        borrowernumber => $self->{patron_id},
                    }
                ) if grep { $credit_type eq $_ } ( 'PAYMENT', 'WRITEOFF' );

                Koha::Plugins->call(
                    'after_account_action',
                    {
                        action  => "add_credit",
                        payload => {
                            type => lc($credit_type),
                            line => $line->get_from_storage, #TODO Seems unneeded
                        }
                    }
                );

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
        }
        $_->rethrow;
    };

    return $line;
}

=head3 payin_amount

    my $credit = $account->payin_amount(
        {
            amount          => $amount,
            type            => $credit_type,
            payment_type    => $payment_type,
            cash_register   => $register_id,
            interface       => $interface,
            library_id      => $branchcode,
            user_id         => $staff_id,
            debits          => $debit_lines,
            description     => $description,
            note            => $note
        }
    );

This method allows an amount to be paid into a patrons account and immediately applied against debts.

You can optionally pass a debts parameter which consists of an arrayref of Koha::Account::Line debit lines.

$credit_type can be any of:
  - 'PAYMENT'
  - 'WRITEOFF'
  - 'FORGIVEN'

=cut

sub payin_amount {
    my ( $self, $params ) = @_;

    # check for mandatory params
    my @mandatory = ( 'interface', 'amount', 'type' );
    for my $param (@mandatory) {
        unless ( defined( $params->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw(
                error => "The $param parameter is mandatory" );
        }
    }

    # Check for mandatory register
    Koha::Exceptions::Account::RegisterRequired->throw()
      if ( C4::Context->preference("UseCashRegisters")
        && defined( $params->{payment_type} )
        && ( $params->{payment_type} eq 'CASH' || $params->{payment_type} eq 'SIP00' )
        && !defined($params->{cash_register}) );

    # amount should always be passed as a positive value
    my $amount = $params->{amount};
    unless ( $amount > 0 ) {
        Koha::Exceptions::Account::AmountNotPositive->throw(
            error => 'Payin amount passed is not positive' );
    }

    my $credit;
    my $schema = Koha::Database->new->schema;
    $schema->txn_do(
        sub {

            # Add payin credit
            $credit = $self->add_credit($params);

            # Offset debts passed first
            if ( exists( $params->{debits} ) ) {
                $credit = $credit->apply(
                    {
                        debits => $params->{debits}
                    }
                );
            }

            # Offset against remaining balance if AutoReconcile
            if ( C4::Context->preference("AccountAutoReconcile")
                && $credit->amountoutstanding != 0 )
            {
                $credit = $credit->apply(
                    {
                        debits => [ $self->outstanding_debits->as_list ]
                    }
                );
            }
        }
    );

    return $credit;
}

=head3 add_debit

This method allows adding debits to a patron's account

    my $debit_line = Koha::Account->new({ patron_id => $patron_id })->add_debit(
        {
            amount           => $amount,
            description      => $description,
            note             => $note,
            user_id          => $user_id,
            interface        => $interface,
            library_id       => $library_id,
            type             => $debit_type,
            transaction_type => $transaction_type,
            cash_register    => $register_id,
            item_id          => $item_id,
            issue_id         => $issue_id
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
  - PAYOUT

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

    # check for cash register if using cash
    Koha::Exceptions::Account::RegisterRequired->throw()
      if ( C4::Context->preference("UseCashRegisters")
        && defined( $params->{transaction_type} )
        && ( $params->{transaction_type} eq 'CASH' || $params->{payment_type} eq 'SIP00' )
        && !defined( $params->{cash_register} ) );

    # amount should always be a positive value
    my $amount = $params->{amount};
    unless ( $amount > 0 ) {
        Koha::Exceptions::Account::AmountNotPositive->throw(
            error => 'Debit amount passed is not positive' );
    }

    my $description      = $params->{description} // q{};
    my $note             = $params->{note} // q{};
    my $user_id          = $params->{user_id};
    my $interface        = $params->{interface};
    my $library_id       = $params->{library_id};
    my $cash_register    = $params->{cash_register};
    my $debit_type       = $params->{type};
    my $transaction_type = $params->{transaction_type};
    my $item_id          = $params->{item_id};
    my $issue_id         = $params->{issue_id};

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
                        payment_type      => $transaction_type,
                        note              => $note,
                        manager_id        => $user_id,
                        interface         => $interface,
                        itemnumber        => $item_id,
                        issue_id          => $issue_id,
                        branchcode        => $library_id,
                        register_id       => $cash_register,
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
                        type     => 'CREATE',
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

=head3 payout_amount

    my $debit = $account->payout_amount(
        {
            payout_type => $payout_type,
            register_id => $register_id,
            staff_id    => $staff_id,
            interface   => 'intranet',
            amount      => $amount,
            credits     => $credit_lines
        }
    );

This method allows an amount to be paid out from a patrons account against outstanding credits.

$payout_type can be any of the defined payment_types:

=cut

sub payout_amount {
    my ( $self, $params ) = @_;

    # Check for mandatory parameters
    my @mandatory =
      ( 'interface', 'staff_id', 'branch', 'payout_type', 'amount' );
    for my $param (@mandatory) {
        unless ( defined( $params->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw(
                error => "The $param parameter is mandatory" );
        }
    }

    # Check for mandatory register
    Koha::Exceptions::Account::RegisterRequired->throw()
      if ( C4::Context->preference("UseCashRegisters")
        && ( $params->{payout_type} eq 'CASH' || $params->{payout_type} eq 'SIP00' )
        && !defined($params->{cash_register}) );

    # Amount should always be passed as a positive value
    my $amount = $params->{amount};
    unless ( $amount > 0 ) {
        Koha::Exceptions::Account::AmountNotPositive->throw(
            error => 'Payout amount passed is not positive' );
    }

    # Amount should always be less than or equal to outstanding credit
    my $outstanding = 0;
    my $outstanding_credits =
      exists( $params->{credits} )
      ? $params->{credits}
      : $self->outstanding_credits->as_list;
    for my $credit ( @{$outstanding_credits} ) {
        $outstanding += $credit->amountoutstanding;
    }
    $outstanding = $outstanding * -1;
    Koha::Exceptions::ParameterTooHigh->throw( error =>
"Amount to payout ($amount) is higher than amountoutstanding ($outstanding)"
    ) unless ( $outstanding >= $amount );

    my $payout;
    my $schema = Koha::Database->new->schema;
    $schema->txn_do(
        sub {

            # A 'payout' is a 'debit'
            $payout = $self->add_debit(
                {
                    amount            => $params->{amount},
                    type              => 'PAYOUT',
                    transaction_type  => $params->{payout_type},
                    amountoutstanding => $params->{amount},
                    user_id           => $params->{staff_id},
                    interface         => $params->{interface},
                    branchcode        => $params->{branch},
                    cash_register     => $params->{cash_register}
                }
            );

            # Offset against credits
            for my $credit ( @{$outstanding_credits} ) {
                $credit->apply( { debits => [$payout] } );
                $payout->discard_changes;
                last if $payout->amountoutstanding == 0;
            }

            # Set payout as paid
            $payout->status('PAID')->store;
        }
    );

    return $payout;
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

It returns a Koha::Account::Lines iterator.

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

It returns a Koha::Account::Lines iterator.

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

=head1 AUTHORS

=encoding utf8

Kyle M Hall <kyle.m.hall@gmail.com>
Tomás Cohen Arazi <tomascohen@gmail.com>
Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut
