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
use C4::Context;
use Date::Calc qw/Today/;
use vars qw($VERSION @ISA @EXPORT);
use C4::Accounts;
use Date::Manip qw/UnixDate/;
use C4::Log; # logaction

# set the version for version checking
$VERSION = do { my @v = '$Revision$' =~ /\d+/g; 
shift(@v) . "." . join("_", map {sprintf "%03d", $_ } @v); };

=head1 NAME

C4::Circulation::Fines - Koha module dealing with fines

=head1 SYNOPSIS

  use C4::Overdues;

=head1 DESCRIPTION

This module contains several functions for dealing with fines for
overdue items. It is primarily used by the 'misc/fines2.pl' script.

=head1 FUNCTIONS

=over 2

=cut

@ISA    = qw(Exporter);
# subs to rename (and maybe merge some...)
push @EXPORT, qw(
        &CalcFine
        &Getoverdues
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
);
# subs to remove
push @EXPORT, qw(
        &BorType
);

#
# All subs to move : check that an equivalent don't exist already before moving
#

# subs to move to Circulation.pm
push @EXPORT, qw(
        &GetIssuingRules
        &GetIssuesIteminfo
);
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

=item Getoverdues

  ($count, $overdues) = &Getoverdues();

Returns the list of all overdue books.

C<$count> is the number of elements in C<@{$overdues}>.

C<$overdues> is a reference-to-array. Each element is a
reference-to-hash whose keys are the fields of the issues table in the
Koha database.

=cut

#'
sub Getoverdues {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "Select * from issues where date_due < now() and returndate is
  NULL order by borrowernumber "
    );
    $sth->execute;

    # FIXME - Use push @results
    my $i = 0;
    my @results;
    while ( my $data = $sth->fetchrow_hashref ) {
        $results[$i] = $data;
        $i++;
    }
    $sth->finish;

    #  print @results;
    # FIXME - Bogus API.
    return ( $i, \@results );
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
    my ( $itemnumber, $bortype, $difference , $dues  ) = @_;
    my $dbh = C4::Context->dbh;
    my $data = GetIssuingRules($itemnumber,$bortype);
    my $amount = 0;
    my $printout;
    my $countspecialday=&GetSpecialHolidays($dues,$itemnumber);
    my $countrepeatableday=&GetRepeatableHolidays($dues,$itemnumber,$difference);    
    my $countalldayclosed = $countspecialday + $countrepeatableday;
    my $daycount = $difference - $countalldayclosed;    
    my $daycounttotal = $daycount - $data->{'firstremind'};
        if ($data->{'firstremind'} < $daycount)
    {
    $amount   = $daycounttotal*$data->{'fine'};
    }
 return ( $amount, $data->{'chargename'}, $printout ,$daycounttotal ,$daycount );
}


=item GetSpecialHolidays

&GetSpecialHolidays($date_dues,$itemnumber);

return number of special days  between date of the day and date due

C<$date_dues> is the envisaged date of book return.

C<$itemnumber> is the book's item number.

=cut

sub GetSpecialHolidays {
my ($date_dues,$itemnumber) = @_;
# calcul the today date
my $today = join "-", &Today();

# return the holdingbranch
my $iteminfo=GetIssuesIteminfo($itemnumber);
# use sql request to find all date between date_due and today
my $dbh = C4::Context->dbh;
my $query=qq|SELECT DATE_FORMAT(concat(year,'-',month,'-',day),'%Y-%m-%d')as date 
FROM `special_holidays`
WHERE DATE_FORMAT(concat(year,'-',month,'-',day),'%Y-%m-%d') >= ?
AND   DATE_FORMAT(concat(year,'-',month,'-',day),'%Y-%m-%d') <= ?
AND branchcode=?
|;
my @result=GetWdayFromItemnumber($itemnumber);
my @result_date;
my $wday;
my $dateinsec;
my $sth = $dbh->prepare($query);
$sth->execute($date_dues,$today,$iteminfo->{'branchcode'});

while ( my $special_date=$sth->fetchrow_hashref){
    push (@result_date,$special_date);
}

my $specialdaycount=scalar(@result_date);

    for (my $i=0;$i<scalar(@result_date);$i++){
        $dateinsec=UnixDate($result_date[$i]->{'date'},"%o");
        (undef,undef,undef,undef,undef,undef,$wday,undef,undef) =localtime($dateinsec);
        for (my $j=0;$j<scalar(@result);$j++){
            if ($wday == ($result[$j]->{'weekday'})){
            $specialdaycount --;
            }
        }
    }

return $specialdaycount;
}

