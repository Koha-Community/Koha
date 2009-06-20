package C4::Overdues;


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
use Date::Calc qw/Today Date_to_Days/;
use Date::Manip qw/UnixDate/;
use C4::Circulation;
use C4::Context;
use C4::Accounts;
use C4::Log; # logaction
use C4::Debug;

use vars qw($VERSION @ISA @EXPORT);

BEGIN {
	# set the version for version checking
	$VERSION = 3.01;
	require Exporter;
	@ISA    = qw(Exporter);
	# subs to rename (and maybe merge some...)
	push @EXPORT, qw(
        &CalcFine
        &Getoverdues
        &checkoverdues
        &CheckAccountLineLevelInfo
        &CheckAccountLineItemInfo
        &CheckExistantNotifyid
        &GetNextIdNotify
        &GetNotifyId
        &NumberNotifyId
        &AmountNotify
        &UpdateAccountLines
        &UpdateFine
        &GetOverdueDelays
        &GetOverduerules
        &GetFine
        &CreateItemAccountLine
        &ReplacementCost2
        
        &CheckItemNotify
        &GetOverduesForBranch
        &RemoveNotifyLine
        &AddNotifyLine
	);
	# subs to remove
	push @EXPORT, qw(
        &BorType
	);

	# check that an equivalent don't exist already before moving

	# subs to move to Circulation.pm
	push @EXPORT, qw(
        &GetIssuesIteminfo
	);
    #
	# &GetIssuingRules - delete.
	# use C4::Circulation::GetIssuingRule instead.
	
	# subs to move to Members.pm
	push @EXPORT, qw(
        &CheckBorrowerDebarred
        &UpdateBorrowerDebarred
	);
	# subs to move to Biblio.pm
	push @EXPORT, qw(
        &GetItems
        &ReplacementCost
	);
}

=head1 NAME

C4::Circulation::Fines - Koha module dealing with fines

=head1 SYNOPSIS

  use C4::Overdues;

=head1 DESCRIPTION

This module contains several functions for dealing with fines for
overdue items. It is primarily used by the 'misc/fines2.pl' script.

=head1 FUNCTIONS

=head2 Getoverdues

  $overdues = Getoverdues( { minimumdays => 1, maximumdays => 30 } );

Returns the list of all overdue books, with their itemtype.

C<$overdues> is a reference-to-array. Each element is a
reference-to-hash whose keys are the fields of the issues table in the
Koha database.

=cut

#'
sub Getoverdues {
    my $params = shift;
    my $dbh = C4::Context->dbh;
    my $statement;
    if ( C4::Context->preference('item-level_itypes') ) {
        $statement = "
   SELECT issues.*, items.itype as itemtype, items.homebranch, items.barcode
     FROM issues 
LEFT JOIN items       USING (itemnumber)
    WHERE date_due < now() 
";
    } else {
        $statement = "
   SELECT issues.*, biblioitems.itemtype, items.itype, items.homebranch, items.barcode
     FROM issues 
LEFT JOIN items       USING (itemnumber)
LEFT JOIN biblioitems USING (biblioitemnumber)
    WHERE date_due < now() 
";
    }

    my @bind_parameters;
    if ( exists $params->{'minimumdays'} and exists $params->{'maximumdays'} ) {
        $statement .= ' AND TO_DAYS( NOW() )-TO_DAYS( date_due ) BETWEEN ? and ? ';
        push @bind_parameters, $params->{'minimumdays'}, $params->{'maximumdays'};
    } elsif ( exists $params->{'minimumdays'} ) {
        $statement .= ' AND ( TO_DAYS( NOW() )-TO_DAYS( date_due ) ) > ? ';
        push @bind_parameters, $params->{'minimumdays'};
    } elsif ( exists $params->{'maximumdays'} ) {
        $statement .= ' AND ( TO_DAYS( NOW() )-TO_DAYS( date_due ) ) < ? ';
        push @bind_parameters, $params->{'maximumdays'};
    }
    $statement .= 'ORDER BY borrowernumber';
    my $sth = $dbh->prepare( $statement );
    $sth->execute( @bind_parameters );
    return $sth->fetchall_arrayref({});
}


=head2 checkoverdues

($count, $overdueitems) = checkoverdues($borrowernumber);

Returns a count and a list of overdueitems for a given borrowernumber

=cut

sub checkoverdues {
    my $borrowernumber = shift or return;
    my $sth = C4::Context->dbh->prepare(
        "SELECT * FROM issues
         LEFT JOIN items       ON issues.itemnumber      = items.itemnumber
         LEFT JOIN biblio      ON items.biblionumber     = biblio.biblionumber
         LEFT JOIN biblioitems ON items.biblioitemnumber = biblioitems.biblioitemnumber
            WHERE issues.borrowernumber  = ?
            AND   issues.date_due < NOW()"
    );
    # FIXME: SELECT * across 4 tables?  do we really need the marc AND marcxml blobs??
    $sth->execute($borrowernumber);
    my $results = $sth->fetchall_arrayref({});
    return ( scalar(@$results), $results);  # returning the count and the results is silly
}

