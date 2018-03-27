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
# along with Koha; if not, see <http://www.gnu.org/licenses>.


use strict;
#use warnings; FIXME - Bug 2505
use C4::Context;
use C4::Stats;
use C4::Members;
use C4::Circulation qw(ReturnLostItem);
use C4::Log qw(logaction);
use Koha::Account;
use Koha::Account::Lines;
use Koha::Account::Offsets;
use Koha::Items;

use Data::Dumper qw(Dumper);

use vars qw(@ISA @EXPORT);

BEGIN {
    require Exporter;
    @ISA    = qw(Exporter);
    @EXPORT = qw(
      &manualinvoice
      &getnextacctno
      &getcharges
      &ModNote
      &getcredits
      &getrefunds
      &chargelostitem
      &ReversePayment
      &purge_zero_balance_fees
    );
}

=head1 NAME

C4::Accounts - Functions for dealing with Koha accounts

=head1 SYNOPSIS

use C4::Accounts;

=head1 DESCRIPTION

The functions in this module deal with the monetary aspect of Koha,
including looking up and modifying the amount of money owed by a
patron.

=head1 FUNCTIONS

=head2 getnextacctno

  $nextacct = &getnextacctno($borrowernumber);

Returns the next unused account number for the patron with the given
borrower number.

=cut

#'
# FIXME - Okay, so what does the above actually _mean_?
sub getnextacctno {
    my ($borrowernumber) = shift or return;
    my $sth = C4::Context->dbh->prepare(
        "SELECT accountno+1 FROM accountlines
            WHERE    (borrowernumber = ?)
            ORDER BY accountno DESC
            LIMIT 1"
    );
    $sth->execute($borrowernumber);
    return ($sth->fetchrow || 1);
}

=head2 fixaccounts (removed)

  &fixaccounts($accountlines_id, $borrowernumber, $accountnumber, $amount);

#'
# FIXME - I don't understand what this function does.
sub fixaccounts {
    my ( $accountlines_id, $borrowernumber, $accountno, $amount ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "SELECT * FROM accountlines WHERE accountlines_id=?"
    );
    $sth->execute( $accountlines_id );
    my $data = $sth->fetchrow_hashref;

    # FIXME - Error-checking
    my $diff        = $amount - $data->{'amount'};
    my $outstanding = $data->{'amountoutstanding'} + $diff;
    $sth->finish;

    $dbh->do(<<EOT);
        UPDATE  accountlines
        SET     amount = '$amount',
                amountoutstanding = '$outstanding'
        WHERE   accountlines_id = $accountlines_id
EOT
	# FIXME: exceedingly bad form.  Use prepare with placholders ("?") in query and execute args.
}

=cut

=head2 chargelostitem

In a default install of Koha the following lost values are set
1 = Lost
2 = Long overdue
3 = Lost and paid for

FIXME: itemlost should be set to 3 after payment is made, should be a warning to the interface that a charge has been added
FIXME : if no replacement price, borrower just doesn't get charged?

=cut

