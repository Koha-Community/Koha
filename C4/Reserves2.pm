# -*- tab-width: 8 -*-
# NOTE: This file uses standard 8-character tabs

package C4::Reserves2;

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
use C4::Search;
	# FIXME - C4::Reserves2 uses C4::Search, which uses C4::Reserves2.
	# So Perl complains that all of the functions here get redefined.
#use C4::Accounts;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Reserves2 - FIXME

=head1 SYNOPSIS

  use C4::Reserves2;

=head1 DESCRIPTION

FIXME

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
# FIXME Take out CalcReserveFee after it can be removed from opac-reserves.pl
@EXPORT = qw(
    &FindReserves
    &CheckReserves
    &CheckWaiting
    &CancelReserve
    &CalcReserveFee
    &FillReserve
    &ReserveWaiting
    &CreateReserve
    &updatereserves
    &UpdateReserve
    &getreservetitle
    &Findgroupreserve
);

# make all your functions, whether exported or not;

=item FindReserves

  ($count, $results) = &FindReserves($biblionumber, $borrowernumber);

Looks books up in the reserves. C<$biblionumber> is the biblionumber
of the book to look up. C<$borrowernumber> is the borrower number of a
patron whose books to look up.

Either C<$biblionumber> or C<$borrowernumber> may be the empty string,
but not both. If both are specified, C<&FindReserves> looks up the
given book for the given patron. If only C<$biblionumber> is
specified, C<&FindReserves> looks up that book for all patrons. If
only C<$borrowernumber> is specified, C<&FindReserves> looks up all of
that patron's reserves. If neither is specified, C<&FindReserves>
barfs.

For each book thus found, C<&FindReserves> checks the reserve
constraints and does something I don't understand.

C<&FindReserves> returns a two-element array:

C<$count> is the number of elements in C<$results>.

C<$results> is a reference-to-array; each element is a
reference-to-hash, whose keys are (I think) all of the fields of the
reserves, borrowers, and biblio tables of the Koha database.

