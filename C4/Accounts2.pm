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
use C4::Members;
use C4::Circulation::Circ2;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;        # FIXME - Should probably be different from
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
@EXPORT = qw( 
&getnextacctno);

# FIXME - Never used
sub displayaccounts{
  my ($env)=@_;
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


# FIXME - Never used, but not exported, either.
sub returnlost{
  my ($borrnum,$itemnum)=@_;
  my $dbh = C4::Context->dbh;
  my $borrower=borrdata('',$borrnum);
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


# fixcredit
# $amountleft = &fixcredit($env, $bornumber, $data, $barcode, $type, $user);
#
# This function is only used internally.
# FIXME - Figure out what this function does, and write it down.
sub fixcredit{
  #here we update both the accountoffsets and the account lines
  my ($env,$bornumber,$data,$barcode,$type,$user)=@_;
  my $dbh = C4::Context->dbh;
  my $newamtos = 0;
  my $accdata = "";
  my $amountleft = $data;
  if ($barcode ne ''){
    my $item=getiteminformation($env,'',$barcode);
    my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
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
    $sth->execute($bornumber,$item->{'itemnumber'});
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
     $usth->execute($newamtos,$bornumber,$thisacct);
     $usth->finish;
     $usth = $dbh->prepare("insert into accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values (?,?,?,?)");
     $usth->execute($bornumber,$accdata->{'accountno'},$nextaccntno,$newamtos);
     $usth->finish;
  }
  # begin transaction
  my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
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
     $usth = $dbh->prepare("insert into accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values (?,?,?,?)");
     $usth->execute($bornumber,$accdata->{'accountno'},$nextaccntno,$newamtos);
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
  my $newamtos = 0;
  my $accdata = "";
#  my $branch=$env->{'branchcode'};
  my $amountleft = $data *-1;

  # begin transaction
  my $nextaccntno = getnextacctno($env,$bornumber,$dbh);
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
     $usth = $dbh->prepare("insert into accountoffsets
     (borrowernumber, accountno, offsetaccount,  offsetamount)
     values (?,?,?,?)");
     $usth->execute($bornumber,$accdata->{'accountno'},$nextaccntno,$newamtos);
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

