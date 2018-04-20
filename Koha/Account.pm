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

use C4::Log qw( logaction );
use C4::Stats qw( UpdateStats );

use Koha::Patrons;
use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::DateUtils qw( dt_from_string );

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
        sip         => $sipmode,
        note        => $note,
        description => $description,
        library_id  => $branchcode,
        lines        => $lines, # Arrayref of Koha::Account::Line objects to pay
        account_type => $type,  # accounttype code
        offset_type => $offset_type,    # offset type code
    }
);

=cut

sub pay {
    my ( $self, $params ) = @_;

    my $amount       = $params->{amount};
    my $sip          = $params->{sip};
    my $description  = $params->{description};
    my $note         = $params->{note} || q{};
    my $library_id   = $params->{library_id};
    my $lines        = $params->{lines};
    my $type         = $params->{type} || 'payment';
    my $payment_type = $params->{payment_type} || undef;
    my $account_type = $params->{account_type};
    my $offset_type  = $params->{offset_type} || $type eq 'writeoff' ? 'Writeoff' : 'Payment';

    my $userenv = C4::Context->userenv;

    my $patron = Koha::Patrons->find( $self->{patron_id} );

    # We should remove accountno, it is no longer needed
    my $last = Koha::Account::Lines->search(
        {
            borrowernumber => $self->{patron_id}
        },
        {
            order_by => 'accountno'
        }
    )->next();
    my $accountno = $last ? $last->accountno + 1 : 1;

    my $manager_id = $userenv ? $userenv->{number} : 0;

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

        if ( $fine->itemnumber && $fine->accounttype && ( $fine->accounttype eq 'Rep' || $fine->accounttype eq 'L' ) )
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
                        accountno             => $fine->accountno,
                        manager_id            => $manager_id,
                        note                  => $note,
                    }
                )
            );
            push( @fines_paid, $fine->id );
        }
    }

    # Were not passed a specific line to pay, or the payment was for more
    # than the what was owed on the given line. In that case pay down other
    # lines with remaining balance.
    my @outstanding_fines;
    @outstanding_fines = Koha::Account::Lines->search(
        {
            borrowernumber    => $self->{patron_id},
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
                        accountno             => $fine->accountno,
                        manager_id            => $manager_id,
                        note                  => $note,
                    }
                )
            );
            push( @fines_paid, $fine->id );
        }

        $balance_remaining = $balance_remaining - $amount_to_pay;
        last unless $balance_remaining > 0;
    }

    $account_type ||=
        $type eq 'writeoff' ? 'W'
      : defined($sip)       ? "Pay$sip"
      :                       'Pay';

    $description ||= $type eq 'writeoff' ? 'Writeoff' : q{};

    my $payment = Koha::Account::Line->new(
        {
            borrowernumber    => $self->{patron_id},
            accountno         => $accountno,
            date              => dt_from_string(),
            amount            => 0 - $amount,
            description       => $description,
            accounttype       => $account_type,
            payment_type      => $payment_type,
            amountoutstanding => 0 - $balance_remaining,
            manager_id        => $manager_id,
            note              => $note,
        }
    )->store();

    foreach my $o ( @account_offsets ) {
        $o->credit_id( $payment->id() );
        $o->store();
    }

    $library_id ||= $userenv ? $userenv->{'branch'} : undef;

    UpdateStats(
        {
            branch         => $library_id,
            type           => $type,
            amount         => $amount,
            borrowernumber => $self->{patron_id},
            accountno      => $accountno,
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
                    accountno         => $accountno,
                    amount            => 0 - $amount,
                    amountoutstanding => 0 - $balance_remaining,
                    accounttype       => $account_type,
                    accountlines_paid => \@fines_paid,
                    manager_id        => $manager_id,
                }
            )
        );
    }

    if ( C4::Context->preference('UseEmailReceipts') ) {
        require C4::Letters;
        if (
            my $letter = C4::Letters::GetPreparedLetter(
                module                 => 'circulation',
                letter_code            => uc("ACCOUNT_$type"),
                message_transport_type => 'email',
                lang    => Koha::Patrons->find( $self->{patron_id} )->lang,
                tables => {
                    borrowers       => $self->{patron_id},
                    branches        => $self->{library_id},
                },
                substitute => {
                    credit => $payment,
                    offsets => scalar Koha::Account::Offsets->search( { id => { -in => [ map { $_->id } @account_offsets ] } } ),
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
        library_id   => $library_id,
        sip          => $sip,
        payment_type => $payment_type,
        type         => $credit_type,
        item_id      => $item_id
    }
);

$credit_type can be any of:
  - 'credit'
  - 'payment'
  - 'forgiven'
  - 'lost_item_return'
  - 'writeoff'

=cut

sub add_credit {

    my ( $self, $params ) = @_;

    # amount is passed as a positive value, but we store credit as negative values
    my $amount       = $params->{amount} * -1;
    my $description  = $params->{description} // q{};
    my $note         = $params->{note} // q{};
    my $user_id      = $params->{user_id};
    my $library_id   = $params->{library_id};
    my $sip          = $params->{sip};
    my $payment_type = $params->{payment_type};
    my $type         = $params->{type} || 'payment';
    my $item_id      = $params->{item_id};

    my $schema = Koha::Database->new->schema;

    my $account_type = $Koha::Account::account_type->{$type};
    $account_type .= $sip
        if defined $sip &&
           $type eq 'payment';

    my $line;

    $schema->txn_do(
        sub {
            # We should remove accountno, it is no longer needed
            my $last = Koha::Account::Lines->search( { borrowernumber => $self->{patron_id} },
                { order_by => 'accountno' } )->next();
            my $accountno = $last ? $last->accountno + 1 : 1;

            # Insert the account line
            $line = Koha::Account::Line->new(
                {   borrowernumber    => $self->{patron_id},
                    date              => \'NOW()',
                    amount            => $amount,
                    description       => $description,
                    accounttype       => $account_type,
                    amountoutstanding => $amount,
                    payment_type      => $payment_type,
                    note              => $note,
                    manager_id        => $user_id,
                    itemnumber        => $item_id
                }
            )->store();

            # Record the account offset
            my $account_offset = Koha::Account::Offset->new(
                {   credit_id => $line->id,
                    type      => $Koha::Account::offset_type->{$type},
                    amount    => $amount
                }
            )->store();

            UpdateStats(
                {   branch         => $library_id,
                    type           => $type,
                    amount         => $amount,
                    borrowernumber => $self->{patron_id},
                    accountno      => $accountno,
                }
            ) if grep { $type eq $_ } ('payment', 'writeoff') ;

            if ( C4::Context->preference("FinesLog") ) {
                logaction(
                    "FINES", 'CREATE',
                    $self->{patron_id},
                    Dumper(
                        {   action            => "create_$type",
                            borrowernumber    => $self->{patron_id},
                            accountno         => $accountno,
                            amount            => $amount,
                            description       => $description,
                            amountoutstanding => $amount,
                            accounttype       => $account_type,
                            note              => $note,
                            itemnumber        => $item_id,
                            manager_id        => $user_id,
                        }
                    )
                );
            }
        }
    );

    return $line;
}

=head3 balance

my $balance = $self->balance

Return the balance (sum of amountoutstanding columns)

=cut

sub balance {
    my ($self) = @_;
    my $fines = Koha::Account::Lines->search(
        {
            borrowernumber => $self->{patron_id},
        },
        {
            select => [ { sum => 'amountoutstanding' } ],
            as => ['total_amountoutstanding'],
        }
    );

    return ( $fines->count )
      ? $fines->next->get_column('total_amountoutstanding') + 0
      : 0;
}

=head3 outstanding_debits

my $lines = Koha::Account->new({ patron_id => $patron_id })->outstanding_debits;

=cut

sub outstanding_debits {
    my ($self) = @_;

    my $lines = Koha::Account::Lines->search(
        {
            borrowernumber    => $self->{patron_id},
            amountoutstanding => { '>' => 0 }
        }
    );

    return $lines;
}

=head3 outstanding_credits

my $lines = Koha::Account->new({ patron_id => $patron_id })->outstanding_credits;

=cut

sub outstanding_credits {
    my ($self) = @_;

    my $lines = Koha::Account::Lines->search(
        {
            borrowernumber    => $self->{patron_id},
            amountoutstanding => { '<' => 0 }
        }
    );

    return $lines;
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

    # FIXME REMOVE And add a warning in the about page + update DB if length(MANUAL_INV) > 5
    my $ACCOUNT_TYPE_LENGTH = 5;    # this is plain ridiculous...

    my @not_fines;
    push @not_fines, 'Res'
      unless C4::Context->preference('HoldsInNoissuesCharge');
    push @not_fines, 'Rent'
      unless C4::Context->preference('RentalsInNoissuesCharge');
    unless ( C4::Context->preference('ManInvInNoissuesCharge') ) {
        my $dbh = C4::Context->dbh;
        push @not_fines,
          @{
            $dbh->selectcol_arrayref(q|
                SELECT authorised_value FROM authorised_values WHERE category = 'MANUAL_INV'
            |)
          };
    }
    @not_fines = map { substr( $_, 0, $ACCOUNT_TYPE_LENGTH ) } uniq(@not_fines);

    my $non_issues_charges = Koha::Account::Lines->search(
        {
            borrowernumber => $self->{patron_id},
            accounttype    => { -not_in => \@not_fines }
        },
        {
            select => [ { sum => 'amountoutstanding' } ],
            as     => ['non_issues_charges'],
        }
    );
    return $non_issues_charges->count
      ? $non_issues_charges->next->get_column('non_issues_charges') + 0
      : 0;
}

1;

=head2 Name mappings

=head3 $offset_type

=cut

our $offset_type = {
    'credit'           => 'Manual Credit',
    'forgiven'         => 'Writeoff',
    'lost_item_return' => 'Lost Item Return',
    'payment'          => 'Payment',
    'writeoff'         => 'Writeoff'
};

=head3 $account_type

=cut

our $account_type = {
    'credit'           => 'C',
    'forgiven'         => 'FOR',
    'lost_item_return' => 'CR',
    'payment'          => 'Pay',
    'writeoff'         => 'W'
};

=head1 AUTHOR

Kyle M Hall <kyle.m.hall@gmail.com>

=cut