=head2 CalcFine

  ($amount, $chargename, $daycount, $daycounttotal) =
    &CalcFine($item, $categorycode, $branch, $days_overdue, $description, $start_date, $end_date );

Calculates the fine for a book.

The issuingrules table in the Koha database is a fine matrix, listing
the penalties for each type of patron for each type of item and each branch (e.g., the
standard fine for books might be $0.50, but $1.50 for DVDs, or staff
members might get a longer grace period between the first and second
reminders that a book is overdue).


C<$item> is an item object (hashref).

C<$categorycode> is the category code (string) of the patron who currently has
the book.

C<$branchcode> is the library (string) whose issuingrules govern this transaction.

C<$days_overdue> is the number of days elapsed since the book's due date.
  NOTE: supplying days_overdue is deprecated.

C<$start_date> & C<$end_date> are C4::Dates objects 
defining the date range over which to determine the fine.
Note that if these are defined, we ignore C<$difference> and C<$dues> , 
but retain these for backwards-comptibility with extant fines scripts.

Fines scripts should just supply the date range over which to calculate the fine.

C<&CalcFine> returns four values:

C<$amount> is the fine owed by the patron (see above).

C<$chargename> is the chargename field from the applicable record in
the categoryitem table, whatever that is.

C<$daycount> is the number of days between start and end dates, Calendar adjusted (where needed), 
minus any applicable grace period.

C<$daycounttotal> is C<$daycount> without consideration of grace period.

FIXME - What is chargename supposed to be ?

FIXME: previously attempted to return C<$message> as a text message, either "First Notice", "Second Notice",
or "Final Notice".  But CalcFine never defined any value.

=cut

sub CalcFine {
    my ( $item, $bortype, $branchcode, $difference ,$dues , $start_date, $end_date  ) = @_;
	$debug and warn sprintf("CalcFine(%s, %s, %s, %s, %s, %s, %s)",
			($item ? '{item}' : 'UNDEF'), 
			($bortype    || 'UNDEF'), 
			($branchcode || 'UNDEF'), 
			($difference || 'UNDEF'), 
			($dues       || 'UNDEF'), 
			($start_date ? ($start_date->output('iso') || 'Not a C4::Dates object') : 'UNDEF'), 
			(  $end_date ? (  $end_date->output('iso') || 'Not a C4::Dates object') : 'UNDEF')
	);
    my $dbh = C4::Context->dbh;
    my $amount = 0;
	my $daystocharge;
	# get issuingrules (fines part will be used)
    $debug and warn sprintf("CalcFine calling GetIssuingRule(%s, %s, %s)", $bortype, $item->{'itemtype'}, $branchcode);
    my $data = C4::Circulation::GetIssuingRule($bortype, $item->{'itemtype'}, $branchcode);
	if($difference) {
		# if $difference is supplied, the difference has already been calculated, but we still need to adjust for the calendar.
    	# use copy-pasted functions from calendar module.  (deprecated -- these functions will be removed from C4::Overdues ).
	    my $countspecialday    =    &GetSpecialHolidays($dues,$item->{itemnumber});
	    my $countrepeatableday = &GetRepeatableHolidays($dues,$item->{itemnumber},$difference);    
	    my $countalldayclosed  = $countspecialday + $countrepeatableday;
	    $daystocharge = $difference - $countalldayclosed;
	} else {
		# if $difference is not supplied, we have C4::Dates objects giving us the date range, and we use the calendar module.
		if(C4::Context->preference('finesCalendar') eq 'noFinesWhenClosed') {
			my $calendar = C4::Calendar->new( branchcode => $branchcode );
			$daystocharge = $calendar->daysBetween( $start_date, $end_date );
		} else {
			$daystocharge = Date_to_Days(split('-',$end_date->output('iso'))) - Date_to_Days(split('-',$start_date->output('iso')));
		}
	}
	# correct for grace period.
	my $days_minus_grace = $daystocharge - $data->{'firstremind'};
    if ($data->{'chargeperiod'} > 0 && $days_minus_grace > 0 ) { 
        $amount = int($days_minus_grace / $data->{'chargeperiod'}) * $data->{'fine'};
    } else {
        # a zero (or null)  chargeperiod means no charge.
    }
	$amount = C4::Context->preference('maxFine') if(C4::Context->preference('maxFine') && ( $amount > C4::Context->preference('maxFine')));
	$debug and warn sprintf("CalcFine returning (%s, %s, %s, %s)", $amount, $data->{'chargename'}, $days_minus_grace, $daystocharge);
    return ($amount, $data->{'chargename'}, $days_minus_grace, $daystocharge);
    # FIXME: chargename is NEVER populated anywhere.
}


=head2 GetSpecialHolidays

&GetSpecialHolidays($date_dues,$itemnumber);

return number of special days  between date of the day and date due

C<$date_dues> is the envisaged date of book return.

C<$itemnumber> is the book's item number.

