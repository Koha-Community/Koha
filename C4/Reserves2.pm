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
@EXPORT = qw(&FindReserves &CheckReserves &CheckWaiting &CancelReserve &FillReserve &ReserveWaiting &CreateReserve &updatereserves &UpdateReserve &getreservetitle &Findgroupreserve);

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
  my $query="SELECT *,reserves.branchcode,biblio.title AS btitle
                      FROM reserves,borrowers,biblio ";
  # FIXME - These three bits of SQL seem to contain a fair amount of
  # redundancy. Wouldn't it be better to have a @clauses array, add
  # one or two clauses as necessary, then join(" AND ", @clauses) ?
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
  # FIXME - $i is unnecessary and bogus
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
      # FIXME - What is this if-statement doing? How do constraints work?
      if ($data->{'constrainttype'} eq 'o') {
	  my $conquery = "SELECT biblioitemnumber FROM reserveconstraints
                           WHERE biblionumber   = ?
                             AND borrowernumber = ?
                             AND reservedate    = ?";
	  my $csth=$dbh->prepare($conquery);
	  # FIXME - Why use separate variables for this?
	  my $bibn = $data->{'biblionumber'};
	  my $born = $data->{'borrowernumber'};
	  my $resd = $data->{'reservedate'};
	  $csth->execute($bibn, $born, $resd);
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
      $results[$i]=$data;		# FIXME - Use push @results
      $i++;
  }
#  print $query;
  $sth->finish;
  return($i,\@results);
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
	$item = $dbh->quote($item);
	$borr = $dbh->quote($borr);
	# update the database...
	# FIXME - Use $dbh->do()
        my $query = "update reserves set cancellationdate = now(),
                                         found            = Null,
                                         priority         = 0
                                   where itemnumber       = $item
                                     and borrowernumber   = $borr";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	$sth->finish;
    }
    if (($biblio and $borr) and (not $item)) {

	# removing a reserve record....
	my $q_biblio = $dbh->quote($biblio);
	$borr = $dbh->quote($borr);

	# get the prioritiy on this record....
	my $priority;
	{
	my $query = "SELECT priority FROM reserves
                                    WHERE biblionumber   = $q_biblio
                                      AND borrowernumber = $borr
                                      AND cancellationdate is NULL
                                      AND (found <> 'F' or found is NULL)";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	($priority) = $sth->fetchrow_array;
	$sth->finish;
	}

	# update the database, removing the record...
	{
        my $query = "update reserves set cancellationdate = now(),
                                         found            = Null,
                                         priority         = 0
                                   where biblionumber     = $q_biblio
                                     and borrowernumber   = $borr
                                     and cancellationdate is NULL
                                     and (found <> 'F' or found is NULL)";
	my $sth = $dbh->prepare($query);
	$sth->execute;
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
    my $biblio = $res->{'biblionumber'}; my $qbiblio = $dbh->quote($biblio);
    my $borr = $res->{'borrowernumber'}; $borr = $dbh->quote($borr);
    my $resdate = $res->{'reservedate'}; $resdate = $dbh->quote($resdate);

    # get the priority on this record....
    my $priority;
    {
    my $query = "SELECT priority FROM reserves
                                WHERE biblionumber   = $qbiblio
                                  AND borrowernumber = $borr
                                  AND reservedate    = $resdate)";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    ($priority) = $sth->fetchrow_array;
    $sth->finish;
    }

    # update the database...
    {
    my $query = "UPDATE reserves SET found            = 'F',
                                     priority         = 0
                               WHERE biblionumber     = $qbiblio
                                 AND reservedate      = $resdate
                                 AND borrowernumber   = $borr";
    my $sth = $dbh->prepare($query);
    $sth->execute;
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
	    # FIXME - Rewrite this without so much duplication and
	    # redundancy
	    my $newpr = $rec->{'priority'};      $newpr = $dbh->quote($newpr - 1);
	    my $nbib = $rec->{'biblionumber'};   $nbib = $dbh->quote($nbib);
	    my $nbor = $rec->{'borrowernumber'}; $nbor = $dbh->quote($nbor);
	    my $nresd = $rec->{'reservedate'};   $nresd = $dbh->quote($nresd);
            my $query = "UPDATE reserves SET priority = $newpr
                               WHERE biblionumber     = $nbib
                                 AND borrowernumber   = $nbor
                                 AND reservedate      = $nresd";
	    #warn $query;
	    my $sth = $dbh->prepare($query);
	    $sth->execute;
	    $sth->finish;
	}
    }
}

