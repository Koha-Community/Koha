package C4::Circulation::Main;

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

use strict;
require Exporter;
use DBI;
use C4::Context;
use C4::Circulation::Issues;
	# FIXME - C4::Circulation::Main and C4::Circulation::Issues
	# use each other, so functions get redefined.
#use C4::Circulation::Returns;
	# FIXME - C4::Circulation::Main and C4::Circulation::Returns
	# use each other, so functions get redefined.
use C4::Circulation::Renewals;
	# FIXME - C4::Circulation::Main and C4::Circulation::Renewals
	# use each other, so functions get redefined.
use C4::Circulation::Borrower;
	# FIXME - C4::Circulation::Main and C4::Circulation::Borrower
	# use each other, so functions get redefined.
use C4::Reserves;
use C4::Search;
use C4::InterfaceCDK;
use C4::Security;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&pastitems &checkoverdues &previousissue
&checkreserve &checkwaiting &scanbook &scanborrower &getbranch &getprinter);

=head1 NAME

C4::Circulation::Main - Koha circulation desk functions

=head1 SYNOPSIS

  use C4::Circulation::Main;

=head1 DESCRIPTION

This module provides functions useful to the circulation desk,
primarily for checking reserves and overdue items.

=head1 FUNCTIONS

=over 2

=cut