=cut

sub GetSpecialHolidays {
    my ( $date_dues, $itemnumber ) = @_;

    # calcul the today date
    my $today = join "-", &Today();

    # return the holdingbranch
    my $iteminfo = GetIssuesIteminfo($itemnumber);

    # use sql request to find all date between date_due and today
    my $dbh = C4::Context->dbh;
    my $query =
      qq|SELECT DATE_FORMAT(concat(year,'-',month,'-',day),'%Y-%m-%d') as date
FROM `special_holidays`
WHERE DATE_FORMAT(concat(year,'-',month,'-',day),'%Y-%m-%d') >= ?
AND   DATE_FORMAT(concat(year,'-',month,'-',day),'%Y-%m-%d') <= ?
AND branchcode=?
|;
    my @result = GetWdayFromItemnumber($itemnumber);
    my @result_date;
    my $wday;
    my $dateinsec;
    my $sth = $dbh->prepare($query);
    $sth->execute( $date_dues, $today, $iteminfo->{'branchcode'} )
      ;    # FIXME: just use NOW() in SQL instead of passing in $today

    while ( my $special_date = $sth->fetchrow_hashref ) {
        push( @result_date, $special_date );
    }

    my $specialdaycount = scalar(@result_date);

    for ( my $i = 0 ; $i < scalar(@result_date) ; $i++ ) {
        $dateinsec = UnixDate( $result_date[$i]->{'date'}, "%o" );
        ( undef, undef, undef, undef, undef, undef, $wday, undef, undef ) =
          localtime($dateinsec);
        for ( my $j = 0 ; $j < scalar(@result) ; $j++ ) {
            if ( $wday == ( $result[$j]->{'weekday'} ) ) {
                $specialdaycount--;
            }
        }
    }

    return $specialdaycount;
}

=head2 GetRepeatableHolidays

&GetRepeatableHolidays($date_dues, $itemnumber, $difference,);

return number of day closed between date of the day and date due

C<$date_dues> is the envisaged date of book return.

C<$itemnumber> is item number.

C<$difference> numbers of between day date of the day and date due

=cut

sub GetRepeatableHolidays {
    my ( $date_dues, $itemnumber, $difference ) = @_;
    my $dateinsec = UnixDate( $date_dues, "%o" );
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime($dateinsec);
    my @result = GetWdayFromItemnumber($itemnumber);
    my @dayclosedcount;
    my $j;

    for ( my $i = 0 ; $i < scalar(@result) ; $i++ ) {
        my $k = $wday;

        for ( $j = 0 ; $j < $difference ; $j++ ) {
            if ( $result[$i]->{'weekday'} == $k ) {
                push( @dayclosedcount, $k );
            }
            $k++;
            ( $k = 0 ) if ( $k eq 7 );
        }
    }
    return scalar(@dayclosedcount);
}


=head2 GetWayFromItemnumber

&Getwdayfromitemnumber($itemnumber);

return the different week day from repeatable_holidays table

C<$itemnumber> is  item number.

=cut

sub GetWdayFromItemnumber {
    my ($itemnumber) = @_;
    my $iteminfo = GetIssuesIteminfo($itemnumber);
    my @result;
    my $query = qq|SELECT weekday
    FROM repeatable_holidays
    WHERE branchcode=?
|;
    my $sth = C4::Context->dbh->prepare($query);

    $sth->execute( $iteminfo->{'branchcode'} );
    while ( my $weekday = $sth->fetchrow_hashref ) {
        push( @result, $weekday );
    }
    return @result;
}


=head2 GetIssuesIteminfo

&GetIssuesIteminfo($itemnumber);

return all data from issues about item

C<$itemnumber> is  item number.

=cut

sub GetIssuesIteminfo {
    my ($itemnumber) = @_;
    my $dbh          = C4::Context->dbh;
    my $query        = qq|SELECT *
    FROM issues
    WHERE itemnumber=?
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute($itemnumber);
    my ($issuesinfo) = $sth->fetchrow_hashref;
    return $issuesinfo;
}


=head2 UpdateFine

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

