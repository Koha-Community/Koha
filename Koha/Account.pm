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

=cut

sub pay {
    my ( $self, $params ) = @_;

    my $amount = $params->{amount};
    my $sip    = $params->{sip};
    my $note   = $params->{note} || q{};

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

    my @outstanding_fines = Koha::Account::Lines->search(
        {
            borrowernumber    => $self->{patron_id},
            amountoutstanding => { '>' => 0 },
        }
    );

    my $balance_remaining = $amount;
    my @fines_paid;
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

    my $branch = $userenv ? $userenv->{'branch'} : undef;
    UpdateStats(
        {
            branch         => $branch,
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
}

1;

=head1 AUTHOR

Kyle M Hall <kyle.m.hall@gmail.com>

=cut
