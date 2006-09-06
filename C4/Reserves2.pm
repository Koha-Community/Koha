# -*- tab-width: 8 -*-
# NOTE: This file uses standard 8-character tabs

package C4::Reserves2;

# $Id$

# Copyright 2000-2002 Katipo Communications
#
# This file is hard coded with koha-reserves table to be used only by the OPAC -TG.
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

use C4::Context;
use C4::Search;
use C4::Biblio;
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
@EXPORT = qw(&FindReserves
             &FindAllReserves
		     &CheckReserves
 		     &CheckWaiting
		     &CancelReserve
		     &CalcReserveFee
		     &FillReserve
		     &ReserveWaiting
		     &CreateReserve
		     &UpdateReserves
		     &UpdateReserve
		     &getreservetitle
		     &Findgroupreserve
			 &findActiveReserve
		
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

C<&FindReserves> returns a two-element array:

C<$count> is the number of elements in C<$results>.

C<$results> is a reference-to-array; each element is a
reference-to-hash, whose keys are (I think) all of the fields of the
reserves, borrowers, and biblio tables of the Koha database.

=cut
#'
sub FindReserves {
	my ($bib, $bor) = @_;
	my @params;

	my $dbh = C4::Context->dbh;
	# Find the desired items in the reserves
	my $query="SELECT *, reserves.branchcode,  reserves.timestamp as rtimestamp,  DATE_FORMAT(reserves.timestamp, '%T')	AS time
			   FROM reserves,borrowers,items ";
	if ($bib ne ''){
		#$bib = $dbh->quote($bib);
		if ($bor ne ''){
			# Both $bib and $bor specified
			# Find a particular book for a particular patron
			#$bor = $dbh->quote($bor);
			$query .=  "WHERE (reserves.biblionumber = ?) and
						      (borrowers.borrowernumber = ?) and
						      (reserves.borrowernumber = borrowers.borrowernumber) and
						    (reserves.itemnumber=items.itemnumber) and
						      (cancellationdate IS NULL) and
							  (found <> 1) ";
						      
						push @params, $bib, $bor;
		} else {
			# $bib specified, but not $bor
			# Find a particular book for all patrons
			$query .= "WHERE (reserves.borrowernumber = borrowers.borrowernumber) and
					         (reserves.biblionumber = ?) and
						    (reserves.itemnumber=items.itemnumber) and
					         (cancellationdate IS NULL) and
							 (found <> 1) ";

							 push @params, $bib;
		}
	} else {
		$query .= "WHERE (reserves.biblionumber = items.biblionumber) and
		                 (borrowers.borrowernumber = ?) and
					     (reserves.borrowernumber  = borrowers.borrowernumber) and
						    (reserves.itemnumber=items.itemnumber) and
					     (cancellationdate IS NULL) and
					     (found <> 1)";

						 push @params, $bor;
	}
	$query.=" order by reserves.timestamp";
	my $sth = $dbh->prepare($query);
	$sth->execute(@params);

	my $i = 0;
	my @results;
	while (my $data = $sth->fetchrow_hashref){
		my ($bibdata) =XMLgetbibliohash($dbh,$data->{'biblionumber'});
		my ($itemhash)=XMLgetitemhash($dbh,$data->{'itemnumber'});
		$data->{'holdingbranch'}=XML_readline_onerecord($itemhash,"holdingbranch","holdings");
		$data->{'author'} =XML_readline_onerecord($bibdata,"author","biblios");
		$data->{'publishercode'} = XML_readline_onerecord($bibdata,"publishercode","biblios");
		$data->{'publicationyear'} = XML_readline_onerecord($bibdata,"publicationyear","biblios");
		$data->{'title'} = XML_readline_onerecord($bibdata,"title","biblios");
		push @results, $data;
		$i++;
	}
	$sth->finish;

	return($i,\@results);
}

=item FindAllReserves

  ($count, $results) = &FindAllReserves($biblionumber, $borrowernumber);

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

C<&FindAllReserves> returns a two-element array:

C<$count> is the number of elements in C<$results>.

C<$results> is a reference-to-array; each element is a
reference-to-hash, whose keys are (I think) all of the fields of the
reserves, borrowers, and biblio tables of the Koha database.

=cut
#'
sub FindAllReserves {
	my ($bib, $bor) = @_;
	my @params;
	
my $dbh;

	 $dbh = C4::Context->dbh;

	# Find the desired items in the reserves
	my $query="SELECT *,
	                  reserves.branchcode,
					  biblio.title AS btitle, 
					  reserves.timestamp as rtimestamp,
					  DATE_FORMAT(reserves.timestamp, '%T')	AS time
			   FROM reserves,
				    borrowers,
                    biblio ";
	if ($bib ne ''){
		#$bib = $dbh->quote($bib);
		if ($bor ne ''){
			# Both $bib and $bor specified
			# Find a particular book for a particular patron
			#$bor = $dbh->quote($bor);
			$query .=  "WHERE (reserves.biblionumber = ?) and
						      (borrowers.borrowernumber = ?) and
						      (reserves.borrowernumber = borrowers.borrowernumber) and
						      (biblio.biblionumber = ?) and
						      (cancellationdate IS NULL) and
							  (found <> 1) and
						      (reservefrom > NOW())";
						push @params, $bib, $bor, $bib;
		} else {
			# $bib specified, but not $bor
			# Find a particular book for all patrons
			$query .= "WHERE (reserves.borrowernumber = borrowers.borrowernumber) and
					         (biblio.biblionumber = ?) and
					         (reserves.biblionumber = ?) and
					         (cancellationdate IS NULL) and
							 (found <> 1) and
					         (reservefrom > NOW())";
							 push @params, $bib, $bib;
		}
	} else {
		$query .= "WHERE (reserves.biblionumber = biblio.biblionumber) and
		                 (borrowers.borrowernumber = ?) and
					     (reserves.borrowernumber  = borrowers.borrowernumber) and
						 (reserves.biblionumber = biblio.biblionumber) and
					     (cancellationdate IS NULL) and
					     (found <> 1) and
					     (reservefrom > NOW())";
						 push @params, $bor;
	}
	$query.=" order by reserves.timestamp";
	my $sth = $dbh->prepare($query);
	$sth->execute(@params);

	my $i = 0;
	my @results;
	while (my $data = $sth->fetchrow_hashref){
		my $bibdata = C4::Search::bibdata($data->{'biblionumber'});
		$data->{'author'} = $bibdata->{'author'};
		$data->{'publishercode'} = $bibdata->{'publishercode'};
		$data->{'publicationyear'} = $bibdata->{'publicationyear'};
		$data->{'title'} = $bibdata->{'title'};
		push @results, $data;
		$i++;
	}
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
	
    } else {
	my $qbc=$dbh->quote($barcode);
	# Look up the item by barcode
	$sth=$dbh->prepare("SELECT items.itemnumber
                             FROM items
                            WHERE  barcode=$qbc");
	    $sth->execute;
	($item) = $sth->fetchrow;
    $sth->finish;
    }

    
# if item is not for loan it cannot be reserved either.....
#    return (0, 0) if ($notforloan);
# get the reserves...
    # Find this item in the reserves
    my ($count, @reserves) = Findgroupreserve($item);
    # $priority and $highest are used to find the most important item
    # in the list returned by &Findgroupreserve. (The lower $priority,
    # the more important the item.)
    # $highest is the most important item we've seen so far.
    my $priority = 10000000;
    my $highest;
    if ($count) {
	foreach my $res (@reserves) {
	   if ($res->{found} eq "W"){
	   return ("Waiting", $res);
		}else{
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

  &CancelReserve($reserveid);

Cancels a reserve.

Use reserveid to cancel the reservation.

C<$reserveid> is the reserve ID to cancel.

=cut
#'
sub CancelReserve {
    my ($biblio, $item, $borr) = @_;

my $dbh;

	 $dbh = C4::Context->dbh;

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
		my $sth=$dbh->prepare("SELECT priority FROM reserves
										WHERE biblionumber   = ?
										AND borrowernumber = ?
										AND cancellationdate is NULL
										AND (found <> 1 )");
		$sth->execute($biblio,$borr);
		($priority) = $sth->fetchrow_array;
		$sth->finish;

		# update the database, removing the record...
		 $sth = $dbh->prepare("update reserves set cancellationdate = now(),
											found            = 0,
											priority         = 0
									where biblionumber     = ?
										and borrowernumber   = ?
										and cancellationdate is NULL
										and (found <> 1 )");
		$sth->execute($biblio,$borr);
		$sth->finish;
		# now fix the priority on the others....
		fixpriority($priority, $biblio);
    }
}
=item FillReserve

  &FillReserve($reserveid, $itemnumber);

Fill a reserve. If I understand this correctly, this means that the
reserved book has been found and given to the patron who reserved it.

C<$reserve> specifies the reserve id to fill. 

C<$itemnumber> specifies the borrowed itemnumber for the reserve. 

=cut
#'
sub FillReserve {
    my ($res) = @_;
my $dbh;
	 $dbh = C4::Context->dbh;
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
    my $query = "UPDATE reserves SET found            = 1,
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
my $dbh;
 $dbh = C4::Context->dbh;

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
	
my $dbh;

	 $dbh = C4::Context->dbh;

# get priority and biblionumber....
    my $sth = $dbh->prepare("SELECT reserves.priority     as priority,
                        reserves.biblionumber as biblionumber,
                        reserves.branchcode   as branchcode,
                        reserves.timestamp     as timestamp
                      FROM reserves
                     WHERE  reserves.itemnumber        = ?
                       AND reserves.borrowernumber = ?
                       AND reserves.cancellationdate is NULL
                       AND (reserves.found <> '1' or reserves.found is NULL)");
    $sth->execute($item,$borr);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    my $biblio = $data->{'biblionumber'};
    my $timestamp = $data->{'timestamp'};
# update reserves record....
    $sth = $dbh->prepare("UPDATE reserves SET priority = 0, found = 'W'
                            WHERE borrowernumber = ?
                              AND itemnumber = ?
                              AND timestamp = ?");
    $sth->execute($borr,$item,$timestamp);
    $sth->finish;
# now fix up the remaining priorities....
    fixpriority($data->{'priority'}, $biblio);
    my $branchcode = $data->{'branchcode'};
    return $branchcode;
}

# XXX - POD
sub CheckWaiting {
    my ($borr)=@_;
	
my $dbh;
	 $dbh = C4::Context->dbh;
    my @itemswaiting;
    my $sth = $dbh->prepare("SELECT * FROM reserves
                         WHERE borrowernumber = ?
                           AND reserves.found = 'W'
                           AND cancellationdate is NULL");
    $sth->execute($borr);
    while (my $data=$sth->fetchrow_hashref) {
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
  my ($itemnumber)=@_;

my	 $dbh = C4::Context->dbh;

  my $sth = $dbh->prepare("SELECT *
                           FROM reserves
                           WHERE (itemnumber = ?) AND
							     (cancellationdate IS NULL) AND
			                     (found <> 1) 
						   ORDER BY timestamp");
  $sth->execute($itemnumber);
  my @results;
  while (my $data = $sth->fetchrow_hashref) {
		push(@results,$data);
  }
  $sth->finish;
  return(scalar(@results),@results);
}

# FIXME - A somewhat different version of this function appears in
# C4::Reserves. Pick one and stick with it.
# XXX - POD
sub CreateReserve {
	my ($env, $borrnum,$registeredby ,$biblionumber,$reservefrom, $reserveto, $branch, 
	  $constraint, $priority, $notes, $title,$bibitems,$itemnumber) = @_;

my 	 $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("INSERT INTO reserves
								(borrowernumber, registeredby, reservedate, biblionumber, reservefrom, 
								reserveto, branchcode, constrainttype, priority, found, reservenotes,itemnumber)
  							VALUES (?, ?, NOW(),?,?,?,?,?,?,0,?,?)");
    $sth->execute($borrnum, $registeredby, $biblionumber, $reservefrom, $reserveto, $branch, $constraint, $priority, $notes,$itemnumber);
my $fee=CalcReserveFee($env,$borrnum,$biblionumber,$constraint,$bibitems);
 if ($fee > 0) {

    my $nextacctno = &getnextacctno($env,$borrnum,$dbh);
    my $usth = $dbh->prepare("insert into accountlines
    (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding)
						          values
    (?,?,now(),?,?,'Res',?)");
    $usth->execute($borrnum,$nextacctno,$fee,'Reserve Charge -'. $title,$fee);
    $usth->finish;
  }
	return 1;
}

# FIXME - A functionally identical version of this function appears in
# C4::Reserves. Pick one and stick with it.
# XXX - Internal use only
# FIXME - opac-reserves.pl need to use it, temporarily put into @EXPORT

sub CalcReserveFee {
  my ($env,$borrnum,$biblionumber,$constraint,$bibitems) = @_;
  #check for issues;
my	 $dbh = C4::Context->dbh;


  my $const = lc substr($constraint,0,1);
  my $sth = $dbh->prepare("SELECT * FROM borrowers,categories
                WHERE (borrowernumber = ?)
                  AND (borrowers.categorycode = categories.categorycode)");
  $sth->execute($borrnum);
  my $data = $sth->fetchrow_hashref;
  $sth->finish();
  my $fee = $data->{'reservefee'};
  
  if ($fee > 0) {
    # check for items on issue
   
   
    my $issues = 0;
    my $x = 0;
    my $allissued = 1;
  
      my $sth2 = $dbh->prepare("SELECT * FROM items
                     WHERE biblionumber = ?");
      $sth2->execute($biblionumber);
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
sub UpdateReserves {
    #subroutine to update a reserve
    my ($rank,$biblio,$borrower,$branch,$cataloger)=@_;
    return if $rank eq "W";
    return if $rank eq "n";
my $dbh;
	 $dbh = C4::Context->dbh;

    if ($rank eq "del") {
	my $sth=$dbh->prepare("UPDATE reserves SET cancellationdate=now(),registeredby=?
                                   WHERE biblionumber   = ?
                                     AND borrowernumber = ?
	                             AND cancellationdate is NULL
                                     AND (found <> 1 )");
	$sth->execute($cataloger,$biblio, $borrower);
	$sth->finish;
    } else {
	my $sth=$dbh->prepare("UPDATE reserves SET priority = ? ,branchcode = ?,  found = 0
                                   WHERE biblionumber   = ?
                                     AND borrowernumber = ?
	                             AND cancellationdate is NULL
                                     AND (found <> 1)");
	$sth->execute($rank, $branch, $biblio, $borrower);
	$sth->finish;
    }
}

# XXX - POD
sub UpdateReserve {
    #subroutine to update a reserve
    my ($reserveid, $timestamp) = @_;

my $dbh;
	 $dbh = C4::Context->dbh;


	my $sth=$dbh->prepare("UPDATE reserves 
	                       SET timestamp = $timestamp,
							   reservedate = DATE_FORMAT($timestamp, '%Y-%m-%d')
                           WHERE (reserveid = $reserveid)");
	$sth->execute();
	$sth->finish;
}

# XXX - POD
sub getreservetitle {
 my ($biblio,$bor,$date,$timestamp)=@_;
my	 $dbh = C4::Context->dbh;


 my $sth=$dbh->prepare("Select * from reserveconstraints where
 reserveconstraints.biblionumber=? and reserveconstraints.borrowernumber
 = ? and reserveconstraints.reservedate=? and
 reserveconstraints.timestamp=?");
 $sth->execute($biblio,$bor,$date,$timestamp);
 my $data=$sth->fetchrow_hashref;
 $sth->finish;
 return($data);
}

sub findActiveReserve {
	my ($borrowernumber, $biblionumber, $from, $days) = @_;
my	 $dbh = C4::Context->dbh;

	my $sth = $dbh->prepare("SELECT * 
							FROM reserves 
							WHERE 
								borrowernumber = ? 
								AND biblionumber = ? 
								AND (cancellationdate IS NULL) 
								AND (found <> 1) 
								AND ((? BETWEEN reservefrom AND reserveto) 
								OR (ADDDATE(?, INTERVAL ? DAY) BETWEEN reservefrom AND reserveto))
							");
	$sth->execute($borrowernumber, $biblionumber, $from, $from, $days);
	return ($sth->rows);
}

1;