package C4::Accounts2; #assumes C4/Accounts2


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
require Exporter;
use C4::Context;
use C4::Stats;
use C4::Search;
use C4::Circulation::Circ2;
use C4::Members;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;	# FIXME - Should probably be different from
			# the version for C4::Accounts

=head1 NAME

C4::Accounts - Functions for dealing with Koha accounts

=head1 SYNOPSIS

  use C4::Accounts2;

=head1 DESCRIPTION

The functions in this module deal with the monetary aspect of Koha,
including looking up and modifying the amount of money owed by a
patron.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&checkaccount	&recordpayment &fixaccounts &makepayment &manualinvoice
				&getnextacctno &manualcredit
				
				&dailyAccountBalance &addDailyAccountOp &getDailyAccountOp);

=item checkaccount

  $owed = &checkaccount($env, $borrowernumber, $dbh, $date);

Looks up the total amount of money owed by a borrower (fines, etc.).

C<$borrowernumber> specifies the borrower to look up.

C<$dbh> is a DBI::db handle for the Koha database.

C<$env> is ignored.

=cut
#'
sub checkaccount  {
  #take borrower number
  #check accounts and list amounts owing
	my ($env,$bornumber,$dbh,$date)=@_;
	my $select="SELECT SUM(amountoutstanding) AS total
			FROM accountlines
		WHERE borrowernumber = ?
			AND amountoutstanding<>0";
	my @bind = ($bornumber);
	if ($date ne ''){
	$select.=" AND date < ?";
	push(@bind,$date);
	}
	#  print $select;
	my $sth=$dbh->prepare($select);
	$sth->execute(@bind);
	my $data=$sth->fetchrow_hashref;
	my $total = $data->{'total'};
	$sth->finish;
	# output(1,2,"borrower owes $total");
	#if ($total > 0){
	#  # output(1,2,"borrower owes $total");
	#  if ($total > 5){
	#    reconcileaccount($env,$dbh,$bornumber,$total);
	#  }
	#}
	#  pause();
	return($total);
}

=item recordpayment

  &recordpayment($env, $borrowernumber, $payment);

Record payment by a patron. C<$borrowernumber> is the patron's
borrower number. C<$payment> is a floating-point number, giving the
amount that was paid. C<$env> is a reference-to-hash;
C<$env-E<gt>{branchcode}> is the code of the branch where payment was
made.

Amounts owed are paid off oldest first. That is, if the patron has a
$1 fine from Feb. 1, another $1 fine from Mar. 1, and makes a payment
of $1.50, then the oldest fine will be paid off in full, and $0.50
will be credited to the next one.