#
# Question: Why should the caller have to
# specify both the item number and the borrower number? A book can't
# be on loan to two different people, so the item number should be
# sufficient.
#
# Possible Answer: You might update a fine for a damaged item, *after* it is returned.
#
sub UpdateFine {
    my ( $itemnum, $borrowernumber, $amount, $type, $due ) = @_;
	$debug and warn "UpdateFine($itemnum, $borrowernumber, $amount, " . ($type||'""') . ", $due) called";
    my $dbh = C4::Context->dbh;
    # FIXME - What exactly is this query supposed to do? It looks up an
    # entry in accountlines that matches the given item and borrower
    # numbers, where the description contains $due, and where the
    # account type has one of several values, but what does this _mean_?
    # Does it look up existing fines for this item?
    # FIXME - What are these various account types? ("FU", "O", "F", "M")
	#	"L"   is LOST item
	#   "A"   is Account Management Fee
	#   "N"   is New Card
	#   "M"   is Sundry
	#   "O"   is Overdue ??
	#   "F"   is Fine ??
	#   "FU"  is Fine UPDATE??
	#	"Pay" is Payment
	#   "REF" is Cash Refund
    my $sth = $dbh->prepare(
        "SELECT * FROM accountlines
		WHERE itemnumber=?
		AND   borrowernumber=?
		AND   accounttype IN ('FU','O','F','M')
		AND   description like ? "
    );
    $sth->execute( $itemnum, $borrowernumber, "%$due%" );

    if ( my $data = $sth->fetchrow_hashref ) {

		# we're updating an existing fine.  Only modify if we're adding to the charge.
        # Note that in the current implementation, you cannot pay against an accruing fine
        # (i.e. , of accounttype 'FU').  Doing so will break accrual.
    	if ( $data->{'amount'} != $amount ) {
            my $diff = $amount - $data->{'amount'};
            $diff = 0 if ( $data->{amount} > $amount);
            my $out  = $data->{'amountoutstanding'} + $diff;
            my $query = "
                UPDATE accountlines
				SET date=now(), amount=?, amountoutstanding=?,
					lastincrement=?, accounttype='FU'
	  			WHERE borrowernumber=?
				AND   itemnumber=?
				AND   accounttype IN ('FU','O')
				AND   description LIKE ?
				LIMIT 1 ";
            my $sth2 = $dbh->prepare($query);
			# FIXME: BOGUS query cannot ensure uniqueness w/ LIKE %x% !!!
			# 		LIMIT 1 added to prevent multiple affected lines
			# FIXME: accountlines table needs unique key!! Possibly a combo of borrowernumber and accountline.  
			# 		But actually, we should just have a regular autoincrementing PK and forget accountline,
			# 		including the bogus getnextaccountno function (doesn't prevent conflict on simultaneous ops).
			# FIXME: Why only 2 account types here?
			$debug and print STDERR "UpdateFine query: $query\n" .
				"w/ args: $amount, $out, $diff, $data->{'borrowernumber'}, $data->{'itemnumber'}, \"\%$due\%\"\n";
            $sth2->execute($amount, $out, $diff, $data->{'borrowernumber'}, $data->{'itemnumber'}, "%$due%");
        } else {
            #      print "no update needed $data->{'amount'}"
        }
    } else {
        my $sth4 = $dbh->prepare(
            "SELECT title FROM biblio LEFT JOIN items ON biblio.biblionumber=items.biblionumber WHERE items.itemnumber=?"
        );
        $sth4->execute($itemnum);
        my $title = $sth4->fetchrow;

#         #   print "not in account";
#         my $sth3 = $dbh->prepare("Select max(accountno) from accountlines");
#         $sth3->execute;
# 
#         # FIXME - Make $accountno a scalar.
#         my @accountno = $sth3->fetchrow_array;
#         $sth3->finish;
#         $accountno[0]++;
# begin transaction
		my $nextaccntno = C4::Accounts::getnextacctno($borrowernumber);
		my $desc = ($type ? "$type " : '') . "$title $due";	# FIXEDME, avoid whitespace prefix on empty $type
		my $query = "INSERT INTO accountlines
		    (borrowernumber,itemnumber,date,amount,description,accounttype,amountoutstanding,lastincrement,accountno)
			    VALUES (?,?,now(),?,?,'FU',?,?,?)";
		my $sth2 = $dbh->prepare($query);
		$debug and print STDERR "UpdateFine query: $query\nw/ args: $borrowernumber, $itemnum, $amount, $desc, $amount, $amount, $nextaccntno\n";
        $sth2->execute($borrowernumber, $itemnum, $amount, $desc, $amount, $amount, $nextaccntno);
    }
    # logging action
    &logaction(
        "FINES",
        $type,
        $borrowernumber,
        "due=".$due."  amount=".$amount." itemnumber=".$itemnum
        ) if C4::Context->preference("FinesLog");
}

=head2 BorType

  $borrower = &BorType($borrowernumber);

Looks up a patron by borrower number.

C<$borrower> is a reference-to-hash whose keys are all of the fields
from the borrowers and categories tables of the Koha database. Thus,
C<$borrower> contains all information about both the borrower and
category he or she belongs to.

=cut

#'
sub BorType {
    my ($borrowernumber) = @_;
    my $dbh              = C4::Context->dbh;
    my $sth              = $dbh->prepare(
        "SELECT * from borrowers
      LEFT JOIN categories ON borrowers.categorycode=categories.categorycode 
      WHERE borrowernumber=?"
    );
    $sth->execute($borrowernumber);
    return $sth->fetchrow_hashref;
}

=head2 ReplacementCost

  $cost = &ReplacementCost($itemnumber);

Returns the replacement cost of the item with the given item number.

=cut

