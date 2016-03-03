package C4::Reserves;

# Copyright 2000-2002 Katipo Communications
#           2006 SAN Ouest Provence
#           2007-2010 BibLibre Paul POULAIN
#           2011 Catalyst IT
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.


use strict;
#use warnings; FIXME - Bug 2505
use C4::Context;
use C4::Biblio;
use C4::Members;
use C4::Items;
use C4::Circulation;
use C4::Accounts;

# for _koha_notify_reserve
use C4::Members::Messaging;
use C4::Members qw();
use C4::Letters;

use Koha::DateUtils;
use Koha::Calendar;
use Koha::Database;
use Koha::Hold;
use Koha::Holds;
use Koha::Libraries;

use List::MoreUtils qw( firstidx any );
use Carp;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

=head1 NAME

C4::Reserves - Koha functions for dealing with reservation.

=head1 SYNOPSIS

  use C4::Reserves;

=head1 DESCRIPTION

This modules provides somes functions to deal with reservations.

  Reserves are stored in reserves table.
  The following columns contains important values :
  - priority >0      : then the reserve is at 1st stage, and not yet affected to any item.
             =0      : then the reserve is being dealed
  - found : NULL       : means the patron requested the 1st available, and we haven't chosen the item
            T(ransit)  : the reserve is linked to an item but is in transit to the pickup branch
            W(aiting)  : the reserve is linked to an item, is at the pickup branch, and is waiting on the hold shelf
            F(inished) : the reserve has been completed, and is done
  - itemnumber : empty : the reserve is still unaffected to an item
                 filled: the reserve is attached to an item
  The complete workflow is :
  ==== 1st use case ====
  patron request a document, 1st available :                      P >0, F=NULL, I=NULL
  a library having it run "transfertodo", and clic on the list
         if there is no transfer to do, the reserve waiting
         patron can pick it up                                    P =0, F=W,    I=filled
         if there is a transfer to do, write in branchtransfer    P =0, F=T,    I=filled
           The pickup library receive the book, it check in       P =0, F=W,    I=filled
  The patron borrow the book                                      P =0, F=F,    I=filled

  ==== 2nd use case ====
  patron requests a document, a given item,
    If pickup is holding branch                                   P =0, F=W,   I=filled
    If transfer needed, write in branchtransfer                   P =0, F=T,    I=filled
        The pickup library receive the book, it checks it in      P =0, F=W,    I=filled
  The patron borrow the book                                      P =0, F=F,    I=filled

=head1 FUNCTIONS

=cut

BEGIN {
    # set the version for version checking
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT = qw(
        &AddReserve

        &GetReserve
        &GetReservesFromItemnumber
        &GetReservesFromBiblionumber
        &GetReservesFromBorrowernumber
        &GetReservesForBranch
        &GetReservesToBranch
        &GetReserveCount
        &GetReserveInfo
        &GetReserveStatus

        &GetOtherReserves

        &ModReserveFill
        &ModReserveAffect
        &ModReserve
        &ModReserveStatus
        &ModReserveCancelAll
        &ModReserveMinusPriority
        &MoveReserve

        &CheckReserves
        &CanBookBeReserved
        &CanItemBeReserved
        &CanReserveBeCanceledFromOpac
        &CancelReserve
        &CancelExpiredReserves

        &AutoUnsuspendReserves

        &IsAvailableForItemLevelRequest

        &OPACItemHoldsAllowed

        &AlterPriority
        &ToggleLowestPriority

        &ReserveSlip
        &ToggleSuspend
        &SuspendAll

        &GetReservesControlBranch

        IsItemOnHoldAndFound
    );
    @EXPORT_OK = qw( MergeHolds );
}

=head2 AddReserve

    AddReserve($branch,$borrowernumber,$biblionumber,$bibitems,$priority,$resdate,$expdate,$notes,$title,$checkitem,$found)

Adds reserve and generates HOLDPLACED message.

The following tables are available witin the HOLDPLACED message:

    branches
    borrowers
    biblio
    biblioitems
    items

=cut

sub AddReserve {
    my (
        $branch,    $borrowernumber, $biblionumber,
        $bibitems,  $priority, $resdate, $expdate, $notes,
        $title,      $checkitem, $found
    ) = @_;

    if ( Koha::Holds->search( { borrowernumber => $borrowernumber, biblionumber => $biblionumber } )->count() > 0 ) {
        carp("AddReserve: borrower $borrowernumber already has a hold for biblionumber $biblionumber");
        return;
    }

    my $dbh     = C4::Context->dbh;

    $resdate = output_pref( { str => dt_from_string( $resdate ), dateonly => 1, dateformat => 'iso' })
        or output_pref({ dt => dt_from_string, dateonly => 1, dateformat => 'iso' });

    $expdate = output_pref({ str => $expdate, dateonly => 1, dateformat => 'iso' });

    if ( C4::Context->preference('AllowHoldDateInFuture') ) {

        # Make room in reserves for this before those of a later reserve date
        $priority = _ShiftPriorityByDateAndPriority( $biblionumber, $resdate, $priority );
    }

    my $waitingdate;

    # If the reserv had the waiting status, we had the value of the resdate
    if ( $found eq 'W' ) {
        $waitingdate = $resdate;
    }

    # updates take place here
    my $hold = Koha::Hold->new(
        {
            borrowernumber => $borrowernumber,
            biblionumber   => $biblionumber,
            reservedate    => $resdate,
            branchcode     => $branch,
            priority       => $priority,
            reservenotes   => $notes,
            itemnumber     => $checkitem,
            found          => $found,
            waitingdate    => $waitingdate,
            expirationdate => $expdate
        }
    )->store();
    my $reserve_id = $hold->id();

    # add a reserve fee if needed
    my $fee = GetReserveFee( $borrowernumber, $biblionumber );
    ChargeReserveFee( $borrowernumber, $fee, $title );

    _FixPriority({ biblionumber => $biblionumber});

    # Send e-mail to librarian if syspref is active
    if(C4::Context->preference("emailLibrarianWhenHoldIsPlaced")){
        my $borrower = C4::Members::GetMember(borrowernumber => $borrowernumber);
        my $library = Koha::Libraries->find($borrower->{branchcode})->unblessed;
        if ( my $letter =  C4::Letters::GetPreparedLetter (
            module => 'reserves',
            letter_code => 'HOLDPLACED',
            branchcode => $branch,
            tables => {
                'branches'    => $library,
                'borrowers'   => $borrower,
                'biblio'      => $biblionumber,
                'biblioitems' => $biblionumber,
                'items'       => $checkitem,
            },
        ) ) {

            my $admin_email_address = $library->{'branchemail'} || C4::Context->preference('KohaAdminEmailAddress');

            C4::Letters::EnqueueLetter(
                {   letter                 => $letter,
                    borrowernumber         => $borrowernumber,
                    message_transport_type => 'email',
                    from_address           => $admin_email_address,
                    to_address           => $admin_email_address,
                }
            );
        }
    }

    return $reserve_id;
}

=head2 GetReserve

    $res = GetReserve( $reserve_id );

    Return the current reserve.

=cut

sub GetReserve {
    my ($reserve_id) = @_;

    my $dbh = C4::Context->dbh;

    my $query = "SELECT * FROM reserves WHERE reserve_id = ?";
    my $sth = $dbh->prepare( $query );
    $sth->execute( $reserve_id );
    return $sth->fetchrow_hashref();
}

=head2 GetReservesFromBiblionumber

  my $reserves = GetReservesFromBiblionumber({
    biblionumber => $biblionumber,
    [ itemnumber => $itemnumber, ]
    [ all_dates => 1|0 ]
  });

This function gets the list of reservations for one C<$biblionumber>,
returning an arrayref pointing to the reserves for C<$biblionumber>.

By default, only reserves whose start date falls before the current
time are returned.  To return all reserves, including future ones,
the C<all_dates> parameter can be included and set to a true value.

If the C<itemnumber> parameter is supplied, reserves must be targeted
to that item or not targeted to any item at all; otherwise, they
are excluded from the list.

=cut

sub GetReservesFromBiblionumber {
    my ( $params ) = @_;
    my $biblionumber = $params->{biblionumber} or return [];
    my $itemnumber = $params->{itemnumber};
    my $all_dates = $params->{all_dates} // 0;
    my $dbh   = C4::Context->dbh;

    # Find the desired items in the reserves
    my @params;
    my $query = "
        SELECT  reserve_id,
                branchcode,
                timestamp AS rtimestamp,
                priority,
                biblionumber,
                borrowernumber,
                reservedate,
                found,
                itemnumber,
                reservenotes,
                expirationdate,
                lowestPriority,
                suspend,
                suspend_until
        FROM     reserves
        WHERE biblionumber = ? ";
    push( @params, $biblionumber );
    unless ( $all_dates ) {
        $query .= " AND reservedate <= CAST(NOW() AS DATE) ";
    }
    if ( $itemnumber ) {
        $query .= " AND ( itemnumber IS NULL OR itemnumber = ? )";
        push( @params, $itemnumber );
    }
    $query .= "ORDER BY priority";
    my $sth = $dbh->prepare($query);
    $sth->execute( @params );
    my @results;
    while ( my $data = $sth->fetchrow_hashref ) {
        push @results, $data;
    }
    return \@results;
}

