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
use DBI;
use C4::Context;
use C4::Stats;
use C4::Search;
use C4::Circulation::Circ2;
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
@EXPORT = qw(&recordpayment &fixaccounts &makepayment &manualinvoice
&getnextacctno);

# FIXME - Never used
sub displayaccounts{
  my ($env)=@_;
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
  my $updquery = "";
  my $newamtos = 0;
  my $accdata = "";
  my $branch=$env->{'branchcode'};
  my $amountleft = $data;
  # begin transaction
  my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
  # get lines with outstanding amounts to offset
  my $query = "select * from accountlines
  where (borrowernumber = '$bornumber') and (amountoutstanding<>0)
  order by date";
  my $sth = $dbh->prepare($query);
  $sth->execute;
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
     $updquery = "update accountlines set amountoutstanding= '$newamtos'
     where (borrowernumber = '$bornumber') and (accountno='$thisacct')";
     my $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
     $updquery = "insert into accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values ($bornumber,$accdata->{'accountno'},$nextaccntno,$newamtos)";
     $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
  }
  # create new line
  $updquery = "insert into accountlines
  (borrowernumber, accountno,date,amount,description,accounttype,amountoutstanding)
  values ($bornumber,$nextaccntno,now(),0-$data,'Payment,thanks',
  'Pay',0-$amountleft)";
  my $usth = $dbh->prepare($updquery);
  $usth->execute;
  $usth->finish;
  UpdateStats($env,$branch,'payment',$data,'','','',$bornumber);
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
  #here we update both the accountoffsets and the account lines
  #updated to check, if they are paying off a lost item, we return the item
  # from their card, and put a note on the item record
  my ($bornumber,$accountno,$amount,$user)=@_;
  my $env;
  my $dbh = C4::Context->dbh;
  # begin transaction
  my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
  my $newamtos=0;
  my $sel="Select * from accountlines where  borrowernumber=$bornumber and
  accountno=$accountno";
  my $sth=$dbh->prepare($sel);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;

  $dbh->do(<<EOT);
	UPDATE	accountlines
	SET	amountoutstanding = 0
	WHERE	borrowernumber = $bornumber
	  AND	accountno = $accountno
EOT

#  print $updquery;
  $dbh->do(<<EOT);
	INSERT INTO	accountoffsets
			(borrowernumber, accountno, offsetaccount,
			 offsetamount)
	VALUES		($bornumber, $accountno, $nextaccntno, $newamtos)
EOT

  # create new line
  my $payment=0-$amount;
  $dbh->do(<<EOT);
	INSERT INTO	accountlines
			(borrowernumber, accountno, date, amount,
			 description, accounttype, amountoutstanding)
	VALUES		($bornumber, $nextaccntno, now(), $payment,
			'Payment,thanks - $user', 'Pay', 0)