#'
sub ReplacementCost {
    my ($itemnum) = @_;
    my $dbh       = C4::Context->dbh;
    my $sth       =
      $dbh->prepare("Select replacementprice from items where itemnumber=?");
    $sth->execute($itemnum);

    # FIXME - Use fetchrow_array or a slice.
    my $data = $sth->fetchrow_hashref;
    return ( $data->{'replacementprice'} );
}

=head2 GetFine

$data->{'sum(amountoutstanding)'} = &GetFine($itemnum,$borrowernumber);

return the total of fine

C<$itemnum> is item number

C<$borrowernumber> is the borrowernumber

=cut 


sub GetFine {
    my ( $itemnum, $borrowernumber ) = @_;
    my $dbh   = C4::Context->dbh();
    my $query = "SELECT sum(amountoutstanding) FROM accountlines
    where accounttype like 'F%'  
  AND amountoutstanding > 0 AND itemnumber = ? AND borrowernumber=?";
    my $sth = $dbh->prepare($query);
    $sth->execute( $itemnum, $borrowernumber );
    my $data = $sth->fetchrow_hashref();
    return ( $data->{'sum(amountoutstanding)'} );
}


=head2 GetIssuingRules

FIXME - This sub should be deprecated and removed.
It ignores branch and defaults.

$data = &GetIssuingRules($itemtype,$categorycode);

Looks up for all issuingrules an item info 

C<$itemnumber> is a reference-to-hash whose keys are all of the fields
from the borrowers and categories tables of the Koha database. Thus,

C<$categorycode> contains  information about borrowers category 

C<$data> contains all information about both the borrower and
category he or she belongs to.
=cut 

sub GetIssuingRules {
	warn "GetIssuingRules is deprecated: use GetIssuingRule from C4::Circulation instead.";
   my ($itemtype,$categorycode)=@_;
   my $dbh   = C4::Context->dbh();    
   my $query=qq|SELECT *
        FROM issuingrules
        WHERE issuingrules.itemtype=?
            AND issuingrules.categorycode=?
        |;
    my $sth = $dbh->prepare($query);
    #  print $query;
    $sth->execute($itemtype,$categorycode);
    return $sth->fetchrow_hashref;
}


sub ReplacementCost2 {
    my ( $itemnum, $borrowernumber ) = @_;
    my $dbh   = C4::Context->dbh();
    my $query = "SELECT amountoutstanding
         FROM accountlines
             WHERE accounttype like 'L'
         AND amountoutstanding > 0
         AND itemnumber = ?
         AND borrowernumber= ?";
    my $sth = $dbh->prepare($query);
    $sth->execute( $itemnum, $borrowernumber );
    my $data = $sth->fetchrow_hashref();
    return ( $data->{'amountoutstanding'} );
}


=head2 GetNextIdNotify

($result) = &GetNextIdNotify($reference);

Returns the new file number

C<$result> contains the next file number

C<$reference> contains the beggining of file number

=cut

sub GetNextIdNotify {
    my ($reference) = @_;
    my $query = qq|SELECT max(notify_id)
         FROM accountlines
         WHERE notify_id  like \"$reference%\"
         |;

    # AND borrowernumber=?|;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute();
    my $result = $sth->fetchrow;
    my $count;
    if ( $result eq '' ) {
        ( $result = $reference . "01" );
    }
    else {
        $count = substr( $result, 6 ) + 1;

        if ( $count < 10 ) {
            ( $count = "0" . $count );
        }
        $result = $reference . $count;
    }
    return $result;
}

=head2 NumberNotifyId

(@notify) = &NumberNotifyId($borrowernumber);

Returns amount for all file per borrowers
C<@notify> array contains all file per borrowers

C<$notify_id> contains the file number for the borrower number nad item number

=cut

sub NumberNotifyId{
    my ($borrowernumber)=@_;
    my $dbh = C4::Context->dbh;
    my $query=qq|    SELECT distinct(notify_id)
            FROM accountlines
            WHERE borrowernumber=?|;
    my @notify;
    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    while ( my ($numberofnotify) = $sth->fetchrow ) {
        push( @notify, $numberofnotify );
    }
    return (@notify);
}

=head2 AmountNotify

($totalnotify) = &AmountNotify($notifyid);

Returns amount for all file per borrowers
C<$notifyid> is the file number

C<$totalnotify> contains amount of a file

C<$notify_id> contains the file number for the borrower number and item number

=cut

sub AmountNotify{
    my ($notifyid,$borrowernumber)=@_;
    my $dbh = C4::Context->dbh;
    my $query=qq|    SELECT sum(amountoutstanding)
            FROM accountlines
            WHERE notify_id=? AND borrowernumber = ?|;
    my $sth=$dbh->prepare($query);
	$sth->execute($notifyid,$borrowernumber);
	my $totalnotify=$sth->fetchrow;
    $sth->finish;
    return ($totalnotify);
}


=head2 GetNotifyId

($notify_id) = &GetNotifyId($borrowernumber,$itemnumber);

Returns the file number per borrower and itemnumber

C<$borrowernumber> is a reference-to-hash whose keys are all of the fields
from the items tables of the Koha database. Thus,

