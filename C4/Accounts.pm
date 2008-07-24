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
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA


use strict;
use C4::Context;
use C4::Stats;
use C4::Members;
use C4::Items;
use C4::Circulation;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
	$VERSION = 3.03;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&recordpayment &makepayment &manualinvoice
		&getnextacctno &reconcileaccount &getcharges &getcredits
		&getrefunds
	); # removed &fixaccounts
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
  (borrowernumber, accountno,date,amount,description,accounttype,amountoutstanding)
  VALUES (?,?,now(),?,'Payment,thanks','Pay',?)"
    );
    $usth->execute( $borrowernumber, $nextaccntno, 0 - $data, 0 - $amountleft );
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

    # begin transaction
    my $nextaccntno = getnextacctno($borrowernumber);
    my $newamtos    = 0;
    my $sth =
      $dbh->prepare(
        "SELECT * FROM accountlines WHERE  borrowernumber=? AND accountno=?");
    $sth->execute( $borrowernumber, $accountno );
    my $data = $sth->fetchrow_hashref;
    $sth->finish;

    $dbh->do(
        "UPDATE  accountlines
        SET     amountoutstanding = 0
        WHERE   borrowernumber = $borrowernumber
          AND   accountno = $accountno
        "
    );

    #  print $updquery;
#    $dbh->do( "
#        INSERT INTO     accountoffsets
#                        (borrowernumber, accountno, offsetaccount,
#                         offsetamount)
#        VALUES          ($borrowernumber, $accountno, $nextaccntno, $newamtos)
#        " );

    # create new line
    my $payment = 0 - $amount;
    $dbh->do( "
        INSERT INTO     accountlines
                        (borrowernumber, accountno, date, amount,
                         description, accounttype, amountoutstanding)
        VALUES          ($borrowernumber, $nextaccntno, now(), $payment,
                        'Payment,thanks - $user', 'Pay', 0)
        " );

    # FIXME - The second argument to &UpdateStats is supposed to be the
    # branch code.
    # UpdateStats is now being passed $accountno too. MTJ
    UpdateStats( $user, 'payment', $amount, '', '', '', $borrowernumber,
        $accountno );
    $sth->finish;

    #check to see what accounttype
    if ( $data->{'accounttype'} eq 'Rep' || $data->{'accounttype'} eq 'L' ) {
        returnlost( $borrowernumber, $data->{'itemnumber'} );
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

sub returnlost {
    my ( $borrowernumber, $itemnum ) = @_;
    C4::Circulation::MarkIssueReturned( $borrowernumber, $itemnum );
    my $borrower = C4::Members::GetMember( $borrowernumber, 'borrowernumber' );
    my @datearr = localtime(time);
    my $date = ( 1900 + $datearr[5] ) . "-" . ( $datearr[4] + 1 ) . "-" . $datearr[3];
    my $bor = "$borrower->{'firstname'} $borrower->{'surname'} $borrower->{'cardnumber'}";
    ModItem({ paidfor =>  "Paid for by $bor $date" }, undef, $itemnum);
}

=head2 manualinvoice

  &manualinvoice($borrowernumber, $itemnumber, $description, $type,
                 $amount, $user);

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
    my ( $borrowernumber, $itemnum, $desc, $type, $amount, $user ) = @_;
    my $dbh      = C4::Context->dbh;
    my $notifyid = 0;
    my $insert;
    $itemnum =~ s/ //g;
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

    if ( $itemnum ne '' ) {
        $desc .= " " . $itemnum;
        my $sth = $dbh->prepare(
            "INSERT INTO  accountlines
                        (borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding, itemnumber,notify_id)
        VALUES (?, ?, now(), ?,?, ?,?,?,?)");
     $sth->execute($borrowernumber, $accountno, $amount, $desc, $type, $amountleft, $itemnum,$notifyid) || return $sth->errstr;
  } else {
    my $sth=$dbh->prepare("INSERT INTO  accountlines
            (borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding,notify_id)
            VALUES (?, ?, now(), ?, ?, ?, ?,?)"
        );
        $sth->execute( $borrowernumber, $accountno, $amount, $desc, $type,
            $amountleft, $notifyid );
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
END { }    # module clean-up code here (global destructor)

1;
__END__

=head1 SEE ALSO

DBI(3)

=cut