# XXX - POD
sub ReserveWaiting {
    my ($item, $borr) = @_;
    my $dbh = C4::Context->dbh;
    $item = $dbh->quote($item);
    $borr = $dbh->quote($borr);
# get priority and biblionumber....
    my $query = "SELECT reserves.priority     as priority,
                        reserves.biblionumber as biblionumber,
                        reserves.branchcode   as branchcode,
                        reserves.timestamp     as timestamp
                      FROM reserves,items
                     WHERE reserves.biblionumber   = items.biblionumber
                       AND items.itemnumber        = $item
                       AND reserves.borrowernumber = $borr
                       AND reserves.cancellationdate is NULL
                       AND (reserves.found <> 'F' or reserves.found is NULL)";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    my $biblio = $data->{'biblionumber'};
    my $timestamp = $data->{'timestamp'};
    my $q_biblio = $dbh->quote($biblio);
    my $q_timestamp = $dbh->quote($timestamp);
    warn "Timestamp: ".$timestamp."\n";
# update reserves record....
    $query = "UPDATE reserves SET priority = 0, found = 'W', itemnumber = $item
                            WHERE borrowernumber = $borr
                              AND biblionumber = $q_biblio
                              AND timestamp = $q_timestamp";
    warn "Query: ".$query."\n";
    $sth = $dbh->prepare($query);
    $sth->execute;
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
    $borr = $dbh->quote($borr);
    my @itemswaiting;
    my $query = "SELECT * FROM reserves
                         WHERE borrowernumber = $borr
                           AND reserves.found = 'W'
                           AND cancellationdate is NULL";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    # FIXME - Use 'push'
    my $cnt=0;
    if (my $data=$sth->fetchrow_hashref) {
	$itemswaiting[$cnt] =$data;
	$cnt ++;
    }
    $sth->finish;
    return ($cnt,\@itemswaiting);
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
  $bibitem=$dbh->quote($bibitem);
  my $query = "SELECT reserves.biblionumber               AS biblionumber,
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
                WHERE reserves.biblionumber = $biblio
                  AND ( ( reserveconstraints.biblioitemnumber = $bibitem
                      AND reserves.borrowernumber = reserveconstraints.borrowernumber
                      AND reserves.reservedate    =reserveconstraints.reservedate )
                   OR reserves.constrainttype='a' )
                  AND reserves.cancellationdate is NULL
                  AND (reserves.found <> 'F' or reserves.found is NULL)";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  # FIXME - $i is unnecessary and bogus
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;		 # FIXME - Use push
    $i++;
  }
  $sth->finish;
  return($i,@results);
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
    my $updquery = "insert into accountlines
    (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding)
						          values
    ($borrnum,$nextacctno,now(),$fee,'Reserve Charge - $title','Res',$fee)";
    my $usth = $dbh->prepare($updquery);
    $usth->execute;
    $usth->finish;
  }
  #if ($const eq 'a'){
    my $query="insert into reserves
   (borrowernumber,biblionumber,reservedate,branchcode,constrainttype,priority,reservenotes)
    values
