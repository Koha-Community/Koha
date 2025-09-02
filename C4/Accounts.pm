package C4::Accounts;

# Copyright 2000-2002 Katipo Communications
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use base 'Exporter';

BEGIN {
    our @EXPORT = qw(
        chargelostitem
        purge_zero_balance_fees
    );
}

use C4::Context;
use C4::Stats;
use C4::Members;
use Koha::Account;
use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::Items;

=head1 NAME

C4::Accounts - Functions for dealing with Koha accounts

=head1 SYNOPSIS

use C4::Accounts;

=head1 DESCRIPTION

The functions in this module deal with the monetary aspect of Koha,
including looking up and modifying the amount of money owed by a
patron.

=head1 FUNCTIONS

=head2 chargelostitem

In a default install of Koha the following lost values are set
1 = Lost
2 = Long overdue
3 = Lost and paid for

FIXME: itemlost should be set to 3 after payment is made, should be a warning to the interface that a charge has been added
FIXME : if no replacement price, borrower just doesn't get charged?

=cut

sub chargelostitem {
    my $dbh = C4::Context->dbh();
    my ( $borrowernumber, $itemnumber, $replacementprice, $description ) = @_;
    my $item  = Koha::Items->find($itemnumber);
    my $itype = $item->itemtype;
    $replacementprice //= 0;
    my $defaultreplacecost        = $itype->defaultreplacecost;
    my $processfee                = $itype->processfee;
    my $usedefaultreplacementcost = C4::Context->preference("useDefaultReplacementCost");
    my $processingfeenote         = C4::Context->preference("ProcessingFeeNote");

    if ( $usedefaultreplacementcost && $replacementprice == 0 && $defaultreplacecost ) {
        $replacementprice = $defaultreplacecost;
    }
    my $checkout = Koha::Checkouts->find( { itemnumber => $itemnumber } );
    if ( !$checkout && $item->in_bundle ) {
        my $host = $item->bundle_host;
        $checkout = $host->checkout;
    }
    my $issue_id = $checkout ? $checkout->issue_id : undef;

    my $account = Koha::Account->new( { patron_id => $borrowernumber } );

    # first make sure the borrower hasn't already been charged for this item (for this issuance)
    my $existing_charges = $account->lines->search(
        {
            itemnumber      => $itemnumber,
            debit_type_code => 'LOST',
            issue_id        => $issue_id
        }
    )->count();

    # OK, they haven't
    unless ($existing_charges) {

        #add processing fee
        if ( $processfee && $processfee > 0 ) {
            my $accountline = $account->add_debit(
                {
                    amount      => $processfee,
                    description => $description,
                    note        => $processingfeenote,
                    user_id     => C4::Context->userenv ? C4::Context->userenv->{'number'} : undef,
                    interface   => C4::Context->interface,
                    library_id  => C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef,
                    type        => 'PROCESSING',
                    item_id     => $itemnumber,
                    issue_id    => $issue_id,
                }
            );
        }

        #add replace cost
        if ( $replacementprice > 0 ) {
            my $accountline = $account->add_debit(
                {
                    amount      => $replacementprice,
                    description => $description,
                    note        => undef,
                    user_id     => C4::Context->userenv ? C4::Context->userenv->{'number'} : undef,
                    interface   => C4::Context->interface,
                    library_id  => C4::Context->userenv ? C4::Context->userenv->{'branch'} : undef,
                    type        => 'LOST',
                    item_id     => $itemnumber,
                    issue_id    => $issue_id,
                }
            );
        }
    }
}

=head2 purge_zero_balance_fees

  purge_zero_balance_fees( $days );

Delete accountlines entries where amountoutstanding is 0 or NULL which are more than a given number of days old.

B<$days> -- Zero balance fees older than B<$days> days old will be deleted.

B<Warning:> Because fines and payments are not linked in accountlines, it is
possible for a fine to be deleted without the accompanying payment,
or vice versa. This won't affect the account balance, but might be
confusing to staff.

=cut

sub purge_zero_balance_fees {
    my $days  = shift;
    my $count = 0;

    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        q{
            DELETE a1 FROM accountlines a1

            LEFT JOIN account_offsets credit_offset ON ( a1.accountlines_id = credit_offset.credit_id )
            LEFT JOIN accountlines a2 ON ( credit_offset.debit_id = a2.accountlines_id )

            LEFT JOIN account_offsets debit_offset ON ( a1.accountlines_id = debit_offset.debit_id )
            LEFT JOIN accountlines a3 ON ( debit_offset.credit_id = a3.accountlines_id )

            WHERE a1.date < date_sub(curdate(), INTERVAL ? DAY)
              AND ( a1.amountoutstanding = 0 OR a1.amountoutstanding IS NULL )
              AND ( a2.amountoutstanding = 0 OR a2.amountoutstanding IS NULL )
              AND ( a3.amountoutstanding = 0 OR a3.amountoutstanding IS NULL )
        }
    );
    $sth->execute($days) or die $dbh->errstr;
}

END { }    # module clean-up code here (global destructor)

1;
__END__

=head1 SEE ALSO

DBI(3)

=cut