=cut
#'
sub FindReserves {
	my ($bib,$bor)=@_;
	my $dbh = C4::Context->dbh;
	# Find the desired items in the reserves
	my $query="SELECT *,reserves.branchcode,biblio.title AS btitle, reserves.timestamp as rtimestamp FROM reserves,borrowers,biblio ";
	# FIXME - These three bits of SQL seem to contain a fair amount of
	# redundancy. Wouldn't it be better to have a @clauses array, add
	# one or two clauses as necessary, then join(" AND ", @clauses) ?
	# FIXME: not keen on quote() and interpolation either, but it looks safe
	if ($bib ne ''){
		$bib = $dbh->quote($bib);
		if ($bor ne ''){
			# Both $bib and $bor specified
			# Find a particular book for a particular patron
			$bor = $dbh->quote($bor);
			$query .=  " where reserves.biblionumber   = $bib
						and borrowers.borrowernumber = $bor
						and reserves.borrowernumber = borrowers.borrowernumber
						and biblio.biblionumber     = $bib
						and cancellationdate is NULL
						and (found <> 'F' or found is NULL)";
		} else {
			# $bib specified, but not $bor
			# Find a particular book for all patrons
			$query .= " where reserves.borrowernumber = borrowers.borrowernumber
					and biblio.biblionumber     = $bib
					and reserves.biblionumber   = $bib
					and cancellationdate is NULL
					and (found <> 'F' or found is NULL)";
		}
	} else {
		# FIXME - Check that $bor was given
		# No $bib given.
		# Find all books for the given patron.
		$query .= " where borrowers.borrowernumber = $bor
					and reserves.borrowernumber  = borrowers.borrowernumber
					and reserves.biblionumber    = biblio.biblionumber
					and cancellationdate is NULL and
					(found <> 'F' or found is NULL)";
	}
	$query.=" order by priority";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	my @results;
	while (my $data=$sth->fetchrow_hashref){
		# FIXME - What is this if-statement doing? How do constraints work?
		if ($data->{'constrainttype'} eq 'o') {
			my $csth=$dbh->prepare("SELECT biblioitemnumber FROM reserveconstraints
							WHERE biblionumber   = ?
							AND borrowernumber = ?
							AND reservedate    = ?");
			$csth->execute($data->{'biblionumber'}, $data->{'borrowernumber'}, $data->{'reservedate'});
			my ($bibitemno) = $csth->fetchrow_array;
			$csth->finish;
			# Look up the book we just found.
			my $bdata = C4::Search::bibitemdata($bibitemno);
			# Add the results of this latest search to the current
			# results.
			# FIXME - An 'each' would probably be more efficient.
			foreach my $key (keys %$bdata) {
				$data->{$key} = $bdata->{$key};
			}
		}
		push @results, $data;
	}
	$sth->finish;
	return($#results+1,\@results);
}

=item CheckReserves

  ($status, $reserve) = &CheckReserves($itemnumber, $barcode);

Find a book in the reserves.

C<$itemnumber> is the book's item number. C<$barcode> is its barcode.
Either one, but not both, may be false. If both are specified,
C<&CheckReserves> uses C<$itemnumber>.

$itemnubmer can be false, in which case uses the barcode. (Never uses
both. $itemnumber gets priority).

As I understand it, C<&CheckReserves> looks for the given item in the
reserves. If it is found, that's a match, and C<$status> is set to
C<Waiting>.

Otherwise, it finds the most important item in the reserves with the
same biblio number as this book (I'm not clear on this) and returns it
with C<$status> set to C<Reserved>.

C<&CheckReserves> returns a two-element list:

C<$status> is either C<Waiting>, C<Reserved> (see above), or 0.

C<$reserve> is the reserve item that matched. It is a
reference-to-hash whose keys are mostly the fields of the reserves
table in the Koha database.

=cut
#'
sub CheckReserves {
    my ($item, $barcode) = @_;
#    warn "In CheckReserves: itemnumber = $item";
    my $dbh = C4::Context->dbh;
    my $sth;
    if ($item) {
	my $qitem=$dbh->quote($item);
	# Look up the item by itemnumber
	$sth=$dbh->prepare("SELECT items.biblionumber, items.biblioitemnumber, itemtypes.notforloan
                             FROM items, biblioitems, itemtypes
                            WHERE items.biblioitemnumber = biblioitems.biblioitemnumber
                              AND biblioitems.itemtype = itemtypes.itemtype
                              AND itemnumber=$qitem");
    } else {
	my $qbc=$dbh->quote($barcode);
	# Look up the item by barcode
	$sth=$dbh->prepare("SELECT items.biblionumber, items.biblioitemnumber, itemtypes.notforloan
                             FROM items, biblioitems, itemtypes
                            WHERE items.biblioitemnumber = biblioitems.biblioitemnumber
                              AND biblioitems.itemtype = itemtypes.itemtype
                              AND barcode=$qbc");
	# FIXME - This function uses $item later on. Ought to set it here.
    }
    $sth->execute;
    my ($biblio, $bibitem, $notforloan) = $sth->fetchrow_array;
    $sth->finish;
# if item is not for loan it cannot be reserved either.....
    return (0, 0) if ($notforloan);
# get the reserves...
    # Find this item in the reserves
    my ($count, @reserves) = Findgroupreserve($bibitem, $biblio);
    # $priority and $highest are used to find the most important item
    # in the list returned by &Findgroupreserve. (The lower $priority,
    # the more important the item.)
    # $highest is the most important item we've seen so far.
    my $priority = 10000000;
    my $highest;
    if ($count) {
	foreach my $res (@reserves) {
	    # FIXME - $item might be undefined or empty: the caller
	    # might be searching by barcode.
	    if ($res->{'itemnumber'} == $item) {
		# Found it
		return ("Waiting", $res);
	    } else {
		# See if this item is more important than what we've got
		# so far.
		if ($res->{'priority'} != 0 && $res->{'priority'} < $priority) {
		    $priority = $res->{'priority'};
		    $highest = $res;
		}
	    }
	}
    }

    # If we get this far, then no exact match was found. Print the
    # most important item on the list. I think this tells us who's
    # next in line to get this book.
    if ($highest) {	# FIXME - $highest might be undefined
	$highest->{'itemnumber'} = $item;
	return ("Reserved", $highest);
    } else {
	return (0, 0);
    }
}

=item CancelReserve

  &CancelReserve($biblionumber, $itemnumber, $borrowernumber);

Cancels a reserve.

Use either C<$biblionumber> or C<$itemnumber> to specify the item to
cancel, but not both: if both are given, C<&CancelReserve> does
nothing.

C<$borrowernumber> is the borrower number of the patron on whose
behalf the book was reserved.

If C<$biblionumber> was given, C<&CancelReserve> also adjusts the
priorities of the other people who are waiting on the book.

=cut
#'
sub CancelReserve {
    my ($biblio, $item, $borr) = @_;
    my $dbh = C4::Context->dbh;
    #warn "In CancelReserve";
    if (($item and $borr) and (not $biblio)) {
	# removing a waiting reserve record....
	# update the database...
	my $sth = $dbh->prepare("update reserves set cancellationdate = now(),
                                         found            = Null,
                                         priority         = 0
                                   where itemnumber       = ?
                                     and borrowernumber   = ?");
	$sth->execute($item,$borr);
	$sth->finish;
    }
    if (($biblio and $borr) and (not $item)) {

	# removing a reserve record....

	# get the prioritiy on this record....
	my $priority;
	{
	my $sth=$dbh->prepare("SELECT priority FROM reserves
                                    WHERE biblionumber   = ?
                                      AND borrowernumber = ?
                                      AND cancellationdate is NULL
                                      AND (found <> 'F' or found is NULL)");
	$sth->execute($biblio,$borr);
	($priority) = $sth->fetchrow_array;
	$sth->finish;
	}

	# update the database, removing the record...
	{
	my $sth = $dbh->prepare("update reserves set cancellationdate = now(),
                                         found            = Null,
                                         priority         = 0
                                   where biblionumber     = ?
                                     and borrowernumber   = ?
                                     and cancellationdate is NULL
                                     and (found <> 'F' or found is NULL)");
	$sth->execute($biblio,$borr);
	$sth->finish;
	}

	# now fix the priority on the others....
	fixpriority($priority, $biblio);
    }
}

=item FillReserve

  &FillReserve($reserve);

Fill a reserve. If I understand this correctly, this means that the
reserved book has been found and given to the patron who reserved it.

C<$reserve> specifies the reserve to fill. It is a reference-to-hash
whose keys are fields from the reserves table in the Koha database.

=cut
#'
sub FillReserve {
    my ($res) = @_;
    my $dbh = C4::Context->dbh;

    # fill in a reserve record....
    # FIXME - Remove some of the redundancy here
    my $biblio = $res->{'biblionumber'}; my $qbiblio =$biblio;
    my $borr = $res->{'borrowernumber'}; 
    my $resdate = $res->{'reservedate'}; 

    # get the priority on this record....
    my $priority;
    {
    my $query = "SELECT priority FROM reserves
                                WHERE biblionumber   = ?
                                  AND borrowernumber = ?
                                  AND reservedate    = ?";
    my $sth=$dbh->prepare($query);
    $sth->execute($qbiblio,$borr,$resdate);
    ($priority) = $sth->fetchrow_array;
    $sth->finish;
    }

    # update the database...
    {
    my $query = "UPDATE reserves SET found            = 'F',
                                     priority         = 0
                               WHERE biblionumber     = ?
                                 AND reservedate      = ?
                                 AND borrowernumber   = ?";
    my $sth = $dbh->prepare($query);
    $sth->execute($qbiblio,$resdate,$borr);
    $sth->finish;
    }

    # now fix the priority on the others (if the priority wasn't
    # already sorted!)....
    unless ($priority == 0) {
	fixpriority($priority, $biblio);
    }
}

# Only used internally
# Decrements (makes more important) the reserves for all of the
# entries waiting on the given book, if their priority is > $priority.
sub fixpriority {
    my ($priority, $biblio) =  @_;
    my $dbh = C4::Context->dbh;
    my ($count, $reserves) = FindReserves($biblio);
    foreach my $rec (@$reserves) {
	if ($rec->{'priority'} > $priority) {
	    my $sth = $dbh->prepare("UPDATE reserves SET priority = ?
                               WHERE biblionumber     = ?
                                 AND borrowernumber   = ?
                                 AND reservedate      = ?");
	    $sth->execute($rec->{'priority'},$rec->{'biblionumber'},$rec->{'borrowernumber'},$rec->{'reservedate'});
	    $sth->finish;
	}
    }
}

# XXX - POD
sub ReserveWaiting {
    my ($item, $borr) = @_;
    my $dbh = C4::Context->dbh;
# get priority and biblionumber....
    my $sth = $dbh->prepare("SELECT reserves.priority     as priority,
                        reserves.biblionumber as biblionumber,
                        reserves.branchcode   as branchcode,
                        reserves.timestamp     as timestamp
                      FROM reserves,items
                     WHERE reserves.biblionumber   = items.biblionumber
                       AND items.itemnumber        = ?
                       AND reserves.borrowernumber = ?
                       AND reserves.cancellationdate is NULL
                       AND (reserves.found <> 'F' or reserves.found is NULL)");
    $sth->execute($item,$borr);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    my $biblio = $data->{'biblionumber'};
    my $timestamp = $data->{'timestamp'};
# update reserves record....
    $sth = $dbh->prepare("UPDATE reserves SET priority = 0, found = 'W', itemnumber = ?
                            WHERE borrowernumber = ?
                              AND biblionumber = ?
                              AND timestamp = ?");
    $sth->execute($item,$borr,$biblio,$timestamp);
    $sth->finish;
# now fix up the remaining priorities....
    fixpriority($data->{'priority'}, $biblio);
    my $branchcode = $data->{'branchcode'};
    return $branchcode;
}

# XXX - POD
sub CheckWaiting {
    my ($borr)=@_;
    my $dbh = C4::Context->dbh;
    my @itemswaiting;
    my $sth = $dbh->prepare("SELECT * FROM reserves
                         WHERE borrowernumber = ?
                           AND reserves.found = 'W'
                           AND cancellationdate is NULL");
    $sth->execute($borr);
    if (my $data=$sth->fetchrow_hashref) {
	  push(@itemswaiting,$data);
    }
    $sth->finish;
    return (scalar(@itemswaiting),\@itemswaiting);
}

=item Findgroupreserve

  ($count, @results) = &Findgroupreserve($biblioitemnumber, $biblionumber);

I don't know what this does, because I don't understand how reserve
constraints work. I think the idea is that you reserve a particular
biblio, and the constraint allows you to restrict it to a given
biblioitem (e.g., if you want to borrow the audio book edition of "The
Prophet", rather than the first available publication).

C<&Findgroupreserve> returns a two-element array:

C<$count> is the number of elements in C<@results>.

C<@results> is an array of references-to-hash whose keys are mostly
fields from the reserves table of the Koha database, plus
C<biblioitemnumber>.

=cut
#'
sub Findgroupreserve {
  my ($bibitem,$biblio)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("SELECT reserves.biblionumber               AS biblionumber,
                      reserves.borrowernumber             AS borrowernumber,
                      reserves.reservedate                AS reservedate,
                      reserves.branchcode                 AS branchcode,
                      reserves.cancellationdate           AS cancellationdate,
                      reserves.found                      AS found,
                      reserves.reservenotes               AS reservenotes,
                      reserves.priority                   AS priority,
                      reserves.timestamp                  AS timestamp,
                      reserveconstraints.biblioitemnumber AS biblioitemnumber,
                      reserves.itemnumber                 AS itemnumber
                 FROM reserves LEFT JOIN reserveconstraints
                   ON reserves.biblionumber = reserveconstraints.biblionumber
                WHERE reserves.biblionumber = ?
                  AND ( ( reserveconstraints.biblioitemnumber = ?
                      AND reserves.borrowernumber = reserveconstraints.borrowernumber
                      AND reserves.reservedate    =reserveconstraints.reservedate )
                   OR reserves.constrainttype='a' )
                  AND reserves.cancellationdate is NULL
                  AND (reserves.found <> 'F' or reserves.found is NULL)");
  $sth->execute($biblio, $bibitem);
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    push(@results,$data);
  }
  $sth->finish;
  return(scalar(@results),@results);
}

# FIXME - A somewhat different version of this function appears in
# C4::Reserves. Pick one and stick with it.
# XXX - POD
sub CreateReserve {
  my
($env,$branch,$borrnum,$biblionumber,$constraint,$bibitems,$priority,$notes,$title)= @_;
  my $fee=CalcReserveFee($env,$borrnum,$biblionumber,$constraint,$bibitems);
  my $dbh = C4::Context->dbh;
  my $const = lc substr($constraint,0,1);
  my @datearr = localtime(time);
  my $resdate =(1900+$datearr[5])."-".($datearr[4]+1)."-".$datearr[3];
  #eval {
  # updates take place here
  if ($fee > 0) {
#    print $fee;
    my $nextacctno = &getnextacctno($env,$borrnum,$dbh);
    my $usth = $dbh->prepare("insert into accountlines
    (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding)
						          values
    (?,?,now(),?,?,'Res',?)");
    $usth->execute($borrnum,$nextacctno,$fee,'Reserve Charge - $title',$fee);
    $usth->finish;
  }
  #if ($const eq 'a'){
    my $sth = $dbh->prepare("insert into reserves
   (borrowernumber,biblionumber,reservedate,branchcode,constrainttype,priority,reservenotes)
    values (?,?,?,?,?,?,?)");
    $sth->execute($borrnum,$biblionumber,$resdate,$branch,$const,$priority,$notes);
    $sth->finish;
  #}
  if (($const eq "o") || ($const eq "e")) {
    my $numitems = @$bibitems;
    my $i = 0;
    while ($i < $numitems) {
      my $biblioitem = @$bibitems[$i];
      my $sth = $dbh->prepare("insert into
      reserveconstraints
      (borrowernumber,biblionumber,reservedate,biblioitemnumber)
      values (?,?,?,?)");
      $sth->execute($borrnum,$biblionumber,$resdate,$biblioitem);
      $sth->finish;
      $i++;
    }
  }
#  print $query;
  return();
}

# FIXME - A functionally identical version of this function appears in
# C4::Reserves. Pick one and stick with it.
# XXX - Internal use only
# FIXME - opac-reserves.pl need to use it, temporarily put into @EXPORT
sub CalcReserveFee {
  my ($env,$borrnum,$biblionumber,$constraint,$bibitems) = @_;
  #check for issues;
  my $dbh = C4::Context->dbh;
  my $const = lc substr($constraint,0,1);
  my $sth = $dbh->prepare("SELECT * FROM borrowers,categories
                WHERE (borrowernumber = ?)
                  AND (borrowers.categorycode = categories.categorycode)");
  $sth->execute($borrnum);
  my $data = $sth->fetchrow_hashref;
  $sth->finish();
  my $fee = $data->{'reservefee'};
  my $cntitems = @->$bibitems;
  if ($fee > 0) {
    # check for items on issue
    # first find biblioitem records
    my @biblioitems;
    my $sth1 = $dbh->prepare("SELECT * FROM biblio,biblioitems
                   WHERE (biblio.biblionumber = ?)
                     AND (biblio.biblionumber = biblioitems.biblionumber)");
    $sth1->execute($biblionumber);
    while (my $data1=$sth1->fetchrow_hashref) {
      if ($const eq "a") {
        push @biblioitems,$data1;
      } else {
        my $found = 0;
	my $x = 0;
	while ($x < $cntitems) {
          if (@$bibitems->{'biblioitemnumber'} == $data->{'biblioitemnumber'}) {
            $found = 1;
	  }
	  $x++;
	}
	if ($const eq 'o') {
	  if ( $found == 1) {
	    push @biblioitems,$data1;
	  }
        } else {
	  if ($found == 0) {
	    push @biblioitems,$data1;
	  }
	}
      }
    }
    $sth1->finish;
    my $cntitemsfound = @biblioitems;
    my $issues = 0;
    my $x = 0;
    my $allissued = 1;
    while ($x < $cntitemsfound) {
      my $bitdata = $biblioitems[$x];
      my $sth2 = $dbh->prepare("SELECT * FROM items
                     WHERE biblioitemnumber = ?");
      $sth2->execute($bitdata->{'biblioitemnumber'});
      while (my $itdata=$sth2->fetchrow_hashref) {
        my $sth3 = $dbh->prepare("SELECT * FROM issues
                       WHERE itemnumber = ?
                         AND returndate IS NULL");
        $sth3->execute($itdata->{'itemnumber'});
        if (my $isdata=$sth3->fetchrow_hashref) {
	} else {
	  $allissued = 0;
	}
      }
      $x++;
    }
    if ($allissued == 0) {
      my $rsth = $dbh->prepare("SELECT * FROM reserves WHERE biblionumber = ?");
      $rsth->execute($biblionumber);
      if (my $rdata = $rsth->fetchrow_hashref) {
      } else {
        $fee = 0;
      }
    }
  }
#  print "fee $fee";
  return $fee;
}

# XXX - Internal use
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

# XXX - POD
sub updatereserves{
  #subroutine to update a reserve
  my ($rank,$biblio,$borrower,$del,$branch)=@_;
  my $dbh = C4::Context->dbh;
  if ($del == 0){
    my $sth = $dbh->prepare("Update reserves set priority=?,branchcode=? where
    biblionumber=? and borrowernumber=?");
    $sth->execute($rank,$branch,$biblio,$borrower);
    $sth->finish();
  } else {
    my $sth=$dbh->prepare("Select * from reserves where biblionumber=? and
    borrowernumber=?");
    $sth->execute($biblio,$borrower);
    my $data=$sth->fetchrow_hashref;
    $sth->finish();
    $sth=$dbh->prepare("Select * from reserves where biblionumber=? and
    priority > ? and cancellationdate is NULL
    order by priority") || die $dbh->errstr;
    $sth->execute($biblio,$data->{'priority'}) || die $sth->errstr;
    while (my $data=$sth->fetchrow_hashref){
      $data->{'priority'}--;
      my $sth3=$dbh->prepare("Update reserves set priority=?
      where biblionumber=? and borrowernumber=?");
      $sth3->execute($data->{'priority'},$data->{'biblionumber'},$data->{'borrowernumber'}) || die $sth3->errstr;
      $sth3->finish();
    }
    $sth->finish();
    $sth=$dbh->prepare("update reserves set cancellationdate=now() where biblionumber=?
    and borrowernumber=?");
    $sth->execute($biblio,$borrower);
    $sth->finish;
  }
}

# XXX - POD
sub UpdateReserve {
    #subroutine to update a reserve
    my ($rank,$biblio,$borrower,$branch)=@_;
    return if $rank eq "W";
    return if $rank eq "n";
    my $dbh = C4::Context->dbh;
    if ($rank eq "del") {
	my $sth=$dbh->prepare("UPDATE reserves SET cancellationdate=now()
                                   WHERE biblionumber   = ?
                                     AND borrowernumber = ?
	                             AND cancellationdate is NULL
                                     AND (found <> 'F' or found is NULL)");
	$sth->execute($biblio, $borrower);
	$sth->finish;
    } else {
	my $sth=$dbh->prepare("UPDATE reserves SET priority = ? ,branchcode = ?, itemnumber = NULL, found = NULL
                                   WHERE biblionumber   = ?
                                     AND borrowernumber = ?
	                             AND cancellationdate is NULL
                                     AND (found <> 'F' or found is NULL)");
	$sth->execute($rank, $branch, $biblio, $borrower);
	$sth->finish;
    }
}

# XXX - POD
sub getreservetitle {
 my ($biblio,$bor,$date,$timestamp)=@_;
 my $dbh = C4::Context->dbh;
 my $sth=$dbh->prepare("Select * from reserveconstraints,biblioitems where
 reserveconstraints.biblioitemnumber=biblioitems.biblioitemnumber
 and reserveconstraints.biblionumber=? and reserveconstraints.borrowernumber
 = ? and reserveconstraints.reservedate=? and
 reserveconstraints.timestamp=?");
 $sth->execute($biblio,$bor,$date,$timestamp);
 my $data=$sth->fetchrow_hashref;
 $sth->finish;
 return($data);
}
