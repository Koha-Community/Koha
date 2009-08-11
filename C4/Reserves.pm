package C4::Reserves;

# Copyright 2000-2002 Katipo Communications
#           2006 SAN Ouest Provence
#           2007 BibLibre Paul POULAIN
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
# use warnings;  # FIXME: someday
use C4::Context;
use C4::Biblio;
use C4::Items;
use C4::Search;
use C4::Circulation;
use C4::Accounts;

# for _koha_notify_reserve
use C4::Members::Messaging;
use C4::Members qw( GetMember );
use C4::Letters;
use C4::Branch qw( GetBranchDetail );
use C4::Dates qw( format_date_in_iso );
use List::MoreUtils qw( firstidx );

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

=head1 NAME

C4::Reserves - Koha functions for dealing with reservation.

=head1 SYNOPSIS

  use C4::Reserves;

=head1 DESCRIPTION

  this modules provides somes functions to deal with reservations.
  
  Reserves are stored in reserves table.
  The following columns contains important values :
  - priority >0      : then the reserve is at 1st stage, and not yet affected to any item.
             =0      : then the reserve is being dealed
  - found : NULL       : means the patron requested the 1st available, and we haven't choosen the item
            W(aiting)  : the reserve has an itemnumber affected, and is on the way
            F(inished) : the reserve has been completed, and is done
  - itemnumber : empty : the reserve is still unaffected to an item
                 filled: the reserve is attached to an item
  The complete workflow is :
  ==== 1st use case ====
  patron request a document, 1st available :                      P >0, F=NULL, I=NULL
  a library having it run "transfertodo", and clic on the list    
         if there is no transfer to do, the reserve waiting
         patron can pick it up                                    P =0, F=W,    I=filled 
         if there is a transfer to do, write in branchtransfer    P =0, F=NULL, I=filled
           The pickup library recieve the book, it check in       P =0, F=W,    I=filled
  The patron borrow the book                                      P =0, F=F,    I=filled
  
  ==== 2nd use case ====
  patron requests a document, a given item,
    If pickup is holding branch                                   P =0, F=W,   I=filled
    If transfer needed, write in branchtransfer                   P =0, F=NULL, I=filled
        The pickup library recieve the book, it checks it in      P =0, F=W,    I=filled
  The patron borrow the book                                      P =0, F=F,    I=filled
  
=head1 FUNCTIONS

=over 2

=cut

BEGIN {
    # set the version for version checking
    $VERSION = 3.01;
	require Exporter;
    @ISA = qw(Exporter);
    @EXPORT = qw(
        &AddReserve
  
        &GetReservesFromItemnumber
        &GetReservesFromBiblionumber
        &GetReservesFromBorrowernumber
        &GetReservesForBranch
        &GetReservesToBranch
        &GetReserveCount
        &GetReserveFee
		&GetReserveInfo
    
        &GetOtherReserves
        
        &ModReserveFill
        &ModReserveAffect
        &ModReserve
        &ModReserveStatus
        &ModReserveCancelAll
        &ModReserveMinusPriority
        
        &CheckReserves
        &CancelReserve

        &IsAvailableForItemLevelRequest
    );
}    

=item AddReserve

    AddReserve($branch,$borrowernumber,$biblionumber,$constraint,$bibitems,$priority,$notes,$title,$checkitem,$found)

=cut

sub AddReserve {
    my (
        $branch,    $borrowernumber, $biblionumber,
        $constraint, $bibitems,  $priority, $resdate,  $notes,
        $title,      $checkitem, $found
    ) = @_;
    my $fee =
          GetReserveFee($borrowernumber, $biblionumber, $constraint,
            $bibitems );
    my $dbh     = C4::Context->dbh;
    my $const   = lc substr( $constraint, 0, 1 );
    $resdate = format_date_in_iso( $resdate ) if ( $resdate );
    $resdate = C4::Dates->today( 'iso' ) unless ( $resdate );
    if ( C4::Context->preference( 'AllowHoldDateInFuture' ) ) {
	# Make room in reserves for this before those of a later reserve date
	$priority = _ShiftPriorityByDateAndPriority( $biblionumber, $resdate, $priority );
    }
    my $waitingdate;

    # If the reserv had the waiting status, we had the value of the resdate
    if ( $found eq 'W' ) {
        $waitingdate = $resdate;
    }

    #eval {
    # updates take place here
    if ( $fee > 0 ) {
        my $nextacctno = &getnextacctno( $borrowernumber );
        my $query      = qq/
        INSERT INTO accountlines
            (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding)
        VALUES
            (?,?,now(),?,?,'Res',?)
    /;
        my $usth = $dbh->prepare($query);
        $usth->execute( $borrowernumber, $nextacctno, $fee,
            "Reserve Charge - $title", $fee );
    }

    #if ($const eq 'a'){
    my $query = qq/
        INSERT INTO reserves
            (borrowernumber,biblionumber,reservedate,branchcode,constrainttype,
            priority,reservenotes,itemnumber,found,waitingdate)
        VALUES
             (?,?,?,?,?,
             ?,?,?,?,?)
    /;
    my $sth = $dbh->prepare($query);
    $sth->execute(
        $borrowernumber, $biblionumber, $resdate, $branch,
        $const,          $priority,     $notes,   $checkitem,
        $found,          $waitingdate
    );

    #}
    ($const eq "o" || $const eq "e") or return;   # FIXME: why not have a useful return value?
    $query = qq/
        INSERT INTO reserveconstraints
            (borrowernumber,biblionumber,reservedate,biblioitemnumber)
        VALUES
            (?,?,?,?)
    /;
    $sth = $dbh->prepare($query);    # keep prepare outside the loop!
    foreach (@$bibitems) {
        $sth->execute($borrowernumber, $biblionumber, $resdate, $_);
    }
    return;     # FIXME: why not have a useful return value?
}

