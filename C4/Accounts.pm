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

# $Id$

use strict;
require Exporter;
use C4::Context;
use C4::Stats;
use C4::Members;
#use C4::Circulation::Circ2;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = do { my @v = '$Revision$' =~ /\d+/g; 
shift(@v) . "." . join("_", map {sprintf "%03d", $_ } @v); };

=head1 NAME

C4::Accounts - Functions for dealing with Koha accounts

=head1 SYNOPSIS

use C4::Accounts;

=head1 DESCRIPTION

The functions in this module deal with the monetary aspect of Koha,
including looking up and modifying the amount of money owed by a
patron.

=head1 FUNCTIONS

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&checkaccount &recordpayment &fixaccounts &makepayment &manualinvoice
&getnextacctno &reconcileaccount);

=head2 checkaccount

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
    my ($env,$borrowernumber,$dbh,$date)=@_;
    my $select="SELECT SUM(amountoutstanding) AS total
            FROM accountlines
        WHERE borrowernumber = ?
            AND amountoutstanding<>0";
    my @bind = ($borrowernumber);
    if ($date && $date ne ''){
    $select.=" AND date < ?";
    push(@bind,$date);
    }
    #  print $select;
    my $sth=$dbh->prepare($select);
    $sth->execute(@bind);
    my $data=$sth->fetchrow_hashref;
    my $total = $data->{'total'} || 0;
    $sth->finish;
    # output(1,2,"borrower owes $total");
    #if ($total > 0){
    #  # output(1,2,"borrower owes $total");
    #  if ($total > 5){
    #    reconcileaccount($env,$dbh,$borrowernumber,$total);
    #  }
    #}
    #  pause();
    return($total);
}

