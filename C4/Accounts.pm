package C4::Accounts;

# Copyright 2000-2002 Katipo Communications
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


use strict;
#use warnings; FIXME - Bug 2505
use C4::Context;
use C4::Stats;
use C4::Members;
use C4::Circulation qw(ReturnLostItem);

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
    $VERSION = 3.08.01.002;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&recordpayment
		&makepayment
		&manualinvoice
		&getnextacctno
		&reconcileaccount
		&getcharges
		&ModNote
		&getcredits
		&getrefunds
		&chargelostitem
		&ReversePayment
                &makepartialpayment
                &recordpayment_selectaccts
                &WriteOffFee
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

=head2 recordpayment

  &recordpayment($borrowernumber, $payment);

Record payment by a patron. C<$borrowernumber> is the patron's
borrower number. C<$payment> is a floating-point number, giving the
amount that was paid. 

Amounts owed are paid off oldest first. That is, if the patron has a
$1 fine from Feb. 1, another $1 fine from Mar. 1, and makes a payment
of $1.50, then the oldest fine will be paid off in full, and $0.50
will be credited to the next one.

=cut

#'
sub recordpayment {

    #here we update the account lines
    my ( $borrowernumber, $data ) = @_;
    my $dbh        = C4::Context->dbh;
    my $newamtos   = 0;
    my $accdata    = "";
    my $branch     = C4::Context->userenv->{'branch'};
    my $amountleft = $data;
    my $manager_id = 0;
    $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;

    # begin transaction
    my $nextaccntno = getnextacctno($borrowernumber);

    # get lines with outstanding amounts to offset
    my $sth = $dbh->prepare(
        "SELECT * FROM accountlines
  WHERE (borrowernumber = ?) AND (amountoutstanding<>0)
  ORDER BY date"
    );
    $sth->execute($borrowernumber);

    # offset transactions
    while ( ( $accdata = $sth->fetchrow_hashref ) and ( $amountleft > 0 ) ) {
        if ( $accdata->{'amountoutstanding'} < $amountleft ) {
            $newamtos = 0;
            $amountleft -= $accdata->{'amountoutstanding'};
        }
        else {
            $newamtos   = $accdata->{'amountoutstanding'} - $amountleft;
            $amountleft = 0;
        }
        my $thisacct = $accdata->{accountno};
        my $usth     = $dbh->prepare(
            "UPDATE accountlines SET amountoutstanding= ?
     WHERE (borrowernumber = ?) AND (accountno=?)"
        );
        $usth->execute( $newamtos, $borrowernumber, $thisacct );
        $usth->finish;
#        $usth = $dbh->prepare(
#            "INSERT INTO accountoffsets
#     (borrowernumber, accountno, offsetaccount,  offsetamount)
#     VALUES (?,?,?,?)"
#        );
#        $usth->execute( $borrowernumber, $accdata->{'accountno'},
#            $nextaccntno, $newamtos );
        $usth->finish;
    }

    # create new line
    my $usth = $dbh->prepare(
        "INSERT INTO accountlines
  (borrowernumber, accountno,date,amount,description,accounttype,amountoutstanding,manager_id)
  VALUES (?,?,now(),?,'Payment,thanks','Pay',?,?)"
    );
    $usth->execute( $borrowernumber, $nextaccntno, 0 - $data, 0 - $amountleft, $manager_id );
    $usth->finish;
    UpdateStats( $branch, 'payment', $data, '', '', '', $borrowernumber, $nextaccntno );
    $sth->finish;
}

=head2 makepayment

  &makepayment($borrowernumber, $acctnumber, $amount, $branchcode);

Records the fact that a patron has paid off the entire amount he or
she owes.

C<$borrowernumber> is the patron's borrower number. C<$acctnumber> is
the account that was credited. C<$amount> is the amount paid (this is
only used to record the payment. It is assumed to be equal to the
amount owed). C<$branchcode> is the code of the branch where payment
was made.

=cut