=item GetRepeatableHolidays

&GetRepeatableHolidays($date_dues, $itemnumber, $difference,);

return number of day closed between date of the day and date due

C<$date_dues> is the envisaged date of book return.

C<$itemnumber> is item number.

C<$difference> numbers of between day date of the day and date due

=cut

sub GetRepeatableHolidays{
my ($date_dues,$itemnumber,$difference) = @_;
my $dateinsec=UnixDate($date_dues,"%o");
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime($dateinsec);
my @result=GetWdayFromItemnumber($itemnumber);
my @dayclosedcount;
my $j;

for (my $i=0;$i<scalar(@result);$i++){
    my $k=$wday;

        for ( $j=0;$j<$difference;$j++){
            if ($result[$i]->{'weekday'} == $k)
                    {
                    push ( @dayclosedcount ,$k);
            }
        $k++;
        ($k=0) if($k eq 7);
        }
    }
return scalar(@dayclosedcount);
}


=item GetWayFromItemnumber

&Getwdayfromitemnumber($itemnumber);

return the different week day from repeatable_holidays table

C<$itemnumber> is  item number.

=cut

sub GetWdayFromItemnumber{
my($itemnumber)=@_;
my $iteminfo=GetIssuesIteminfo($itemnumber);
my @result;
my $dbh = C4::Context->dbh;
my $query = qq|SELECT weekday  
    FROM repeatable_holidays
    WHERE branchcode=?
|;
my $sth = $dbh->prepare($query);
    #  print $query;

$sth->execute($iteminfo->{'branchcode'});
while ( my $weekday=$sth->fetchrow_hashref){
    push (@result,$weekday);
    }
return @result;
}


=item GetIssuesIteminfo

&GetIssuesIteminfo($itemnumber);

return all data from issues about item

C<$itemnumber> is  item number.

=cut

sub GetIssuesIteminfo{
my($itemnumber)=@_;
my $dbh = C4::Context->dbh;
my $query = qq|SELECT *  
    FROM issues
    WHERE itemnumber=?
    AND returndate IS NULL|;
my $sth = $dbh->prepare($query);
$sth->execute($itemnumber);
my ($issuesinfo)=$sth->fetchrow_hashref;
return $issuesinfo;
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
    my ( $itemnum, $borrowernumber, $amount, $type, $due ) = @_;
    my $dbh = C4::Context->dbh;
    # FIXME - What exactly is this query supposed to do? It looks up an
    # entry in accountlines that matches the given item and borrower
    # numbers, where the description contains $due, and where the
    # account type has one of several values, but what does this _mean_?
    # Does it look up existing fines for this item?
    # FIXME - What are these various account types? ("FU", "O", "F", "M")
    my $sth = $dbh->prepare(
        "Select * from accountlines where itemnumber=? and
  borrowernumber=? and (accounttype='FU' or accounttype='O' or
  accounttype='F' or accounttype='M') and description like ?"
    );
    $sth->execute( $itemnum, $borrowernumber, "%$due%" );

    if ( my $data = $sth->fetchrow_hashref ) {

        # I think this if-clause deals with the case where we're updating
        # an existing fine.
        #    print "in accounts ...";
    if ( $data->{'amount'} != $amount ) {
           
        #      print "updating";
            my $diff = $amount - $data->{'amount'};
            my $out  = $data->{'amountoutstanding'} + $diff;
            my $sth2 = $dbh->prepare(
                "update accountlines set date=now(), amount=?,
      amountoutstanding=?,accounttype='FU' where
      borrowernumber=? and itemnumber=?
      and (accounttype='FU' or accounttype='O') and description like ?"
            );
            $sth2->execute( $amount, $out, $data->{'borrowernumber'},
                $data->{'itemnumber'}, "%$due%" );
            $sth2->finish;
        }
        else {

            #      print "no update needed $data->{'amount'}"
        }
    }
    else {

        # I think this else-clause deals with the case where we're adding
        # a new fine.
        my $sth4 = $dbh->prepare(
            "select title from biblio,items where items.itemnumber=?
    and biblio.biblionumber=items.biblionumber"
        );
        $sth4->execute($itemnum);
        my $title = $sth4->fetchrow_hashref;
        $sth4->finish;

#         #   print "not in account";
#         my $sth3 = $dbh->prepare("Select max(accountno) from accountlines");
#         $sth3->execute;
# 
#         # FIXME - Make $accountno a scalar.
#         my @accountno = $sth3->fetchrow_array;
#         $sth3->finish;
#         $accountno[0]++;
# begin transaction
  my $nextaccntno = getnextacctno($borrowernumber);
    my $sth2 = $dbh->prepare(
            "INSERT INTO accountlines
    (borrowernumber,itemnumber,date,amount,
    description,accounttype,amountoutstanding,accountno) VALUES
    (?,?,now(),?,?,'FU',?,?)"
        );
        $sth2->execute( $borrowernumber, $itemnum, $amount,
            "$type $title->{'title'} $due",
            $amount, $nextaccntno);
        $sth2->finish;
    }
    # logging action
    &logaction(
        C4::Context->userenv->{'number'},
        "FINES",
        $type,
        $borrowernumber,
        "due=".$due."  amount=".$amount." itemnumber=".$itemnum
        ) if C4::Context->preference("FinesLog");

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
    my ($borrowernumber) = @_;
    my $dbh              = C4::Context->dbh;
    my $sth              = $dbh->prepare(
        "Select * from borrowers,categories where
  borrowernumber=? and
borrowers.categorycode=categories.categorycode"
    );
    $sth->execute($borrowernumber);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    return ($data);
}