=head2 GetReservesFromItemnumber

 ( $reservedate, $borrowernumber, $branchcode, $reserve_id, $waitingdate ) = GetReservesFromItemnumber($itemnumber);

Get the first reserve for a specific item number (based on priority). Returns the abovementioned values for that reserve.

The routine does not look at future reserves (read: item level holds), but DOES include future waits (a confirmed future hold).

=cut

sub GetReservesFromItemnumber {
    my ($itemnumber) = @_;

    my $schema = Koha::Database->new()->schema();

    my $r = $schema->resultset('Reserve')->search(
        {
            itemnumber => $itemnumber,
            suspend    => 0,
            -or        => [
                reservedate => \'<= CAST( NOW() AS DATE )',
                waitingdate => { '!=', undef }
            ]
        },
        {
            order_by => 'priority',
        }
    )->first();

    return unless $r;

    return (
        $r->reservedate(),
        $r->get_column('borrowernumber'),
        $r->get_column('branchcode'),
        $r->reserve_id(),
        $r->waitingdate(),
    );
}

=head2 GetReservesFromBorrowernumber

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

=head2 CanBookBeReserved

  $canReserve = &CanBookBeReserved($borrowernumber, $biblionumber)
  if ($canReserve eq 'OK') { #We can reserve this Item! }

See CanItemBeReserved() for possible return values.

=cut

sub CanBookBeReserved{
    my ($borrowernumber, $biblionumber) = @_;

    my $items = GetItemnumbersForBiblio($biblionumber);
    #get items linked via host records
    my @hostitems = get_hostitemnumbers_of($biblionumber);
    if (@hostitems){
    push (@$items,@hostitems);
    }

    my $canReserve;
    foreach my $item (@$items) {
        $canReserve = CanItemBeReserved( $borrowernumber, $item );
        return 'OK' if $canReserve eq 'OK';
    }
    return $canReserve;
}

=head2 CanItemBeReserved

  $canReserve = &CanItemBeReserved($borrowernumber, $itemnumber)
  if ($canReserve eq 'OK') { #We can reserve this Item! }

@RETURNS OK,              if the Item can be reserved.
         ageRestricted,   if the Item is age restricted for this borrower.
         damaged,         if the Item is damaged.
         cannotReserveFromOtherBranches, if syspref 'canreservefromotherbranches' is OK.
         tooManyReserves, if the borrower has exceeded his maximum reserve amount.
         notReservable,   if holds on this item are not allowed

=cut

sub CanItemBeReserved{
    my ($borrowernumber, $itemnumber) = @_;

    my $dbh             = C4::Context->dbh;
    my $ruleitemtype; # itemtype of the matching issuing rule
    my $allowedreserves = 0;
            
    # we retrieve borrowers and items informations #
    # item->{itype} will come for biblioitems if necessery
    my $item = GetItem($itemnumber);
    my $biblioData = C4::Biblio::GetBiblioData( $item->{biblionumber} );
    my $borrower = C4::Members::GetMember('borrowernumber'=>$borrowernumber);

    # If an item is damaged and we don't allow holds on damaged items, we can stop right here
    return 'damaged' if ( $item->{damaged} && !C4::Context->preference('AllowHoldsOnDamagedItems') );

    #Check for the age restriction
    my ($ageRestriction, $daysToAgeRestriction) = C4::Circulation::GetAgeRestriction( $biblioData->{agerestriction}, $borrower );
    return 'ageRestricted' if $daysToAgeRestriction && $daysToAgeRestriction > 0;

    my $controlbranch = C4::Context->preference('ReservesControlBranch');

    # we retrieve user rights on this itemtype and branchcode
    my $sth = $dbh->prepare("SELECT categorycode, itemtype, branchcode, reservesallowed
                             FROM issuingrules
                             WHERE (categorycode in (?,'*') )
                             AND (itemtype IN (?,'*'))
                             AND (branchcode IN (?,'*'))
                             ORDER BY
                               categorycode DESC,
                               itemtype     DESC,
                               branchcode   DESC;"
                           );

    my $querycount ="SELECT
                            count(*) as count
                            FROM reserves
                                LEFT JOIN items USING (itemnumber)
                                LEFT JOIN biblioitems ON (reserves.biblionumber=biblioitems.biblionumber)
                                LEFT JOIN borrowers USING (borrowernumber)
                            WHERE borrowernumber = ?
                                ";
    
    
    my $branchcode   = "";
    my $branchfield  = "reserves.branchcode";

    if( $controlbranch eq "ItemHomeLibrary" ){
        $branchfield = "items.homebranch";
        $branchcode = $item->{homebranch};
    }elsif( $controlbranch eq "PatronLibrary" ){
        $branchfield = "borrowers.branchcode";
        $branchcode = $borrower->{branchcode};
    }
    
    # we retrieve rights 
    $sth->execute($borrower->{'categorycode'}, $item->{'itype'}, $branchcode);
    if(my $rights = $sth->fetchrow_hashref()){
        $ruleitemtype    = $rights->{itemtype};
        $allowedreserves = $rights->{reservesallowed}; 
    }else{
        $ruleitemtype = '*';
    }

    # we retrieve count

    $querycount .= "AND $branchfield = ?";
    
    # If using item-level itypes, fall back to the record
    # level itemtype if the hold has no associated item
    $querycount .=
      C4::Context->preference('item-level_itypes')
      ? " AND COALESCE( itype, itemtype ) = ?"
      : " AND itemtype = ?"
      if ( $ruleitemtype ne "*" );

    my $sthcount = $dbh->prepare($querycount);
    
    if($ruleitemtype eq "*"){
        $sthcount->execute($borrowernumber, $branchcode);
    }else{
        $sthcount->execute($borrowernumber, $branchcode, $ruleitemtype);
    }

    my $reservecount = "0";
    if(my $rowcount = $sthcount->fetchrow_hashref()){
        $reservecount = $rowcount->{count};
    }
    # we check if it's ok or not
    if( $reservecount >= $allowedreserves ){
        return 'tooManyReserves';
    }

    my $circ_control_branch = C4::Circulation::_GetCircControlBranch($item,
        $borrower);
    my $branchitemrule = C4::Circulation::GetBranchItemRule($circ_control_branch,
        $item->{itype});

    if ( $branchitemrule->{holdallowed} == 0 ) {
        return 'notReservable';
    }

    if (   $branchitemrule->{holdallowed} == 1
        && $borrower->{branchcode} ne $item->{homebranch} )
    {
          return 'cannotReserveFromOtherBranches';
    }

    # If reservecount is ok, we check item branch if IndependentBranches is ON
    # and canreservefromotherbranches is OFF
    if ( C4::Context->preference('IndependentBranches')
        and !C4::Context->preference('canreservefromotherbranches') )
    {
        my $itembranch = $item->{homebranch};
        if ($itembranch ne $borrower->{branchcode}) {
            return 'cannotReserveFromOtherBranches';
        }
    }

    return 'OK';
}

=head2 CanReserveBeCanceledFromOpac

    $number = CanReserveBeCanceledFromOpac($reserve_id, $borrowernumber);

    returns 1 if reserve can be cancelled by user from OPAC.
    First check if reserve belongs to user, next checks if reserve is not in
    transfer or waiting status

=cut

sub CanReserveBeCanceledFromOpac {
    my ($reserve_id, $borrowernumber) = @_;

    return unless $reserve_id and $borrowernumber;
    my $reserve = GetReserve($reserve_id);

    return 0 unless $reserve->{borrowernumber} == $borrowernumber;
    return 0 if ( $reserve->{found} eq 'W' ) or ( $reserve->{found} eq 'T' );

    return 1;

}

=head2 GetReserveCount

  $number = &GetReserveCount($borrowernumber);

this function returns the number of reservation for a borrower given on input arg.

=cut

sub GetReserveCount {
    my ($borrowernumber) = @_;

    my $dbh = C4::Context->dbh;

    my $query = "
        SELECT COUNT(*) AS counter
        FROM reserves
        WHERE borrowernumber = ?
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    my $row = $sth->fetchrow_hashref;
    return $row->{counter};
}

=head2 GetOtherReserves

  ($messages,$nextreservinfo)=$GetOtherReserves(itemnumber);

Check queued list of this document and check if this document must be transferred

=cut

sub GetOtherReserves {
    my ($itemnumber) = @_;
    my $messages;
    my $nextreservinfo;
    my ( undef, $checkreserves, undef ) = CheckReserves($itemnumber);
    if ($checkreserves) {
        my $iteminfo = GetItem($itemnumber);
        if ( $iteminfo->{'holdingbranch'} ne $checkreserves->{'branchcode'} ) {
            $messages->{'transfert'} = $checkreserves->{'branchcode'};
            #minus priorities of others reservs
            ModReserveMinusPriority(
                $itemnumber,
                $checkreserves->{'reserve_id'},
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
                $checkreserves->{'reserve_id'},
            );
            ModReserveStatus($itemnumber,'W');
        }

        $nextreservinfo = $checkreserves->{'borrowernumber'};
    }

    return ( $messages, $nextreservinfo );
}

=head2 ChargeReserveFee

    $fee = ChargeReserveFee( $borrowernumber, $fee, $title );

    Charge the fee for a reserve (if $fee > 0)

=cut

sub ChargeReserveFee {
    my ( $borrowernumber, $fee, $title ) = @_;
    return if !$fee || $fee==0; # the last test is needed to include 0.00
    my $accquery = qq{
INSERT INTO accountlines ( borrowernumber, accountno, date, amount, description, accounttype, amountoutstanding ) VALUES (?, ?, NOW(), ?, ?, 'Res', ?)
    };
    my $dbh = C4::Context->dbh;
    my $nextacctno = &getnextacctno( $borrowernumber );
    $dbh->do( $accquery, undef, ( $borrowernumber, $nextacctno, $fee, "Reserve Charge - $title", $fee ) );
}

=head2 GetReserveFee

    $fee = GetReserveFee( $borrowernumber, $biblionumber );

    Calculate the fee for a reserve (if applicable).

=cut

sub GetReserveFee {
    my ( $borrowernumber, $biblionumber ) = @_;
    my $borquery = qq{
SELECT reservefee FROM borrowers LEFT JOIN categories ON borrowers.categorycode = categories.categorycode WHERE borrowernumber = ?
    };
    my $issue_qry = qq{
SELECT COUNT(*) FROM items
LEFT JOIN issues USING (itemnumber)
WHERE items.biblionumber=? AND issues.issue_id IS NULL
    };
    my $holds_qry = qq{
SELECT COUNT(*) FROM reserves WHERE biblionumber=? AND borrowernumber<>?
    };

    my $dbh = C4::Context->dbh;
    my ( $fee ) = $dbh->selectrow_array( $borquery, undef, ($borrowernumber) );
    my $hold_fee_mode = C4::Context->preference('HoldFeeMode') || 'not_always';
    if( $fee and $fee > 0 and $hold_fee_mode ne 'always' ) {
        # This is a reconstruction of the old code:
        # Compare number of items with items issued, and optionally check holds
        # If not all items are issued and there are no holds: charge no fee
        # NOTE: Lost, damaged, not-for-loan, etc. are just ignored here
        my ( $notissued, $reserved );
        ( $notissued ) = $dbh->selectrow_array( $issue_qry, undef,
            ( $biblionumber ) );
        if( $notissued ) {
            ( $reserved ) = $dbh->selectrow_array( $holds_qry, undef,
                ( $biblionumber, $borrowernumber ) );
            $fee = 0 if $reserved == 0;
        }
    }
    return $fee;
}

=head2 GetReservesToBranch

  @transreserv = GetReservesToBranch( $frombranch );

Get reserve list for a given branch

=cut

sub GetReservesToBranch {
    my ( $frombranch ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare(
        "SELECT reserve_id,borrowernumber,reservedate,itemnumber,timestamp
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

=head2 GetReservesForBranch

  @transreserv = GetReservesForBranch($frombranch);

=cut

sub GetReservesForBranch {
    my ($frombranch) = @_;
    my $dbh = C4::Context->dbh;

    my $query = "
        SELECT reserve_id,borrowernumber,reservedate,itemnumber,waitingdate
        FROM   reserves 
        WHERE   priority='0'
        AND found='W'
    ";
    $query .= " AND branchcode=? " if ( $frombranch );
    $query .= "ORDER BY waitingdate" ;

    my $sth = $dbh->prepare($query);
    if ($frombranch){
     $sth->execute($frombranch);
    } else {
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

=head2 GetReserveStatus

  $reservestatus = GetReserveStatus($itemnumber);

Takes an itemnumber and returns the status of the reserve placed on it.
If several reserves exist, the reserve with the lower priority is given.

=cut

## FIXME: I don't think this does what it thinks it does.
## It only ever checks the first reserve result, even though
## multiple reserves for that bib can have the itemnumber set
## the sub is only used once in the codebase.
sub GetReserveStatus {
    my ($itemnumber) = @_;

    my $dbh = C4::Context->dbh;

    my ($sth, $found, $priority);
    if ( $itemnumber ) {
        $sth = $dbh->prepare("SELECT found, priority FROM reserves WHERE itemnumber = ? order by priority LIMIT 1");
        $sth->execute($itemnumber);
        ($found, $priority) = $sth->fetchrow_array;
    }

    if(defined $found) {
        return 'Waiting'  if $found eq 'W' and $priority == 0;
        return 'Finished' if $found eq 'F';
    }

    return 'Reserved' if $priority > 0;

    return ''; # empty string here will remove need for checking undef, or less log lines
}

=head2 CheckReserves

  ($status, $reserve, $all_reserves) = &CheckReserves($itemnumber);
  ($status, $reserve, $all_reserves) = &CheckReserves(undef, $barcode);
  ($status, $reserve, $all_reserves) = &CheckReserves($itemnumber,undef,$lookahead);

Find a book in the reserves.

C<$itemnumber> is the book's item number.
C<$lookahead> is the number of days to look in advance for future reserves.

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
    my ( $item, $barcode, $lookahead_days, $ignore_borrowers) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    my $select;
    if (C4::Context->preference('item-level_itypes')){
	$select = "
           SELECT items.biblionumber,
           items.biblioitemnumber,
           itemtypes.notforloan,
           items.notforloan AS itemnotforloan,
           items.itemnumber,
           items.damaged,
           items.homebranch,
           items.holdingbranch
           FROM   items
           LEFT JOIN biblioitems ON items.biblioitemnumber = biblioitems.biblioitemnumber
           LEFT JOIN itemtypes   ON items.itype   = itemtypes.itemtype
        ";
    }
    else {
	$select = "
           SELECT items.biblionumber,
           items.biblioitemnumber,
           itemtypes.notforloan,
           items.notforloan AS itemnotforloan,
           items.itemnumber,
           items.damaged,
           items.homebranch,
           items.holdingbranch
           FROM   items
           LEFT JOIN biblioitems ON items.biblioitemnumber = biblioitems.biblioitemnumber
           LEFT JOIN itemtypes   ON biblioitems.itemtype   = itemtypes.itemtype
        ";
    }

    if ($item) {
        $sth = $dbh->prepare("$select WHERE itemnumber = ?");
        $sth->execute($item);
    }
    else {
        $sth = $dbh->prepare("$select WHERE barcode = ?");
        $sth->execute($barcode);
    }
    # note: we get the itemnumber because we might have started w/ just the barcode.  Now we know for sure we have it.
    my ( $biblio, $bibitem, $notforloan_per_itemtype, $notforloan_per_item, $itemnumber, $damaged, $item_homebranch, $item_holdingbranch ) = $sth->fetchrow_array;

    return if ( $damaged && !C4::Context->preference('AllowHoldsOnDamagedItems') );

    return unless $itemnumber; # bail if we got nothing.

    # if item is not for loan it cannot be reserved either.....
    # except where items.notforloan < 0 :  This indicates the item is holdable.
    return if  ( $notforloan_per_item > 0 ) or $notforloan_per_itemtype;

    # Find this item in the reserves
    my @reserves = _Findgroupreserve( $bibitem, $biblio, $itemnumber, $lookahead_days, $ignore_borrowers);

    # $priority and $highest are used to find the most important item
    # in the list returned by &_Findgroupreserve. (The lower $priority,
    # the more important the item.)
    # $highest is the most important item we've seen so far.
    my $highest;
    if (scalar @reserves) {
        my $LocalHoldsPriority = C4::Context->preference('LocalHoldsPriority');
        my $LocalHoldsPriorityPatronControl = C4::Context->preference('LocalHoldsPriorityPatronControl');
        my $LocalHoldsPriorityItemControl = C4::Context->preference('LocalHoldsPriorityItemControl');

        my $priority = 10000000;
        foreach my $res (@reserves) {
            if ( $res->{'itemnumber'} == $itemnumber && $res->{'priority'} == 0) {
                return ( "Waiting", $res, \@reserves ); # Found it
            } else {
                my $borrowerinfo;
                my $iteminfo;
                my $local_hold_match;

                if ($LocalHoldsPriority) {
                    $borrowerinfo = C4::Members::GetMember( borrowernumber => $res->{'borrowernumber'} );
                    $iteminfo = C4::Items::GetItem($itemnumber);

                    my $local_holds_priority_item_branchcode =
                      $iteminfo->{$LocalHoldsPriorityItemControl};
                    my $local_holds_priority_patron_branchcode =
                      ( $LocalHoldsPriorityPatronControl eq 'PickupLibrary' )
                      ? $res->{branchcode}
                      : ( $LocalHoldsPriorityPatronControl eq 'HomeLibrary' )
                      ? $borrowerinfo->{branchcode}
                      : undef;
                    $local_hold_match =
                      $local_holds_priority_item_branchcode eq
                      $local_holds_priority_patron_branchcode;
                }

                # See if this item is more important than what we've got so far
                if ( ( $res->{'priority'} && $res->{'priority'} < $priority ) || $local_hold_match ) {
                    $borrowerinfo ||= C4::Members::GetMember( borrowernumber => $res->{'borrowernumber'} );
                    $iteminfo ||= C4::Items::GetItem($itemnumber);
                    my $branch = GetReservesControlBranch( $iteminfo, $borrowerinfo );
                    my $branchitemrule = C4::Circulation::GetBranchItemRule($branch,$iteminfo->{'itype'});
                    next if ($branchitemrule->{'holdallowed'} == 0);
                    next if (($branchitemrule->{'holdallowed'} == 1) && ($branch ne $borrowerinfo->{'branchcode'}));
                    $priority = $res->{'priority'};
                    $highest  = $res;
                    last if $local_hold_match;
                }
            }
        }
    }

    # If we get this far, then no exact match was found.
    # We return the most important (i.e. next) reservation.
    if ($highest) {
        $highest->{'itemnumber'} = $item;
        return ( "Reserved", $highest, \@reserves );
    }

    return ( '' );
}

=head2 CancelExpiredReserves

  CancelExpiredReserves();

Cancels all reserves with an expiration date from before today.

=cut

sub CancelExpiredReserves {

    # Cancel reserves that have passed their expiration date.
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare( "
        SELECT * FROM reserves WHERE DATE(expirationdate) < DATE( CURDATE() )
        AND expirationdate IS NOT NULL
        AND found IS NULL
    " );
    $sth->execute();

    while ( my $res = $sth->fetchrow_hashref() ) {
        CancelReserve({ reserve_id => $res->{'reserve_id'} });
    }

    # Cancel reserves that have been waiting too long
    if ( C4::Context->preference("ExpireReservesMaxPickUpDelay") ) {
        my $max_pickup_delay = C4::Context->preference("ReservesMaxPickUpDelay");
        my $cancel_on_holidays = C4::Context->preference('ExpireReservesOnHolidays');

        my $today = dt_from_string();

        my $query = "SELECT * FROM reserves WHERE TO_DAYS( NOW() ) - TO_DAYS( waitingdate ) > ? AND found = 'W' AND priority = 0";
        $sth = $dbh->prepare( $query );
        $sth->execute( $max_pickup_delay );

        while ( my $res = $sth->fetchrow_hashref ) {
            my $do_cancel = 1;
            unless ( $cancel_on_holidays ) {
                my $calendar = Koha::Calendar->new( branchcode => $res->{'branchcode'} );
                my $is_holiday = $calendar->is_holiday( $today );

                if ( $is_holiday ) {
                    $do_cancel = 0;
                }
            }

            if ( $do_cancel ) {
                CancelReserve({ reserve_id => $res->{'reserve_id'}, charge_cancel_fee => 1 });
            }
        }
    }

}

=head2 AutoUnsuspendReserves

  AutoUnsuspendReserves();

Unsuspends all suspended reserves with a suspend_until date from before today.

=cut

sub AutoUnsuspendReserves {
    my $today = dt_from_string();

    my @holds = Koha::Holds->search( { suspend_until => { '<' => $today->ymd() } } );

    map { $_->suspend(0)->suspend_until(undef)->store() } @holds;
}

=head2 CancelReserve

  CancelReserve({ reserve_id => $reserve_id, [ biblionumber => $biblionumber, borrowernumber => $borrrowernumber, itemnumber => $itemnumber, ] [ charge_cancel_fee => 1 ] });

Cancels a reserve. If C<charge_cancel_fee> is passed and the C<ExpireReservesMaxPickUpDelayCharge> syspref is set, charge that fee to the patron's account.

=cut

sub CancelReserve {
    my ( $params ) = @_;

    my $reserve_id = $params->{'reserve_id'};
    # Filter out only the desired keys; this will insert undefined values for elements missing in
    # \%params, but GetReserveId filters them out anyway.
    $reserve_id = GetReserveId( { biblionumber => $params->{'biblionumber'}, borrowernumber => $params->{'borrowernumber'}, itemnumber => $params->{'itemnumber'} } ) unless ( $reserve_id );

    return unless ( $reserve_id );

    my $dbh = C4::Context->dbh;

    my $reserve = GetReserve( $reserve_id );
    if ($reserve) {
        my $query = "
            UPDATE reserves
            SET    cancellationdate = now(),
                   found            = Null,
                   priority         = 0
            WHERE  reserve_id = ?
        ";
        my $sth = $dbh->prepare($query);
        $sth->execute( $reserve_id );

        $query = "
            INSERT INTO old_reserves
            SELECT * FROM reserves
            WHERE  reserve_id = ?
        ";
        $sth = $dbh->prepare($query);
        $sth->execute( $reserve_id );

        $query = "
            DELETE FROM reserves
            WHERE  reserve_id = ?
        ";
        $sth = $dbh->prepare($query);
        $sth->execute( $reserve_id );

        # now fix the priority on the others....
        _FixPriority({ biblionumber => $reserve->{biblionumber} });

        # and, if desired, charge a cancel fee
        my $charge = C4::Context->preference("ExpireReservesMaxPickUpDelayCharge");
        if ( $charge && $params->{'charge_cancel_fee'} ) {
            manualinvoice($reserve->{'borrowernumber'}, $reserve->{'itemnumber'}, 'Hold waiting too long', 'F', $charge);
        }
    }

    return $reserve;
}

=head2 ModReserve

  ModReserve({ rank => $rank,
               reserve_id => $reserve_id,
               branchcode => $branchcode
               [, itemnumber => $itemnumber ]
               [, biblionumber => $biblionumber, $borrowernumber => $borrowernumber ]
              });

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

B<FIXME:> Note that the forgoing can have the effect of causing
item-level hold requests to turn into title-level requests.  This
will be fixed once reserves has separate columns for requested
itemnumber and supplying itemnumber.

=cut

sub ModReserve {
    my ( $params ) = @_;

    my $rank = $params->{'rank'};
    my $reserve_id = $params->{'reserve_id'};
    my $branchcode = $params->{'branchcode'};
    my $itemnumber = $params->{'itemnumber'};
    my $suspend_until = $params->{'suspend_until'};
    my $borrowernumber = $params->{'borrowernumber'};
    my $biblionumber = $params->{'biblionumber'};

    return if $rank eq "W";
    return if $rank eq "n";

    return unless ( $reserve_id || ( $borrowernumber && ( $biblionumber || $itemnumber ) ) );
    $reserve_id = GetReserveId({ biblionumber => $biblionumber, borrowernumber => $borrowernumber, itemnumber => $itemnumber }) unless ( $reserve_id );

    my $dbh = C4::Context->dbh;
    if ( $rank eq "del" ) {
        CancelReserve({ reserve_id => $reserve_id });
    }
    elsif ($rank =~ /^\d+/ and $rank > 0) {
        my $hold = Koha::Holds->find($reserve_id);

        $hold->set(
            {
                priority    => $rank,
                branchcode  => $branchcode,
                itemnumber  => $itemnumber,
                found       => undef,
                waitingdate => undef
            }
        )->store();

        if ( defined( $suspend_until ) ) {
            if ( $suspend_until ) {
                $suspend_until = eval { dt_from_string( $suspend_until ) };
                $hold->suspend_hold( $suspend_until );
            } else {
                # If the hold is suspended leave the hold suspended, but convert it to an indefinite hold.
                # If the hold is not suspended, this does nothing.
                $hold->set( { suspend_until => undef } )->store();
            }
        }

        _FixPriority({ reserve_id => $reserve_id, rank =>$rank });
    }
}

=head2 ModReserveFill

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
    my $reserve_id = $res->{'reserve_id'};
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
        _FixPriority({ reserve_id => $reserve_id, biblionumber => $biblionumber });
    }
}

=head2 ModReserveStatus

  &ModReserveStatus($itemnumber, $newstatus);

Update the reserve status for the active (priority=0) reserve.

$itemnumber is the itemnumber the reserve is on

$newstatus is the new status.

=cut

sub ModReserveStatus {

    #first : check if we have a reservation for this item .
    my ($itemnumber, $newstatus) = @_;
    my $dbh = C4::Context->dbh;

    my $query = "UPDATE reserves SET found = ?, waitingdate = NOW() WHERE itemnumber = ? AND found IS NULL AND priority = 0";
    my $sth_set = $dbh->prepare($query);
    $sth_set->execute( $newstatus, $itemnumber );

    if ( C4::Context->preference("ReturnToShelvingCart") && $newstatus ) {
      CartToShelf( $itemnumber );
    }
}

=head2 ModReserveAffect

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
    my $reserve_id = GetReserveId({
        borrowernumber => $borrowernumber,
        biblionumber   => $biblionumber,
    });
    return unless defined $reserve_id;
    my $request = GetReserveInfo($reserve_id);
    my $already_on_shelf = ($request && $request->{found} eq 'W') ? 1 : 0;

    # If we affect a reserve that has to be transferred, don't set to Waiting
    my $query;
    if ($transferToDo) {
    $query = "
        UPDATE reserves
        SET    priority = 0,
               itemnumber = ?,
               found = 'T'
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
                    waitingdate = NOW(),
                    itemnumber = ?
            WHERE borrowernumber = ?
              AND biblionumber = ?
        ";
    }
    $sth = $dbh->prepare($query);
    $sth->execute( $itemnumber, $borrowernumber,$biblionumber);
    _koha_notify_reserve( $itemnumber, $borrowernumber, $biblionumber ) if ( !$transferToDo && !$already_on_shelf );
    _FixPriority( { biblionumber => $biblionumber } );
    if ( C4::Context->preference("ReturnToShelvingCart") ) {
      CartToShelf( $itemnumber );
    }

    return;
}

=head2 ModReserveCancelAll

  ($messages,$nextreservinfo) = &ModReserveCancelAll($itemnumber,$borrowernumber);

function to cancel reserv,check other reserves, and transfer document if it's necessary

=cut

sub ModReserveCancelAll {
    my $messages;
    my $nextreservinfo;
    my ( $itemnumber, $borrowernumber ) = @_;

    #step 1 : cancel the reservation
    my $CancelReserve = CancelReserve({ itemnumber => $itemnumber, borrowernumber => $borrowernumber });

    #step 2 launch the subroutine of the others reserves
    ( $messages, $nextreservinfo ) = GetOtherReserves($itemnumber);

    return ( $messages, $nextreservinfo );
}

=head2 ModReserveMinusPriority

  &ModReserveMinusPriority($itemnumber,$borrowernumber,$biblionumber)

Reduce the values of queued list

=cut

sub ModReserveMinusPriority {
    my ( $itemnumber, $reserve_id ) = @_;

    #first step update the value of the first person on reserv
    my $dbh   = C4::Context->dbh;
    my $query = "
        UPDATE reserves
        SET    priority = 0 , itemnumber = ? 
        WHERE  reserve_id = ?
    ";
    my $sth_upd = $dbh->prepare($query);
    $sth_upd->execute( $itemnumber, $reserve_id );
    # second step update all others reserves
    _FixPriority({ reserve_id => $reserve_id, rank => '0' });
}

=head2 GetReserveInfo

  &GetReserveInfo($reserve_id);

Get item and borrower details for a current hold.
Current implementation this query should have a single result.

=cut

sub GetReserveInfo {
    my ( $reserve_id ) = @_;
    my $dbh = C4::Context->dbh;
    my $strsth="SELECT
                   reserve_id,
                   reservedate,
                   reservenotes,
                   reserves.borrowernumber,
                   reserves.biblionumber,
                   reserves.branchcode,
                   reserves.waitingdate,
                   notificationdate,
                   reminderdate,
                   priority,
                   found,
                   firstname,
                   surname,
                   phone,
                   email,
                   address,
                   address2,
                   cardnumber,
                   city,
                   zipcode,
                   biblio.title,
                   biblio.author,
                   items.holdingbranch,
                   items.itemcallnumber,
                   items.itemnumber,
                   items.location,
                   barcode,
                   notes
                FROM reserves
                LEFT JOIN items USING(itemnumber)
                LEFT JOIN borrowers USING(borrowernumber)
                LEFT JOIN biblio ON  (reserves.biblionumber=biblio.biblionumber)
                WHERE reserves.reserve_id = ?";
    my $sth = $dbh->prepare($strsth);
    $sth->execute($reserve_id);

    my $data = $sth->fetchrow_hashref;
    return $data;
}

=head2 IsAvailableForItemLevelRequest

  my $is_available = IsAvailableForItemLevelRequest($item_record,$borrower_record);

Checks whether a given item record is available for an
item-level hold request.  An item is available if

* it is not lost AND
* it is not damaged AND
* it is not withdrawn AND
* does not have a not for loan value > 0

Need to check the issuingrules onshelfholds column,
if this is set items on the shelf can be placed on hold

Note that IsAvailableForItemLevelRequest() does not
check if the staff operator is authorized to place
a request on the item - in particular,
this routine does not check IndependentBranches
and canreservefromotherbranches.

=cut

sub IsAvailableForItemLevelRequest {
    my $item = shift;
    my $borrower = shift;

    my $dbh = C4::Context->dbh;
    # must check the notforloan setting of the itemtype
    # FIXME - a lot of places in the code do this
    #         or something similar - need to be
    #         consolidated
    my $itype = _get_itype($item);
    my $notforloan_per_itemtype
      = $dbh->selectrow_array("SELECT notforloan FROM itemtypes WHERE itemtype = ?",
                              undef, $itype);

    return 0 if
        $notforloan_per_itemtype ||
        $item->{itemlost}        ||
        $item->{notforloan} > 0  ||
        $item->{withdrawn}        ||
        ($item->{damaged} && !C4::Context->preference('AllowHoldsOnDamagedItems'));


    return 1 if _OnShelfHoldsAllowed($itype,$borrower->{categorycode},$item->{holdingbranch});

    return $item->{onloan} || GetReserveStatus($item->{itemnumber}) eq "Waiting";
}

=head2 OnShelfHoldsAllowed

  OnShelfHoldsAllowed($itemtype,$borrowercategory,$branchcode);

Checks issuingrules, using the borrowers categorycode, the itemtype, and branchcode to see if onshelf
holds are allowed, returns true if so.

=cut

sub OnShelfHoldsAllowed {
    my ($item, $borrower) = @_;

    my $itype = _get_itype($item);
    return _OnShelfHoldsAllowed($itype,$borrower->{categorycode},$item->{holdingbranch});
}

sub _get_itype {
    my $item = shift;

    my $itype;
    if (C4::Context->preference('item-level_itypes')) {
        # We can't trust GetItem to honour the syspref, so safest to do it ourselves
        # When GetItem is fixed, we can remove this
        $itype = $item->{itype};
    }
    else {
        # XXX This is a bit dodgy. It relies on biblio itemtype column having different name.
        # So if we already have a biblioitems join when calling this function,
        # we don't need to access the database again
        $itype = $item->{itemtype};
    }
    unless ($itype) {
        my $dbh = C4::Context->dbh;
        my $query = "SELECT itemtype FROM biblioitems WHERE biblioitemnumber = ? ";
        my $sth = $dbh->prepare($query);
        $sth->execute($item->{biblioitemnumber});
        if (my $data = $sth->fetchrow_hashref()){
            $itype = $data->{itemtype};
        }
    }
    return $itype;
}

sub _OnShelfHoldsAllowed {
    my ($itype,$borrowercategory,$branchcode) = @_;

    my $rule = C4::Circulation::GetIssuingRule($borrowercategory, $itype, $branchcode);
    return $rule->{onshelfholds};
}

=head2 AlterPriority

  AlterPriority( $where, $reserve_id );

This function changes a reserve's priority up, down, to the top, or to the bottom.
Input: $where is 'up', 'down', 'top' or 'bottom'. Biblionumber, Date reserve was placed

=cut

sub AlterPriority {
    my ( $where, $reserve_id ) = @_;

    my $dbh = C4::Context->dbh;

    my $reserve = GetReserve( $reserve_id );

    if ( $reserve->{cancellationdate} ) {
        warn "I cannot alter the priority for reserve_id $reserve_id, the reserve has been cancelled (".$reserve->{cancellationdate}.')';
        return;
    }

    if ( $where eq 'up' || $where eq 'down' ) {

      my $priority = $reserve->{'priority'};
      $priority = $where eq 'up' ? $priority - 1 : $priority + 1;
      _FixPriority({ reserve_id => $reserve_id, rank => $priority })

    } elsif ( $where eq 'top' ) {

      _FixPriority({ reserve_id => $reserve_id, rank => '1' })

    } elsif ( $where eq 'bottom' ) {

      _FixPriority({ reserve_id => $reserve_id, rank => '999999' });

    }
}

=head2 ToggleLowestPriority

  ToggleLowestPriority( $borrowernumber, $biblionumber );

This function sets the lowestPriority field to true if is false, and false if it is true.

=cut

sub ToggleLowestPriority {
    my ( $reserve_id ) = @_;

    my $dbh = C4::Context->dbh;

    my $sth = $dbh->prepare( "UPDATE reserves SET lowestPriority = NOT lowestPriority WHERE reserve_id = ?");
    $sth->execute( $reserve_id );
    
    _FixPriority({ reserve_id => $reserve_id, rank => '999999' });
}

=head2 ToggleSuspend

  ToggleSuspend( $reserve_id );

This function sets the suspend field to true if is false, and false if it is true.
If the reserve is currently suspended with a suspend_until date, that date will
be cleared when it is unsuspended.

=cut

sub ToggleSuspend {
    my ( $reserve_id, $suspend_until ) = @_;

    $suspend_until = dt_from_string($suspend_until) if ($suspend_until);

    my $hold = Koha::Holds->find( $reserve_id );

    if ( $hold->is_suspended ) {
        $hold->resume()
    } else {
        $hold->suspend_hold( $suspend_until );
    }
}

=head2 SuspendAll

  SuspendAll(
      borrowernumber   => $borrowernumber,
      [ biblionumber   => $biblionumber, ]
      [ suspend_until  => $suspend_until, ]
      [ suspend        => $suspend ]
  );

  This function accepts a set of hash keys as its parameters.
  It requires either borrowernumber or biblionumber, or both.

  suspend_until is wholly optional.

=cut

sub SuspendAll {
    my %params = @_;

    my $borrowernumber = $params{'borrowernumber'} || undef;
    my $biblionumber   = $params{'biblionumber'}   || undef;
    my $suspend_until  = $params{'suspend_until'}  || undef;
    my $suspend = defined( $params{'suspend'} ) ? $params{'suspend'} : 1;

    $suspend_until = eval { dt_from_string($suspend_until) }
      if ( defined($suspend_until) );

    return unless ( $borrowernumber || $biblionumber );

    my $params;
    $params->{found}          = undef;
    $params->{borrowernumber} = $borrowernumber if $borrowernumber;
    $params->{biblionumber}   = $biblionumber if $biblionumber;

    my @holds = Koha::Holds->search($params);

    if ($suspend) {
        map { $_->suspend_hold($suspend_until) } @holds;
    }
    else {
        map { $_->resume() } @holds;
    }
}


=head2 _FixPriority

  _FixPriority({
    reserve_id => $reserve_id,
    [rank => $rank,]
    [ignoreSetLowestRank => $ignoreSetLowestRank]
  });

  or

  _FixPriority({ biblionumber => $biblionumber});

This routine adjusts the priority of a hold request and holds
on the same bib.

In the first form, where a reserve_id is passed, the priority of the
hold is set to supplied rank, and other holds for that bib are adjusted
accordingly.  If the rank is "del", the hold is cancelled.  If no rank
is supplied, all of the holds on that bib have their priority adjusted
as if the second form had been used.

In the second form, where a biblionumber is passed, the holds on that
bib (that are not captured) are sorted in order of increasing priority,
then have reserves.priority set so that the first non-captured hold
has its priority set to 1, the second non-captured hold has its priority
set to 2, and so forth.

In both cases, holds that have the lowestPriority flag on are have their
priority adjusted to ensure that they remain at the end of the line.

Note that the ignoreSetLowestRank parameter is meant to be used only
when _FixPriority calls itself.

=cut

sub _FixPriority {
    my ( $params ) = @_;
    my $reserve_id = $params->{reserve_id};
    my $rank = $params->{rank} // '';
    my $ignoreSetLowestRank = $params->{ignoreSetLowestRank};
    my $biblionumber = $params->{biblionumber};

    my $dbh = C4::Context->dbh;

    unless ( $biblionumber ) {
        my $res = GetReserve( $reserve_id );
        $biblionumber = $res->{biblionumber};
    }

    if ( $rank eq "del" ) {
         CancelReserve({ reserve_id => $reserve_id });
    }
    elsif ( $rank eq "W" || $rank eq "0" ) {

        # make sure priority for waiting or in-transit items is 0
        my $query = "
            UPDATE reserves
            SET    priority = 0
            WHERE reserve_id = ?
            AND found IN ('W', 'T')
        ";
        my $sth = $dbh->prepare($query);
        $sth->execute( $reserve_id );
    }
    my @priority;

    # get whats left
    my $query = "
        SELECT reserve_id, borrowernumber, reservedate
        FROM   reserves
        WHERE  biblionumber   = ?
          AND  ((found <> 'W' AND found <> 'T') OR found IS NULL)
        ORDER BY priority ASC
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute( $biblionumber );
    while ( my $line = $sth->fetchrow_hashref ) {
        push( @priority,     $line );
    }

    # To find the matching index
    my $i;
    my $key = -1;    # to allow for 0 to be a valid result
    for ( $i = 0 ; $i < @priority ; $i++ ) {
        if ( $reserve_id == $priority[$i]->{'reserve_id'} ) {
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
        WHERE  reserve_id = ?
    ";
    $sth = $dbh->prepare($query);
    for ( my $j = 0 ; $j < @priority ; $j++ ) {
        $sth->execute(
            $j + 1,
            $priority[$j]->{'reserve_id'}
        );
    }
    
    $sth = $dbh->prepare( "SELECT reserve_id FROM reserves WHERE lowestPriority = 1 ORDER BY priority" );
    $sth->execute();

    unless ( $ignoreSetLowestRank ) {
      while ( my $res = $sth->fetchrow_hashref() ) {
        _FixPriority({
            reserve_id => $res->{'reserve_id'},
            rank => '999999',
            ignoreSetLowestRank => 1
        });
      }
    }
}

=head2 _Findgroupreserve

  @results = &_Findgroupreserve($biblioitemnumber, $biblionumber, $itemnumber, $lookahead, $ignore_borrowers);

Looks for a holds-queue based item-specific match first, then for a holds-queue title-level match, returning the
first match found.  If neither, then we look for non-holds-queue based holds.
Lookahead is the number of days to look in advance.

C<&_Findgroupreserve> returns :
C<@results> is an array of references-to-hash whose keys are mostly
fields from the reserves table of the Koha database, plus
C<biblioitemnumber>.

=cut

sub _Findgroupreserve {
    my ( $bibitem, $biblio, $itemnumber, $lookahead, $ignore_borrowers) = @_;
    my $dbh   = C4::Context->dbh;

    # TODO: consolidate at least the SELECT portion of the first 2 queries to a common $select var.
    # check for exact targeted match
    my $item_level_target_query = qq{
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
               reserves.itemnumber          AS itemnumber,
               reserves.reserve_id          AS reserve_id
        FROM reserves
        JOIN biblioitems USING (biblionumber)
        JOIN hold_fill_targets USING (biblionumber, borrowernumber, itemnumber)
        WHERE found IS NULL
        AND priority > 0
        AND item_level_request = 1
        AND itemnumber = ?
        AND reservedate <= DATE_ADD(NOW(),INTERVAL ? DAY)
        AND suspend = 0
        ORDER BY priority
    };
    my $sth = $dbh->prepare($item_level_target_query);
    $sth->execute($itemnumber, $lookahead||0);
    my @results;
    if ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data )
          unless any{ $data->{borrowernumber} eq $_ } @$ignore_borrowers ;
    }
    return @results if @results;

    # check for title-level targeted match
    my $title_level_target_query = qq{
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
               reserves.itemnumber          AS itemnumber,
               reserves.reserve_id          AS reserve_id
        FROM reserves
        JOIN biblioitems USING (biblionumber)
        JOIN hold_fill_targets USING (biblionumber, borrowernumber)
        WHERE found IS NULL
        AND priority > 0
        AND item_level_request = 0
        AND hold_fill_targets.itemnumber = ?
        AND reservedate <= DATE_ADD(NOW(),INTERVAL ? DAY)
        AND suspend = 0
        ORDER BY priority
    };
    $sth = $dbh->prepare($title_level_target_query);
    $sth->execute($itemnumber, $lookahead||0);
    @results = ();
    if ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data )
          unless any{ $data->{borrowernumber} eq $_ } @$ignore_borrowers ;
    }
    return @results if @results;

    my $query = qq{
        SELECT reserves.biblionumber               AS biblionumber,
               reserves.borrowernumber             AS borrowernumber,
               reserves.reservedate                AS reservedate,
               reserves.waitingdate                AS waitingdate,
               reserves.branchcode                 AS branchcode,
               reserves.cancellationdate           AS cancellationdate,
               reserves.found                      AS found,
               reserves.reservenotes               AS reservenotes,
               reserves.priority                   AS priority,
               reserves.timestamp                  AS timestamp,
               reserves.itemnumber                 AS itemnumber,
               reserves.reserve_id                 AS reserve_id
        FROM reserves
        WHERE reserves.biblionumber = ?
          AND (reserves.itemnumber IS NULL OR reserves.itemnumber = ?)
          AND reserves.reservedate <= DATE_ADD(NOW(),INTERVAL ? DAY)
          AND suspend = 0
          ORDER BY priority
    };
    $sth = $dbh->prepare($query);
    $sth->execute( $biblio, $itemnumber, $lookahead||0);
    @results = ();
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data )
          unless any{ $data->{borrowernumber} eq $_ } @$ignore_borrowers ;
    }
    return @results;
}