=head2 recordpayment

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
  my ($env,$borrowernumber,$data)=@_;
  my $dbh = C4::Context->dbh;
  my $newamtos = 0;
  my $accdata = "";
  my $branch=$env->{'branchcode'};
    warn $branch;
  my $amountleft = $data;
  # begin transaction
  my $nextaccntno = getnextacctno($env,$borrowernumber,$dbh);
  # get lines with outstanding amounts to offset
  my $sth = $dbh->prepare("select * from accountlines
  where (borrowernumber = ?) and (amountoutstanding<>0)
  order by date");
  $sth->execute($borrowernumber);
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
     $usth->execute($newamtos,$borrowernumber,$thisacct);
     $usth->finish;
     $usth = $dbh->prepare("insert into accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values (?,?,?,?)");
     $usth->execute($borrowernumber,$accdata->{'accountno'},$nextaccntno,$newamtos);
     $usth->finish;
  }
  # create new line
  my $usth = $dbh->prepare("insert into accountlines
  (borrowernumber, accountno,date,amount,description,accounttype,amountoutstanding)
  values (?,?,now(),?,'Payment,thanks','Pay',?)");
  $usth->execute($borrowernumber,$nextaccntno,0-$data,0-$amountleft);
  $usth->finish;
  UpdateStats($env,$branch,'payment',$data,'','','',$borrowernumber);
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
sub makepayment{
  #here we update both the accountoffsets and the account lines
  #updated to check, if they are paying off a lost item, we return the item
  # from their card, and put a note on the item record
  my ($borrowernumber,$accountno,$amount,$user,$branch)=@_;
  my %env;
  $env{'branchcode'}=$branch;
  my $dbh = C4::Context->dbh;
  # begin transaction
  my $nextaccntno = getnextacctno(\%env,$borrowernumber,$dbh);
  my $newamtos=0;
  my $sth=$dbh->prepare("Select * from accountlines where  borrowernumber=? and accountno=?");
  $sth->execute($borrowernumber,$accountno);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;

  $dbh->do(<<EOT);
        UPDATE  accountlines
        SET     amountoutstanding = 0
        WHERE   borrowernumber = $borrowernumber
          AND   accountno = $accountno
EOT

#  print $updquery;
  $dbh->do(<<EOT);
        INSERT INTO     accountoffsets
                        (borrowernumber, accountno, offsetaccount,
                         offsetamount)
        VALUES          ($borrowernumber, $accountno, $nextaccntno, $newamtos)
EOT

  # create new line
  my $payment=0-$amount;
  $dbh->do(<<EOT);
        INSERT INTO     accountlines
                        (borrowernumber, accountno, date, amount,
                         description, accounttype, amountoutstanding)
        VALUES          ($borrowernumber, $nextaccntno, now(), $payment,
                        'Payment,thanks - $user', 'Pay', 0)
EOT

  # FIXME - The second argument to &UpdateStats is supposed to be the
  # branch code.
  # UpdateStats is now being passed $accountno too. MTJ
  UpdateStats(\%env,$user,'payment',$amount,'','','',$borrowernumber,$accountno);
  $sth->finish;
  #check to see what accounttype
  if ($data->{'accounttype'} eq 'Rep' || $data->{'accounttype'} eq 'L'){
    returnlost($borrowernumber,$data->{'itemnumber'});
  }
}

=head2 getnextacctno

  $nextacct = &getnextacctno($env, $borrowernumber, $dbh);

Returns the next unused account number for the patron with the given
borrower number.

C<$dbh> is a DBI::db handle to the Koha database.

C<$env> is ignored.

=cut

#'
# FIXME - Okay, so what does the above actually _mean_?
sub getnextacctno {
  my ($env,$borrowernumber,$dbh)=@_;
  my $nextaccntno = 1;
  my $sth = $dbh->prepare("select * from accountlines
  where (borrowernumber = ?)
  order by accountno desc");
  $sth->execute($borrowernumber);
  if (my $accdata=$sth->fetchrow_hashref){
    $nextaccntno = $accdata->{'accountno'} + 1;
  }
  $sth->finish;
  return($nextaccntno);
}

=head2 fixaccounts

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
        UPDATE  accountlines
        SET     amount = '$amount',
                amountoutstanding = '$outstanding'
        WHERE   borrowernumber = $borrowernumber
          AND   accountno = $accountno
EOT
 }

# FIXME - Never used, but not exported, either.
sub returnlost{
  my ($borrowernumber,$itemnum)=@_;
  my $dbh = C4::Context->dbh;
  my $borrower=borrdata('',$borrowernumber);
  my $sth=$dbh->prepare("Update issues set returndate=now() where
  borrowernumber=? and itemnumber=? and returndate is null");
  $sth->execute($borrowernumber,$itemnum);
  $sth->finish;
  my @datearr = localtime(time);
  my $date = (1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  my $bor="$borrower->{'firstname'} $borrower->{'surname'} $borrower->{'cardnumber'}";
  $sth=$dbh->prepare("Update items set paidfor=? where itemnumber=?");
  $sth->execute("Paid for by $bor $date",$itemnum);
  $sth->finish;
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
# FIXME - Okay, so what does this function do, really?
sub manualinvoice{
  my ($borrowernumber,$itemnum,$desc,$type,$amount,$user)=@_;
  my $dbh = C4::Context->dbh;
  my $notifyid;
  my $insert;
  $itemnum=~ s/ //g;
  my %env;
  my $accountno=getnextacctno('',$borrowernumber,$dbh);
  my $amountleft=$amount;

  if ($type eq 'CS' || $type eq 'CB' || $type eq 'CW'
  || $type eq 'CF' || $type eq 'CL'){
    my $amount2=$amount*-1;     # FIXME - $amount2 = -$amount
    $amountleft=fixcredit(\%env,$borrowernumber,$amount2,$itemnum,$type,$user);
  }
  if ($type eq 'N'){
    $desc.="New Card";
  }
  if ($type eq 'F'){
    $desc.="Fine";
  }
  if ($type eq 'A'){
    $desc.="Account Management fee";
  }
  if ($type eq 'M'){
    $desc.="Sundry";
  }     
        
  if ($type eq 'L' && $desc eq ''){
    
    $desc="Lost Item";
  }
  if ($type eq 'REF'){
    $desc.="Cash Refund";    
    $amountleft=refund('',$borrowernumber,$amount);
  }
  if(($type eq 'L') or ($type eq 'F') or ($type eq 'A') or ($type eq 'N') or ($type eq 'M') ){
  $notifyid=1;  
  }
    
  if ($itemnum ne ''){
    $desc.=" ".$itemnum;
    my $sth=$dbh->prepare("INSERT INTO  accountlines
                        (borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding, itemnumber,notify_id)
        VALUES (?, ?, now(), ?,?, ?,?,?,?)");
#     $sth->execute($borrowernumber, $accountno, $amount, $desc, $type, $amountleft, $data->{'itemnumber'});
     $sth->execute($borrowernumber, $accountno, $amount, $desc, $type, $amountleft, $itemnum,$notifyid);
  } else {
    my $sth=$dbh->prepare("INSERT INTO  accountlines
            (borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding,notify_id)
            VALUES (?, ?, now(), ?, ?, ?, ?,?)");
    $sth->execute($borrowernumber, $accountno, $amount, $desc, $type, $amountleft,$notifyid);
  }
}

=head2 fixcredit

 $amountleft = &fixcredit($env, $borrowernumber, $data, $barcode, $type, $user);

 This function is only used internally, not exported.
 FIXME - Figure out what this function does, and write it down.

=cut

sub fixcredit{
  #here we update both the accountoffsets and the account lines
  my ($env,$borrowernumber,$data,$barcode,$type,$user)=@_;
  my $dbh = C4::Context->dbh;
  my $newamtos = 0;
  my $accdata = "";
  my $amountleft = $data;
  if ($barcode ne ''){
    my $item=getiteminformation('',$barcode);
    my $nextaccntno = getnextacctno($env,$borrowernumber,$dbh);
    my $query="Select * from accountlines where (borrowernumber=?
    and itemnumber=? and amountoutstanding > 0)";
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
    $sth->execute($borrowernumber,$item->{'itemnumber'});
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
     my $usth = $dbh->prepare("update accountlines set amountoutstanding= ?
     where (borrowernumber = ?) and (accountno=?)");
     $usth->execute($newamtos,$borrowernumber,$thisacct);
     $usth->finish;
     $usth = $dbh->prepare("insert into accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values (?,?,?,?)");
     $usth->execute($borrowernumber,$accdata->{'accountno'},$nextaccntno,$newamtos);
     $usth->finish;
  }
  # begin transaction
  my $nextaccntno = getnextacctno($env,$borrowernumber,$dbh);
  # get lines with outstanding amounts to offset
  my $sth = $dbh->prepare("select * from accountlines
  where (borrowernumber = ?) and (amountoutstanding >0)
  order by date");
  $sth->execute($borrowernumber);
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
     $usth->execute($newamtos,$borrowernumber,$thisacct);
     $usth->finish;
     $usth = $dbh->prepare("insert into accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values (?,?,?,?)");
     $usth->execute($borrowernumber,$accdata->{'accountno'},$nextaccntno,$newamtos);
     $usth->finish;
  }
  $sth->finish;
  $env->{'branch'}=$user;
  $type="Credit ".$type;
  UpdateStats($env,$user,$type,$data,$user,'','',$borrowernumber);
  $amountleft*=-1;
  return($amountleft);

}

=head2 refund

# FIXME - Figure out what this function does, and write it down.

=cut 

sub refund{
  #here we update both the accountoffsets and the account lines
  my ($env,$borrowernumber,$data)=@_;
  my $dbh = C4::Context->dbh;
  my $newamtos = 0;
  my $accdata = "";
#  my $branch=$env->{'branchcode'};
  my $amountleft = $data *-1;

  # begin transaction
  my $nextaccntno = getnextacctno($env,$borrowernumber,$dbh);
  # get lines with outstanding amounts to offset
  my $sth = $dbh->prepare("select * from accountlines
  where (borrowernumber = ?) and (amountoutstanding<0)
  order by date");
  $sth->execute($borrowernumber);
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
     $usth->execute($newamtos,$borrowernumber,$thisacct);
     $usth->finish;
     $usth = $dbh->prepare("insert into accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values (?,?,?,?)");
     $usth->execute($borrowernumber,$accdata->{'accountno'},$nextaccntno,$newamtos);
     $usth->finish;
  }
  $sth->finish;
  return($amountleft);
}


END { }       # module clean-up code here (global destructor)

1;
__END__


=head1 SEE ALSO

DBI(3)

=cut