=item ReplacementCost

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

    # FIXME - Use fetchrow_array or something.
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    return ( $data->{'replacementprice'} );
}

=item GetFine

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
    $sth->finish();
    $dbh->disconnect();
    return ( $data->{'sum(amountoutstanding)'} );
}




=item GetIssuingRules

$data = &GetIssuingRules($itemnumber,$categorycode);

Looks up for all issuingrules an item info 

C<$itemnumber> is a reference-to-hash whose keys are all of the fields
from the borrowers and categories tables of the Koha database. Thus,

C<$categorycode> contains  information about borrowers category 

C<$data> contains all information about both the borrower and
category he or she belongs to.
=cut 

sub GetIssuingRules {
   my ($itemnumber,$categorycode)=@_;
   my $dbh   = C4::Context->dbh();    
   my $query=qq|SELECT * 
        FROM items
        LEFT JOIN biblioitems ON items.biblioitemnumber=biblioitems.biblioitemnumber
        LEFT JOIN itemtypes ON  biblioitems.itemtype=itemtypes.itemtype
        LEFT JOIN issuingrules ON issuingrules.itemtype=itemtypes.itemtype
        WHERE items.itemnumber=?
        AND issuingrules.categorycode=?
        AND  (items.itemlost <> 1
        OR items.itemlost is NULL)|;
    my $sth = $dbh->prepare($query);
    #  print $query;
    $sth->execute($itemnumber,$categorycode);
    my ($data) = $sth->fetchrow_hashref;
   $sth->finish;
return ($data);

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
    $sth->finish();
    $dbh->disconnect();
    return ( $data->{'amountoutstanding'} );
}


=item GetNextIdNotify

($result) = &GetNextIdNotify($reference);

Returns the new file number

C<$result> contains the next file number

C<$reference> contains the beggining of file number

=cut



sub GetNextIdNotify {
my ($reference)=@_;
my $query=qq|SELECT max(notify_id) 
         FROM accountlines
         WHERE notify_id  like \"$reference%\"
         |;
# AND borrowernumber=?|;   
my $dbh = C4::Context->dbh;
my $sth=$dbh->prepare($query);
$sth->execute();
my $result=$sth->fetchrow;
$sth->finish;
my $count;
    if ($result eq '')
    {
    ($result=$reference."01")  ;
    }else
    {
    $count=substr($result,6)+1;
     
    if($count<10){
     ($count = "0".$count);
     }
     $result=$reference.$count;
     }
return $result;
}


=item AmountNotify

(@notify) = &AmountNotify($borrowernumber);

Returns amount for all file per borrowers
C<@notify> array contains all file per borrowers

C<$notify_id> contains the file number for the borrower number nad item number

=cut

sub NumberNotifyId{
    my ($borrowernumber)=@_;
    my $dbh = C4::Context->dbh;
    my $query=qq|    SELECT distinct(notify_id)
            FROM accountlines
            WHERE borrowernumber=?
	    AND notify_id != 0
	    AND notify_id != 1	|;
    my @notify;
    my $sth=$dbh->prepare($query);
        $sth->execute($borrowernumber);
          while ( my $numberofotify=$sth->fetchrow_array){
    push (@notify,$numberofotify);
    }
    $sth->finish;

    return (@notify);

}