=head2 _koha_notify_reserve

  _koha_notify_reserve( $itemnumber, $borrowernumber, $biblionumber );

Sends a notification to the patron that their hold has been filled (through
ModReserveAffect, _not_ ModReserveFill)

The letter code for this notice may be found using the following query:

    select distinct letter_code
    from message_transports
    inner join message_attributes using (message_attribute_id)
    where message_name = 'Hold_Filled'

This will probably sipmly be 'HOLD', but because it is defined in the database,
it is subject to addition or change.

The following tables are availalbe witin the notice:

    branches
    borrowers
    biblio
    biblioitems
    reserves
    items

=cut

sub _koha_notify_reserve {
    my ($itemnumber, $borrowernumber, $biblionumber) = @_;

    my $dbh = C4::Context->dbh;
    my $borrower = C4::Members::GetMember(borrowernumber => $borrowernumber);

    # Try to get the borrower's email address
    my $to_address = C4::Members::GetNoticeEmailAddress($borrowernumber);

    my $messagingprefs = C4::Members::Messaging::GetMessagingPreferences( {
            borrowernumber => $borrowernumber,
            message_name => 'Hold_Filled'
    } );

    my $sth = $dbh->prepare("
        SELECT *
        FROM   reserves
        WHERE  borrowernumber = ?
            AND biblionumber = ?
    ");
    $sth->execute( $borrowernumber, $biblionumber );
    my $reserve = $sth->fetchrow_hashref;
    my $library = Koha::Libraries->find( $reserve->{branchcode} )->unblessed;

    my $admin_email_address = $library->{branchemail} || C4::Context->preference('KohaAdminEmailAddress');

    my %letter_params = (
        module => 'reserves',
        branchcode => $reserve->{branchcode},
        tables => {
            'branches'       => $library,
            'borrowers'      => $borrower,
            'biblio'         => $biblionumber,
            'biblioitems'    => $biblionumber,
            'reserves'       => $reserve,
            'items', $reserve->{'itemnumber'},
        },
        substitute => { today => output_pref( { dt => dt_from_string, dateonly => 1 } ) },
    );

    my $notification_sent = 0; #Keeping track if a Hold_filled message is sent. If no message can be sent, then default to a print message.
    my $send_notification = sub {
        my ( $mtt, $letter_code ) = (@_);
        return unless defined $letter_code;
        $letter_params{letter_code} = $letter_code;
        $letter_params{message_transport_type} = $mtt;
        my $letter =  C4::Letters::GetPreparedLetter ( %letter_params );
        unless ($letter) {
            warn "Could not find a letter called '$letter_params{'letter_code'}' for $mtt in the 'reserves' module";
            return;
        }

        C4::Letters::EnqueueLetter( {
            letter => $letter,
            borrowernumber => $borrowernumber,
            from_address => $admin_email_address,
            message_transport_type => $mtt,
        } );
    };

    while ( my ( $mtt, $letter_code ) = each %{ $messagingprefs->{transports} } ) {
        next if (
               ( $mtt eq 'email' and not $to_address ) # No email address
            or ( $mtt eq 'sms'   and not $borrower->{smsalertnumber} ) # No SMS number
            or ( $mtt eq 'phone' and C4::Context->preference('TalkingTechItivaPhoneNotification') ) # Notice is handled by TalkingTech_itiva_outbound.pl
        );

        &$send_notification($mtt, $letter_code);
        $notification_sent++;
    }
    #Making sure that a print notification is sent if no other transport types can be utilized.
    if (! $notification_sent) {
        &$send_notification('print', 'HOLD');
    }
    
}

=head2 _ShiftPriorityByDateAndPriority

  $new_priority = _ShiftPriorityByDateAndPriority( $biblionumber, $reservedate, $priority );

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
    my $query = "SELECT priority FROM reserves WHERE biblionumber = ? AND ( reservedate > ? OR priority > ? ) ORDER BY priority ASC LIMIT 1";
    my $sth = $dbh->prepare( $query );
    $sth->execute( $biblio, $resdate, $new_priority );
    my $min_priority = $sth->fetchrow;
    # if no such matches are found, $new_priority remains as original value
    $new_priority = $min_priority if ( $min_priority );

    # Shift the priority up by one; works in conjunction with the next SQL statement
    $query = "UPDATE reserves
              SET priority = priority+1
              WHERE biblionumber = ?
              AND borrowernumber = ?
              AND reservedate = ?
              AND found IS NULL";
    my $sth_update = $dbh->prepare( $query );

    # Select all reserves for the biblio with priority greater than $new_priority, and order greatest to least
    $query = "SELECT borrowernumber, reservedate FROM reserves WHERE priority >= ? AND biblionumber = ? ORDER BY priority DESC";
    $sth = $dbh->prepare( $query );
    $sth->execute( $new_priority, $biblio );
    while ( my $row = $sth->fetchrow_hashref ) {
	$sth_update->execute( $biblio, $row->{borrowernumber}, $row->{reservedate} );
    }

    return $new_priority;  # so the caller knows what priority they wind up receiving
}

