package C4::Circulation::Fines;

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
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Circulation::Fines - Koha module dealing with fines

=head1 SYNOPSIS

  use C4::Circulation::Fines;

=head1 DESCRIPTION

This module contains several functions for dealing with fines for
overdue items. It is primarily used by the 'misc/fines2.pl' script.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&Getoverdues &CalcFine &BorType &UpdateFine &ReplacementCost);

=item Getoverdues

  ($count, $overdues) = &Getoverdues();

Returns the list of all overdue books.

C<$count> is the number of elements in C<@{$overdues}>.

C<$overdues> is a reference-to-array. Each element is a
reference-to-hash whose keys are the fields of the issues table in the
Koha database.

=cut
#'
sub Getoverdues{
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from issues where date_due < now() and returndate is
  NULL order by borrowernumber");
  $sth->execute;
  # FIXME - Use push @results
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
#  print @results;
  # FIXME - Bogus API.
  return($i,\@results);
}

=item CalcFine

  ($amount, $chargename, $message) =
	&CalcFine($itemnumber, $borrowercode, $days_overdue);

Calculates the fine for a book.

The issuingrules table in the Koha database is a fine matrix, listing
the penalties for each type of patron for each type of item and each branch (e.g., the
standard fine for books might be $0.50, but $1.50 for DVDs, or staff
members might get a longer grace period between the first and second
reminders that a book is overdue).

The fine is calculated as follows: if it is time for the first
reminder, the fine is the value listed for the given (branch, item type,
borrower code) combination. If it is time for the second reminder, the
fine is doubled. Finally, if it is time to send the account to a
collection agency, the fine is set to 5 local monetary units (a really
good deal for the patron if the library is in Italy). Otherwise, the
fine is 0.

Note that the way this function is currently implemented, it only
returns a nonzero value on the notable days listed above. That is, if
the categoryitems entry says to send a first reminder 7 days after the
book is due, then if you call C<&CalcFine> 7 days after the book is
due, it will give a nonzero fine. If you call C<&CalcFine> the next
day, however, it will say that the fine is 0.

C<$itemnumber> is the book's item number.

C<$borrowercode> is the borrower code of the patron who currently has
the book.

C<$days_overdue> is the number of days elapsed since the book's due
date.

C<&CalcFine> returns a list of three values:

C<$amount> is the fine owed by the patron (see above).

C<$chargename> is the chargename field from the applicable record in
the categoryitem table, whatever that is.

C<$message> is a text message, either "First Notice", "Second Notice",
or "Final Notice".

