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

use C4::Log qw( logaction );
use C4::Stats qw( UpdateStats );

use Koha::Account::Line;
use Koha::Account::Lines;
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

This method allows payments to be made against feees

Koha::Account->new( { patron_id => $borrowernumber } )->pay(
    {
        amount     => $amount,
        sip        => $sipmode,
        note       => $note,
        id         => $accountlines_id,
        library_id => $branchcode,
    }
);

=cut

sub pay {
    my ( $self, $params ) = @_;

    my $amount          = $params->{amount};
    my $sip             = $params->{sip};
    my $note            = $params->{note} || q{};
    my $accountlines_id = $params->{accountlines_id};
    my $library_id      = $params->{library_id};

    my $userenv = C4::Context->userenv;

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

    # We were passed a specific line to pay
    if ( $accountlines_id ) {
        my $fine = Koha::Account::Lines->find( $accountlines_id );

        # If accountline id is passed but no amount, we pay that line in full
        $amount = $fine->amountoutstanding unless defined($amount);

        my $old_amountoutstanding = $fine->amountoutstanding;
        my $new_amountoutstanding = $old_amountoutstanding - $amount;
        $fine->amountoutstanding( $new_amountoutstanding )->store();
        $balance_remaining = $balance_remaining - $amount;

        if ( $fine->accounttype eq 'Rep' || $fine->accounttype eq 'L' )
        {
            C4::Circulation::ReturnLostItem( $self->{patron_id}, $fine->itemnumber );
        }

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

        if ( C4::Context->preference("FinesLog") ) {
            logaction(
                "FINES", 'MODIFY',
                $self->{patron_id},
                Dumper(
                    {
                        action                => 'fee_payment',
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

    my $account_type = defined($sip) ? "Pay$sip" : 'Pay';

    my $payment = Koha::Account::Line->new(
        {
            borrowernumber    => $self->{patron_id},
            accountno         => $accountno,
            date              => dt_from_string(),
            amount            => 0 - $amount,
            description       => q{},
            accounttype       => $account_type,
            amountoutstanding => 0 - $balance_remaining,
            manager_id        => $manager_id,
            note              => $note,
        }
    )->store();

    $library_id ||= $userenv ? $userenv->{'branch'} : undef;

    UpdateStats(
        {
            branch         => $library_id,
            type           => 'payment',
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
                    action            => 'create_payment',
                    borrowernumber    => $self->{patron_id},
                    accountno         => $accountno,
                    amount            => 0 - $amount,
                    amountoutstanding => 0 - $balance_remaining,
                    accounttype       => 'Pay',
                    accountlines_paid => \@fines_paid,
                    manager_id        => $manager_id,
                }
            )
        );
    }

    return $payment->id;
}

1;

=head1 AUTHOR

Kyle M Hall <kyle.m.hall@gmail.com>

=cut