=head2 OPACItemHoldsAllowed

  OPACItemHoldsAllowed($item_record,$borrower_record);

Checks issuingrules, using the borrowers categorycode, the itemtype, and branchcode to see
if specific item holds are allowed, returns true if so.

=cut

sub OPACItemHoldsAllowed {
    my ($item,$borrower) = @_;

    my $branchcode = $item->{homebranch} or die "No homebranch";
    my $itype;
    my $dbh = C4::Context->dbh;
    if (C4::Context->preference('item-level_itypes')) {
       # We can't trust GetItem to honour the syspref, so safest to do it ourselves
       # When GetItem is fixed, we can remove this
       $itype = $item->{itype};
    }
    else {
       my $query = "SELECT itemtype FROM biblioitems WHERE biblioitemnumber = ? ";
       my $sth = $dbh->prepare($query);
       $sth->execute($item->{biblioitemnumber});
       if (my $data = $sth->fetchrow_hashref()){
           $itype = $data->{itemtype};
       }
    }

    my $query = "SELECT opacitemholds,categorycode,itemtype,branchcode FROM issuingrules WHERE
          (issuingrules.categorycode = ? OR issuingrules.categorycode = '*')
        AND
          (issuingrules.itemtype = ? OR issuingrules.itemtype = '*')
        AND
          (issuingrules.branchcode = ? OR issuingrules.branchcode = '*')
        ORDER BY
          issuingrules.categorycode desc,
          issuingrules.itemtype desc,
          issuingrules.branchcode desc
       LIMIT 1";
    my $sth = $dbh->prepare($query);
    $sth->execute($borrower->{categorycode},$itype,$branchcode);
    my $data = $sth->fetchrow_hashref;
    my $opacitemholds = uc substr ($data->{opacitemholds}, 0, 1);
    return '' if $opacitemholds eq 'N';
    return $opacitemholds;
}