C<$itemnumber> contains the borrower categorycode

C<$notify_id> contains the file number for the borrower number nad item number

=cut

sub GetNotifyId {
    my ( $borrowernumber, $itemnumber ) = @_;
    my $query = qq|SELECT notify_id
           FROM accountlines
           WHERE borrowernumber=?
          AND itemnumber=?
           AND (accounttype='FU' or accounttype='O')|;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare($query);
    $sth->execute( $borrowernumber, $itemnumber );
    my ($notify_id) = $sth->fetchrow;
    $sth->finish;
    return ($notify_id);
}

=head2 CreateItemAccountLine

() = &CreateItemAccountLine($borrowernumber,$itemnumber,$date,$amount,$description,$accounttype,$amountoutstanding,$timestamp,$notify_id,$level);

update the account lines with file number or with file level

C<$items> is a reference-to-hash whose keys are all of the fields
from the items tables of the Koha database. Thus,

C<$itemnumber> contains the item number

C<$borrowernumber> contains the borrower number

C<$date> contains the date of the day

C<$amount> contains item price

C<$description> contains the descritpion of accounttype 

C<$accounttype> contains the account type

C<$amountoutstanding> contains the $amountoutstanding 

C<$timestamp> contains the timestamp with time and the date of the day

C<$notify_id> contains the file number

C<$level> contains the file level

=cut

sub CreateItemAccountLine {
    my (
        $borrowernumber, $itemnumber,  $date,              $amount,
        $description,    $accounttype, $amountoutstanding, $timestamp,
        $notify_id,      $level
    ) = @_;
    my $dbh         = C4::Context->dbh;
    my $nextaccntno = C4::Accounts::getnextacctno($borrowernumber);
    my $query       = "INSERT into accountlines
         (borrowernumber,accountno,itemnumber,date,amount,description,accounttype,amountoutstanding,timestamp,notify_id,notify_level)
          VALUES
             (?,?,?,?,?,?,?,?,?,?,?)";

    my $sth = $dbh->prepare($query);
    $sth->execute(
        $borrowernumber, $nextaccntno,       $itemnumber,
        $date,           $amount,            $description,
        $accounttype,    $amountoutstanding, $timestamp,
        $notify_id,      $level
    );
}

=head2 UpdateAccountLines

() = &UpdateAccountLines($notify_id,$notify_level,$borrowernumber,$itemnumber);

update the account lines with file number or with file level

C<$items> is a reference-to-hash whose keys are all of the fields
from the items tables of the Koha database. Thus,

C<$itemnumber> contains the item number

C<$notify_id> contains the file number

C<$notify_level> contains the file level

C<$borrowernumber> contains the borrowernumber

=cut

sub UpdateAccountLines {
    my ( $notify_id, $notify_level, $borrowernumber, $itemnumber ) = @_;
    my $query;
    if ( $notify_id eq '' ) {
        $query = qq|UPDATE accountlines
    SET  notify_level=?
    WHERE borrowernumber=? AND itemnumber=?
    AND (accounttype='FU' or accounttype='O')|;
    } else {
        $query = qq|UPDATE accountlines
     SET notify_id=?, notify_level=?
   WHERE borrowernumber=?
    AND itemnumber=?
    AND (accounttype='FU' or accounttype='O')|;
    }

    my $sth = C4::Context->dbh->prepare($query);
    if ( $notify_id eq '' ) {
        $sth->execute( $notify_level, $borrowernumber, $itemnumber );
    } else {
        $sth->execute( $notify_id, $notify_level, $borrowernumber, $itemnumber );
    }
}

=head2 GetItems

($items) = &GetItems($itemnumber);

Returns the list of all delays from overduerules.

C<$items> is a reference-to-hash whose keys are all of the fields
from the items tables of the Koha database. Thus,

C<$itemnumber> contains the borrower categorycode

=cut

# FIXME: This is a bad function to have here.
# Shouldn't it be in C4::Items?
# Shouldn't it be called GetItem since you only get 1 row?
# Shouldn't it be called GetItem since you give it only 1 itemnumber?

sub GetItems {
    my $itemnumber = shift or return;
    my $query = qq|SELECT *
             FROM items
              WHERE itemnumber=?|;
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute($itemnumber);
    my ($items) = $sth->fetchrow_hashref;
    return ($items);
}

=head2 GetOverdueDelays

(@delays) = &GetOverdueDelays($categorycode);

Returns the list of all delays from overduerules.

C<@delays> it's an array contains the three delays from overduerules table

C<$categorycode> contains the borrower categorycode

=cut

sub GetOverdueDelays {
    my ($category) = @_;
    my $query      = qq|SELECT delay1,delay2,delay3
                FROM overduerules
                WHERE categorycode=?|;
    my $sth = C4::Context->dbh->prepare($query);
    $sth->execute($category);
    my (@delays) = $sth->fetchrow_array;
    return (@delays);
}

=head2 GetBranchcodesWithOverdueRules

=over 4