('$borrnum','$biblionumber','$resdate','$branch','$const','$priority','$notes')";
    my $sth = $dbh->prepare($query);
    $sth->execute();
    $sth->finish;
  #}
  if (($const eq "o") || ($const eq "e")) {
    my $numitems = @$bibitems;
    my $i = 0;
    while ($i < $numitems) {
      my $biblioitem = @$bibitems[$i];
      my $query = "insert into
      reserveconstraints
      (borrowernumber,biblionumber,reservedate,biblioitemnumber)
      values
      ('$borrnum','$biblionumber','$resdate','$biblioitem')";
      my $sth = $dbh->prepare($query);
      $sth->execute();
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
sub CalcReserveFee {
  my ($env,$borrnum,$biblionumber,$constraint,$bibitems) = @_;
  #check for issues;
  my $dbh = C4::Context->dbh;
  my $const = lc substr($constraint,0,1);
  my $query = "SELECT * FROM borrowers,categories
                WHERE (borrowernumber = ?)
                  AND (borrowers.categorycode = categories.categorycode)";
  my $sth = $dbh->prepare($query);
  $sth->execute($borrnum);
  my $data = $sth->fetchrow_hashref;
  $sth->finish();
  my $fee = $data->{'reservefee'};
  my $cntitems = @->$bibitems;
  if ($fee > 0) {
    # check for items on issue
    # first find biblioitem records
    my @biblioitems;
    my $query1 = "SELECT * FROM biblio,biblioitems
                   WHERE (biblio.biblionumber = ?)
                     AND (biblio.biblionumber = biblioitems.biblionumber)";
    my $sth1 = $dbh->prepare($query1);
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
      my $query2 = "SELECT * FROM items
                     WHERE biblioitemnumber = ?";
      my $sth2 = $dbh->prepare($query2);
      $sth2->execute($bitdata->{'biblioitemnumber'});
      while (my $itdata=$sth2->fetchrow_hashref) {
        my $query3 = "SELECT * FROM issues
                       WHERE itemnumber = ?
                         AND returndate IS NULL";

        my $sth3 = $dbh->prepare($query3);
        $sth3->execute($itdata->{'itemnumber'});
        if (my $isdata=$sth3->fetchrow_hashref) {
	} else {
	  $allissued = 0;
	}
      }
      $x++;
    }
    if ($allissued == 0) {
      my $rquery = "SELECT * FROM reserves WHERE biblionumber = ?";
      my $rsth = $dbh->prepare($rquery);
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

# XXX - POD
sub updatereserves{
  #subroutine to update a reserve
  my ($rank,$biblio,$borrower,$del,$branch)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Update reserves ";
  if ($del == 0){
    $query.="set  priority='$rank',branchcode='$branch' where
    biblionumber=$biblio and borrowernumber=$borrower";
  } else {
    $query="Select * from reserves where biblionumber=$biblio and
    borrowernumber=$borrower";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    my $data=$sth->fetchrow_hashref;
    $sth->finish;
    $query="Select * from reserves where biblionumber=$biblio and
    priority > '$data->{'priority'}' and cancellationdate is NULL
    order by priority";
    my $sth2=$dbh->prepare($query) || die $dbh->errstr;
    $sth2->execute || die $sth2->errstr;
    while (my $data=$sth2->fetchrow_hashref){
      $data->{'priority'}--;
      $query="Update reserves set priority=$data->{'priority'} where
      biblionumber=$data->{'biblionumber'} and
      borrowernumber=$data->{'borrowernumber'}";
      my $sth3=$dbh->prepare($query);
      $sth3->execute || die $sth3->errstr;
      $sth3->finish;
    }
    $sth2->finish;
    $query="update reserves set cancellationdate=now() where biblionumber=$biblio
    and borrowernumber=$borrower";
  }
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
}

# XXX - POD
sub UpdateReserve {
    #subroutine to update a reserve
    my ($rank,$biblio,$borrower,$branch)=@_;
    return if $rank eq "W";
    return if $rank eq "n";
    my $dbh = C4::Context->dbh;
    if ($rank eq "del") {
	my $query = "UPDATE reserves SET cancellationdate=now()
                                   WHERE biblionumber   = ?
                                     AND borrowernumber = ?
	                             AND cancellationdate is NULL
                                     AND (found <> 'F' or found is NULL)";
	my $sth=$dbh->prepare($query);
	$sth->execute($biblio, $borrower);
	$sth->finish;
    } else {
	my $query = "UPDATE reserves SET priority = ? ,branchcode = ?, itemnumber = NULL, found = NULL
                                   WHERE biblionumber   = ?
                                     AND borrowernumber = ?
	                             AND cancellationdate is NULL
                                     AND (found <> 'F' or found is NULL)";
	my $sth=$dbh->prepare($query);
	$sth->execute($rank, $branch, $biblio, $borrower);
	$sth->finish;
    }
}

# XXX - POD
sub getreservetitle {
 my ($biblio,$bor,$date,$timestamp)=@_;
 my $dbh = C4::Context->dbh;
 my $query="Select * from reserveconstraints,biblioitems where
 reserveconstraints.biblioitemnumber=biblioitems.biblioitemnumber
 and reserveconstraints.biblionumber=$biblio and reserveconstraints.borrowernumber
 = $bor and reserveconstraints.reservedate='$date' and
 reserveconstraints.timestamp=$timestamp";
 my $sth=$dbh->prepare($query);
 $sth->execute;
 my $data=$sth->fetchrow_hashref;
 $sth->finish;
# print $query;
 return($data);
}