=head2 MoveReserve

  MoveReserve( $itemnumber, $borrowernumber, $cancelreserve )

Use when checking out an item to handle reserves
If $cancelreserve boolean is set to true, it will remove existing reserve

=cut

sub MoveReserve {
    my ( $itemnumber, $borrowernumber, $cancelreserve ) = @_;

    my $lookahead = C4::Context->preference('ConfirmFutureHolds'); #number of days to look for future holds
    my ( $restype, $res, $all_reserves ) = CheckReserves( $itemnumber, undef, $lookahead );
    return unless $res;

    my $biblionumber     =  $res->{biblionumber};
    my $biblioitemnumber = $res->{biblioitemnumber};

    if ($res->{borrowernumber} == $borrowernumber) {
        ModReserveFill($res);
    }
    else {
        # warn "Reserved";
        # The item is reserved by someone else.
        # Find this item in the reserves

        my $borr_res;
        foreach (@$all_reserves) {
            $_->{'borrowernumber'} == $borrowernumber or next;
            $_->{'biblionumber'}   == $biblionumber   or next;

            $borr_res = $_;
            last;
        }

        if ( $borr_res ) {
            # The item is reserved by the current patron
            ModReserveFill($borr_res);
        }

        if ( $cancelreserve eq 'revert' ) { ## Revert waiting reserve to priority 1
            RevertWaitingStatus({ itemnumber => $itemnumber });
        }
        elsif ( $cancelreserve eq 'cancel' || $cancelreserve ) { # cancel reserves on this item
            CancelReserve( { reserve_id => $res->{'reserve_id'} } );
        }
    }
}