# FIXME - This is only used in C4::Circmain and telnet/startint.pl,
# which look obsolete. Presumably this means this function is obsolete
# as well.
# Otherwise, it needs a POD.
sub getbranch {
  my ($env) = @_;
  my $dbh = C4::Context->dbh;
  my $sth = $dbh->prepare("select * from branches order by branchcode");
  $sth->execute;
  if ($sth->rows>1) {
      my @branches;
      while (my $data = $sth->fetchrow_hashref) {
	push @branches,$data;
      }
      brmenu ($env,\@branches);
  } else {
      my $data = $sth->fetchrow_hashref;
      $env->{'branchcode'}=$data->{'branchcode'};
  }
  $sth = $dbh->prepare("select * from branches
    where branchcode = ?");
  $sth->execute($env->{'branchcode'});
  my $data = $sth->fetchrow_hashref;
  $env->{'brdata'} = $data;
  $env->{'branchname'} = $data->{'branchname'};
  $sth->finish;
}

# FIXME - This is only used in C4::Circmain and telnet/startint.pl,
# which look obsolete. Presumably this means this function is obsolete
# as well.
# Otherwise, it needs a POD.
sub getprinter {
  my ($env) = @_;
  my $dbh = C4::Context->dbh;
  my $sth = $dbh->prepare("select * from printers order by printername");
  $sth->execute;
  if ($sth->rows>1) {
      my @printers;
      while (my $data = $sth->fetchrow_hashref) {
	push @printers,$data;
      }
      prmenu ($env,\@printers);
  } else {
      my $data=$sth->fetchrow_hashref;
      $env->{'queue'}=$data->{'printqueue'};
      $env->{'printtype'}=$data->{'printtype'};
  }
  $sth->finish;
}

# FIXME - This is not the same as &C4::Circulation::pastitems, though
# the two appear to share some code.
# FIXME - This function is called in &C4::Circulation::Issues::Issue
# and in telnet/borrwraper.pl, both of which look obsolete. Presumably
# this means this function is obsolete as well.
# Otherwise, it needs a POD.
sub pastitems{
  #Get list of all items borrower has currently on issue
  my ($env,$bornum,$dbh)=@_;
  my $sth=$dbh->prepare("select * from issues  where (borrowernumber=?)
    and (returndate is null) order by date_due");
  $sth->execute($bornum);
  my $i=0;
  my @items;
  my @items2;
  while (my $data1=$sth->fetchrow_hashref) {
    my $data = itemnodata($env,$dbh,$data1->{'itemnumber'}); #C4::Search
    my @date = split("-",$data1->{'date_due'});
    my $odate = (@date[2]+0)."-".(@date[1]+0)."-".@date[0];
    my $line = C4::Circulation::Issues::formatitem($env,$data,$odate,"");
    $items[$i]=$line;
    $i++;
  }
  $sth->finish();
  return(\@items,\@items2);
}

=item checkoverdues

  $num_items = &checkoverdues($env, $borrowernumber, $dbh);

Returns the number of overdue books a patron has.

C<$env> is ignored.

C<$borrowernumber> is the patron's borrower number.

C<$dbh> is a DBI handle to the Koha database.

=cut
#'
sub checkoverdues{
  #checks whether a borrower has overdue items
  # FIXME - Use C4::Context->dbh instead of getting $dbh as an argument
  my ($env,$bornum,$dbh)=@_;
  my $sth=$dbh->prepare("Select count(*) from issues where borrowernumber=? and
        returndate is NULL and date_due < curdate()");
  $sth->execute($bornum);
  my $data = $sth->fetchrow_hashref;
  $sth->finish;
  return $data->{'count(*)'};
}

# FIXME - This is quite similar to &C4::Circulation::previousissue
# FIXME - Never used. Obsolete, presumably.
# Otherwise, it needs a POD.
sub previousissue {
  my ($env,$itemnum,$dbh,$bornum)=@_;
  my $sth=$dbh->prepare("Select
     firstname,surname,issues.borrowernumber,cardnumber,returndate
     from issues,borrowers where
     issues.itemnumber='$itemnum' and
     issues.borrowernumber=borrowers.borrowernumber
     and issues.returndate is NULL");
  $sth->execute;
  my $borrower=$sth->fetchrow_hashref;
  my $canissue = "Y";
  $sth->finish;
  my $newdate;
  if ($borrower->{'borrowernumber'} ne ''){
    if ($bornum eq $borrower->{'borrowernumber'}){
      # no need to issue
      my ($renewstatus) = C4::Circulation::Renewals::renewstatus($env,$dbh,$bornum,$itemnum);
      my ($resbor,$resrec) = checkreserve($env,$dbh,$itemnum);
      if ($renewstatus == "0") {
        info_msg($env,"</S>Issued to this borrower - No renewals<!S>");
	$canissue = "N";
      } elsif ($resbor ne "") {
        my $resp = C4::InterfaceCDK::msg_ny($env,"Book is issued to this borrower",
	  "and is reserved - Renew?");
        if ($resp eq "Y") {
	  $newdate = C4::Circulation::Renewals::renewbook($env,$dbh,$bornum,$itemnum);
	  $canissue = "R";
	} else {
	  $canissue = "N";
	}
      } else {
        my $resp = C4::InterfaceCDK::msg_yn($env,"Book is issued to this borrower", "Renew?");
        if ($resp eq "Y") {
          $newdate = C4::Circulation::Renewals::renewbook($env,$dbh,$bornum,$itemnum);
     	  $canissue = "R";
        } else {
          $canissue = "N";
        }
      }
    } else {
      my $text="Issued to $borrower->{'firstname'} $borrower->{'surname'} ($borrower->{'cardnumber'})";
      my $resp = C4::InterfaceCDK::msg_yn($env,$text,"Mark as returned?");
      if ( $resp eq "Y") {
        &returnrecord($env,$dbh,$borrower->{'borrowernumber'},$itemnum);
      }	else {
        $canissue = "N";
      }
    }
  }
  return($borrower->{'borrowernumber'},$canissue,$newdate);
}

=item checkreserve

  ($borrowernumber, $reserve) = &checkreserve($env, $dbh, $itemnumber);

C<$env> is ignored.

C<$dbh> is a DBI handle to the Koha database.

C<$itemnumber> is the number of the item to find.

C<&checkreserve> returns two values:

C<$borrowernumber> is the borrower number of the patron for whom the
book is reserved, or the empty string. I can't tell when it returns a
number and when it returns a string, nor what it means.

C<$reserve> describes the reserved item. It is a reference-to-hash
whose keys are the fields of the reserves and items tables of the Koha
database.

=cut
#'
sub checkreserve{
  # Check for reserves for biblio
  # FIXME - Use C4::Context->dbh to get $dbh, instead of passing it
  # on the argument list.
  my ($env,$dbh,$itemnum)=@_;
  my $resbor = "";
  # Find this item in the reserves.
  # Apparently reserves.found=='W' means "Waiting".
  # FIXME - Is it necessary to get every field from both tables?
  my $sth = $dbh->prepare("select * from reserves,items
    where (items.itemnumber = ?)
    and (reserves.cancellationdate is NULL)
    and (items.biblionumber = reserves.biblionumber)
    and ((reserves.found = 'W')
    or (reserves.found is null))
    order by priority");
  $sth->execute($itemnum);
  my $resrec;
  if (my $data=$sth->fetchrow_hashref) {
    $resrec=$data;
    my $const = $data->{'constrainttype'};
    if ($const eq "a") {		# FIXME - What does 'a' mean?
      $resbor = $data->{'borrowernumber'};
    } else {
      my $found = 0;
      my $csth = $dbh->prepare("select * from reserveconstraints,items
         where (borrowernumber=?)
         and reservedate=?
	 and reserveconstraints.biblionumber=?
	 and (items.itemnumber=? and
	 items.biblioitemnumber = reserveconstraints.biblioitemnumber)");
      $csth->execute($data->{'borrowernumber'},$data->{'reservedate'},$data->{'biblionumber'},$itemnum);
      if (my $cdata=$csth->fetchrow_hashref) {$found = 1;}
      if ($const eq 'o') {		# FIXME - What does 'o' mean?
        if ($found eq 1) {$resbor = $data->{'borrowernumber'};}
      } else {
        if ($found eq 0) {$resbor = $data->{'borrowernumber'};}
      }
      $csth->finish();
    }
  }
  $sth->finish;
  return ($resbor,$resrec);
}

# FIXME - This is only used in C4::Circulation::Borrower, which
# appears to be obsolete. Presumably this function is obsolete as
# well. Otherwise, it needs a POD.
sub checkwaiting{
  # check for reserves waiting
  my ($env,$dbh,$bornum)=@_;
  my @itemswaiting;
  my $sth = $dbh->prepare("select * from reserves
    where (borrowernumber = ?)
    and (reserves.found='W') and cancellationdate is NULL");
  $sth->execute($bornum);
  my $cnt=0;
  if (my $data=$sth->fetchrow_hashref) {
    @itemswaiting[$cnt] =$data;
    $cnt ++
  }
  $sth->finish;
  return ($cnt,\@itemswaiting);
}

# FIXME - This is identical to &C4::Circulation::scanbook
# FIXME - This function is only used in tkperl/tkcirc, if anywhere
# (it's hard to tell). Presumably it's obsolete.
# Otherwise, it needs a POD.
sub scanbook {
  my ($env,$interface)=@_;
  #scan barcode
  my ($number,$reason)=dialog("Book Barcode:");
  $number=uc $number;
  return ($number,$reason);
}

# FIXME - This is very similar to &C4::Circulation::scanborrower
# FIXME - This is only used in C4::Circulation::Borrower, which
# appears to be obsolete. Presumably this function is obsolete as
# well.
# Otherwise, it needs a POD.
sub scanborrower {
  my ($env,$interface)=@_;
  #scan barcode
  my ($number,$reason,$book)=C4::InterfaceCDK::borrower_dialog($env); #C4::InterfaceCDK
  $number= $number;		# FIXME - WTF?
  $book=uc $book;
  return ($number,$reason,$book);
}

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
