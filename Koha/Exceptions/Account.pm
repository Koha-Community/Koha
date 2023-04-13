package Koha::Exceptions::Account;

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

use Koha::Exception;

use Exception::Class (

    'Koha::Exceptions::Account' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::Account::IsNotCredit' => {
        isa         => 'Koha::Exceptions::Account',
        description => 'Account line is not a credit'
    },
    'Koha::Exceptions::Account::IsNotDebit' => {
        isa         => 'Koha::Exceptions::Account',
        description => 'Account line is not a credit'
    },
    'Koha::Exceptions::Account::NoAvailableCredit' => {
        isa         => 'Koha::Exceptions::Account',
        description => 'No outstanding credit'
    },
    'Koha::Exceptions::Account::AmountNotPositive' => {
        isa         => 'Koha::Exceptions::Account',
        description => 'Amount should be a positive decimal'
    },
    'Koha::Exceptions::Account::UnrecognisedType' => {
        isa         => 'Koha::Exceptions::Account',
        description => 'Account type was not recognised'
    },
    'Koha::Exceptions::Account::RegisterRequired' => {
        isa         => 'Koha::Exceptions::Account',
        description => 'Account transaction requires a cash register'
    },
    'Koha::Exceptions::Account::PaymentTypeRequired' => {
        isa         => 'Koha::Exceptions::Account',
        description => 'Account transaction requires a payment type'
    }
);

=head1 NAME

Koha::Exceptions::Account - Base class for Account exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Account

Generic Account exception

=head2 Koha::Exceptions::Account::IsNotCredit

Exception to be used when an action on an account line requires it to be a
credit and it isn't.

=head2 Koha::Exceptions::Account::IsNotDebit

Exception to be used when an action on an account line requires it to be a
debit and it isn't.

=head2 Koha::Exceptions::Account::NoAvailableCredit

Exception to be used when a credit has no amount outstanding and is required
to be applied to outstanding debits.

=head2 Koha::Exceptions::Account::AmountNotPositive

Exception to be used when a passed credit or debit amount is not a positive
decimal value.

=head2 Koha::Exceptions::Account::UnrecognisedType

Exception to be used when a passed credit or debit is not of a recognised type.

=cut

=head2 Koha::Exceptions::Account::RegisterRequired

Exception to be used when UseCashRegisters is enabled and one is not passed for a transaction.

=cut

1;