=item GetReservesFromBiblionumber

($count, $title_reserves) = &GetReserves($biblionumber);

This function gets the list of reservations for one C<$biblionumber>, returning a count
of the reserves and an arrayref pointing to the reserves for C<$biblionumber>.

=cut

sub GetReservesFromBiblionumber {
    my ($biblionumber) = shift or return (0, []);
    my ($all_dates) = shift;
    my $dbh   = C4::Context->dbh;

    # Find the desired items in the reserves
    my $query = "
        SELECT  branchcode,
                timestamp AS rtimestamp,
                priority,
                biblionumber,
                borrowernumber,
                reservedate,
                constrainttype,
                found,
                itemnumber,
                reservenotes
        FROM     reserves
        WHERE biblionumber = ? ";
    unless ( $all_dates ) {
        $query .= "AND reservedate <= CURRENT_DATE()";
    }
    $query .= "ORDER BY priority";
    my $sth = $dbh->prepare($query);
    $sth->execute($biblionumber);
    my @results;
    my $i = 0;
    while ( my $data = $sth->fetchrow_hashref ) {

        # FIXME - What is this doing? How do constraints work?
        if ($data->{constrainttype} eq 'o') {
            $query = '
                SELECT biblioitemnumber
                FROM  reserveconstraints
                WHERE  biblionumber   = ?
                AND   borrowernumber = ?
                AND   reservedate    = ?
            ';
            my $csth = $dbh->prepare($query);
            $csth->execute($data->{biblionumber}, $data->{borrowernumber}, $data->{reservedate});
            my @bibitemno;
            while ( my $bibitemnos = $csth->fetchrow_array ) {
                push( @bibitemno, $bibitemnos );    # FIXME: inefficient: use fetchall_arrayref
            }
            my $count = scalar @bibitemno;
    
            # if we have two or more different specific itemtypes
            # reserved by same person on same day
            my $bdata;
            if ( $count > 1 ) {
                $bdata = GetBiblioItemData( $bibitemno[$i] );   # FIXME: This doesn't make sense.
                $i++; #  $i can increase each pass, but the next @bibitemno might be smaller?
            }
            else {
                # Look up the book we just found.
                $bdata = GetBiblioItemData( $bibitemno[0] );
            }
            # Add the results of this latest search to the current
            # results.
            # FIXME - An 'each' would probably be more efficient.
            foreach my $key ( keys %$bdata ) {
                $data->{$key} = $bdata->{$key};
            }
        }
        push @results, $data;
    }
    return ( $#results + 1, \@results );
}

=item GetReservesFromItemnumber

 ( $reservedate, $borrowernumber, $branchcode ) = GetReservesFromItemnumber($itemnumber);

   TODO :: Description here

=cut

sub GetReservesFromItemnumber {
    my ( $itemnumber, $all_dates ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "
    SELECT reservedate,borrowernumber,branchcode
    FROM   reserves
    WHERE  itemnumber=?
    ";
    unless ( $all_dates ) {
	$query .= " AND reservedate <= CURRENT_DATE()";
    }
    my $sth_res = $dbh->prepare($query);
    $sth_res->execute($itemnumber);
    my ( $reservedate, $borrowernumber,$branchcode ) = $sth_res->fetchrow_array;
    return ( $reservedate, $borrowernumber, $branchcode );
}

=item GetReservesFromBorrowernumber

    $borrowerreserv = GetReservesFromBorrowernumber($borrowernumber,$tatus);
    
    TODO :: Descritpion
    
=cut

sub GetReservesFromBorrowernumber {
    my ( $borrowernumber, $status ) = @_;
    my $dbh   = C4::Context->dbh;
    my $sth;
    if ($status) {
        $sth = $dbh->prepare("
            SELECT *
            FROM   reserves
            WHERE  borrowernumber=?
                AND found =?
            ORDER BY reservedate
        ");
        $sth->execute($borrowernumber,$status);
    } else {
        $sth = $dbh->prepare("
            SELECT *
            FROM   reserves
            WHERE  borrowernumber=?
            ORDER BY reservedate
        ");
        $sth->execute($borrowernumber);
    }
    my $data = $sth->fetchall_arrayref({});
    return @$data;
}
#-------------------------------------------------------------------------------------

=item GetReserveCount

$number = &GetReserveCount($borrowernumber);

this function returns the number of reservation for a borrower given on input arg.

=cut

sub GetReserveCount {
    my ($borrowernumber) = @_;

    my $dbh = C4::Context->dbh;

    my $query = '
        SELECT COUNT(*) AS counter
        FROM reserves
          WHERE borrowernumber = ?
    ';
    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    my $row = $sth->fetchrow_hashref;
    return $row->{counter};
}

=item GetOtherReserves

($messages,$nextreservinfo)=$GetOtherReserves(itemnumber);

Check queued list of this document and check if this document must be  transfered

=cut

sub GetOtherReserves {
    my ($itemnumber) = @_;
    my $messages;
    my $nextreservinfo;
    my ( $restype, $checkreserves ) = CheckReserves($itemnumber);
    if ($checkreserves) {
        my $iteminfo = GetItem($itemnumber);
        if ( $iteminfo->{'holdingbranch'} ne $checkreserves->{'branchcode'} ) {
            $messages->{'transfert'} = $checkreserves->{'branchcode'};
            #minus priorities of others reservs
            ModReserveMinusPriority(
                $itemnumber,
                $checkreserves->{'borrowernumber'},
                $iteminfo->{'biblionumber'}
            );

            #launch the subroutine dotransfer
            C4::Items::ModItemTransfer(
                $itemnumber,
                $iteminfo->{'holdingbranch'},
                $checkreserves->{'branchcode'}
              ),
              ;
        }

     #step 2b : case of a reservation on the same branch, set the waiting status
        else {
            $messages->{'waiting'} = 1;
            ModReserveMinusPriority(
                $itemnumber,
                $checkreserves->{'borrowernumber'},
                $iteminfo->{'biblionumber'}
            );
            ModReserveStatus($itemnumber,'W');
        }

        $nextreservinfo = $checkreserves->{'borrowernumber'};
    }

    return ( $messages, $nextreservinfo );
}

=item GetReserveFee

$fee = GetReserveFee($borrowernumber,$biblionumber,$constraint,$biblionumber);

Calculate the fee for a reserve

=cut

sub GetReserveFee {
    my ($borrowernumber, $biblionumber, $constraint, $bibitems ) = @_;

    #check for issues;
    my $dbh   = C4::Context->dbh;
    my $const = lc substr( $constraint, 0, 1 );
    my $query = qq/
      SELECT * FROM borrowers
    LEFT JOIN categories ON borrowers.categorycode = categories.categorycode
    WHERE borrowernumber = ?
    /;
    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    my $data = $sth->fetchrow_hashref;
    $sth->finish();
    my $fee      = $data->{'reservefee'};
    my $cntitems = @- > $bibitems;

    if ( $fee > 0 ) {

        # check for items on issue
        # first find biblioitem records
        my @biblioitems;
        my $sth1 = $dbh->prepare(
            "SELECT * FROM biblio LEFT JOIN biblioitems on biblio.biblionumber = biblioitems.biblionumber
                   WHERE (biblio.biblionumber = ?)"
        );
        $sth1->execute($biblionumber);
        while ( my $data1 = $sth1->fetchrow_hashref ) {
            if ( $const eq "a" ) {
                push @biblioitems, $data1;
            }
            else {
                my $found = 0;
                my $x     = 0;
                while ( $x < $cntitems ) {
                    if ( @$bibitems->{'biblioitemnumber'} ==
                        $data->{'biblioitemnumber'} )
                    {
                        $found = 1;
                    }
                    $x++;
                }
                if ( $const eq 'o' ) {
                    if ( $found == 1 ) {
                        push @biblioitems, $data1;
                    }
                }
                else {
                    if ( $found == 0 ) {
                        push @biblioitems, $data1;
                    }
                }
            }
        }
        $sth1->finish;
        my $cntitemsfound = @biblioitems;
        my $issues        = 0;
        my $x             = 0;
        my $allissued     = 1;
        while ( $x < $cntitemsfound ) {
            my $bitdata = $biblioitems[$x];
            my $sth2    = $dbh->prepare(
                "SELECT * FROM items
                     WHERE biblioitemnumber = ?"
            );
            $sth2->execute( $bitdata->{'biblioitemnumber'} );
            while ( my $itdata = $sth2->fetchrow_hashref ) {
                my $sth3 = $dbh->prepare(
                    "SELECT * FROM issues
                       WHERE itemnumber = ?"
                );
                $sth3->execute( $itdata->{'itemnumber'} );
                if ( my $isdata = $sth3->fetchrow_hashref ) {
                }
                else {
                    $allissued = 0;
                }
            }
            $x++;
        }
        if ( $allissued == 0 ) {
            my $rsth =
              $dbh->prepare("SELECT * FROM reserves WHERE biblionumber = ?");
            $rsth->execute($biblionumber);
            if ( my $rdata = $rsth->fetchrow_hashref ) {
            }
            else {
                $fee = 0;
            }
        }
    }
    return $fee;
}

=item GetReservesToBranch

@transreserv = GetReservesToBranch( $frombranch );

Get reserve list for a given branch

=cut

sub GetReservesToBranch {
    my ( $frombranch ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "SELECT borrowernumber,reservedate,itemnumber,timestamp
         FROM reserves 
         WHERE priority='0' 
           AND branchcode=?"
    );
    $sth->execute( $frombranch );
    my @transreserv;
    my $i = 0;
    while ( my $data = $sth->fetchrow_hashref ) {
        $transreserv[$i] = $data;
        $i++;
    }
    return (@transreserv);
}

=item GetReservesForBranch

@transreserv = GetReservesForBranch($frombranch);

=cut

sub GetReservesForBranch {
    my ($frombranch) = @_;
    my $dbh          = C4::Context->dbh;
	my $query        = "SELECT borrowernumber,reservedate,itemnumber,waitingdate
        FROM   reserves 
        WHERE   priority='0'
            AND found='W' ";
    if ($frombranch){
        $query .= " AND branchcode=? ";
	}
    $query .= "ORDER BY waitingdate" ;
    my $sth = $dbh->prepare($query);
    if ($frombranch){
		$sth->execute($frombranch);
	}
    else {
		$sth->execute();
	}
    my @transreserv;
    my $i = 0;
    while ( my $data = $sth->fetchrow_hashref ) {
        $transreserv[$i] = $data;
        $i++;
    }
    return (@transreserv);
}

=item CheckReserves

  ($status, $reserve) = &CheckReserves($itemnumber);
  ($status, $reserve) = &CheckReserves(undef, $barcode);

Find a book in the reserves.

C<$itemnumber> is the book's item number.

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

sub CheckReserves {
    my ( $item, $barcode ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    my $select = "
    SELECT items.biblionumber,
           items.biblioitemnumber,
           itemtypes.notforloan,
           items.notforloan AS itemnotforloan,
           items.itemnumber
    FROM   items
    LEFT JOIN biblioitems ON items.biblioitemnumber = biblioitems.biblioitemnumber
    LEFT JOIN itemtypes   ON biblioitems.itemtype   = itemtypes.itemtype
    ";

    if ($item) {
        $sth = $dbh->prepare("$select WHERE reservedate <= CURRENT_DATE() AND itemnumber = ?");
        $sth->execute($item);
    }
    else {
        $sth = $dbh->prepare("$select WHERE reservedate <= CURRENT_DATE() AND barcode = ?");
        $sth->execute($barcode);
    }
    # note: we get the itemnumber because we might have started w/ just the barcode.  Now we know for sure we have it.
    my ( $biblio, $bibitem, $notforloan_per_itemtype, $notforloan_per_item, $itemnumber ) = $sth->fetchrow_array;

    return ( 0, 0 ) unless $itemnumber; # bail if we got nothing.

    # if item is not for loan it cannot be reserved either.....
    #    execpt where items.notforloan < 0 :  This indicates the item is holdable. 
    return ( 0, 0 ) if  ( $notforloan_per_item > 0 ) or $notforloan_per_itemtype;

    # Find this item in the reserves
    my @reserves = _Findgroupreserve( $bibitem, $biblio, $itemnumber );

    # $priority and $highest are used to find the most important item
    # in the list returned by &_Findgroupreserve. (The lower $priority,
    # the more important the item.)
    # $highest is the most important item we've seen so far.
    my $highest;
    if (scalar @reserves) {
        my $priority = 10000000;
        foreach my $res (@reserves) {
            if ( $res->{'itemnumber'} == $itemnumber && $res->{'priority'} == 0) {
                return ( "Waiting", $res ); # Found it
            } else {
                # See if this item is more important than what we've got so far
                if ( $res->{'priority'} && $res->{'priority'} < $priority ) {
                    $priority = $res->{'priority'};
                    $highest  = $res;
                }
            }
        }
    }

    # If we get this far, then no exact match was found.
    # We return the most important (i.e. next) reservation.
    if ($highest) {
        $highest->{'itemnumber'} = $item;
        return ( "Reserved", $highest );
    }
    else {
        return ( 0, 0 );
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

sub CancelReserve {
    my ( $biblio, $item, $borr ) = @_;
    my $dbh = C4::Context->dbh;
        if ( $item and $borr ) {
        # removing a waiting reserve record....
        # update the database...
        my $query = "
            UPDATE reserves
            SET    cancellationdate = now(),
                   found            = Null,
                   priority         = 0
            WHERE  itemnumber       = ?
             AND   borrowernumber   = ?
        ";
        my $sth = $dbh->prepare($query);
        $sth->execute( $item, $borr );
        $sth->finish;
        $query = "
            INSERT INTO old_reserves
            SELECT * FROM reserves
            WHERE  itemnumber       = ?
             AND   borrowernumber   = ?
        ";
        $sth = $dbh->prepare($query);
        $sth->execute( $item, $borr );
        $query = "
            DELETE FROM reserves
            WHERE  itemnumber       = ?
             AND   borrowernumber   = ?
        ";
        $sth = $dbh->prepare($query);
        $sth->execute( $item, $borr );
    }
    else {
        # removing a reserve record....
        # get the prioritiy on this record....
        my $priority;
        my $query = qq/
            SELECT priority FROM reserves
            WHERE biblionumber   = ?
              AND borrowernumber = ?
              AND cancellationdate IS NULL
              AND itemnumber IS NULL
        /;
        my $sth = $dbh->prepare($query);
        $sth->execute( $biblio, $borr );
        ($priority) = $sth->fetchrow_array;
        $sth->finish;
        $query = qq/
            UPDATE reserves
            SET    cancellationdate = now(),
                   found            = Null,
                   priority         = 0
            WHERE  biblionumber     = ?
              AND  borrowernumber   = ?
        /;

        # update the database, removing the record...
        $sth = $dbh->prepare($query);
        $sth->execute( $biblio, $borr );
        $sth->finish;

        $query = qq/
            INSERT INTO old_reserves
            SELECT * FROM reserves
            WHERE  biblionumber     = ?
              AND  borrowernumber   = ?
        /;
        $sth = $dbh->prepare($query);
        $sth->execute( $biblio, $borr );

        $query = qq/
            DELETE FROM reserves
            WHERE  biblionumber     = ?
              AND  borrowernumber   = ?
        /;
        $sth = $dbh->prepare($query);
        $sth->execute( $biblio, $borr );

        # now fix the priority on the others....
        _FixPriority( $priority, $biblio );
    }
}

=item ModReserve

=over 4

ModReserve($rank, $biblio, $borrower, $branch[, $itemnumber])

=back

Change a hold request's priority or cancel it.

C<$rank> specifies the effect of the change.  If C<$rank>
is 'W' or 'n', nothing happens.  This corresponds to leaving a
request alone when changing its priority in the holds queue
for a bib.

If C<$rank> is 'del', the hold request is cancelled.

If C<$rank> is an integer greater than zero, the priority of
the request is set to that value.  Since priority != 0 means
that the item is not waiting on the hold shelf, setting the 
priority to a non-zero value also sets the request's found
status and waiting date to NULL. 

The optional C<$itemnumber> parameter is used only when
C<$rank> is a non-zero integer; if supplied, the itemnumber 
of the hold request is set accordingly; if omitted, the itemnumber
is cleared.

FIXME: Note that the forgoing can have the effect of causing
item-level hold requests to turn into title-level requests.  This
will be fixed once reserves has separate columns for requested
itemnumber and supplying itemnumber.

=cut

sub ModReserve {
    #subroutine to update a reserve
    my ( $rank, $biblio, $borrower, $branch , $itemnumber) = @_;
     return if $rank eq "W";
     return if $rank eq "n";
    my $dbh = C4::Context->dbh;
    if ( $rank eq "del" ) {
        my $query = qq/
            UPDATE reserves
            SET    cancellationdate=now()
            WHERE  biblionumber   = ?
             AND   borrowernumber = ?
        /;
        my $sth = $dbh->prepare($query);
        $sth->execute( $biblio, $borrower );
        $sth->finish;
        $query = qq/
            INSERT INTO old_reserves
            SELECT *
            FROM   reserves 
            WHERE  biblionumber   = ?
             AND   borrowernumber = ?
        /;
        $sth = $dbh->prepare($query);
        $sth->execute( $biblio, $borrower );
        $query = qq/
            DELETE FROM reserves 
            WHERE  biblionumber   = ?
             AND   borrowernumber = ?
        /;
        $sth = $dbh->prepare($query);
        $sth->execute( $biblio, $borrower );
        
    }
    elsif ($rank =~ /^\d+/ and $rank > 0) {
        my $query = qq/
        UPDATE reserves SET priority = ? ,branchcode = ?, itemnumber = ?, found = NULL, waitingdate = NULL
            WHERE biblionumber   = ?
             AND borrowernumber = ?
        /;
        my $sth = $dbh->prepare($query);
        $sth->execute( $rank, $branch,$itemnumber, $biblio, $borrower);
        $sth->finish;
        _FixPriority( $biblio, $borrower, $rank);
    }
}

=item ModReserveFill

  &ModReserveFill($reserve);

Fill a reserve. If I understand this correctly, this means that the
reserved book has been found and given to the patron who reserved it.

C<$reserve> specifies the reserve to fill. It is a reference-to-hash
whose keys are fields from the reserves table in the Koha database.

=cut

sub ModReserveFill {
    my ($res) = @_;
    my $dbh = C4::Context->dbh;
    # fill in a reserve record....
    my $biblionumber = $res->{'biblionumber'};
    my $borrowernumber    = $res->{'borrowernumber'};
    my $resdate = $res->{'reservedate'};

    # get the priority on this record....
    my $priority;
    my $query = "SELECT priority
                 FROM   reserves
                 WHERE  biblionumber   = ?
                  AND   borrowernumber = ?
                  AND   reservedate    = ?";
    my $sth = $dbh->prepare($query);
    $sth->execute( $biblionumber, $borrowernumber, $resdate );
    ($priority) = $sth->fetchrow_array;
    $sth->finish;

    # update the database...
    $query = "UPDATE reserves
                  SET    found            = 'F',
                         priority         = 0
                 WHERE  biblionumber     = ?
                    AND reservedate      = ?
                    AND borrowernumber   = ?
                ";
    $sth = $dbh->prepare($query);
    $sth->execute( $biblionumber, $resdate, $borrowernumber );
    $sth->finish;

    # move to old_reserves
    $query = "INSERT INTO old_reserves
                 SELECT * FROM reserves
                 WHERE  biblionumber     = ?
                    AND reservedate      = ?
                    AND borrowernumber   = ?
                ";
    $sth = $dbh->prepare($query);
    $sth->execute( $biblionumber, $resdate, $borrowernumber );
    $query = "DELETE FROM reserves
                 WHERE  biblionumber     = ?
                    AND reservedate      = ?
                    AND borrowernumber   = ?
                ";
    $sth = $dbh->prepare($query);
    $sth->execute( $biblionumber, $resdate, $borrowernumber );
    
    # now fix the priority on the others (if the priority wasn't
    # already sorted!)....
    unless ( $priority == 0 ) {
        _FixPriority( $priority, $biblionumber );
    }
}

=item ModReserveStatus

&ModReserveStatus($itemnumber, $newstatus);

Update the reserve status for the active (priority=0) reserve.

$itemnumber is the itemnumber the reserve is on

$newstatus is the new status.

=cut

sub ModReserveStatus {

    #first : check if we have a reservation for this item .
    my ($itemnumber, $newstatus) = @_;
    my $dbh          = C4::Context->dbh;
    my $query = " UPDATE reserves
    SET    found=?,waitingdate = now()
    WHERE itemnumber=?
      AND found IS NULL
      AND priority = 0
    ";
    my $sth_set = $dbh->prepare($query);
    $sth_set->execute( $newstatus, $itemnumber );
}

=item ModReserveAffect

&ModReserveAffect($itemnumber,$borrowernumber,$diffBranchSend);

This function affect an item and a status for a given reserve
The itemnumber parameter is used to find the biblionumber.
with the biblionumber & the borrowernumber, we can affect the itemnumber
to the correct reserve.

if $transferToDo is not set, then the status is set to "Waiting" as well.
otherwise, a transfer is on the way, and the end of the transfer will 
take care of the waiting status
=cut

sub ModReserveAffect {
    my ( $itemnumber, $borrowernumber,$transferToDo ) = @_;
    my $dbh = C4::Context->dbh;

    # we want to attach $itemnumber to $borrowernumber, find the biblionumber
    # attached to $itemnumber
    my $sth = $dbh->prepare("SELECT biblionumber FROM items WHERE itemnumber=?");
    $sth->execute($itemnumber);
    my ($biblionumber) = $sth->fetchrow;

    # get request - need to find out if item is already
    # waiting in order to not send duplicate hold filled notifications
    my $request = GetReserveInfo($borrowernumber, $biblionumber);
    my $already_on_shelf = ($request && $request->{found} eq 'W') ? 1 : 0;

    # If we affect a reserve that has to be transfered, don't set to Waiting
    my $query;
    if ($transferToDo) {
    $query = "
        UPDATE reserves
        SET    priority = 0,
               itemnumber = ?
        WHERE borrowernumber = ?
          AND biblionumber = ?
    ";
    }
    else {
    # affect the reserve to Waiting as well.
    $query = "
        UPDATE reserves
        SET     priority = 0,
                found = 'W',
                waitingdate=now(),
                itemnumber = ?
        WHERE borrowernumber = ?
          AND biblionumber = ?
    ";
    }
    $sth = $dbh->prepare($query);
    $sth->execute( $itemnumber, $borrowernumber,$biblionumber);
    _koha_notify_reserve( $itemnumber, $borrowernumber, $biblionumber ) if ( !$transferToDo && !$already_on_shelf );

    return;
}

=item ModReserveCancelAll

($messages,$nextreservinfo) = &ModReserveCancelAll($itemnumber,$borrowernumber);

    function to cancel reserv,check other reserves, and transfer document if it's necessary

=cut

sub ModReserveCancelAll {
    my $messages;
    my $nextreservinfo;
    my ( $itemnumber, $borrowernumber ) = @_;

    #step 1 : cancel the reservation
    my $CancelReserve = CancelReserve( undef, $itemnumber, $borrowernumber );

    #step 2 launch the subroutine of the others reserves
    ( $messages, $nextreservinfo ) = GetOtherReserves($itemnumber);

    return ( $messages, $nextreservinfo );
}

=item ModReserveMinusPriority

&ModReserveMinusPriority($itemnumber,$borrowernumber,$biblionumber)

Reduce the values of queuded list     

=cut

sub ModReserveMinusPriority {
    my ( $itemnumber, $borrowernumber, $biblionumber ) = @_;

    #first step update the value of the first person on reserv
    my $dbh   = C4::Context->dbh;
    my $query = "
        UPDATE reserves
        SET    priority = 0 , itemnumber = ? 
        WHERE  borrowernumber=?
          AND  biblionumber=?
    ";
    my $sth_upd = $dbh->prepare($query);
    $sth_upd->execute( $itemnumber, $borrowernumber, $biblionumber );
    # second step update all others reservs
    _FixPriority($biblionumber, $borrowernumber, '0');
}

=item GetReserveInfo

&GetReserveInfo($borrowernumber,$biblionumber);

 Get item and borrower details for a current hold.
 Current implementation this query should have a single result.
=cut

sub GetReserveInfo {
	my ( $borrowernumber, $biblionumber ) = @_;
    my $dbh = C4::Context->dbh;
	my $strsth="SELECT reservedate, reservenotes, reserves.borrowernumber,
				reserves.biblionumber, reserves.branchcode,
				notificationdate, reminderdate, priority, found,
				firstname, surname, phone, 
				email, address, address2,
				cardnumber, city, zipcode,
				biblio.title, biblio.author,
				items.holdingbranch, items.itemcallnumber, items.itemnumber, 
				barcode, notes
			FROM reserves left join items 
				ON items.itemnumber=reserves.itemnumber , 
				borrowers, biblio 
			WHERE 
				reserves.borrowernumber=?  &&
				reserves.biblionumber=? && 
				reserves.borrowernumber=borrowers.borrowernumber && 
				reserves.biblionumber=biblio.biblionumber ";
	my $sth = $dbh->prepare($strsth); 
	$sth->execute($borrowernumber,$biblionumber);

	my $data = $sth->fetchrow_hashref;
	return $data;

}

=item IsAvailableForItemLevelRequest

=over 4

my $is_available = IsAvailableForItemLevelRequest($itemnumber);

=back

Checks whether a given item record is available for an
item-level hold request.  An item is available if

* it is not lost AND 
* it is not damaged AND 
* it is not withdrawn AND 
* does not have a not for loan value > 0

Whether or not the item is currently on loan is 
also checked - if the AllowOnShelfHolds system preference
is ON, an item can be requested even if it is currently
on loan to somebody else.  If the system preference
is OFF, an item that is currently checked out cannot
be the target of an item-level hold request.

Note that IsAvailableForItemLevelRequest() does not
check if the staff operator is authorized to place
a request on the item - in particular,
this routine does not check IndependantBranches
and canreservefromotherbranches.

=cut

sub IsAvailableForItemLevelRequest {
    my $itemnumber = shift;
   
    my $item = GetItem($itemnumber);

    # must check the notforloan setting of the itemtype
    # FIXME - a lot of places in the code do this
    #         or something similar - need to be
    #         consolidated
    my $dbh = C4::Context->dbh;
    my $notforloan_query;
    if (C4::Context->preference('item-level_itypes')) {
        $notforloan_query = "SELECT itemtypes.notforloan
                             FROM items
                             JOIN itemtypes ON (itemtypes.itemtype = items.itype)
                             WHERE itemnumber = ?";
    } else {
        $notforloan_query = "SELECT itemtypes.notforloan
                             FROM items
                             JOIN biblioitems USING (biblioitemnumber)
                             JOIN itemtypes USING (itemtype)
                             WHERE itemnumber = ?";
    }
    my $sth = $dbh->prepare($notforloan_query);
    $sth->execute($itemnumber);
    my $notforloan_per_itemtype = 0;
    if (my ($notforloan) = $sth->fetchrow_array) {
        $notforloan_per_itemtype = 1 if $notforloan;
    }

    my $available_per_item = 1;
    $available_per_item = 0 if $item->{itemlost} or
                               ( $item->{notforloan} > 0 ) or
                               ($item->{damaged} and not C4::Context->preference('AllowHoldsOnDamagedItems')) or
                               $item->{wthdrawn} or
                               $notforloan_per_itemtype;


    if (C4::Context->preference('AllowOnShelfHolds')) {
        return $available_per_item;
    } else {
        return ($available_per_item and $item->{onloan}); 
    }
}

=item _FixPriority

&_FixPriority($biblio,$borrowernumber,$rank);

 Only used internally (so don't export it)
 Changed how this functions works #
 Now just gets an array of reserves in the rank order and updates them with
 the array index (+1 as array starts from 0)
 and if $rank is supplied will splice item from the array and splice it back in again
 in new priority rank

=cut 

sub _FixPriority {
    my ( $biblio, $borrowernumber, $rank ) = @_;
    my $dbh = C4::Context->dbh;
     if ( $rank eq "del" ) {
         CancelReserve( $biblio, undef, $borrowernumber );
     }
    if ( $rank eq "W" || $rank eq "0" ) {

        # make sure priority for waiting items is 0
        my $query = qq/
            UPDATE reserves
            SET    priority = 0
            WHERE biblionumber = ?
              AND borrowernumber = ?
              AND found ='W'
        /;
        my $sth = $dbh->prepare($query);
        $sth->execute( $biblio, $borrowernumber );
    }
    my @priority;
    my @reservedates;

    # get whats left
# FIXME adding a new security in returned elements for changing priority,
# now, we don't care anymore any reservations with itemnumber linked (suppose a waiting reserve)
	# This is wrong a waiting reserve has W set
	# The assumption that having an itemnumber set means waiting is wrong and should be corrected any place it occurs
    my $query = qq/
        SELECT borrowernumber, reservedate, constrainttype
        FROM   reserves
        WHERE  biblionumber   = ?
          AND  ((found <> 'W') or found is NULL)
        ORDER BY priority ASC
    /;
    my $sth = $dbh->prepare($query);
    $sth->execute($biblio);
    while ( my $line = $sth->fetchrow_hashref ) {
        push( @reservedates, $line );
        push( @priority,     $line );
    }

    # To find the matching index
    my $i;
    my $key = -1;    # to allow for 0 to be a valid result
    for ( $i = 0 ; $i < @priority ; $i++ ) {
        if ( $borrowernumber == $priority[$i]->{'borrowernumber'} ) {
            $key = $i;    # save the index
            last;
        }
    }

    # if index exists in array then move it to new position
    if ( $key > -1 && $rank ne 'del' && $rank > 0 ) {
        my $new_rank = $rank -
          1;    # $new_rank is what you want the new index to be in the array
        my $moving_item = splice( @priority, $key, 1 );
        splice( @priority, $new_rank, 0, $moving_item );
    }

    # now fix the priority on those that are left....
    $query = "
            UPDATE reserves
            SET    priority = ?
                WHERE  biblionumber = ?
                 AND borrowernumber   = ?
                 AND reservedate = ?
         AND found IS NULL
    ";
    $sth = $dbh->prepare($query);
    for ( my $j = 0 ; $j < @priority ; $j++ ) {
        $sth->execute(
            $j + 1, $biblio,
            $priority[$j]->{'borrowernumber'},
            $priority[$j]->{'reservedate'}
        );
        $sth->finish;
    }
}

=item _Findgroupreserve

  @results = &_Findgroupreserve($biblioitemnumber, $biblionumber, $itemnumber);

Looks for an item-specific match first, then for a title-level match, returning the
first match found.  If neither, then we look for a 3rd kind of match based on
reserve constraints.

TODO: add more explanation about reserve constraints

C<&_Findgroupreserve> returns :
C<@results> is an array of references-to-hash whose keys are mostly
fields from the reserves table of the Koha database, plus
C<biblioitemnumber>.

=cut

sub _Findgroupreserve {
    my ( $bibitem, $biblio, $itemnumber ) = @_;
    my $dbh   = C4::Context->dbh;

    # TODO: consolidate at least the SELECT portion of the first 2 queries to a common $select var.
    # check for exact targetted match
    my $item_level_target_query = qq/
        SELECT reserves.biblionumber        AS biblionumber,
               reserves.borrowernumber      AS borrowernumber,
               reserves.reservedate         AS reservedate,
               reserves.branchcode          AS branchcode,
               reserves.cancellationdate    AS cancellationdate,
               reserves.found               AS found,
               reserves.reservenotes        AS reservenotes,
               reserves.priority            AS priority,
               reserves.timestamp           AS timestamp,
               biblioitems.biblioitemnumber AS biblioitemnumber,
               reserves.itemnumber          AS itemnumber
        FROM reserves
        JOIN biblioitems USING (biblionumber)
        JOIN hold_fill_targets USING (biblionumber, borrowernumber, itemnumber)
        WHERE found IS NULL
        AND priority > 0
        AND item_level_request = 1
        AND itemnumber = ?
        AND reservedate <= CURRENT_DATE()
    /;
    my $sth = $dbh->prepare($item_level_target_query);
    $sth->execute($itemnumber);
    my @results;
    if ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
    }
    return @results if @results;
    
    # check for title-level targetted match
    my $title_level_target_query = qq/
        SELECT reserves.biblionumber        AS biblionumber,
               reserves.borrowernumber      AS borrowernumber,
               reserves.reservedate         AS reservedate,
               reserves.branchcode          AS branchcode,
               reserves.cancellationdate    AS cancellationdate,
               reserves.found               AS found,
               reserves.reservenotes        AS reservenotes,
               reserves.priority            AS priority,
               reserves.timestamp           AS timestamp,
               biblioitems.biblioitemnumber AS biblioitemnumber,
               reserves.itemnumber          AS itemnumber
        FROM reserves
        JOIN biblioitems USING (biblionumber)
        JOIN hold_fill_targets USING (biblionumber, borrowernumber)
        WHERE found IS NULL
        AND priority > 0
        AND item_level_request = 0
        AND hold_fill_targets.itemnumber = ?
        AND reservedate <= CURRENT_DATE()
    /;
    $sth = $dbh->prepare($title_level_target_query);
    $sth->execute($itemnumber);
    @results = ();
    if ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
    }
    return @results if @results;

    my $query = qq/
        SELECT reserves.biblionumber               AS biblionumber,
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
        FROM reserves
          LEFT JOIN reserveconstraints ON reserves.biblionumber = reserveconstraints.biblionumber
        WHERE reserves.biblionumber = ?
          AND ( ( reserveconstraints.biblioitemnumber = ?
          AND reserves.borrowernumber = reserveconstraints.borrowernumber
          AND reserves.reservedate    = reserveconstraints.reservedate )
          OR  reserves.constrainttype='a' )
          AND (reserves.itemnumber IS NULL OR reserves.itemnumber = ?)
          AND reservedate <= CURRENT_DATE()
    /;
    $sth = $dbh->prepare($query);
    $sth->execute( $biblio, $bibitem, $itemnumber );
    @results = ();
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
    }
    return @results;
}

=item _koha_notify_reserve

=over 4

_koha_notify_reserve( $itemnumber, $borrowernumber, $biblionumber );

=back

Sends a notification to the patron that their hold has been filled (through
ModReserveAffect, _not_ ModReserveFill)

=cut

sub _koha_notify_reserve {
    my ($itemnumber, $borrowernumber, $biblionumber) = @_;

    my $dbh = C4::Context->dbh;
    my $messagingprefs = C4::Members::Messaging::GetMessagingPreferences( { borrowernumber => $borrowernumber, message_name => 'Hold Filled' } );

    return if ( !defined( $messagingprefs->{'letter_code'} ) );

    my $sth = $dbh->prepare("
        SELECT *
        FROM   reserves
        WHERE  borrowernumber = ?
            AND biblionumber = ?
    ");
    $sth->execute( $borrowernumber, $biblionumber );
    my $reserve = $sth->fetchrow_hashref;
    my $branch_details = GetBranchDetail( $reserve->{'branchcode'} );

    my $admin_email_address = $branch_details->{'branchemail'} || C4::Context->preference('KohaAdminEmailAddress');

    my $letter = getletter( 'reserves', $messagingprefs->{'letter_code'} );

    C4::Letters::parseletter( $letter, 'branches', $reserve->{'branchcode'} );
    C4::Letters::parseletter( $letter, 'borrowers', $reserve->{'borrowernumber'} );
    C4::Letters::parseletter( $letter, 'biblio', $reserve->{'biblionumber'} );
    C4::Letters::parseletter( $letter, 'reserves', $reserve->{'borrowernumber'}, $reserve->{'biblionumber'} );

    if ( $reserve->{'itemnumber'} ) {
        C4::Letters::parseletter( $letter, 'items', $reserve->{'itemnumber'} );
    }
    $letter->{'content'} =~ s/<<[a-z0-9_]+\.[a-z0-9]+>>//g; #remove any stragglers

    if ( -1 !=  firstidx { $_ eq 'email' } @{$messagingprefs->{transports}} ) {
        # aka, 'email' in ->{'transports'}
        C4::Letters::EnqueueLetter(
            {   letter                 => $letter,
                borrowernumber         => $borrowernumber,
                message_transport_type => 'email',
                from_address           => $admin_email_address,
            }
        );
    }

    if ( -1 != firstidx { $_ eq 'sms' } @{$messagingprefs->{transports}} ) {
        C4::Letters::EnqueueLetter(
            {   letter                 => $letter,
                borrowernumber         => $borrowernumber,
                message_transport_type => 'sms',
            }
        );
    }
}

=item _ShiftPriorityByDateAndPriority

=over 4

$new_priority = _ShiftPriorityByDateAndPriority( $biblionumber, $reservedate, $priority );

=back

This increments the priority of all reserves after the one
 with either the lowest date after C<$reservedate>
 or the lowest priority after C<$priority>.

It effectively makes room for a new reserve to be inserted with a certain
 priority, which is returned.

This is most useful when the reservedate can be set by the user.  It allows
 the new reserve to be placed before other reserves that have a later
 reservedate.  Since priority also is set by the form in reserves/request.pl
 the sub accounts for that too.

=cut

sub _ShiftPriorityByDateAndPriority {
    my ( $biblio, $resdate, $new_priority ) = @_;

    my $dbh = C4::Context->dbh;
    my $query = "SELECT priority FROM reserves WHERE biblionumber = ? AND ( reservedate > ? OR priority > ? ) ORDER BY priority ASC";
    my $sth = $dbh->prepare( $query );
    $sth->execute( $biblio, $resdate, $new_priority );
    my ( $min_priority ) = $sth->fetchrow;
    $sth->finish;  # $sth might have more data.
    $new_priority = $min_priority if ( $min_priority );
    my $updated_priority = $new_priority + 1;

    $query = "
 UPDATE reserves
    SET priority = ?
  WHERE biblionumber = ?
    AND borrowernumber = ?
    AND reservedate = ?
    AND found IS NULL";
    my $sth_update = $dbh->prepare( $query );

    $query = "SELECT * FROM reserves WHERE priority >= ?";
    $sth = $dbh->prepare( $query );
    $sth->execute( $new_priority );
    while ( my $row = $sth->fetchrow_hashref ) {
	$sth_update->execute( $updated_priority, $biblio, $row->{borrowernumber}, $row->{reservedate} );
	$updated_priority++;
    }

    return $new_priority;  # so the caller knows what priority they end up at
}

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut

1;