my @branchcodes = C4::Overdues::GetBranchcodesWithOverdueRules()

returns a list of branch codes for branches with overdue rules defined.

=back

=cut

sub GetBranchcodesWithOverdueRules {
    my $dbh               = C4::Context->dbh;
    my $rqoverduebranches = $dbh->prepare("SELECT DISTINCT branchcode FROM overduerules WHERE delay1 IS NOT NULL AND branchcode <> ''");
    $rqoverduebranches->execute;
    my @branches = map { shift @$_ } @{ $rqoverduebranches->fetchall_arrayref };
    return @branches;
}

=head2 CheckAccountLineLevelInfo

($exist) = &CheckAccountLineLevelInfo($borrowernumber,$itemnumber,$accounttype,notify_level);

Check and Returns the list of all overdue books.

C<$exist> contains number of line in accounlines
with the same .biblionumber,itemnumber,accounttype,and notify_level

C<$borrowernumber> contains the borrower number

C<$itemnumber> contains item number

C<$accounttype> contains account type

C<$notify_level> contains the accountline level 


=cut

sub CheckAccountLineLevelInfo {
    my ( $borrowernumber, $itemnumber, $level ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = qq|SELECT count(*)
            FROM accountlines
            WHERE borrowernumber =?
            AND itemnumber = ?
            AND notify_level=?|;
    my $sth = $dbh->prepare($query);
    $sth->execute( $borrowernumber, $itemnumber, $level );
    my ($exist) = $sth->fetchrow;
    return ($exist);
}

=head2 GetOverduerules

($overduerules) = &GetOverduerules($categorycode);

Returns the value of borrowers (debarred or not) with notify level

C<$overduerules> return value of debbraed field in overduerules table

C<$category> contains the borrower categorycode

C<$notify_level> contains the notify level

=cut

sub GetOverduerules {
    my ( $category, $notify_level ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = qq|SELECT debarred$notify_level
                     FROM overduerules
                    WHERE categorycode=?|;
    my $sth = $dbh->prepare($query);
    $sth->execute($category);
    my ($overduerules) = $sth->fetchrow;
    return ($overduerules);
}


=head2 CheckBorrowerDebarred

($debarredstatus) = &CheckBorrowerDebarred($borrowernumber);

Check if the borrowers is already debarred

C<$debarredstatus> return 0 for not debarred and return 1 for debarred

C<$borrowernumber> contains the borrower number

=cut

# FIXME: Shouldn't this be in C4::Members?
sub CheckBorrowerDebarred {
    my ($borrowernumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = qq|
        SELECT debarred
        FROM borrowers
        WHERE borrowernumber=?
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    my ($debarredstatus) = $sth->fetchrow;
    return ( $debarredstatus eq '1' ? 1 : 0 );
}

=head2 UpdateBorrowerDebarred

($borrowerstatut) = &UpdateBorrowerDebarred($borrowernumber);

update status of borrowers in borrowers table (field debarred)

C<$borrowernumber> borrower number

=cut

sub UpdateBorrowerDebarred{
    my($borrowernumber) = @_;
    my $dbh = C4::Context->dbh;
        my $query=qq|UPDATE borrowers
             SET debarred='1'
                     WHERE borrowernumber=?
            |;
    my $sth=$dbh->prepare($query);
        $sth->execute($borrowernumber);
        $sth->finish;
        return 1;
}

=head2 CheckExistantNotifyid

  ($exist) = &CheckExistantNotifyid($borrowernumber,$itemnumber,$accounttype,$notify_id);

Check and Returns the notify id if exist else return 0.

C<$exist> contains a notify_id 

C<$borrowernumber> contains the borrower number

C<$date_due> contains the date of item return 


=cut

sub CheckExistantNotifyid {
    my ( $borrowernumber, $date_due ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = qq|SELECT notify_id FROM accountlines
             LEFT JOIN issues ON issues.itemnumber= accountlines.itemnumber
             WHERE accountlines.borrowernumber =?
              AND date_due = ?|;
    my $sth = $dbh->prepare($query);
    $sth->execute( $borrowernumber, $date_due );
    return $sth->fetchrow || 0;
}

=head2 CheckAccountLineItemInfo

  ($exist) = &CheckAccountLineItemInfo($borrowernumber,$itemnumber,$accounttype,$notify_id);

Check and Returns the list of all overdue items from the same file number(notify_id).

C<$exist> contains number of line in accounlines
with the same .biblionumber,itemnumber,accounttype,notify_id

C<$borrowernumber> contains the borrower number

C<$itemnumber> contains item number

C<$accounttype> contains account type

C<$notify_id> contains the file number 

=cut

sub CheckAccountLineItemInfo {
    my ( $borrowernumber, $itemnumber, $accounttype, $notify_id ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = qq|SELECT count(*) FROM accountlines
             WHERE borrowernumber =?
             AND itemnumber = ?
              AND accounttype= ?
            AND notify_id = ?|;
    my $sth = $dbh->prepare($query);
    $sth->execute( $borrowernumber, $itemnumber, $accounttype, $notify_id );
    my ($exist) = $sth->fetchrow;
    return ($exist);
}

=head2 CheckItemNotify

Sql request to check if the document has alreday been notified
this function is not exported, only used with GetOverduesForBranch

=cut

sub CheckItemNotify {
    my ($notify_id,$notify_level,$itemnumber) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("
    SELECT COUNT(*)
     FROM notifys
    WHERE notify_id    = ?
     AND  notify_level = ? 
     AND  itemnumber   = ? ");
    $sth->execute($notify_id,$notify_level,$itemnumber);
    my $notified = $sth->fetchrow;
    return ($notified);
}

=head2 GetOverduesForBranch

Sql request for display all information for branchoverdues.pl
2 possibilities : with or without location .
display is filtered by branch

FIXME: This function should be renamed.

=cut

sub GetOverduesForBranch {
    my ( $branch, $location) = @_;
	my $itype_link =  (C4::Context->preference('item-level_itypes')) ?  " items.itype " :  " biblioitems.itemtype ";
    my $dbh = C4::Context->dbh;
    my $select = "
    SELECT
            borrowers.borrowernumber,
            borrowers.surname,
            borrowers.firstname,
            borrowers.phone,
            borrowers.email,
               biblio.title,
               biblio.biblionumber,
               issues.date_due,
               issues.returndate,
               issues.branchcode,
             branches.branchname,
                items.barcode,
                items.itemcallnumber,
                items.location,
                items.itemnumber,
            itemtypes.description,
         accountlines.notify_id,
         accountlines.notify_level,
         accountlines.amountoutstanding
    FROM  accountlines
    LEFT JOIN issues      ON    issues.itemnumber     = accountlines.itemnumber
                          AND   issues.borrowernumber = accountlines.borrowernumber
    LEFT JOIN borrowers   ON borrowers.borrowernumber = accountlines.borrowernumber
    LEFT JOIN items       ON     items.itemnumber     = issues.itemnumber
    LEFT JOIN biblio      ON      biblio.biblionumber =  items.biblionumber
    LEFT JOIN biblioitems ON biblioitems.biblioitemnumber = items.biblioitemnumber
    LEFT JOIN itemtypes   ON itemtypes.itemtype       = $itype_link
    LEFT JOIN branches    ON  branches.branchcode     = issues.branchcode
    WHERE (accountlines.amountoutstanding  != '0.000000')
      AND (accountlines.accounttype         = 'FU'      )
      AND (issues.branchcode =  ?   )
      AND (issues.date_due  <= NOW())
    ";
    my @getoverdues;
    my $i = 0;
    my $sth;
    if ($location) {
        $sth = $dbh->prepare("$select AND items.location = ? ORDER BY borrowers.surname, borrowers.firstname");
        $sth->execute($branch, $location);
    } else {
        $sth = $dbh->prepare("$select ORDER BY borrowers.surname, borrowers.firstname");
        $sth->execute($branch);
    }
    while ( my $data = $sth->fetchrow_hashref ) {
    #check if the document has already been notified
        my $countnotify = CheckItemNotify($data->{'notify_id'}, $data->{'notify_level'}, $data->{'itemnumber'});
        if ($countnotify eq '0') {
            $getoverdues[$i] = $data;
            $i++;
        }
    }
    return (@getoverdues);
}


=head2 AddNotifyLine

&AddNotifyLine($borrowernumber, $itemnumber, $overduelevel, $method, $notifyId)

Creat a line into notify, if the method is phone, the notification_send_date is implemented to

=cut

sub AddNotifyLine {
    my ( $borrowernumber, $itemnumber, $overduelevel, $method, $notifyId ) = @_;
    my $dbh = C4::Context->dbh;
    if ( $method eq "phone" ) {
        my $sth = $dbh->prepare(
            "INSERT INTO notifys (borrowernumber,itemnumber,notify_date,notify_send_date,notify_level,method,notify_id)
        VALUES (?,?,now(),now(),?,?,?)"
        );
        $sth->execute( $borrowernumber, $itemnumber, $overduelevel, $method,
            $notifyId );
    }
    else {
        my $sth = $dbh->prepare(
            "INSERT INTO notifys (borrowernumber,itemnumber,notify_date,notify_level,method,notify_id)
        VALUES (?,?,now(),?,?,?)"
        );
        $sth->execute( $borrowernumber, $itemnumber, $overduelevel, $method,
            $notifyId );
    }
    return 1;
}

=head2 RemoveNotifyLine

&RemoveNotifyLine( $borrowernumber, $itemnumber, $notify_date );

Cancel a notification

=cut

sub RemoveNotifyLine {
    my ( $borrowernumber, $itemnumber, $notify_date ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "DELETE FROM notifys 
            WHERE
            borrowernumber=?
            AND itemnumber=?
            AND notify_date=?"
    );
    $sth->execute( $borrowernumber, $itemnumber, $notify_date );
    return 1;
}

1;
__END__

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