=head2 MergeHolds

  MergeHolds($dbh,$to_biblio, $from_biblio);

This shifts the holds from C<$from_biblio> to C<$to_biblio> and reorders them by the date they were placed

=cut

sub MergeHolds {
    my ( $dbh, $to_biblio, $from_biblio ) = @_;
    my $sth = $dbh->prepare(
        "SELECT count(*) as reserve_count FROM reserves WHERE biblionumber = ?"
    );
    $sth->execute($from_biblio);
    if ( my $data = $sth->fetchrow_hashref() ) {

        # holds exist on old record, if not we don't need to do anything
        $sth = $dbh->prepare(
            "UPDATE reserves SET biblionumber = ? WHERE biblionumber = ?");
        $sth->execute( $to_biblio, $from_biblio );

        # Reorder by date
        # don't reorder those already waiting

        $sth = $dbh->prepare(
"SELECT * FROM reserves WHERE biblionumber = ? AND (found <> ? AND found <> ? OR found is NULL) ORDER BY reservedate ASC"
        );
        my $upd_sth = $dbh->prepare(
"UPDATE reserves SET priority = ? WHERE biblionumber = ? AND borrowernumber = ?
        AND reservedate = ? AND (itemnumber = ? or itemnumber is NULL) "
        );
        $sth->execute( $to_biblio, 'W', 'T' );
        my $priority = 1;
        while ( my $reserve = $sth->fetchrow_hashref() ) {
            $upd_sth->execute(
                $priority,                    $to_biblio,
                $reserve->{'borrowernumber'}, $reserve->{'reservedate'},
                $reserve->{'itemnumber'}
            );
            $priority++;
        }
    }
}