=cut
#'
sub CalcFine {
  my ($itemnumber,$bortype,$difference)=@_;
  my $dbh = C4::Context->dbh;

  # Look up the categoryitem record for this book's item type and the
  # given borrwer type.
  # The reason this query is so messy is that it's a messy question:
  # given the barcode, we can find the book's items record. This gives
  # us the biblioitems record, which gives us a set of categoryitem
  # records. Then we select the one that corresponds to the desired
  # borrower type.

  # FIXME - Is it really necessary to get absolutely everything from
  # all four tables? It looks as if this code only wants
  # firstremind, chargeperiod, accountsent, and chargename from the
  # categoryitem table.

  my $sth=$dbh->prepare("Select * from items,biblioitems,itemtypes,categoryitem where items.itemnumber=?
  and items.biblioitemnumber=biblioitems.biblioitemnumber and
  biblioitems.itemtype=itemtypes.itemtype and
  categoryitem.itemtype=itemtypes.itemtype and
  categoryitem.categorycode='?' and (items.itemlost <> 1 or items.itemlost is NULL)");
#  print $query;
  $sth->execute($itemnumber,$bortype);
  my $data=$sth->fetchrow_hashref;
	# FIXME - Error-checking: the item might be lost, or there
	# might not be an entry in 'categoryitem' for this item type
	# or borrower type.
  $sth->finish;
  my $amount=0;
  my $printout;

  # Is it time to send out the first reminder?
  # FIXME - I'm not sure the "=="s are correct here. Let's say that
  # $data->{firstremind} is today, but 'fines2.pl' doesn't run for
  # some reason (the cron daemon died, the server crashed, the
  # sysadmin had the machine down for maintenance, or whatever).
  #
  # Then the next day, the book is $data->{firstremind}+1 days
  # overdue. But this function returns $amount == 0, $printout ==
  # undef, on the assumption that 'fines2.pl' ran the previous day. So
  # the first thing the patron gets is a second notice, but that's a
  # week after the server crash, so people may not connect the two
  # events.
  if ($difference == $data->{'firstremind'}){
    # Yes. Set the fine as listed.
    $amount=$data->{'fine'};
    $printout="First Notice";
  }

  # Is it time to send out a second reminder?
  my $second=$data->{'firstremind'}+$data->{'chargeperiod'};
  if ($difference == $second){
    # Yes. The fine is double.
    $amount=$data->{'fine'}*2;
    $printout="Second Notice";
  }

  # Is it time to send the account to a collection agency?
  # FIXME - At least, I *think* that's what this code is doing.
  if ($difference == $data->{'accountsent'} && $data->{'fine'} > 0){
    # Yes. Set the fine at 5 local monetary units.
    # FIXME - This '5' shouldn't be hard-wired.
    $amount=5;
    $printout="Final Notice";
  }
  return($amount,$data->{'chargename'},$printout);
}

=item UpdateFine

  &UpdateFine($itemnumber, $borrowernumber, $amount, $type, $description);

(Note: the following is mostly conjecture and guesswork.)

Updates the fine owed on an overdue book.

C<$itemnumber> is the book's item number.

C<$borrowernumber> is the borrower number of the patron who currently
has the book on loan.

C<$amount> is the current amount owed by the patron.

C<$type> will be used in the description of the fine.

C<$description> is a string that must be present in the description of
the fine. I think this is expected to be a date in DD/MM/YYYY format.

C<&UpdateFine> looks up the amount currently owed on the given item
and sets it to C<$amount>, creating, if necessary, a new entry in the
accountlines table of the Koha database.

=cut
#'
# FIXME - This API doesn't look right: why should the caller have to
# specify both the item number and the borrower number? A book can't
# be on loan to two different people, so the item number should be
# sufficient.
sub UpdateFine {
  my ($itemnum,$bornum,$amount,$type,$due)=@_;
  my $dbh = C4::Context->dbh;
  # FIXME - What exactly is this query supposed to do? It looks up an
  # entry in accountlines that matches the given item and borrower
  # numbers, where the description contains $due, and where the
  # account type has one of several values, but what does this _mean_?
  # Does it look up existing fines for this item?
  # FIXME - What are these various account types? ("FU", "O", "F", "M")
  my $sth=$dbh->prepare("Select * from accountlines where itemnumber=? and
  borrowernumber=? and (accounttype='FU' or accounttype='O' or
  accounttype='F' or accounttype='M') and description like ?");
  $sth->execute($itemnum,$bornum,"%$due%");

  if (my $data=$sth->fetchrow_hashref){
    # I think this if-clause deals with the case where we're updating
    # an existing fine.
#    print "in accounts ...";
    if ($data->{'amount'} != $amount){

#      print "updating";
      my $diff=$amount - $data->{'amount'};
      my $out=$data->{'amountoutstanding'}+$diff;
      my $sth2=$dbh->prepare("update accountlines set date=now(), amount=?,
      amountoutstanding=?,accounttype='FU' where
      borrowernumber=? and itemnumber=?
      and (accounttype='FU' or accounttype='O') and description like ?");
      $sth2->execute($amount,$out,$data->{'borrowernumber'},$data->{'itemnumber'},"%$due%");
      $sth2->finish;
    } else {
#      print "no update needed $data->{'amount'}"
    }
  } else {
    # I think this else-clause deals with the case where we're adding
    # a new fine.
    my $sth4=$dbh->prepare("select title from biblio,items where items.itemnumber=?
    and biblio.biblionumber=items.biblionumber");
    $sth4->execute($itemnum);
    my $title=$sth4->fetchrow_hashref;
    $sth4->finish;
 #   print "not in account";
    my $sth3=$dbh->prepare("Select max(accountno) from accountlines");
    $sth3->execute;
    # FIXME - Make $accountno a scalar.
    my @accountno=$sth3->fetchrow_array;
    $sth3->finish;
    $accountno[0]++;
    my $sth2=$dbh->prepare("Insert into accountlines
    (borrowernumber,itemnumber,date,amount,
    description,accounttype,amountoutstanding,accountno) values
    (?,?,now(),?,?,'FU',?,?)");
    $sth2->execute($bornum,$itemnum,$amount,"$type $title->{'title'} $due",$amount,$accountno[0]);
    $sth2->finish;
  }
  $sth->finish;
}

=item BorType

  $borrower = &BorType($borrowernumber);

Looks up a patron by borrower number.

C<$borrower> is a reference-to-hash whose keys are all of the fields
from the borrowers and categories tables of the Koha database. Thus,
C<$borrower> contains all information about both the borrower and
category he or she belongs to.

=cut
#'
sub BorType {
  my ($borrowernumber)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from borrowers,categories where
  borrowernumber=? and
borrowers.categorycode=categories.categorycode");
  $sth->execute($borrowernumber);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

=item ReplacementCost

  $cost = &ReplacementCost($itemnumber);

Returns the replacement cost of the item with the given item number.

=cut
#'
sub ReplacementCost{
  my ($itemnum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select replacementprice from items where itemnumber=?");
  $sth->execute($itemnum);
  # FIXME - Use fetchrow_array or something.
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data->{'replacementprice'});
}

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
