package C4::Circulation::Borrower;

# $Id$

#package to deal with Issues
#written 3/11/99 by chris@katipo.co.nz


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

# FIXME - This module is never used. Obsolete?

use strict;
require Exporter;
use DBI;
use C4::Context;
use C4::Accounts;
use C4::InterfaceCDK;
use C4::Interface::FlagsCDK;
use C4::Circulation::Main;
	# FIXME - C4::Circulation::Main and C4::Circulation::Borrower
	# use each other, so functions get redefined.
use C4::Circulation::Issues;
	# FIXME - C4::Circulation::Issues and C4::Circulation::Borrower
	# use each other, so functions get redefined.
use C4::Circulation::Renewals;
use C4::Scan;
use C4::Search;
use C4::Stats;
use C4::Format;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&findborrower &Borenq &findoneborrower &NewBorrowerNumber
&findguarantees);

sub findborrower  {
  my ($env,$dbh) = @_;
  C4::InterfaceCDK::helptext('');	# FIXME - This looks useless
  C4::InterfaceCDK::clearscreen();
  my $bornum = "";
  my $sth = "";
  my $borcode = "";
  my $borrower;
  my $reason = "";
  my $book;
  while (($bornum eq '') && ($reason eq "")) {
    #get borrowerbarcode from scanner
    my $title = C4::InterfaceCDK::titlepanel($env,$env->{'sysarea'},"Borrower Entry");
    if ($env->{'newborrower'} eq "") {
      ($borcode,$reason,$book)=&C4::Circulation::Main::scanborrower($env);
    } else {
      $borcode = $env->{'newborrower'};
      $reason = "";
      $book = "";
      $env->{'newborrower'}= "";
    }
    #C4::Circulation::Main
    if ($reason eq "") {
      if ($borcode ne '') {
        ($bornum,$borrower) = findoneborrower($env,$dbh,$borcode);
        $env->{'IssuesAllowed'} = 1;
      } elsif ($book ne "") {
        my $iss_sth=$dbh->prepare("select * from issues,items where (barcode = ?)
          and (items.itemnumber = issues.itemnumber)
          and (issues.returndate is null)");
        $iss_sth->execute($book);
        if (my $issdata  = $iss_sth->fetchrow_hashref) {
           $bornum=$issdata->{'borrowernumber'};
	   $sth = $dbh->prepare("Select * from borrowers
	     where borrowernumber =  '$bornum'");
	   $sth->execute;
	   $borrower=$sth->fetchrow_hashref;
	   $sth->finish;
         } else {
           error_msg($env,"Item $book not found");
         }
	 $iss_sth->finish;
      }
    }
  }
  my ($issuesallowed,$owing);
  if ($reason eq "") {
    $env->{'bornum'} = $bornum;
    $env->{'bcard'} = $borrower->{'cardnumber'};
    my $borrowers=join(' ',($borrower->{'title'},$borrower->{'firstname'},$borrower->{'surname'}));
    my $odues;
    ($issuesallowed,$odues,$owing) = &checktraps($env,$dbh,$bornum,$borrower);
#    error_msg ($env,"bcard =  $env->{'bcard'}");
  }
  #debug_msg ($env,"2 =  $env->{'IssuesAllowed'}");
  return ($bornum, $issuesallowed,$borrower,$reason,$owing);
};


sub findoneborrower {
  #  output(1,1,$borcode);
  my ($env,$dbh,$borcode)=@_;
  my $bornum;
  my $borrower;
  my $ucborcode = uc $borcode;
  my $lcborcode = lc $borcode;
  my $sth=$dbh->prepare("Select * from borrowers where cardnumber=?");
  $sth->execute($ucborcode);
  if ($borrower=$sth->fetchrow_hashref) {
    $bornum=$borrower->{'borrowernumber'};
    $sth->finish;
  } else {
    $sth->finish;
    # my $borquery = "Select * from borrowers
    # where surname ~* '$borcode' order by surname";

    my $sthb =$dbh->prepare("Select * from borrowers where lower(surname) like ? order by surname,firstname");
    $sthb->execute("$lcborcode%");
    my $cntbor = 0;
    my @borrows;
    my @bornums;
    while ($borrower= $sthb->fetchrow_hashref) {
      my $line = $borrower->{'cardnumber'}.' '.$borrower->{'categorycode'}.' '.$borrower->{'surname'}.
        ', '.$borrower->{'othernames'};
      $borrows[$cntbor] = fmtstr($env,$line,"L50");
      $bornums[$cntbor] =$borrower->{'borrowernumber'};
      $cntbor++;
    }
    if ($cntbor == 1)  {
      $bornum = $bornums[0];
      my $query = "select * from borrowers where borrowernumber = '$bornum'";
      $sth = $dbh->prepare($query);
      $sth->execute;
      $borrower =$sth->fetchrow_hashref;
      $sth->finish;
    } elsif ($cntbor > 0) {
      my ($cardnum) = C4::InterfaceCDK::selborrower($env,$dbh,\@borrows,\@bornums);
      $sth = $dbh->prepare("select * from borrowers where cardnumber = ?");
      $sth->execute($cardnum);
      $borrower =$sth->fetchrow_hashref;
      $sth->finish;
      $bornum=$borrower->{'borrowernumber'};
      #C4::InterfaceCDK::clearscreen();
      if ($bornum eq '') {
        error_msg($env,"Borrower not found");
      }
    }
  }
  return ($bornum,$borrower);
}
sub checktraps {
  my ($env,$dbh,$bornum,$borrower) = @_;
  my $issuesallowed = "1";
  #my @traps_set;
  #check amountowing
  my $traps_done;
  my $odues;
  my $amount;
  while ($traps_done ne "DONE") {
    my @traps_set;
    $amount=C4::Accounts::checkaccount($env,$bornum,$dbh);    #from C4::Accounts
    if ($amount > 0) { push (@traps_set,"CHARGES");}
    if ($borrower->{'gonenoaddress'} == 1){ push (@traps_set,"GNA");}
    #check if member has a card reported as lost
    if ($borrower->{'lost'} ==1){push (@traps_set,"LOST");}
    #check the notes field if notes exist display them
    if ($borrower->{'borrowernotes'} ne ''){ push (@traps_set,"NOTES");}
    #check if borrower has overdue items
    #call overdue checker
    my $odues = &C4::Circulation::Main::checkoverdues($env,$bornum,$dbh);
    if ($odues > 0) {push (@traps_set,"ODUES");}
    #check if borrower has any items waiting
    my ($nowaiting,$itemswaiting) = &C4::Circulation::Main::checkwaiting($env,$dbh,$bornum);
    if ($nowaiting > 0) { push (@traps_set,"WAITING"); }
    # FIXME - This should be $traps_set[0], right?
    if (@traps_set[0] ne "" ) {
      ($issuesallowed,$traps_done,$amount,$odues) =
         process_traps($env,$dbh,$bornum,$borrower,
	 $amount,$odues,\@traps_set,$itemswaiting);
    } else {
      $traps_done = "DONE";
    }
  }
  return ($issuesallowed, $odues,$amount);
}

sub process_traps {
  my ($env,$dbh,$bornum,$borrower,$amount,$odues,$traps_set,$waiting) = @_;
  my $issuesallowed = 1;
  my $x = 0;
  my %traps;
  while (@$traps_set[$x] ne "") {
    $traps{@$traps_set[$x]} = 1;
    $x++;
  }
  my $traps_done;
  my $trapact;
  my $issues;
  while ($trapact ne "NONE") {
    $trapact = &trapscreen($env,$bornum,$borrower,$amount,$traps_set);
    if ($trapact eq "CHARGES") {
      C4::Accounts::reconcileaccount($env,$dbh,$bornum,$amount,$borrower,$odues);
      ($odues,$issues,$amount)=borrdata2($env,$bornum);
      if ($amount <= 0) {
        $traps{'CHARGES'} = 0;
        my @newtraps;
	$x =0;
        while ($traps_set->[$x] ne "") {
	  if ($traps_set->[$x] ne "CHARGES") {
            push @newtraps,$traps_set->[$x];
	  }
	  $x++;
        }
	$traps_set = \@newtraps;
      }
    } elsif ($trapact eq "WAITING") {
      reserveslist($env,$borrower,$amount,$odues,$waiting);
    } elsif ($trapact eq "ODUES") {
      C4::Circulation::Renewals::bulkrenew($env,$dbh,$bornum,$amount,$borrower,$odues);
      ($odues,$issues,$amount)=borrdata2($env,$bornum);
      if ($odues == 0) {
        $traps{'ODUES'} = 0;
        my @newtraps;
	$x =0;
        while ($traps_set->[$x] ne "") {
          if ($traps_set->[$x] ne "ODUES") {
            push @newtraps,$traps_set->[$x];
          }
          $x++;
        }
        $traps_set = \@newtraps;
      }
    } elsif  ($trapact eq "NOTES") {
      my $notes = trapsnotes($env,$bornum,$borrower,$amount);
      if ($notes ne $borrower->{'borrowernotes'}) {
        my $sth = $dbh->prepare("update borrowers set borrowernotes = ? where borrowernumber = ?");
		$sth->execute($notes,$bornum);
		$sth->finish();
        $borrower->{'borrowernotes'} = $notes;
      }
      if ($notes eq "") {
        $traps{'NOTES'} = 0;
	my @newtraps;
	$x =0;
	while ($traps_set->[$x] ne "") {
	  if ($traps_set->[$x] ne "NOTES") {
	    push @newtraps,$traps_set->[$x];
	  }
	  $x++;
        }
        $traps_set = \@newtraps;
      }
    }
    my $notr = @$traps_set;
    if ($notr == 0) {
      $trapact = "NONE";
    }
    $traps_done = "DONE";
  }
  if ($traps{'GNA'} eq 1 ) {
    $issuesallowed=0;
    $env->{'IssuesAllowed'} = 0;
  }
  if ($traps{'CHARGES'} eq 1) {
    if ($amount > 5) {
      $env->{'IssuesAllowed'} = 0;
      $issuesallowed=0;
    }
  }
  return ($issuesallowed,$traps_done,$amount,$odues);
} # end of process_traps

sub Borenq {
  my ($env)=@_;
  my $dbh = C4::Context->dbh;
  #get borrower guff
  my $bornum;
  my $issuesallowed;
  my $borrower;
  my $reason;
  $env->{'sysarea'} = "Enquiries";
  while ($reason eq "") {
    $env->{'sysarea'} = "Enquiries";
    ($bornum,$issuesallowed,$borrower,$reason) = &findborrower($env,$dbh);
    if ($reason eq "") {
      my ($data,$reason)=&borrowerwindow($env,$borrower);
      if ($reason eq 'Modify'){
        modifyuser($env,$borrower);
        $reason = "";
      } elsif ($reason eq 'New'){
        $reason = "";
       }
    }
  }
  return $reason;
}

sub modifyuser {
  my ($env,$borrower) = @_;
  debug_msg($env,"Please use intranet");
  #return;
}

sub reserveslist {
  my ($env,$borrower,$amount,$odues,$waiting) = @_;
  my $dbh = C4::Context->dbh;
  my @items;
  my $x=0;
  my $sth=$dbh->prepare("Select * from reserves where
  borrowernumber=? and found='W' and
  cancellationdate is null order by timestamp");
  $sth->execute($borrower->{'borrowernumber'});
  while (my $data=$sth->fetchrow_hashref){
    my $itemdata = itemnodata($env,$dbh,$data->{'itemnumber'});
    if ($itemdata){
      push @items,$itemdata;
    }
  }
  $sth->finish;
  reservesdisplay($env,$borrower,$amount,$odues,\@items);
}

=item NewBorrowerNumber

  $num = &NewBorrowerNumber();

Allocates a new, unused borrower number, and returns it.

=cut
#'
# FIXME - This is identical to C4::Search::NewBorrowerNumber.
# Pick one (preferably this one) and stick with it.

# FIXME - Race condition: this function just says what the next unused
# number is, but doesn't allocate it. Hence, two clients adding
# patrons at the same time could get the same new borrower number and
# clobber each other.
# A better approach might be to change the database to make
# borrowers.borrowernumber a unique key and auto_increment. Then, to
# allocate a new borrower number, use "insert" to create a new record
# (leaving the database daemon with the job of serializing requests),
# and use the newly-created record.

sub NewBorrowerNumber {
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select max(borrowernumber) from borrowers");
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $data->{'max(borrowernumber)'}++;
  return($data->{'max(borrowernumber)'});
}

sub findguarantees{
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select cardnumber,borrowernumber from borrowers where
  guarantor=?");
  $sth->execute($bornum);
  my @dat;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $dat[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@dat);
}