=item AmountNotify

($totalnotify) = &AmountNotify($notifyid);

Returns amount for all file per borrowers
C<$notifyid> is the file number

C<$totalnotify> contains amount of a file

C<$notify_id> contains the file number for the borrower number nad item number

=cut

sub AmountNotify{
    my ($notifyid)=@_;
    my $dbh = C4::Context->dbh;
    my $query=qq|    SELECT sum(amountoutstanding)
            FROM accountlines
            WHERE notify_id=?|;
    my $sth=$dbh->prepare($query);
        $sth->execute($notifyid);
          my $totalnotify=$sth->fetchrow;
    $sth->finish;
    return ($totalnotify);
}


=item GetNotifyId

($notify_id) = &GetNotifyId($borrowernumber,$itemnumber);

Returns the file number per borrower and itemnumber

C<$borrowernumber> is a reference-to-hash whose keys are all of the fields
from the items tables of the Koha database. Thus,

C<$itemnumber> contains the borrower categorycode

C<$notify_id> contains the file number for the borrower number nad item number

=cut

 sub GetNotifyId {
 my ($borrowernumber,$itemnumber)=@_;
 my $query=qq|SELECT notify_id 
           FROM accountlines
           WHERE borrowernumber=?
          AND itemnumber=?
           AND (accounttype='FU' or accounttype='O')|;
 my $dbh = C4::Context->dbh;
 my $sth=$dbh->prepare($query);
 $sth->execute($borrowernumber,$itemnumber);
 my ($notify_id)=$sth->fetchrow;
 $sth->finish;
 return ($notify_id);

 }

=item CreateItemAccountLine

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
  my ($borrowernumber,$itemnumber,$date,$amount,$description,$accounttype,$amountoutstanding,$timestamp,$notify_id,$level)=@_;
  my $dbh = C4::Context->dbh;
  my $nextaccntno = getnextacctno($borrowernumber);
   my $query= "INSERT into accountlines  
         (borrowernumber,accountno,itemnumber,date,amount,description,accounttype,amountoutstanding,timestamp,notify_id,notify_level)
          VALUES
             (?,?,?,?,?,?,?,?,?,?,?)";
  
  
  my $sth=$dbh->prepare($query);
  $sth->execute($borrowernumber,$nextaccntno,$itemnumber,$date,$amount,$description,$accounttype,$amountoutstanding,$timestamp,$notify_id,$level);
  $sth->finish;
 }

=item UpdateAccountLines

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
my ($notify_id,$notify_level,$borrowernumber,$itemnumber)=@_;
my $query;
if ($notify_id eq '')
{

    $query=qq|UPDATE accountlines
    SET  notify_level=?
    WHERE borrowernumber=? AND itemnumber=?
    AND (accounttype='FU' or accounttype='O')|;
}else
{
    $query=qq|UPDATE accountlines
     SET notify_id=?, notify_level=?
           WHERE borrowernumber=?
    AND itemnumber=?
        AND (accounttype='FU' or accounttype='O')|;
}
 my $dbh = C4::Context->dbh;
 my $sth=$dbh->prepare($query);

if ($notify_id eq '')
{
    $sth->execute($notify_level,$borrowernumber,$itemnumber);
}else
{
    $sth->execute($notify_id,$notify_level,$borrowernumber,$itemnumber);
}
 $sth->finish;

}


=item GetItems

($items) = &GetItems($itemnumber);

Returns the list of all delays from overduerules.

C<$items> is a reference-to-hash whose keys are all of the fields
from the items tables of the Koha database. Thus,

C<$itemnumber> contains the borrower categorycode

=cut

sub GetItems {
    my($itemnumber) = @_;
    my $query=qq|SELECT *
             FROM items
              WHERE itemnumber=?|;
        my $dbh = C4::Context->dbh;
        my $sth=$dbh->prepare($query);
        $sth->execute($itemnumber);
        my ($items)=$sth->fetchrow_hashref;
        $sth->finish;
    return($items);
}

=item GetOverdueDelays

(@delays) = &GetOverdueDelays($categorycode);

Returns the list of all delays from overduerules.

C<@delays> it's an array contains the three delays from overduerules table

C<$categorycode> contains the borrower categorycode

=cut

