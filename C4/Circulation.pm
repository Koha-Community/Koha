package C4::Circulation;

# $Id$

#package to deal with circulation


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

# FIXME - This package is never used. Is it obsolete?

use strict;
require Exporter;
use DBI;
use C4::Circulation::Issues;
use C4::Circulation::Returns;
use C4::Circulation::Renewals;
use C4::Circulation::Borrower;
use C4::Reserves;
#use C4::Interface;
use C4::Security;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&Start_circ &scanborrower);

sub Start_circ{
  my ($env)=@_;
  #connect to database
  #start interface
  &startint($env,'Circulation');
  my $donext = 'Circ';
  my $reason;
  my $data;
  while ($donext ne 'Quit') {
    if ($donext  eq "Circ") {
      clearscreen();
      ($reason,$data) = menu($env,'console','Circulation',
        ('Issues','Returns','Borrower Enquiries','Reserves','Log In'));
      #debug_msg($env,"data = $data");
    } else {
      $data = $donext;
    }
    if ($data eq 'Issues') {
      $donext=Issue($env); #C4::Circulation::Issues
      #debug_msg("","do next $donext");
    } elsif ($data eq 'Returns') {
      $donext=Returns($env); #C4::Circulation::Returns
    } elsif ($data eq 'Borrower Enquiries'){
      $donext=Borenq($env); #C4::Circulation::Borrower
    } elsif ($data eq 'Reserves'){
      $donext=EnterReserves($env); #C4::Reserves
    } elsif ($data eq 'Log In') {
      &endint($env);
      &Login($env);   #C4::Security
      &startint($env,'Circulation');
    } elsif ($data eq 'Quit') {
      $donext = $data;
    }
    #debug_msg($env,"donext -  $donext");
  }
  &endint($env)
}

# Not exported.
# FIXME - This is not the same as &C4::Circulation::Main::pastitems,
# though the two appear to share some code.
sub pastitems{
  #Get list of all items borrower has currently on issue
  my ($env,$bornum,$dbh)=@_;
  my $sth=$dbh->prepare("Select * from issues,items,biblio
    where borrowernumber=$bornum and issues.itemnumber=items.itemnumber
    and items.biblionumber=biblio.biblionumber
    and returndate is null
    order by date_due");
  $sth->execute;
  my $i=0;
  my @items;
  my @items2;
  #$items[0]=" "x29;
  #$items2[0]=" "x29;
  $items[0]=" "x72;
  $items2[0]=" "x72;
  while (my $data=$sth->fetchrow_hashref) {
     my $line = "$data->{'date_due'} $data->{'title'}";
     # $items[$i]=fmtstr($env,$line,"L29");
     $items[$i]=fmtstr($env,$line,"L72");
     $i++;
  }
  return(\@items,\@items2);
  $sth->finish;
}

sub checkoverdues{
  #checks whether a borrower has overdue items
  my ($env,$bornum,$dbh)=@_;
  my $sth=$dbh->prepare("Select * from issues,items,biblio where
  borrowernumber=$bornum and issues.itemnumber=items.itemnumber and
  items.biblionumber=biblio.biblionumber");
  $sth->execute;
  my $row=1;
  my $col=40;
  while (my $data=$sth->fetchrow_hashref){
    output($row,$col,$data->{'title'});
    $row++;
  }
  $sth->finish;
}

# FIXME - This is quite similar to &C4::Circulation::Main::previousissue
# FIXME - Never used. Obsolete, presumably.
sub previousissue {
  my ($env,$itemnum,$dbh,$bornum)=@_;
  my $sth=$dbh->prepare("Select firstname,surname,issues.borrowernumber,cardnumber,returndate
  from issues,borrowers where
  issues.itemnumber='$itemnum' and
  issues.borrowernumber=borrowers.borrowernumber and issues.returndate is
NULL");
  $sth->execute;
  my $borrower=$sth->fetchrow_hashref;
  $sth->finish;
  if ($borrower->{'borrowernumber'} ne ''){
    if ($bornum eq $borrower->{'borrowernumber'}){
      # no need to issue
      my ($renewstatus) = &renewstatus($env,$dbh,$bornum,$itemnum);
      my $resp = &msg_yn("Book is issued to this borrower", "Renew?");
      if ($resp == "y") {
        &renewbook($env,$dbh,$bornum,$itemnum);
      }

    } else {
      my $text="Issued to $borrower->{'firstname'} $borrower->{'surname'} ($borrower->{'cardnumber'})";
      my $resp = &msg_yn($text,"Mark as returned?");
      if ($resp == "y") {
        &returnrecord($env,$dbh,$borrower->{'borrowernumber'},$itemnum);
	# can issue
      } else {
        # can't issue
      }
    }
  }
  return($borrower->{'borrowernumber'});
  $sth->finish;
}


sub checkreserve{
  # Check for reserves for biblio
  # does not look at constraints yet
  my ($env,$dbh,$itemnum)=@_;
  my $resbor = "";
  my $sth = $dbh->prepare("select * from reserves,items
  where (items.itemnumber = ?)
  and (items.biblionumber = reserves.biblionumber)
  and (reserves.found is null) order by priority");
  $sth->execute($itemnum);
  if (my $data=$sth->fetchrow_hashref) {
    $resbor = $data->{'borrowernumber'};
  }
  $sth->finish;
  return ($resbor);
}

sub checkwaiting{
  # check for reserves waiting
  my ($env,$dbh,$bornum)=@_;
  my @itemswaiting="";
  my $sth = $dbh->prepare("select * from reserves where (borrowernumber = ?) and (reserves.found='W')");
  $sth->execute($bornum);
  if (my $data=$sth->fetchrow_hashref) {
    push @itemswaiting,$data->{'itemnumber'};
  }
  $sth->finish;
  return (\@itemswaiting);
}

# FIXME - This is identical to &C4::Circulation/Main::scanbook
sub scanbook {
  my ($env,$interface)=@_;
  #scan barcode
  my ($number,$reason)=dialog("Book Barcode:");
  $number=uc $number;
  return ($number,$reason);
}

# FIXME - This is very similar to &C4::Circulation::Main::scanborrower
sub scanborrower {
  my ($env,$interface)=@_;
  #scan barcode
  my ($number,$reason,$book)=&borrower_dialog($env); #C4::Interface
  $number= $number;		# FIXME - WTF?
  $book=uc $book;
  return ($number,$reason,$book);
}