EOT

  # FIXME - The second argument to &UpdateStats is supposed to be the
  # branch code.
  UpdateStats($env,$user,'payment',$amount,'','','',$bornumber);
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
  my $query = "select * from accountlines
  where (borrowernumber = '$bornumber')
  order by accountno desc";
  my $sth = $dbh->prepare($query);
  $sth->execute;
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
  my $query="Select * from accountlines where borrowernumber=$borrowernumber
     and accountno=$accountno";
  my $sth=$dbh->prepare($query);
  $sth->execute;
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
  my $upiss="Update issues set returndate=now() where
  borrowernumber='$borrnum' and itemnumber='$itemnum' and returndate is null";
  my $sth=$dbh->prepare($upiss);
  $sth->execute;
  $sth->finish;
  my @datearr = localtime(time);
  my $date = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  my $bor="$borrower->{'firstname'} $borrower->{'surname'} $borrower->{'cardnumber'}";
  # FIXME - Use $dbh->do();
  my $upitem="Update items set paidfor='Paid for by $bor $date' where itemnumber='$itemnum'";
  $sth=$dbh->prepare($upitem);
  $sth->execute;
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

  if ($type eq 'CS' || $type eq 'CB' || $type eq 'CW'
  || $type eq 'CF' || $type eq 'CL'){
    my $amount2=$amount*-1;	# FIXME - $amount2 = -$amount
    $amountleft=fixcredit(\%env,$bornum,$amount2,$itemnum,$type,$user);
  }
  if ($type eq 'N'){
    $desc.="New Card";
  }
  if ($type eq 'L' && $desc eq ''){
    $desc="Lost Item";
  }
  if ($type eq 'REF'){
    $amountleft=refund('',$bornum,$amount);
  }
  if ($itemnum ne ''){
#     my $sth=$dbh->prepare("Select * from items where barcode='$itemnum'");
#     $sth->execute;
#     my $data=$sth->fetchrow_hashref;
#     $sth->finish;
    $desc.=" ".$itemnum;
    my $sth=$dbh->prepare("INSERT INTO	accountlines
			(borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding, itemnumber)
	VALUES (?, ?, now(), ?,?, ?,?,?)");
#     $sth->execute($bornum, $accountno, $amount, $desc, $type, $amountleft, $data->{'itemnumber'});
     $sth->execute($bornum, $accountno, $amount, $desc, $type, $amountleft, $itemnum);
  } else {
    $desc=$dbh->quote($desc);
    my $sth=$dbh->prepare("INSERT INTO	accountlines
			(borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding)
			VALUES (?, ?, now(), ?, ?, ?, ?)");
    $sth->execute($bornum, $accountno, $amount, $desc, $type, $amountleft);
  }
}

# fixcredit
# $amountleft = &fixcredit($env, $bornumber, $data, $barcode, $type, $user);
#
# This function is only used internally.
# FIXME - Figure out what this function does, and write it down.
sub fixcredit{
  #here we update both the accountoffsets and the account lines
  my ($env,$bornumber,$data,$barcode,$type,$user)=@_;
  my $dbh = C4::Context->dbh;
  my $updquery = "";
  my $newamtos = 0;
  my $accdata = "";
  my $amountleft = $data;
  if ($barcode ne ''){
    my $item=getiteminformation($env,'',$barcode);
    my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
    my $query="Select * from accountlines where (borrowernumber='$bornumber'
    and itemnumber='$item->{'itemnumber'}' and amountoutstanding > 0)";
    if ($type eq 'CL'){
      $query.=" and (accounttype = 'L' or accounttype = 'Rep')";
    } elsif ($type eq 'CF'){
      $query.=" and (accounttype = 'F' or accounttype = 'FU' or
      accounttype='Res' or accounttype='Rent')";
    } elsif ($type eq 'CB'){
      $query.=" and accounttype='A'";
    }
#    print $query;
    my $sth=$dbh->prepare($query);
    $sth->execute;
    $accdata=$sth->fetchrow_hashref;
    $sth->finish;
    if ($accdata->{'amountoutstanding'} < $amountleft) {
        $newamtos = 0;
	$amountleft -= $accdata->{'amountoutstanding'};
     }  else {
        $newamtos = $accdata->{'amountoutstanding'} - $amountleft;
	$amountleft = 0;
     }
          my $thisacct = $accdata->{accountno};
     my $updquery = "update accountlines set amountoutstanding= '$newamtos'
     where (borrowernumber = '$bornumber') and (accountno='$thisacct')";
     my $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
     $updquery = "insert into accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values ($bornumber,$accdata->{'accountno'},$nextaccntno,$newamtos)";
     $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
  }
  # begin transaction
  my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
  # get lines with outstanding amounts to offset
  my $query = "select * from accountlines
  where (borrowernumber = '$bornumber') and (amountoutstanding >0)
  order by date";
  my $sth = $dbh->prepare($query);
  $sth->execute;
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
     $updquery = "update accountlines set amountoutstanding= '$newamtos'
     where (borrowernumber = '$bornumber') and (accountno='$thisacct')";
     my $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
     $updquery = "insert into accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values ($bornumber,$accdata->{'accountno'},$nextaccntno,$newamtos)";
     $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
  }
  $sth->finish;
  $env->{'branch'}=$user;
  $type="Credit ".$type;
  UpdateStats($env,$user,$type,$data,$user,'','',$bornumber);
  $amountleft*=-1;
  return($amountleft);

}

# FIXME - Figure out what this function does, and write it down.
sub refund{
  #here we update both the accountoffsets and the account lines
  my ($env,$bornumber,$data)=@_;
  my $dbh = C4::Context->dbh;
  my $updquery = "";
  my $newamtos = 0;
  my $accdata = "";
#  my $branch=$env->{'branchcode'};
  my $amountleft = $data *-1;

  # begin transaction
  my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
  # get lines with outstanding amounts to offset
  my $query = "select * from accountlines
  where (borrowernumber = '$bornumber') and (amountoutstanding<0)
  order by date";
  my $sth = $dbh->prepare($query);
  $sth->execute;
#  print $query;
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
     $updquery = "update accountlines set amountoutstanding= '$newamtos'
     where (borrowernumber = '$bornumber') and (accountno='$thisacct')";
     my $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
     $updquery = "insert into accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values ($bornumber,$accdata->{'accountno'},$nextaccntno,$newamtos)";
     $usth = $dbh->prepare($updquery);
     $usth->execute;
     $usth->finish;
  }
  $sth->finish;
  return($amountleft);
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 SEE ALSO

DBI(3)

=cut