=cut
#'
sub recordpayment{
  #here we update both the accountoffsets and the account lines
  my ($env,$bornumber,$data)=@_;
  my $dbh = C4::Context->dbh;
  my $newamtos = 0;
  my $accdata = "";
  my $branch=$env->{'branchcode'};
  my $amountleft = $data;
  # begin transaction
  my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
  # get lines with outstanding amounts to offset
  my $sth = $dbh->prepare("select * from accountlines
  where (borrowernumber = ?) and (amountoutstanding<>0)
  order by date");
  $sth->execute($bornumber);
  # offset transactions
  while (($accdata=$sth->fetchrow_hashref) and ($amountleft>0)){
     if ($accdata->{'amountoutstanding'} < $amountleft) {
        $newamtos = 0;
	$amountleft -= $accdata->{'amountoutstanding'};
     }  else {
        $newamtos = $accdata->{'amountoutstanding'} - $amountleft;
	$amountleft = 0;
     }
     my $thisacct = $accdata->{accountno};
     my $usth = $dbh->prepare("update accountlines set amountoutstanding= ?
     where (borrowernumber = ?) and (accountno=?)");
     $usth->execute($newamtos,$bornumber,$thisacct);
     $usth->finish;
 #    $usth = $dbh->prepare("insert into accountoffsets
  #   (borrowernumber, accountno, offsetaccount,  offsetamount)
   #  values (?,?,?,?)");
    # $usth->execute($bornumber,$accdata->{'accountno'},$nextaccntno,$newamtos);
    # $usth->finish;
  }
  # create new line
  my $usth = $dbh->prepare("insert into accountlines
  (borrowernumber, accountno,date,amount,description,accounttype,amountoutstanding)
  values (?,?,now(),?,'Payment,thanks','Pay',?)");
  $usth->execute($bornumber,$nextaccntno,0-$data,0-$amountleft);
  $usth->finish;
#  UpdateStats($env,$branch,'payment',$data,'','','',$bornumber);
  $sth->finish;
}

=item makepayment

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

sub makepayment{
  #here we update  the account lines
  #updated to check, if they are paying off a lost item, we return the item
  # from their card, and put a note on the item record
  my ($bornumber,$accountno,$amount,$user,$type)=@_;
  my $env;
my $desc;
my $pay;
if ($type eq "Pay"){
 $desc="Payment,received by -". $user;
 $pay="Pay";
}else{
 $desc="Written-off -by". $user;
 $pay="W";
}
  my $dbh = C4::Context->dbh;
  # begin transaction
  my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
  my $newamtos=0;
  my $sth=$dbh->prepare("Select * from accountlines where  borrowernumber=? and accountno=?");
  $sth->execute($bornumber,$accountno);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;

  $dbh->do(<<EOT);
	UPDATE	accountlines
	SET	amountoutstanding = amountoutstanding-$amount
	WHERE	borrowernumber = $bornumber
	  AND	accountno = $accountno
EOT

#  print $updquery;
#  $dbh->do(<<EOT);
#	INSERT INTO	accountoffsets
#			(borrowernumber, accountno, offsetaccount,
#			 offsetamount)
#	VALUES		($bornumber, $accountno, $nextaccntno, $newamtos)
# EOT

  # create new line
  my $payment=0-$amount;
if ($data->{'itemnumber'}){
$desc.=" ".$data->{'itemnumber'};

  $dbh->do(<<EOT);
	INSERT INTO	accountlines
			(borrowernumber, accountno, itemnumber,date, amount,
			 description, accounttype, amountoutstanding,offset)
	VALUES		($bornumber, $nextaccntno, $data->{'itemnumber'},now(), $payment,
			'$desc', '$pay', 0,$accountno)
EOT
}else{
  $dbh->do(<<EOT);
INSERT INTO	accountlines
			(borrowernumber, accountno, date, amount,
			 description, accounttype, amountoutstanding,offset)
	VALUES		($bornumber, $nextaccntno, now(), $payment,
			'$desc', '$pay', 0,$accountno)
EOT
}

  # FIXME - The second argument to &UpdateStats is supposed to be the
  # branch code.
#  UpdateStats($env,'MAIN',$pay,$amount,'','','',$bornumber);
  $sth->finish;
  #check to see what accounttype
  if ($data->{'accounttype'} eq 'Rep' || $data->{'accounttype'} eq 'L'){
    returnlost($bornumber,$data->{'itemnumber'});
  }
}

=item getnextacctno

  $nextacct = &getnextacctno($env, $borrowernumber, $dbh);

Returns the next unused account number for the patron with the given
borrower number.

C<$dbh> is a DBI::db handle to the Koha database.

C<$env> is ignored.

=cut
#'
# FIXME - Okay, so what does the above actually _mean_?
sub getnextacctno {
  my ($env,$bornumber,$dbh)=@_;
  my $nextaccntno = 1;
  my $sth = $dbh->prepare("select * from accountlines
  where (borrowernumber = ?)
  order by accountno desc");
  $sth->execute($bornumber);
  if (my $accdata=$sth->fetchrow_hashref){
    $nextaccntno = $accdata->{'accountno'} + 1;
  }
  $sth->finish;
  return($nextaccntno);
}

=item fixaccounts

  &fixaccounts($borrowernumber, $accountnumber, $amount);

=cut
#'
# FIXME - I don't understand what this function does.
sub fixaccounts {
  my ($borrowernumber,$accountno,$amount)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from accountlines where borrowernumber=?
     and accountno=?");
  $sth->execute($borrowernumber,$accountno);
  my $data=$sth->fetchrow_hashref;
	# FIXME - Error-checking
  my $diff=$amount-$data->{'amount'};
  my $outstanding=$data->{'amountoutstanding'}+$diff;
  $sth->finish;

  $dbh->do(<<EOT);
	UPDATE	accountlines
	SET	amount = '$amount',
		amountoutstanding = '$outstanding'
	WHERE	borrowernumber = $borrowernumber
	  AND	accountno = $accountno
EOT
 }

# FIXME - Never used, but not exported, either.
sub returnlost{
  my ($borrnum,$itemnum)=@_;
  my $dbh = C4::Context->dbh;
  my $borrower=borrdata('',$borrnum); #from C4::Search;
  my $sth=$dbh->prepare("Update issues set returndate=now() where
  borrowernumber=? and itemnumber=? and returndate is null");
  $sth->execute($borrnum,$itemnum);
  $sth->finish;
  my @datearr = localtime(time);
  my $date = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  my $bor="$borrower->{'firstname'} $borrower->{'surname'} $borrower->{'cardnumber'}";
  $sth=$dbh->prepare("Update items set paidfor=? where itemnumber=?");
  $sth->execute("Paid for by $bor $date",$itemnum);
  $sth->finish;
}

=item manualinvoice

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
# FIXME - Okay, so what does this function do, really?
sub manualinvoice{
  my ($bornum,$itemnum,$desc,$type,$amount,$user)=@_;
  my $dbh = C4::Context->dbh;
  my $insert;
  $itemnum=~ s/ //g;
  my %env;
  my $accountno=getnextacctno('',$bornum,$dbh);
  my $amountleft=$amount;


  if ($type eq 'N'){
    $desc.="New Card";
  }

  if ($type eq 'L' && $desc eq ''){
    $desc="Lost Item";
  }
 if ($type eq 'REF'){
 $desc="Cash refund";
    $amountleft=refund('',$bornum,$amount);
  }
  if ($itemnum ne ''){

    $desc.=" ".$itemnum;
    my $sth=$dbh->prepare("INSERT INTO	accountlines
			(borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding, itemnumber)
	VALUES (?, ?, now(), ?,?, ?,?,?)");
     $sth->execute($bornum, $accountno, $amount, $desc, $type, $amountleft, $itemnum);
  } else {
    $desc=$dbh->quote($desc);
    my $sth=$dbh->prepare("INSERT INTO	accountlines
			(borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding)
			VALUES (?, ?, now(), ?, ?, ?, ?)");
    $sth->execute($bornum, $accountno, $amount, $desc, $type, $amountleft);
  }
}
sub manualcredit{
  my ($bornum,$itemnum,$desc,$type,$amount,$user,$oldaccount)=@_;
  my $dbh = C4::Context->dbh;
  my $insert;
  $itemnum=~ s/ //g;

  my $accountno=getnextacctno('',$bornum,$dbh);
#  my $amountleft=$amount;
my $amountleft;
my $noerror;
  if ($type eq 'CN' || $type eq 'CA'  || $type eq 'CR' 
  || $type eq 'CF' || $type eq 'CL' || $type eq 'CM'){
    my $amount2=$amount*-1;	# FIXME - $amount2 = -$amount
   ( $amountleft, $noerror,$oldaccount)=fixcredit($dbh,$bornum,$amount2,$itemnum,$type,$user);
  }
 if ($noerror>0){
	  if ($type eq 'CN'){
   	 $desc.="Card fee credited by:".$user;
  	}
	if ($type eq 'CM'){
    	$desc.="Other fees credited by:".$user;
  	}
	if ($type eq 'CR'){
	    $desc.="Resrvation fee credited by:".$user;
  	}
	if ($type eq 'CA'){
   	 $desc.="Managenent fee credited by:".$user;
  	}
  	if ($type eq 'CL' && $desc eq ''){
   	 $desc="Lost Item credited by:".$user;
  	}
 
  	if ($itemnum ne ''){
    	$desc.=" Credited for overdue item:".$itemnum. " by:".$user;
    	my $sth=$dbh->prepare("INSERT INTO	accountlines
			(borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding, itemnumber,offset)
	VALUES (?, ?, now(), ?,?, ?,?,?,?)");
     	$sth->execute($bornum, $accountno, $amount, $desc, $type, $amountleft, $itemnum,$oldaccount);
  	} else {
   	 my $sth=$dbh->prepare("INSERT INTO	accountlines
			(borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding,offset)
			VALUES (?, ?, now(), ?, ?, ?, ?,?)");
    	$sth->execute($bornum, $accountno, $amount, $desc, $type, $amountleft,$oldaccount);
  	}
return ("0");
} else {
	return("1");
}
}
# fixcredit
sub fixcredit{
  #here we update both the accountoffsets and the account lines
  my ($dbh,$bornumber,$data,$itemnumber,$type,$user)=@_;
  my $newamtos = 0;
  my $accdata = "";
  my $amountleft = $data;
 my $env;
    my $query="Select * from accountlines where (borrowernumber=?
    and amountoutstanding > 0)";
my $exectype;
  	  if ($type eq 'CL'){
  	    $query.=" and (accounttype = 'L' or accounttype = 'Rep')";
   	 } elsif ($type eq 'CF'){
   	   $query.=" and ( itemnumber= ? and (accounttype = 'FU' or accounttype='F') )";
		$exectype=1;
  	  } elsif ($type eq 'CN'){
  	    $query.=" and ( accounttype = 'N' )";
  	  } elsif ($type eq 'CR'){
   	   $query.=" and ( itemnumber= ? and ( accounttype='Res' or accounttype='Rent'))";
		$exectype=1;
	}elsif ($type eq 'CM'){
  	    $query.=" and ( accounttype = 'M' )";
  	  }elsif ($type eq 'CA'){
  	    $query.=" and ( accounttype = 'A' )";
  	  }
#    print $query;
    my $sth=$dbh->prepare($query);
 if ($exectype && $itemnumber ne ''){
    $sth->execute($bornumber,$itemnumber);
	}else{
	 $sth->execute($bornumber);
	}
    $accdata=$sth->fetchrow_hashref;
    $sth->finish;

if ($accdata){
  	  if ($accdata->{'amountoutstanding'} < $amountleft) {
  	      $newamtos = 0;
		$amountleft -= $accdata->{'amountoutstanding'};
  	   }  else {
  	      $newamtos = $accdata->{'amountoutstanding'} - $amountleft;
	$amountleft = 0;
  	   }
          my $thisacct = $accdata->{accountno};
     my $usth = $dbh->prepare("update accountlines set amountoutstanding= ?
     where (borrowernumber = ?) and (accountno=?)");
     $usth->execute($newamtos,$bornumber,$thisacct);
     $usth->finish;

  
  # begin transaction
  # get lines with outstanding amounts to offset
  my $sth = $dbh->prepare("select * from accountlines
  where (borrowernumber = ?) and (amountoutstanding >0)
  order by date");
  $sth->execute($bornumber);
#  print $query;
  # offset transactions
  while (($accdata=$sth->fetchrow_hashref) and ($amountleft>0)){
     if ($accdata->{'amountoutstanding'} < $amountleft) {
        $newamtos = 0;
	$amountleft -= $accdata->{'amountoutstanding'};
     }  else {
        $newamtos = $accdata->{'amountoutstanding'} - $amountleft;
	$amountleft = 0;
     }
     my $thisacct = $accdata->{accountno};
     my $usth = $dbh->prepare("update accountlines set amountoutstanding= ?
     where (borrowernumber = ?) and (accountno=?)");
     $usth->execute($newamtos,$bornumber,$thisacct);
     $usth->finish;
  }
  $sth->finish;

  $amountleft*=-1;
  return($amountleft,1,$accdata->{'accountno'});
}else{
return("",0)
}
}

# FIXME - Figure out what this function does, and write it down.
sub refund{
  #here we update both the accountoffsets and the account lines
  my ($env,$bornumber,$data)=@_;
  my $dbh = C4::Context->dbh;
  my $newamtos = 0;
  my $accdata = "";
#  my $branch=$env->{'branchcode'};
  my $amountleft = $data *-1;

  # begin transaction
  # get lines with outstanding amounts to offset
  my $sth = $dbh->prepare("select * from accountlines
  where (borrowernumber = ?) and (amountoutstanding<0)
  order by date");
  $sth->execute($bornumber);
#  print $amountleft;
  # offset transactions
  while (($accdata=$sth->fetchrow_hashref) and ($amountleft<0)){
     if ($accdata->{'amountoutstanding'} > $amountleft) {
        $newamtos = 0;
	$amountleft -= $accdata->{'amountoutstanding'};
     }  else {
        $newamtos = $accdata->{'amountoutstanding'} - $amountleft;
	$amountleft = 0;
     }
#     print $amountleft;
     my $thisacct = $accdata->{accountno};
     my $usth = $dbh->prepare("update accountlines set amountoutstanding= ?
     where (borrowernumber = ?) and (accountno=?)");
     $usth->execute($newamtos,$bornumber,$thisacct);
     $usth->finish;

  }
  $sth->finish;
  return($amountleft);
}

#Funtion to manage the daily account#

sub dailyAccountBalance {
	my ($date) = @_;
	my $dbh = C4::Context->dbh;
	my $sth;
	
	if ($date) {

		$sth = $dbh->prepare("SELECT * FROM dailyaccountbalance WHERE balanceDate = ?");
		$sth->execute($date);
		my $data = $sth->fetchrow_hashref;
		if (!$data->{'balanceDate'}) {
			$data->{'noentry'} = 1;
		}
		return ($data);

	} else {
		
		$sth = $dbh->prepare("SELECT * FROM dailyaccountbalance WHERE balanceDate = CURRENT_DATE()");
		$sth->execute();
	
		if ($sth->rows) {
			return ($sth->fetchrow_hashref);	
		} else  {
			my %hash;
		
			$sth = $dbh->prepare("SELECT currentBalanceInHand FROM dailyaccountbalance ORDER BY balanceDate DESC LIMIT 1");
			$sth->execute();
			if ($sth->rows) {
				($hash{'initialBalanceInHand'}) = $sth->fetchrow_array;
				$hash{'currentBalanceInHand'} = $hash{'initialBalanceInHand'};
			} else {
				$hash{'initialBalanceInHand'} = 0;
				$hash{'currentBalanceInHand'} = 0;
			}
			#gets the current date.
			my @nowarr = localtime();
			my $date = (1900+$nowarr[5])."-".($nowarr[4]+1)."-".$nowarr[3]; 

			$hash{'balanceDate'} = $date;
			$hash{'initialBalanceInHand'} = sprintf  ("%.2f", $hash{'initialBalanceInHand'});
			$hash{'currentBalanceInHand'} = sprintf  ("%.2f", $hash{'currentBalanceInHand'});
			return \%hash;
		}

	}
}

sub addDailyAccountOp {
	my ($description, $amount, $type, $invoice) = @_;
	my $dbh = C4::Context->dbh;
	unless ($invoice) { $invoice = undef};
	my $sth = $dbh->prepare("INSERT INTO dailyaccount (date, description, amount, type, invoice) VALUES (CURRENT_DATE(), ?, ?, ?, ?)");
	$sth->execute($description, $amount, $type, $invoice);
	my $accountop = $dbh->{'mysql_insertid'};
	$sth = $dbh->prepare("SELECT * FROM dailyaccountbalance WHERE balanceDate = CURRENT_DATE()");
	$sth->execute();
	if (!$sth->rows) {
		$sth = $dbh->prepare("SELECT currentBalanceInHand FROM dailyaccountbalance ORDER BY balanceDate DESC LIMIT 1");
		$sth->execute();
		my ($blc) = $sth->fetchrow_array;
		unless ($blc) {$blc = 0}
		$sth = $dbh->prepare("INSERT INTO dailyaccountbalance (balanceDate, initialBalanceInHand, currentBalanceInHand) VALUES (CURRENT_DATE(), ?, ?)");
		$sth->execute($blc, $blc);
	}
	if ($type eq 'D') {
		$amount = -1 * $amount;
	} 
	$sth = $dbh->prepare("UPDATE dailyaccountbalance SET currentBalanceInHand = currentBalanceInHand + ? WHERE balanceDate = CURRENT_DATE()");
	$sth->execute($amount);
	return $accountop; 
}

sub getDailyAccountOp {
	my ($date) = @_;
	my $dbh = C4::Context->dbh;
	my $sth;
	if ($date) {
		$sth = $dbh->prepare("SELECT * FROM dailyaccount WHERE date = ?");
		$sth->execute($date);	
	} else {
		$sth = $dbh->prepare("SELECT * FROM dailyaccount WHERE date = CURRENT_DATE()");
		$sth->execute();
	}
	my @operations;	
	my $count = 1;
	while (my $row = $sth->fetchrow_hashref) {
		$row->{'num'} = $count++; 
		$row->{$row->{'type'}} = 1;
		
		$row->{'invoice'} =~ /(\w*)\-(\w*)\-(\w*)/; 
		$row->{'invoiceNumber'} = $1;
		$row->{'invoiceSupplier'} = $2;
		$row->{'invoiceType'} = $3;
			
		push @operations, $row;
	}
	return (scalar(@operations), \@operations);
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 SEE ALSO

DBI(3)

=cut