#'
# FIXME - I'm not at all sure about the above, because I don't
# understand what the acct* tables in the Koha database are for.
sub makepayment {

    #here we update both the accountoffsets and the account lines
    #updated to check, if they are paying off a lost item, we return the item
    # from their card, and put a note on the item record
    my ( $borrowernumber, $accountno, $amount, $user, $branch ) = @_;
    my $dbh = C4::Context->dbh;
    my $manager_id = 0;
    $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv; 

    # begin transaction
    my $nextaccntno = getnextacctno($borrowernumber);
    my $newamtos    = 0;
    my $sth =
      $dbh->prepare(
        "SELECT * FROM accountlines WHERE  borrowernumber=? AND accountno=?");
    $sth->execute( $borrowernumber, $accountno );
    my $data = $sth->fetchrow_hashref;
    $sth->finish;

    if($data->{'accounttype'} eq "Pay"){
        my $udp = 		
            $dbh->prepare(
                "UPDATE accountlines
                    SET amountoutstanding = 0, description = 'Payment,thanks'
                    WHERE borrowernumber = ?
                    AND accountno = ?
                "
            );
        $udp->execute($borrowernumber, $accountno );
        $udp->finish;
    }else{
        my $udp = 		
            $dbh->prepare(
                "UPDATE accountlines
                    SET amountoutstanding = 0
                    WHERE borrowernumber = ?
                    AND accountno = ?
                "
            );
        $udp->execute($borrowernumber, $accountno );
        $udp->finish;

         # create new line
        my $payment = 0 - $amount;
        
        my $ins = 
            $dbh->prepare( 
                "INSERT 
                    INTO accountlines (borrowernumber, accountno, date, amount, itemnumber, description, accounttype, amountoutstanding, manager_id)
                    VALUES ( ?, ?, now(), ?, ?, 'Payment,thanks', 'Pay', 0, ?)"
            );
        $ins->execute($borrowernumber, $nextaccntno, $payment, $data->{'itemnumber'}, $manager_id);
        $ins->finish;
    }

    # FIXME - The second argument to &UpdateStats is supposed to be the
    # branch code.
    # UpdateStats is now being passed $accountno too. MTJ
    UpdateStats( $user, 'payment', $amount, '', '', '', $borrowernumber,
        $accountno );
    #from perldoc: for SELECT only #$sth->finish;

    #check to see what accounttype
    if ( $data->{'accounttype'} eq 'Rep' || $data->{'accounttype'} eq 'L' ) {
        C4::Circulation::ReturnLostItem( $borrowernumber, $data->{'itemnumber'} );
    }
}

=head2 getnextacctno

  $nextacct = &getnextacctno($borrowernumber);

Returns the next unused account number for the patron with the given
borrower number.

=cut