=head2 RevertWaitingStatus

  RevertWaitingStatus({ itemnumber => $itemnumber });

  Reverts a 'waiting' hold back to a regular hold with a priority of 1.

  Caveat: Any waiting hold fixed with RevertWaitingStatus will be an
          item level hold, even if it was only a bibliolevel hold to
          begin with. This is because we can no longer know if a hold
          was item-level or bib-level after a hold has been set to
          waiting status.

=cut

sub RevertWaitingStatus {
    my ( $params ) = @_;
    my $itemnumber = $params->{'itemnumber'};

    return unless ( $itemnumber );

    my $dbh = C4::Context->dbh;

    ## Get the waiting reserve we want to revert
    my $query = "
        SELECT * FROM reserves
        WHERE itemnumber = ?
        AND found IS NOT NULL
    ";
    my $sth = $dbh->prepare( $query );
    $sth->execute( $itemnumber );
    my $reserve = $sth->fetchrow_hashref();

    ## Increment the priority of all other non-waiting
    ## reserves for this bib record
    $query = "
        UPDATE reserves
        SET
          priority = priority + 1
        WHERE
          biblionumber =  ?
        AND
          priority > 0
    ";
    $sth = $dbh->prepare( $query );
    $sth->execute( $reserve->{'biblionumber'} );

    ## Fix up the currently waiting reserve
    $query = "
    UPDATE reserves
    SET
      priority = 1,
      found = NULL,
      waitingdate = NULL
    WHERE
      reserve_id = ?
    ";
    $sth = $dbh->prepare( $query );
    $sth->execute( $reserve->{'reserve_id'} );
    _FixPriority( { biblionumber => $reserve->{biblionumber} } );
}

