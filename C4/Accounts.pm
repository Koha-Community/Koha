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

use Data::Dumper qw(Dumper);

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
    $VERSION = 3.07.00.049;
	require Exporter;
	@ISA    = qw(Exporter);
	@EXPORT = qw(
		&recordpayment
		&makepayment
		&manualinvoice
		&getnextacctno
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

  &recordpayment($borrowernumber, $payment, $sip_paytype, $note);

Record payment by a patron. C<$borrowernumber> is the patron's
borrower number. C<$payment> is a floating-point number, giving the
amount that was paid. C<$sip_paytype> is an optional flag to indicate this
payment was made over a SIP2 interface, rather than the staff client. The
value passed is the SIP2 payment type value (message 37, characters 21-22)

Amounts owed are paid off oldest first. That is, if the patron has a
$1 fine from Feb. 1, another $1 fine from Mar. 1, and makes a payment
of $1.50, then the oldest fine will be paid off in full, and $0.50
will be credited to the next one.

=cut

#'
sub recordpayment {

    #here we update the account lines
    my ( $borrowernumber, $data, $sip_paytype, $payment_note ) = @_;
    my $dbh        = C4::Context->dbh;
    my $newamtos   = 0;
    my $accdata    = "";
    my $branch     = C4::Context->userenv->{'branch'};
    my $amountleft = $data;
    my $manager_id = 0;
    $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;

    $payment_note //= "";

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
    my @ids;
    while ( ( $accdata = $sth->fetchrow_hashref ) and ( $amountleft > 0 ) ) {
        if ( $accdata->{'amountoutstanding'} < $amountleft ) {
            $newamtos = 0;
            $amountleft -= $accdata->{'amountoutstanding'};
        }
        else {
            $newamtos   = $accdata->{'amountoutstanding'} - $amountleft;
            $amountleft = 0;
        }
        my $thisacct = $accdata->{accountlines_id};
        my $usth     = $dbh->prepare(
            "UPDATE accountlines SET amountoutstanding= ?
     WHERE (accountlines_id = ?)"
        );
        $usth->execute( $newamtos, $thisacct );

        if ( C4::Context->preference("FinesLog") ) {
            $accdata->{'amountoutstanding_new'} = $newamtos;
            logaction("FINES", 'MODIFY', $borrowernumber, Dumper({
                action                => 'fee_payment',
                borrowernumber        => $accdata->{'borrowernumber'},
                old_amountoutstanding => $accdata->{'amountoutstanding'},
                new_amountoutstanding => $newamtos,
                amount_paid           => $accdata->{'amountoutstanding'} - $newamtos,
                accountlines_id       => $accdata->{'accountlines_id'},
                accountno             => $accdata->{'accountno'},
                manager_id            => $manager_id,
                note                  => $payment_note,
            }));
            push( @ids, $accdata->{'accountlines_id'} );
        }
    }

    # create new line
    my $usth = $dbh->prepare(
        "INSERT INTO accountlines
  (borrowernumber, accountno,date,amount,description,accounttype,amountoutstanding,manager_id, note)
  VALUES (?,?,now(),?,'',?,?,?,?)"
    );

    my $paytype = "Pay";
    $paytype .= $sip_paytype if defined $sip_paytype;
    $usth->execute( $borrowernumber, $nextaccntno, 0 - $data, $paytype, 0 - $amountleft, $manager_id, $payment_note );
    $usth->finish;

    UpdateStats({
                branch => $branch,
                type =>'payment',
                amount => $data,
                borrowernumber => $borrowernumber,
                accountno => $nextaccntno }
    );

    if ( C4::Context->preference("FinesLog") ) {
        $accdata->{'amountoutstanding_new'} = $newamtos;
        logaction("FINES", 'CREATE',$borrowernumber,Dumper({
            action            => 'create_payment',
            borrowernumber    => $borrowernumber,
            accountno         => $nextaccntno,
            amount            => $data * -1,
            amountoutstanding => $amountleft * -1,
            accounttype       => 'Pay',
            accountlines_paid => \@ids,
            manager_id        => $manager_id,
        }));
    }

}

=head2 makepayment

  &makepayment($accountlines_id, $borrowernumber, $acctnumber, $amount, $branchcode);

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
    my ( $accountlines_id, $borrowernumber, $accountno, $amount, $user, $branch, $payment_note ) = @_;
    my $dbh = C4::Context->dbh;
    my $manager_id = 0;
    $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv; 

    # begin transaction
    my $nextaccntno = getnextacctno($borrowernumber);
    my $newamtos    = 0;
    my $sth         = $dbh->prepare("SELECT * FROM accountlines WHERE accountlines_id=?");
    $sth->execute( $accountlines_id );
    my $data = $sth->fetchrow_hashref;

    my $payment;
    if ( $data->{'accounttype'} eq "Pay" ){
        my $udp = 		
            $dbh->prepare(
                "UPDATE accountlines
                    SET amountoutstanding = 0
                    WHERE accountlines_id = ?
                "
            );
        $udp->execute($accountlines_id);
    }else{
        my $udp = 		
            $dbh->prepare(
                "UPDATE accountlines
                    SET amountoutstanding = 0
                    WHERE accountlines_id = ?
                "
            );
        $udp->execute($accountlines_id);

         # create new line
        my $payment = 0 - $amount;
        $payment_note //= "";
        
        my $ins = 
            $dbh->prepare( 
                "INSERT 
                    INTO accountlines (borrowernumber, accountno, date, amount, itemnumber, description, accounttype, amountoutstanding, manager_id, note)
                    VALUES ( ?, ?, now(), ?, ?, '', 'Pay', 0, ?, ?)"
            );
        $ins->execute($borrowernumber, $nextaccntno, $payment, $data->{'itemnumber'}, $manager_id, $payment_note);
    }

    if ( C4::Context->preference("FinesLog") ) {
        logaction("FINES", 'MODIFY', $borrowernumber, Dumper({
            action                => 'fee_payment',
            borrowernumber        => $borrowernumber,
            old_amountoutstanding => $data->{'amountoutstanding'},
            new_amountoutstanding => 0,
            amount_paid           => $data->{'amountoutstanding'},
            accountlines_id       => $data->{'accountlines_id'},
            accountno             => $data->{'accountno'},
            manager_id            => $manager_id,
        }));


        logaction("FINES", 'CREATE',$borrowernumber,Dumper({
            action            => 'create_payment',
            borrowernumber    => $borrowernumber,
            accountno         => $nextaccntno,
            amount            => $payment,
            amountoutstanding => 0,,
            accounttype       => 'Pay',
            accountlines_paid => [$data->{'accountlines_id'}],
            manager_id        => $manager_id,
        }));
    }

    UpdateStats({
                branch => $user,
                type => 'payment',
                amount => $amount,
                borrowernumber => $borrowernumber,
                accountno => $accountno}
    );

    #check to see what accounttype
    if ( $data->{'accounttype'} eq 'Rep' || $data->{'accounttype'} eq 'L' ) {
        C4::Circulation::ReturnLostItem( $borrowernumber, $data->{'itemnumber'} );
    }
    my $sthr = $dbh->prepare("SELECT max(accountlines_id) AS lastinsertid FROM accountlines");
    $sthr->execute();
    my $datalastinsertid = $sthr->fetchrow_hashref;
    return $datalastinsertid->{'lastinsertid'};
}

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

        if ( C4::Context->preference("FinesLog") ) {
            logaction("FINES", 'CREATE', $borrowernumber, Dumper({
                action            => 'create_fee',
                borrowernumber    => $borrowernumber,
                accountno         => $accountno,
                amount            => $amount,
                amountoutstanding => $amount,
                description       => $description,
                accounttype       => 'L',
                itemnumber        => $itemnumber,
                manager_id        => $manager_id,
            }));
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

    if ( C4::Context->preference("FinesLog") ) {
        logaction("FINES", 'CREATE',$borrowernumber,Dumper({
            action            => 'create_fee',
            borrowernumber    => $borrowernumber,
            accountno         => $accountno,
            amount            => $amount,
            description       => $desc,
            accounttype       => $type,
            amountoutstanding => $amountleft,
            notify_id         => $notifyid,
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

sub ReversePayment {
    my ( $accountlines_id ) = @_;
    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare('SELECT * FROM accountlines WHERE accountlines_id = ?');
    $sth->execute( $accountlines_id );
    my $row = $sth->fetchrow_hashref();
    my $amount_outstanding = $row->{'amountoutstanding'};

    if ( $amount_outstanding <= 0 ) {
        $sth = $dbh->prepare('UPDATE accountlines SET amountoutstanding = amount * -1, description = CONCAT( description, " Reversed -" ) WHERE accountlines_id = ?');
        $sth->execute( $accountlines_id );
    } else {
        $sth = $dbh->prepare('UPDATE accountlines SET amountoutstanding = 0, description = CONCAT( description, " Reversed -" ) WHERE accountlines_id = ?');
        $sth->execute( $accountlines_id );
    }

    if ( C4::Context->preference("FinesLog") ) {
        my $manager_id = 0;
        $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;

        if ( $amount_outstanding <= 0 ) {
            $row->{'amountoutstanding'} *= -1;
        } else {
            $row->{'amountoutstanding'} = '0';
        }
        $row->{'description'} .= ' Reversed -';
        logaction("FINES", 'MODIFY', $row->{'borrowernumber'}, Dumper({
            action                => 'reverse_fee_payment',
            borrowernumber        => $row->{'borrowernumber'},
            old_amountoutstanding => $row->{'amountoutstanding'},
            new_amountoutstanding => 0 - $amount_outstanding,,
            accountlines_id       => $row->{'accountlines_id'},
            accountno             => $row->{'accountno'},
            manager_id            => $manager_id,
        }));

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
    my ( $borrowernumber, $amount, $accts, $note ) = @_;

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
        'WHERE accountlines_id=?');

    my @ids;
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
        my $thisacct = $accdata->{accountlines_id};
        $sth->execute( $newamtos, $thisacct );

        if ( C4::Context->preference("FinesLog") ) {
            logaction("FINES", 'MODIFY', $borrowernumber, Dumper({
                action                => 'fee_payment',
                borrowernumber        => $borrowernumber,
                old_amountoutstanding => $accdata->{'amountoutstanding'},
                new_amountoutstanding => $newamtos,
                amount_paid           => $accdata->{'amountoutstanding'} - $newamtos,
                accountlines_id       => $accdata->{'accountlines_id'},
                accountno             => $accdata->{'accountno'},
                manager_id            => $manager_id,
            }));
            push( @ids, $accdata->{'accountlines_id'} );
        }

    }

    # create new line
    $sql = 'INSERT INTO accountlines ' .
    '(borrowernumber, accountno,date,amount,description,accounttype,amountoutstanding,manager_id,note) ' .
    q|VALUES (?,?,now(),?,'','Pay',?,?,?)|;
    $dbh->do($sql,{},$borrowernumber, $nextaccntno, 0 - $amount, 0 - $amountleft, $manager_id, $note );
    UpdateStats({
                branch => $branch,
                type => 'payment',
                amount => $amount,
                borrowernumber => $borrowernumber,
                accountno => $nextaccntno}
    );

    if ( C4::Context->preference("FinesLog") ) {
        logaction("FINES", 'CREATE',$borrowernumber,Dumper({
            action            => 'create_payment',
            borrowernumber    => $borrowernumber,
            accountno         => $nextaccntno,
            amount            => 0 - $amount,
            amountoutstanding => 0 - $amountleft,
            accounttype       => 'Pay',
            accountlines_paid => \@ids,
            manager_id        => $manager_id,
        }));
    }

    return;
}

# makepayment needs to be fixed to handle partials till then this separate subroutine
# fills in
sub makepartialpayment {
    my ( $accountlines_id, $borrowernumber, $accountno, $amount, $user, $branch, $payment_note ) = @_;
    my $manager_id = 0;
    $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;
    if (!$amount || $amount < 0) {
        return;
    }
    $payment_note //= "";
    my $dbh = C4::Context->dbh;

    my $nextaccntno = getnextacctno($borrowernumber);
    my $newamtos    = 0;

    my $data = $dbh->selectrow_hashref(
        'SELECT * FROM accountlines WHERE  accountlines_id=?',undef,$accountlines_id);
    my $new_outstanding = $data->{amountoutstanding} - $amount;

    my $update = 'UPDATE  accountlines SET amountoutstanding = ?  WHERE   accountlines_id = ? ';
    $dbh->do( $update, undef, $new_outstanding, $accountlines_id);

    if ( C4::Context->preference("FinesLog") ) {
        logaction("FINES", 'MODIFY', $borrowernumber, Dumper({
            action                => 'fee_payment',
            borrowernumber        => $borrowernumber,
            old_amountoutstanding => $data->{'amountoutstanding'},
            new_amountoutstanding => $new_outstanding,
            amount_paid           => $data->{'amountoutstanding'} - $new_outstanding,
            accountlines_id       => $data->{'accountlines_id'},
            accountno             => $data->{'accountno'},
            manager_id            => $manager_id,
        }));
    }

    # create new line
    my $insert = 'INSERT INTO accountlines (borrowernumber, accountno, date, amount, '
    .  'description, accounttype, amountoutstanding, itemnumber, manager_id, note) '
    . ' VALUES (?, ?, now(), ?, ?, ?, 0, ?, ?, ?)';

    $dbh->do(  $insert, undef, $borrowernumber, $nextaccntno, $amount,
        '', 'Pay', $data->{'itemnumber'}, $manager_id, $payment_note);

    UpdateStats({
                branch => $user,
                type => 'payment',
                amount => $amount,
                borrowernumber => $borrowernumber,
                accountno => $accountno}
    );

    if ( C4::Context->preference("FinesLog") ) {
        logaction("FINES", 'CREATE',$borrowernumber,Dumper({
            action            => 'create_payment',
            borrowernumber    => $user,
            accountno         => $nextaccntno,
            amount            => 0 - $amount,
            accounttype       => 'Pay',
            itemnumber        => $data->{'itemnumber'},
            accountlines_paid => [ $data->{'accountlines_id'} ],
            manager_id        => $manager_id,
        }));
    }

    return;
}

=head2 WriteOffFee

  WriteOffFee( $borrowernumber, $accountline_id, $itemnum, $accounttype, $amount, $branch, $payment_note );

Write off a fine for a patron.
C<$borrowernumber> is the patron's borrower number.
C<$accountline_id> is the accountline_id of the fee to write off.
C<$itemnum> is the itemnumber of of item whose fine is being written off.
C<$accounttype> is the account type of the fine being written off.
C<$amount> is a floating-point number, giving the amount that is being written off.
C<$branch> is the branchcode of the library where the writeoff occurred.
C<$payment_note> is the note to attach to this payment

=cut

sub WriteOffFee {
    my ( $borrowernumber, $accountlines_id, $itemnum, $accounttype, $amount, $branch, $payment_note ) = @_;
    $payment_note //= "";
    $branch ||= C4::Context->userenv->{branch};
    my $manager_id = 0;
    $manager_id = C4::Context->userenv->{'number'} if C4::Context->userenv;

    # if no item is attached to fine, make sure to store it as a NULL
    $itemnum ||= undef;

    my ( $sth, $query );
    my $dbh = C4::Context->dbh();

    $query = "
        UPDATE accountlines SET amountoutstanding = 0
        WHERE accountlines_id = ? AND borrowernumber = ?
    ";
    $sth = $dbh->prepare( $query );
    $sth->execute( $accountlines_id, $borrowernumber );

    if ( C4::Context->preference("FinesLog") ) {
        logaction("FINES", 'MODIFY', $borrowernumber, Dumper({
            action                => 'fee_writeoff',
            borrowernumber        => $borrowernumber,
            accountlines_id       => $accountlines_id,
            manager_id            => $manager_id,
        }));
    }

    $query ="
        INSERT INTO accountlines
        ( borrowernumber, accountno, itemnumber, date, amount, description, accounttype, manager_id, note )
        VALUES ( ?, ?, ?, NOW(), ?, 'Writeoff', 'W', ?, ? )
    ";
    $sth = $dbh->prepare( $query );
    my $acct = getnextacctno($borrowernumber);
    $sth->execute( $borrowernumber, $acct, $itemnum, $amount, $manager_id, $payment_note );

    if ( C4::Context->preference("FinesLog") ) {
        logaction("FINES", 'CREATE',$borrowernumber,Dumper({
            action            => 'create_writeoff',
            borrowernumber    => $borrowernumber,
            accountno         => $acct,
            amount            => 0 - $amount,
            accounttype       => 'W',
            itemnumber        => $itemnum,
            accountlines_paid => [ $accountlines_id ],
            manager_id        => $manager_id,
        }));
    }

    UpdateStats({
                branch => $branch,
                type => 'writeoff',
                amount => $amount,
                borrowernumber => $borrowernumber}
    );

}

END { }    # module clean-up code here (global destructor)

1;
__END__

=head1 SEE ALSO

DBI(3)

=cut