#'
# FIXME - Okay, so what does the above actually _mean_?
sub getnextacctno ($) {
    my ($borrowernumber) = shift or return undef;
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

  &fixaccounts($borrowernumber, $accountnumber, $amount);

#'
# FIXME - I don't understand what this function does.
sub fixaccounts {
    my ( $borrowernumber, $accountno, $amount ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "SELECT * FROM accountlines WHERE borrowernumber=?
     AND accountno=?"
    );
    $sth->execute( $borrowernumber, $accountno );
    my $data = $sth->fetchrow_hashref;

    # FIXME - Error-checking
    my $diff        = $amount - $data->{'amount'};
    my $outstanding = $data->{'amountoutstanding'} + $diff;
    $sth->finish;

    $dbh->do(<<EOT);
        UPDATE  accountlines
        SET     amount = '$amount',
                amountoutstanding = '$outstanding'
        WHERE   borrowernumber = $borrowernumber
          AND   accountno = $accountno
EOT
	# FIXME: exceedingly bad form.  Use prepare with placholders ("?") in query and execute args.
}

=cut

sub chargelostitem{
# lost ==1 Lost, lost==2 longoverdue, lost==3 lost and paid for
# FIXME: itemlost should be set to 3 after payment is made, should be a warning to the interface that
# a charge has been added
# FIXME : if no replacement price, borrower just doesn't get charged?
    my $dbh = C4::Context->dbh();
    my ($borrowernumber, $itemnumber, $amount, $description) = @_;

    # first make sure the borrower hasn't already been charged for this item
    my $sth1=$dbh->prepare("SELECT * from accountlines
    WHERE borrowernumber=? AND itemnumber=? and accounttype='L'");
    $sth1->execute($borrowernumber,$itemnumber);
    my $existing_charge_hashref=$sth1->fetchrow_hashref();

    # OK, they haven't
    unless ($existing_charge_hashref) {
        my $manager_id = 0;
        $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;
        # This item is on issue ... add replacement cost to the borrower's record and mark it returned
        #  Note that we add this to the account even if there's no replacement price, allowing some other
        #  process (or person) to update it, since we don't handle any defaults for replacement prices.
        my $accountno = getnextacctno($borrowernumber);
        my $sth2=$dbh->prepare("INSERT INTO accountlines
        (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding,itemnumber,manager_id)
        VALUES (?,?,now(),?,?,'L',?,?,?)");
        $sth2->execute($borrowernumber,$accountno,$amount,
        $description,$amount,$itemnumber,$manager_id);
        $sth2->finish;
    # FIXME: Log this ?
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
# are :  
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
    my $notifyid = 0;
    my $insert;
    my $accountno  = getnextacctno($borrowernumber);
    my $amountleft = $amount;

#    if (   $type eq 'CS'
#        || $type eq 'CB'
#        || $type eq 'CW'
#        || $type eq 'CF'
#        || $type eq 'CL' )
#    {
#        my $amount2 = $amount * -1;    # FIXME - $amount2 = -$amount
#        $amountleft =
#          fixcredit( $borrowernumber, $amount2, $itemnum, $type, $user );
#    }
    if ( $type eq 'N' ) {
        $desc .= " New Card";
    }
    if ( $type eq 'F' ) {
        $desc .= " Fine";
    }
    if ( $type eq 'A' ) {
        $desc .= " Account Management fee";
    }
    if ( $type eq 'M' ) {
        $desc .= " Sundry";
    }

    if ( $type eq 'L' && $desc eq '' ) {

        $desc = " Lost Item";
    }
#    if ( $type eq 'REF' ) {
#        $desc .= " Cash Refund";
#        $amountleft = refund( '', $borrowernumber, $amount );
#    }
    if (   ( $type eq 'L' )
        or ( $type eq 'F' )
        or ( $type eq 'A' )
        or ( $type eq 'N' )
        or ( $type eq 'M' ) )
    {
        $notifyid = 1;
    }

    if ( $itemnum ) {
        $desc .= ' ' . $itemnum;
        my $sth = $dbh->prepare(
            'INSERT INTO  accountlines
                        (borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding, itemnumber,notify_id, note, manager_id)
        VALUES (?, ?, now(), ?,?, ?,?,?,?,?,?)');
     $sth->execute($borrowernumber, $accountno, $amount, $desc, $type, $amountleft, $itemnum,$notifyid, $note, $manager_id) || return $sth->errstr;
  } else {
    my $sth=$dbh->prepare("INSERT INTO  accountlines
            (borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding,notify_id, note, manager_id)
            VALUES (?, ?, now(), ?, ?, ?, ?,?,?,?)"
        );
        $sth->execute( $borrowernumber, $accountno, $amount, $desc, $type,
            $amountleft, $notifyid, $note, $manager_id );
    }
    return 0;
}

=head2 fixcredit #### DEPRECATED

 $amountleft = &fixcredit($borrowernumber, $data, $barcode, $type, $user);

 This function is only used internally, not exported.

=cut

# This function is deprecated in 3.0

sub fixcredit {

    #here we update both the accountoffsets and the account lines
    my ( $borrowernumber, $data, $barcode, $type, $user ) = @_;
    my $dbh        = C4::Context->dbh;
    my $newamtos   = 0;
    my $accdata    = "";
    my $amountleft = $data;
    if ( $barcode ne '' ) {
        my $item        = GetBiblioFromItemNumber( '', $barcode );
        my $nextaccntno = getnextacctno($borrowernumber);
        my $query       = "SELECT * FROM accountlines WHERE (borrowernumber=?
    AND itemnumber=? AND amountoutstanding > 0)";
        if ( $type eq 'CL' ) {
            $query .= " AND (accounttype = 'L' OR accounttype = 'Rep')";
        }
        elsif ( $type eq 'CF' ) {
            $query .= " AND (accounttype = 'F' OR accounttype = 'FU' OR
      accounttype='Res' OR accounttype='Rent')";
        }
        elsif ( $type eq 'CB' ) {
            $query .= " and accounttype='A'";
        }

        #    print $query;
        my $sth = $dbh->prepare($query);
        $sth->execute( $borrowernumber, $item->{'itemnumber'} );
        $accdata = $sth->fetchrow_hashref;
        $sth->finish;
        if ( $accdata->{'amountoutstanding'} < $amountleft ) {
            $newamtos = 0;
            $amountleft -= $accdata->{'amountoutstanding'};
        }
        else {
            $newamtos   = $accdata->{'amountoutstanding'} - $amountleft;
            $amountleft = 0;
        }
        my $thisacct = $accdata->{accountno};
        my $usth     = $dbh->prepare(
            "UPDATE accountlines SET amountoutstanding= ?
     WHERE (borrowernumber = ?) AND (accountno=?)"
        );
        $usth->execute( $newamtos, $borrowernumber, $thisacct );
        $usth->finish;
        $usth = $dbh->prepare(
            "INSERT INTO accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     VALUES (?,?,?,?)"
        );
        $usth->execute( $borrowernumber, $accdata->{'accountno'},
            $nextaccntno, $newamtos );
        $usth->finish;
    }

    # begin transaction
    my $nextaccntno = getnextacctno($borrowernumber);

    # get lines with outstanding amounts to offset
    my $sth = $dbh->prepare(
        "SELECT * FROM accountlines
  WHERE (borrowernumber = ?) AND (amountoutstanding >0)
  ORDER BY date"
    );
    $sth->execute($borrowernumber);

    #  print $query;
    # offset transactions
    while ( ( $accdata = $sth->fetchrow_hashref ) and ( $amountleft > 0 ) ) {
        if ( $accdata->{'amountoutstanding'} < $amountleft ) {
            $newamtos = 0;
            $amountleft -= $accdata->{'amountoutstanding'};
        }
        else {
            $newamtos   = $accdata->{'amountoutstanding'} - $amountleft;
            $amountleft = 0;
        }
        my $thisacct = $accdata->{accountno};
        my $usth     = $dbh->prepare(
            "UPDATE accountlines SET amountoutstanding= ?
     WHERE (borrowernumber = ?) AND (accountno=?)"
        );
        $usth->execute( $newamtos, $borrowernumber, $thisacct );
        $usth->finish;
        $usth = $dbh->prepare(
            "INSERT INTO accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     VALUE (?,?,?,?)"
        );
        $usth->execute( $borrowernumber, $accdata->{'accountno'},
            $nextaccntno, $newamtos );
        $usth->finish;
    }
    $sth->finish;
    $type = "Credit " . $type;
    UpdateStats( $user, $type, $data, $user, '', '', $borrowernumber );
    $amountleft *= -1;
    return ($amountleft);

}

=head2 refund

#FIXME : DEPRECATED SUB
 This subroutine tracks payments and/or credits against fines/charges
   using the accountoffsets table, which is not used consistently in
   Koha's fines management, and so is not used in 3.0 

=cut 

sub refund {

    #here we update both the accountoffsets and the account lines
    my ( $borrowernumber, $data ) = @_;
    my $dbh        = C4::Context->dbh;
    my $newamtos   = 0;
    my $accdata    = "";
    my $amountleft = $data * -1;

    # begin transaction
    my $nextaccntno = getnextacctno($borrowernumber);

    # get lines with outstanding amounts to offset
    my $sth = $dbh->prepare(
        "SELECT * FROM accountlines
  WHERE (borrowernumber = ?) AND (amountoutstanding<0)
  ORDER BY date"
    );
    $sth->execute($borrowernumber);

    #  print $amountleft;
    # offset transactions
    while ( ( $accdata = $sth->fetchrow_hashref ) and ( $amountleft < 0 ) ) {
        if ( $accdata->{'amountoutstanding'} > $amountleft ) {
            $newamtos = 0;
            $amountleft -= $accdata->{'amountoutstanding'};
        }
        else {
            $newamtos   = $accdata->{'amountoutstanding'} - $amountleft;
            $amountleft = 0;
        }

        #     print $amountleft;
        my $thisacct = $accdata->{accountno};
        my $usth     = $dbh->prepare(
            "UPDATE accountlines SET amountoutstanding= ?
     WHERE (borrowernumber = ?) AND (accountno=?)"
        );
        $usth->execute( $newamtos, $borrowernumber, $thisacct );
        $usth->finish;
        $usth = $dbh->prepare(
            "INSERT INTO accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     VALUES (?,?,?,?)"
        );
        $usth->execute( $borrowernumber, $accdata->{'accountno'},
            $nextaccntno, $newamtos );
        $usth->finish;
    }
    $sth->finish;
    return ($amountleft);
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
    my ( $borrowernumber, $accountno, $note ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare('UPDATE accountlines SET note = ? WHERE borrowernumber = ? AND accountno = ?');
    $sth->execute( $note, $borrowernumber, $accountno );
}

sub getcredits {
	my ( $date, $date2 ) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare(
			        "SELECT * FROM accountlines,borrowers
      WHERE amount < 0 AND accounttype <> 'Pay' AND accountlines.borrowernumber = borrowers.borrowernumber
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

sub ReversePayment {
  my ( $borrowernumber, $accountno ) = @_;
  my $dbh = C4::Context->dbh;
  
  my $sth = $dbh->prepare('SELECT amountoutstanding FROM accountlines WHERE borrowernumber = ? AND accountno = ?');
  $sth->execute( $borrowernumber, $accountno );
  my $row = $sth->fetchrow_hashref();
  my $amount_outstanding = $row->{'amountoutstanding'};
  
  if ( $amount_outstanding <= 0 ) {
    $sth = $dbh->prepare('UPDATE accountlines SET amountoutstanding = amount * -1, description = CONCAT( description, " Reversed -" ) WHERE borrowernumber = ? AND accountno = ?');
    $sth->execute( $borrowernumber, $accountno );
  } else {
    $sth = $dbh->prepare('UPDATE accountlines SET amountoutstanding = 0, description = CONCAT( description, " Reversed -" ) WHERE borrowernumber = ? AND accountno = ?');
    $sth->execute( $borrowernumber, $accountno );
  }
}

=head2 recordpayment_selectaccts

  recordpayment_selectaccts($borrowernumber, $payment,$accts);

Record payment by a patron. C<$borrowernumber> is the patron's
borrower number. C<$payment> is a floating-point number, giving the
amount that was paid. C<$accts> is an array ref to a list of
accountnos which the payment can be recorded against

Amounts owed are paid off oldest first. That is, if the patron has a
$1 fine from Feb. 1, another $1 fine from Mar. 1, and makes a payment
of $1.50, then the oldest fine will be paid off in full, and $0.50
will be credited to the next one.

=cut

sub recordpayment_selectaccts {
    my ( $borrowernumber, $amount, $accts ) = @_;

    my $dbh        = C4::Context->dbh;
    my $newamtos   = 0;
    my $accdata    = q{};
    my $branch     = C4::Context->userenv->{branch};
    my $amountleft = $amount;
    my $manager_id = 0;
    $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;
    my $sql = 'SELECT * FROM accountlines WHERE (borrowernumber = ?) ' .
    'AND (amountoutstanding<>0) ';
    if (@{$accts} ) {
        $sql .= ' AND accountno IN ( ' .  join ',', @{$accts};
        $sql .= ' ) ';
    }
    $sql .= ' ORDER BY date';
    # begin transaction
    my $nextaccntno = getnextacctno($borrowernumber);

    # get lines with outstanding amounts to offset
    my $rows = $dbh->selectall_arrayref($sql, { Slice => {} }, $borrowernumber);

    # offset transactions
    my $sth     = $dbh->prepare('UPDATE accountlines SET amountoutstanding= ? ' .
        'WHERE (borrowernumber = ?) AND (accountno=?)');
    for my $accdata ( @{$rows} ) {
        if ($amountleft == 0) {
            last;
        }
        if ( $accdata->{amountoutstanding} < $amountleft ) {
            $newamtos = 0;
            $amountleft -= $accdata->{amountoutstanding};
        }
        else {
            $newamtos   = $accdata->{amountoutstanding} - $amountleft;
            $amountleft = 0;
        }
        my $thisacct = $accdata->{accountno};
        $sth->execute( $newamtos, $borrowernumber, $thisacct );
    }

    # create new line
    $sql = 'INSERT INTO accountlines ' .
    '(borrowernumber, accountno,date,amount,description,accounttype,amountoutstanding,manager_id) ' .
    q|VALUES (?,?,now(),?,'Payment,thanks','Pay',?,?)|;
    $dbh->do($sql,{},$borrowernumber, $nextaccntno, 0 - $amount, 0 - $amountleft, $manager_id );
    UpdateStats( $branch, 'payment', $amount, '', '', '', $borrowernumber, $nextaccntno );
    return;
}

# makepayment needs to be fixed to handle partials till then this separate subroutine
# fills in
sub makepartialpayment {
    my ( $borrowernumber, $accountno, $amount, $user, $branch ) = @_;
    my $manager_id = 0;
    $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;
    if (!$amount || $amount < 0) {
        return;
    }
    my $dbh = C4::Context->dbh;

    my $nextaccntno = getnextacctno($borrowernumber);
    my $newamtos    = 0;

    my $data = $dbh->selectrow_hashref(
        'SELECT * FROM accountlines WHERE  borrowernumber=? AND accountno=?',undef,$borrowernumber,$accountno);
    my $new_outstanding = $data->{amountoutstanding} - $amount;

    my $update = 'UPDATE  accountlines SET amountoutstanding = ?  WHERE   borrowernumber = ? '
    . ' AND   accountno = ?';
    $dbh->do( $update, undef, $new_outstanding, $borrowernumber, $accountno);

    # create new line
    my $insert = 'INSERT INTO accountlines (borrowernumber, accountno, date, amount, '
    .  'description, accounttype, amountoutstanding, itemnumber, manager_id) '
    . ' VALUES (?, ?, now(), ?, ?, ?, 0, ?, ?)';

    $dbh->do(  $insert, undef, $borrowernumber, $nextaccntno, 0 - $amount,
        "Payment, thanks - $user", 'Pay', $data->{'itemnumber'}, $manager_id);

    UpdateStats( $user, 'payment', $amount, '', '', '', $borrowernumber, $accountno );

    return;
}

=head2 WriteOff

  WriteOff( $borrowernumber, $accountnum, $itemnum, $accounttype, $amount, $branch );

Write off a fine for a patron.
C<$borrowernumber> is the patron's borrower number.
C<$accountnum> is the accountnumber of the fee to write off.
C<$itemnum> is the itemnumber of of item whose fine is being written off.
C<$accounttype> is the account type of the fine being written off.
C<$amount> is a floating-point number, giving the amount that is being written off.
C<$branch> is the branchcode of the library where the writeoff occurred.

=cut

sub WriteOffFee {
    my ( $borrowernumber, $accountnum, $itemnum, $accounttype, $amount, $branch ) = @_;
    $branch ||= C4::Context->userenv->{branch};
    my $manager_id = 0;
    $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;

    # if no item is attached to fine, make sure to store it as a NULL
    $itemnum ||= undef;

    my ( $sth, $query );
    my $dbh = C4::Context->dbh();

    $query = "
        UPDATE accountlines SET amountoutstanding = 0
        WHERE accountno = ? AND borrowernumber = ?
    ";
    $sth = $dbh->prepare( $query );
    $sth->execute( $accountnum, $borrowernumber );

    $query ="
        INSERT INTO accountlines
        ( borrowernumber, accountno, itemnumber, date, amount, description, accounttype, manager_id )
        VALUES ( ?, ?, ?, NOW(), ?, 'Writeoff', 'W', ? )
    ";
    $sth = $dbh->prepare( $query );
    my $acct = getnextacctno($borrowernumber);
    $sth->execute( $borrowernumber, $acct, $itemnum, $amount, $manager_id );

    UpdateStats( $branch, 'writeoff', $amount, q{}, q{}, q{}, $borrowernumber );

}

END { }    # module clean-up code here (global destructor)

1;
__END__

=head1 SEE ALSO

DBI(3)

=cut