=head2 GetReserveId

  $reserve_id = GetReserveId({ biblionumber => $biblionumber, borrowernumber => $borrowernumber [, itemnumber => $itemnumber ] });

  Returnes the first reserve id that matches the given criteria

=cut

sub GetReserveId {
    my ( $params ) = @_;

    return unless ( ( $params->{'biblionumber'} || $params->{'itemnumber'} ) && $params->{'borrowernumber'} );

    my $dbh = C4::Context->dbh();

    my $sql = "SELECT reserve_id FROM reserves WHERE ";

    my @params;
    my @limits;
    foreach my $key ( keys %$params ) {
        if ( defined( $params->{$key} ) ) {
            push( @limits, "$key = ?" );
            push( @params, $params->{$key} );
        }
    }

    $sql .= join( " AND ", @limits );

    my $sth = $dbh->prepare( $sql );
    $sth->execute( @params );
    my $row = $sth->fetchrow_hashref();

    return $row->{'reserve_id'};
}

=head2 ReserveSlip

  ReserveSlip($branchcode, $borrowernumber, $biblionumber)

Returns letter hash ( see C4::Letters::GetPreparedLetter ) or undef

The letter code will be HOLD_SLIP, and the following tables are
available within the slip:

    reserves
    branches
    borrowers
    biblio
    biblioitems
    items

=cut

sub ReserveSlip {
    my ($branch, $borrowernumber, $biblionumber) = @_;

#   return unless ( C4::Context->boolean_preference('printreserveslips') );

    my $reserve_id = GetReserveId({
        biblionumber => $biblionumber,
        borrowernumber => $borrowernumber
    }) or return;
    my $reserve = GetReserveInfo($reserve_id) or return;

    return  C4::Letters::GetPreparedLetter (
        module => 'circulation',
        letter_code => 'HOLD_SLIP',
        branchcode => $branch,
        tables => {
            'reserves'    => $reserve,
            'branches'    => $reserve->{branchcode},
            'borrowers'   => $reserve->{borrowernumber},
            'biblio'      => $reserve->{biblionumber},
            'biblioitems' => $reserve->{biblionumber},
            'items'       => $reserve->{itemnumber},
        },
    );
}

=head2 GetReservesControlBranch

  my $reserves_control_branch = GetReservesControlBranch($item, $borrower);

  Return the branchcode to be used to determine which reserves
  policy applies to a transaction.

  C<$item> is a hashref for an item. Only 'homebranch' is used.

  C<$borrower> is a hashref to borrower. Only 'branchcode' is used.

=cut

sub GetReservesControlBranch {
    my ( $item, $borrower ) = @_;

    my $reserves_control = C4::Context->preference('ReservesControlBranch');

    my $branchcode =
        ( $reserves_control eq 'ItemHomeLibrary' ) ? $item->{'homebranch'}
      : ( $reserves_control eq 'PatronLibrary' )   ? $borrower->{'branchcode'}
      :                                              undef;

    return $branchcode;
}

=head2 CalculatePriority

    my $p = CalculatePriority($biblionumber, $resdate);

Calculate priority for a new reserve on biblionumber, placing it at
the end of the line of all holds whose start date falls before
the current system time and that are neither on the hold shelf
or in transit.

The reserve date parameter is optional; if it is supplied, the
priority is based on the set of holds whose start date falls before
the parameter value.

After calculation of this priority, it is recommended to call
_ShiftPriorityByDateAndPriority. Note that this is currently done in
AddReserves.

=cut

sub CalculatePriority {
    my ( $biblionumber, $resdate ) = @_;

    my $sql = q{
        SELECT COUNT(*) FROM reserves
        WHERE biblionumber = ?
        AND   priority > 0
        AND   (found IS NULL OR found = '')
    };
    #skip found==W or found==T (waiting or transit holds)
    if( $resdate ) {
        $sql.= ' AND ( reservedate <= ? )';
    }
    else {
        $sql.= ' AND ( reservedate < NOW() )';
    }
    my $dbh = C4::Context->dbh();
    my @row = $dbh->selectrow_array(
        $sql,
        undef,
        $resdate ? ($biblionumber, $resdate) : ($biblionumber)
    );

    return @row ? $row[0]+1 : 1;
}

=head2 IsItemOnHoldAndFound

    my $bool = IsItemFoundHold( $itemnumber );

    Returns true if the item is currently on hold
    and that hold has a non-null found status ( W, T, etc. )

=cut

sub IsItemOnHoldAndFound {
    my ($itemnumber) = @_;

    my $rs = Koha::Database->new()->schema()->resultset('Reserve');

    my $found = $rs->count(
        {
            itemnumber => $itemnumber,
            found      => { '!=' => undef }
        }
    );

    return $found;
}

=head1 AUTHOR

Koha Development Team <http://koha-community.org/>

=cut

1;