sub GetOverdueDelays {
    my($category) = @_;
    my $dbh = C4::Context->dbh;
        my $query=qq|SELECT delay1,delay2,delay3
                FROM overduerules
                WHERE categorycode=?|;
    my $sth=$dbh->prepare($query);
        $sth->execute($category);
        my (@delays)=$sth->fetchrow_array;
        $sth->finish;
        return(@delays);
}

=item CheckAccountLineLevelInfo

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
    my($borrowernumber,$itemnumber,$level,$datedue) = @_;
	my @formatdate;
 	@formatdate=split('-',$datedue);
 	$datedue=$formatdate[2]."/".$formatdate[1]."/".$formatdate[0];
	my $dbh = C4::Context->dbh;
    	my $query=	qq|SELECT count(*) 
			FROM accountlines 
			WHERE borrowernumber =?
			AND itemnumber = ?
			AND notify_level=?
 			AND description like ?|;
	my $sth=$dbh->prepare($query);
     	$sth->execute($borrowernumber,$itemnumber,$level,"%$datedue%");
    	my ($exist)=$sth->fetchrow;
    	$sth->finish;
    	return($exist);
}

=item GetOverduerules

($overduerules) = &GetOverduerules($categorycode);

Returns the value of borrowers (debarred or not) with notify level

C<$overduerules> return value of debbraed field in overduerules table

C<$category> contains the borrower categorycode

C<$notify_level> contains the notify level
=cut


sub GetOverduerules{
    my($category,$notify_level) = @_;
    my $dbh = C4::Context->dbh;
        my $query=qq|SELECT debarred$notify_level
             FROM overduerules
             WHERE categorycode=?|;
    my $sth=$dbh->prepare($query);
        $sth->execute($category);
        my ($overduerules)=$sth->fetchrow;
        $sth->finish;
        return($overduerules);
}


=item CheckBorrowerDebarred

($debarredstatus) = &CheckBorrowerDebarred($borrowernumber);

Check if the borrowers is already debarred

C<$debarredstatus> return 0 for not debarred and return 1 for debarred

C<$borrowernumber> contains the borrower number

=cut


sub CheckBorrowerDebarred{
    my($borrowernumber) = @_;
    my $dbh = C4::Context->dbh;
        my $query=qq|SELECT debarred
              FROM borrowers
             WHERE borrowernumber=?
            |;
    my $sth=$dbh->prepare($query);
        $sth->execute($borrowernumber);
        my ($debarredstatus)=$sth->fetchrow;
        $sth->finish;
        if ($debarredstatus eq '1'){
    return(1);}
    else{
    return(0);
    }
}

=item UpdateBorrowerDebarred

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

=item CheckExistantNotifyid

  ($exist) = &CheckExistantNotifyid($borrowernumber,$itemnumber,$accounttype,$notify_id);

Check and Returns the notify id if exist else return 0.

C<$exist> contains a notify_id 

C<$borrowernumber> contains the borrower number

C<$date_due> contains the date of item return 


=cut

sub CheckExistantNotifyid {
    my($borrowernumber,$date_due) = @_;
 	my $dbh = C4::Context->dbh;
  	my @formatdate;
  	@formatdate=split('-',$date_due);
  	$date_due=$formatdate[2]."/".$formatdate[1]."/".$formatdate[0];
	my $query =  qq|SELECT notify_id FROM accountlines 
     			WHERE description like ?
     			AND borrowernumber =?
    			AND( accounttype='FU'  OR accounttype='F' )
                           AND notify_id != 0
   			AND notify_id != 1|;
 	my $sth=$dbh->prepare($query);
       	$sth->execute("%$date_due%",$borrowernumber);
     	my ($exist)=$sth->fetchrow;
     	$sth->finish;
     	if ($exist eq '')
	{
	return(0);
	}else
	    {
	return($exist);
	}
}

=item CheckAccountLineItemInfo

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
     my($borrowernumber,$itemnumber,$accounttype,$notify_id) = @_;
     my $dbh = C4::Context->dbh;
         my $query =  qq|SELECT count(*) FROM accountlines
             WHERE borrowernumber =?
             AND itemnumber = ?
              AND accounttype= ?
            AND notify_id = ?|;
    my $sth=$dbh->prepare($query);
         $sth->execute($borrowernumber,$itemnumber,$accounttype,$notify_id);
         my ($exist)=$sth->fetchrow;
         $sth->finish;
         return($exist);
 }


1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