sub chargelostitem{
    my $dbh = C4::Context->dbh();
    my ($borrowernumber, $itemnumber, $amount, $description) = @_;
    my $itype = Koha::ItemTypes->find({ itemtype => Koha::Items->find($itemnumber)->effective_itemtype() });
    my $replacementprice = $amount;
    my $defaultreplacecost = $itype->defaultreplacecost;
    my $processfee = $itype->processfee;
    my $usedefaultreplacementcost = C4::Context->preference("useDefaultReplacementCost");
    my $processingfeenote = C4::Context->preference("ProcessingFeeNote");
    if ($usedefaultreplacementcost && $amount == 0 && $defaultreplacecost){
        $replacementprice = $defaultreplacecost;
    }
    # first make sure the borrower hasn't already been charged for this item
    # FIXME this should be more exact
    #       there is no reason a user can't lose an item, find and return it, and lost it again
    my $existing_charges = Koha::Account::Lines->search(
        {
            borrowernumber => $borrowernumber,
            itemnumber     => $itemnumber,
            accounttype    => 'L',
        }
    )->count();

    # OK, they haven't
    unless ($existing_charges) {
        #add processing fee
        if ($processfee && $processfee > 0){
            my $accountline = Koha::Account::Line->new(
                {
                    borrowernumber    => $borrowernumber,
                    accountno         => getnextacctno($borrowernumber),
                    date              => \'NOW()',
                    amount            => $processfee,
                    description       => $description,
                    accounttype       => 'PF',
                    amountoutstanding => $processfee,
                    itemnumber        => $itemnumber,
                    note              => $processingfeenote,
                    manager_id        => C4::Context->userenv ? C4::Context->userenv->{'number'} : 0,
                }
            )->store();

            my $account_offset = Koha::Account::Offset->new(
                {
                    debit_id => $accountline->id,
                    type     => 'Processing Fee',
                    amount   => $accountline->amount,
                }
            )->store();

            if ( C4::Context->preference("FinesLog") ) {
                logaction("FINES", 'CREATE',$borrowernumber,Dumper({
                    action            => 'create_fee',
                    borrowernumber    => $accountline->borrowernumber,,
                    accountno         => $accountline->accountno,
                    amount            => $accountline->amount,
                    description       => $accountline->description,
                    accounttype       => $accountline->accounttype,
                    amountoutstanding => $accountline->amountoutstanding,
                    note              => $accountline->note,
                    itemnumber        => $accountline->itemnumber,
                    manager_id        => $accountline->manager_id,
                }));
            }
        }
        #add replace cost
        if ($replacementprice > 0){
            my $accountline = Koha::Account::Line->new(
                {
                    borrowernumber    => $borrowernumber,
                    accountno         => getnextacctno($borrowernumber),
                    date              => \'NOW()',
                    amount            => $replacementprice,
                    description       => $description,
                    accounttype       => 'L',
                    amountoutstanding => $replacementprice,
                    itemnumber        => $itemnumber,
                    manager_id        => C4::Context->userenv ? C4::Context->userenv->{'number'} : 0,
                }
            )->store();

            my $account_offset = Koha::Account::Offset->new(
                {
                    debit_id => $accountline->id,
                    type     => 'Lost Item',
                    amount   => $accountline->amount,
                }
            )->store();

            if ( C4::Context->preference("FinesLog") ) {
                logaction("FINES", 'CREATE',$borrowernumber,Dumper({
                    action            => 'create_fee',
                    borrowernumber    => $accountline->borrowernumber,,
                    accountno         => $accountline->accountno,
                    amount            => $accountline->amount,
                    description       => $accountline->description,
                    accounttype       => $accountline->accounttype,
                    amountoutstanding => $accountline->amountoutstanding,
                    note              => $accountline->note,
                    itemnumber        => $accountline->itemnumber,
                    manager_id        => $accountline->manager_id,
                }));
            }
        }
    }
}

=head2 manualinvoice

  &manualinvoice($borrowernumber, $itemnumber, $description, $type,
                 $amount, $note);

C<$borrowernumber> is the patron's borrower number.
C<$description> is a description of the transaction.
C<$type> may be one of C<CS>, C<CB>, C<CW>, C<CF>, C<CL>, C<N>, C<L>,
or C<REF>.
C<$itemnumber> is the item involved, if pertinent; otherwise, it
should be the empty string.

=cut

#'
# FIXME: In Koha 3.0 , the only account adjustment 'types' passed to this function
# are:
# 		'C' = CREDIT
# 		'FOR' = FORGIVEN  (Formerly 'F', but 'F' is taken to mean 'FINE' elsewhere)
# 		'N' = New Card fee
# 		'F' = Fine
# 		'A' = Account Management fee
# 		'M' = Sundry
# 		'L' = Lost Item
#

sub manualinvoice {
    my ( $borrowernumber, $itemnum, $desc, $type, $amount, $note ) = @_;
    my $manager_id = 0;
    $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;
    my $dbh      = C4::Context->dbh;
    my $insert;
    my $accountno  = getnextacctno($borrowernumber);
    my $amountleft = $amount;

    my $accountline = Koha::Account::Line->new(
        {
            borrowernumber    => $borrowernumber,
            accountno         => $accountno,
            date              => \'NOW()',
            amount            => $amount,
            description       => $desc,
            accounttype       => $type,
            amountoutstanding => $amountleft,
            itemnumber        => $itemnum || undef,
            note              => $note,
            manager_id        => $manager_id,
        }
    )->store();

    my $account_offset = Koha::Account::Offset->new(
        {
            debit_id => $accountline->id,
            type     => 'Manual Debit',
            amount   => $amount,
        }
    )->store();

    if ( C4::Context->preference("FinesLog") ) {
        logaction("FINES", 'CREATE',$borrowernumber,Dumper({
            action            => 'create_fee',
            borrowernumber    => $borrowernumber,
            accountno         => $accountno,
            amount            => $amount,
            description       => $desc,
            accounttype       => $type,
            amountoutstanding => $amountleft,
            note              => $note,
            itemnumber        => $itemnum,
            manager_id        => $manager_id,
        }));
    }

    return 0;
}

