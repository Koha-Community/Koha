package Koha::Exceptions::Account;

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

use Exception::Class (

    'Koha::Exceptions::Account' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Account::IsNotCredit' => {
        isa => 'Koha::Exceptions::Account',
        description => 'Account line is not a credit'
    },
    'Koha::Exceptions::Account::IsNotDebit' => {
        isa => 'Koha::Exceptions::Account',
        description => 'Account line is not a credit'
    },
    'Koha::Exceptions::Account::NoAvailableCredit' => {
        isa => 'Koha::Exceptions::Account',
        description => 'No outstanding credit'
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

=cut

1;
