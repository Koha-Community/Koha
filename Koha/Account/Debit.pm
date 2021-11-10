package Koha::Account::Debit;

# Copyright PTFS Europe 2021
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

use base qw(Koha::Account::Line);

=head1 NAME

Koha::Debit - Koha Debit object class

This object represents a debit account line

=head1 API

=head2 Class Methods

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Account::Debit object
on the API.

=cut

sub to_api_mapping {
    return {
        accountlines_id   => 'account_line_id',
        credit_number     => undef,
        credit_type_code  => undef,
        debit_type_code   => 'type',
        amountoutstanding => 'amount_outstanding',
        borrowernumber    => 'patron_id',
        branchcode        => 'library_id',
        issue_id          => 'checkout_id',
        itemnumber        => 'item_id',
        manager_id        => 'user_id',
        note              => 'internal_note',
        register_id       => 'cash_register_id',
        payment_type      => 'payout_type',
    };
}

=head1 AUTHOR

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
