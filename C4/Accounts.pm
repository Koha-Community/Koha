package C4::Accounts; #assumes C4/Accounts

# This module uses the CDK modules, and crashes if called from a web script
# Hence the existence of Accounts2
#
# This module will be deprecated when we build a new curses/slang/character
# based interface.

# $Id$

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
use C4::Format;
use C4::Search;
use C4::Stats;
use C4::InterfaceCDK;
use C4::Interface::AccountsCDK;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Accounts - Functions for dealing with Koha accounts

=head1 SYNOPSIS

  use C4::Accounts;

=head1 DESCRIPTION

The functions in this module deal with the monetary aspect of Koha,
including looking up and modifying the amount of money owed by a
patron.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&checkaccount &reconcileaccount &getnextacctno);

=item checkaccount

  $owed = &checkaccount($env, $borrowernumber, $dbh);

Looks up the total amount of money owed by a borrower (fines, etc.).

C<$borrowernumber> specifies the borrower to look up.

C<$dbh> is a DBI::db handle for the Koha database.

C<$env> is ignored.

=cut
#'
sub checkaccount  {
  #take borrower number
  #check accounts and list amounts owing
  my ($env,$bornumber,$dbh)=@_;
  my $sth=$dbh->prepare("Select sum(amountoutstanding) from accountlines where
  borrowernumber=$bornumber and amountoutstanding<>0");
  $sth->execute;
  my $total=0;
  while (my $data=$sth->fetchrow_hashref){
    $total += $data->{'sum(amountoutstanding)'};
  }
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

# XXX - POD. Need to figure out C4/Interface/AccountsCDK.pm first,
# though
# FIXME - It looks as though this function really wants to be part of
# a curses-based script.
sub reconcileaccount {
  #print put money owing give person opportunity to pay it off
  my ($env,$dummy,$bornumber,$total)=@_;
  my $dbh = C4::Context->dbh;
  #get borrower record
  my $sth=$dbh->prepare("select * from borrowers
    where borrowernumber=$bornumber");
  $sth->execute;
  my $borrower=$sth->fetchrow_hashref;
  $sth->finish();
  #get borrower information
  $sth=$dbh->prepare("Select * from accountlines where
  borrowernumber=$bornumber and amountoutstanding<>0 order by date");
  $sth->execute;
  #display account information
  &clearscreen();
  #&helptext('F11 quits');
  output(20,0,"Accounts");
  my @accountlines;
  my $row=4;
  my $i=0;
  my $text;
  #output (1,2,"Account Info");
  #output (1,3,"Item\tDate      \tAmount\tDescription");
  while (my $data=$sth->fetchrow_hashref){
    my $line=$i+1;
    my $amount=0+$data->{'amountoutstanding'};
    my $itemdata = itemnodata($env,$dbh,$data->{'itemnumber'});
    $line= $data->{'accountno'}." ".$data->{'date'}." ".$data->{'accounttype'}." ";
    my $title = $itemdata->{'title'};
    if (length($title) > 15 ) {$title = substr($title,0,15);}
    $line .= $itemdata->{'barcode'}." $title ".$data->{'description'};
    $line = fmtstr($env,$line,"L65")." ".fmtdec($env,$amount,"52");
    push @accountlines,$line;
    $i++;
  }
  #get amount paid and update database
  my ($data,$reason)=
    &accountsdialog($env,"Payment Entry",$borrower,\@accountlines,$total);
  if ($data>0) {
    &recordpayment($env,$bornumber,$dbh,$data);
    #Check if the borrower still owes
    $total=&checkaccount($env,$bornumber,$dbh);
  }
  return($total);

}

# FIXME - This function is never used. Then again, it's not exported,
# either.
sub recordpayment{
  #here we update both the accountoffsets and the account lines
  my ($env,$bornumber,$dbh,$data)=@_;
  my $updquery = "";
  my $newamtos = 0;
  my $accdata = "";
  my $amountleft = $data;
  # begin transaction
#  my $sth = $dbh->prepare("begin");
#  $sth->execute;
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
#     print $updquery
     $usth->execute;
     $usth->finish;
  }
  # create new line
  #$updquery = "insert into accountlines (borrowernumber,
  #accountno,date,amount,description,accounttype,amountoutstanding) values
  #($bornumber,$nextaccntno,datetime('now'::abstime),0-$data,'Payment,thanks',
  #'Pay',0-$amountleft)";
  $updquery = "insert into accountlines
  (borrowernumber, accountno,date,amount,description,accounttype,amountoutstanding)
  values ($bornumber,$nextaccntno,now(),0-$data,'Payment,thanks',
  'Pay',0-$amountleft)";
  $usth = $dbh->prepare($updquery);
  $usth->execute;
  $usth->finish;
  UpdateStats($env,'branch','payment',$data)
}

=item getnextacctno

  $nextacct = &getnextacctno($env, $borrowernumber, $dbh);

Returns the next unused account number for the patron with the given
borrower number.

C<$dbh> is a DBI::db handle to the Koha database.

C<$env> is ignored.

=cut
# FIXME - Okay, so what does the above actually _mean_?
sub getnextacctno {
  my ($env,$bornumber,$dbh)=@_;
  my $nextaccntno = 1;
  
  my $query = "select max(accountno)+1 from accountlines";
  my $sth = $dbh->prepare($query);
  $sth->execute;
  if (my $accdata=$sth->fetchrow_hashref){
    $nextaccntno = $accdata->{'accountno'} + 1;
  }
  $sth->finish;
  return$nextaccntno;
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 SEE ALSO

C4::Accounts2(3), DBI(3)

=cut