sub getcharges {
    my ( $borrowerno, $timestamp, $accountno ) = @_;
    my $dbh        = C4::Context->dbh;
    my $timestamp2 = $timestamp - 1;
    my $query      = "";
    my $sth = $dbh->prepare(
            "SELECT * FROM accountlines WHERE borrowernumber=? AND accountno = ?"
          );
    $sth->execute( $borrowerno, $accountno );

    my @results;
    while ( my $data = $sth->fetchrow_hashref ) {
        push @results,$data;
    }
    return (@results);
}

sub ModNote {
    my ( $accountlines_id, $note ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare('UPDATE accountlines SET note = ? WHERE accountlines_id = ?');
    $sth->execute( $note, $accountlines_id );
}

sub getcredits {
	my ( $date, $date2 ) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare(
			        "SELECT * FROM accountlines,borrowers
      WHERE amount < 0 AND accounttype not like 'Pay%' AND accountlines.borrowernumber = borrowers.borrowernumber
	  AND timestamp >=TIMESTAMP(?) AND timestamp < TIMESTAMP(?)"
      );  

    $sth->execute( $date, $date2 );
    my @results;          
    while ( my $data = $sth->fetchrow_hashref ) {
		$data->{'date'} = $data->{'timestamp'};
		push @results,$data;
	}
    return (@results);
} 


sub getrefunds {
	my ( $date, $date2 ) = @_;
	my $dbh = C4::Context->dbh;
	
	my $sth = $dbh->prepare(
			        "SELECT *,timestamp AS datetime                                                                                      
                  FROM accountlines,borrowers
                  WHERE (accounttype = 'REF'
					  AND accountlines.borrowernumber = borrowers.borrowernumber
					                  AND date  >=?  AND date  <?)"
    );

    $sth->execute( $date, $date2 );

    my @results;
    while ( my $data = $sth->fetchrow_hashref ) {
		push @results,$data;
		
	}
    return (@results);
}

#FIXME: ReversePayment should be replaced with a Void Payment feature
sub ReversePayment {
    my ($accountlines_id) = @_;
    my $dbh = C4::Context->dbh;

    my $accountline        = Koha::Account::Lines->find($accountlines_id);
    my $amount_outstanding = $accountline->amountoutstanding;

    my $new_amountoutstanding =
      $amount_outstanding <= 0 ? $accountline->amount * -1 : 0;

    $accountline->description( $accountline->description . " Reversed -" );
    $accountline->amountoutstanding($new_amountoutstanding);
    $accountline->store();

    my $account_offset = Koha::Account::Offset->new(
        {
            credit_id => $accountline->id,
            type      => 'Reverse Payment',
            amount    => $amount_outstanding - $new_amountoutstanding,
        }
    )->store();

    if ( C4::Context->preference("FinesLog") ) {
        my $manager_id = 0;
        $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;

        logaction(
            "FINES", 'MODIFY',
            $accountline->borrowernumber,
            Dumper(
                {
                    action                => 'reverse_fee_payment',
                    borrowernumber        => $accountline->borrowernumber,
                    old_amountoutstanding => $amount_outstanding,
                    new_amountoutstanding => $new_amountoutstanding,
                    ,
                    accountlines_id => $accountline->id,
                    accountno       => $accountline->accountno,
                    manager_id      => $manager_id,
                }
            )
        );
    }
}

=head2 purge_zero_balance_fees

  purge_zero_balance_fees( $days );

Delete accountlines entries where amountoutstanding is 0 or NULL which are more than a given number of days old.

B<$days> -- Zero balance fees older than B<$days> days old will be deleted.

B<Warning:> Because fines and payments are not linked in accountlines, it is
possible for a fine to be deleted without the accompanying payment,
or vise versa. This won't affect the account balance, but might be
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

