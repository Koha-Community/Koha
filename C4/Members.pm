package C4::Members;

# Copyright 2000-2003 Katipo Communications
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
use C4::Context;
use C4::Dates qw(format_date_in_iso);
use Digest::MD5 qw(md5_base64);
use Date::Calc qw/Today Add_Delta_YM/;
use C4::Log; # logaction
use C4::Overdues;
use C4::Reserves;
use C4::Accounts;
use C4::Biblio;

our ($VERSION,@ISA,@EXPORT,@EXPORT_OK,$debug);

BEGIN {
	$VERSION = 3.02;
	$debug = $ENV{DEBUG} || 0;
	require Exporter;
	@ISA = qw(Exporter);
	#Get data
	push @EXPORT, qw(
		&SearchMember 
		&GetMemberDetails
		&GetMember

		&GetGuarantees 

		&GetMemberIssuesAndFines
		&GetPendingIssues
		&GetAllIssues

		&get_institutions 
		&getzipnamecity 
		&getidcity

		&GetAge 
		&GetCities 
		&GetRoadTypes 
		&GetRoadTypeDetails 
		&GetSortDetails
		&GetTitles

    &GetPatronImage
    &PutPatronImage
    &RmPatronImage

		&GetMemberAccountRecords
		&GetBorNotifyAcctRecord

		&GetborCatFromCatType 
		&GetBorrowercategory
    &GetBorrowercategoryList

		&GetBorrowersWhoHaveNotBorrowedSince
		&GetBorrowersWhoHaveNeverBorrowed
		&GetBorrowersWithIssuesHistoryOlderThan

		&GetExpiryDate
	);

	#Modify data
	push @EXPORT, qw(
		&ModMember
		&changepassword
	);

	#Delete data
	push @EXPORT, qw(
		&DelMember
	);

	#Insert data
	push @EXPORT, qw(
		&AddMember
		&add_member_orgs
		&MoveMemberToDeleted
		&ExtendMemberSubscriptionTo 
	);

	#Check data
    push @EXPORT, qw(
        &checkuniquemember
        &checkuserpassword
        &Check_Userid
        &Generate_Userid
        &fixEthnicity
        &ethnicitycategories
        &fixup_cardnumber
        &checkcardnumber
    );
}

=head1 NAME

C4::Members - Perl Module containing convenience functions for member handling

=head1 SYNOPSIS

use C4::Members;

=head1 DESCRIPTION

This module contains routines for adding, modifying and deleting members/patrons/borrowers 

=head1 FUNCTIONS

=over 2

=item SearchMember

  ($count, $borrowers) = &SearchMember($searchstring, $type,$category_type,$filter,$showallbranches);

=back

Looks up patrons (borrowers) by name.

BUGFIX 499: C<$type> is now used to determine type of search.
if $type is "simple", search is performed on the first letter of the
surname only.

$category_type is used to get a specified type of user. 
(mainly adults when creating a child.)

C<$searchstring> is a space-separated list of search terms. Each term
must match the beginning a borrower's surname, first name, or other
name.

C<$filter> is assumed to be a list of elements to filter results on

C<$showallbranches> is used in IndependantBranches Context to display all branches results.

C<&SearchMember> returns a two-element list. C<$borrowers> is a
reference-to-array; each element is a reference-to-hash, whose keys
are the fields of the C<borrowers> table in the Koha database.
C<$count> is the number of elements in C<$borrowers>.

=cut

#'
#used by member enquiries from the intranet
#called by member.pl and circ/circulation.pl
sub SearchMember {
    my ($searchstring, $orderby, $type,$category_type,$filter,$showallbranches ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "";
    my $count;
    my @data;
    my @bind = ();
    
    # this is used by circulation everytime a new borrowers cardnumber is scanned
    # so we can check an exact match first, if that works return, otherwise do the rest
    $query = "SELECT * FROM borrowers
        LEFT JOIN categories ON borrowers.categorycode=categories.categorycode
        ";
    my $sth = $dbh->prepare("$query WHERE cardnumber = ?");
    $sth->execute($searchstring);
    my $data = $sth->fetchall_arrayref({});
    if (@$data){
        return ( scalar(@$data), $data );
    }
    $sth->finish;

    if ( $type eq "simple" )    # simple search for one letter only
    {
        $query .= ($category_type ? " AND category_type = ".$dbh->quote($category_type) : ""); 
        $query .= " WHERE (surname LIKE ? OR cardnumber like ?) ";
        if (C4::Context->preference("IndependantBranches") && !$showallbranches){
          if (C4::Context->userenv && C4::Context->userenv->{flags}!=1 && C4::Context->userenv->{'branch'}){
            $query.=" AND borrowers.branchcode =".$dbh->quote(C4::Context->userenv->{'branch'}) unless (C4::Context->userenv->{'branch'} eq "insecure");
          }
        }
        $query.=" ORDER BY $orderby";
        @bind = ("$searchstring%","$searchstring");
    }
    else    # advanced search looking in surname, firstname and othernames
    {
        @data  = split( ' ', $searchstring );
        $count = @data;
        $query .= " WHERE ";
        if (C4::Context->preference("IndependantBranches") && !$showallbranches){
          if (C4::Context->userenv && C4::Context->userenv->{flags}!=1 && C4::Context->userenv->{'branch'}){
            $query.=" borrowers.branchcode =".$dbh->quote(C4::Context->userenv->{'branch'})." AND " unless (C4::Context->userenv->{'branch'} eq "insecure");
          }      
        }     
        $query.="((surname LIKE ? OR surname LIKE ?
                OR firstname  LIKE ? OR firstname LIKE ?
                OR othernames LIKE ? OR othernames LIKE ?)
        " .
        ($category_type?" AND category_type = ".$dbh->quote($category_type):"");
        @bind = (
            "$data[0]%", "% $data[0]%", "$data[0]%", "% $data[0]%",
            "$data[0]%", "% $data[0]%"
        );
        for ( my $i = 1 ; $i < $count ; $i++ ) {
            $query = $query . " AND (" . " surname LIKE ? OR surname LIKE ?
                OR firstname  LIKE ? OR firstname LIKE ?
                OR othernames LIKE ? OR othernames LIKE ?)";
            push( @bind,
                "$data[$i]%",   "% $data[$i]%", "$data[$i]%",
                "% $data[$i]%", "$data[$i]%",   "% $data[$i]%" );

            # FIXME - .= <<EOT;
        }
        $query = $query . ") OR cardnumber LIKE ? ";
        push( @bind, $searchstring );
        if (C4::Context->preference('ExtendedPatronAttributes')) {
            $query .= "OR borrowernumber IN (
SELECT borrowernumber
FROM borrower_attributes
JOIN borrower_attribute_types USING (code)
WHERE staff_searchable = 1
AND attribute like ?
)";
            push (@bind, $searchstring);
        }
        $query .= "order by $orderby";

        # FIXME - .= <<EOT;
    }

    $sth = $dbh->prepare($query);

    $debug and print STDERR "Q $orderby : $query\n";
    $sth->execute(@bind);
    my @results;
    $data = $sth->fetchall_arrayref({});

    $sth->finish;
    return ( scalar(@$data), $data );
}

=head2 GetMemberDetails

($borrower) = &GetMemberDetails($borrowernumber, $cardnumber);

Looks up a patron and returns information about him or her. If
C<$borrowernumber> is true (nonzero), C<&GetMemberDetails> looks
up the borrower by number; otherwise, it looks up the borrower by card
number.

C<$borrower> is a reference-to-hash whose keys are the fields of the
borrowers table in the Koha database. In addition,
C<$borrower-E<gt>{flags}> is a hash giving more detailed information
about the patron. Its keys act as flags :

    if $borrower->{flags}->{LOST} {
        # Patron's card was reported lost
    }

Each flag has a C<message> key, giving a human-readable explanation of
the flag. If the state of a flag means that the patron should not be
allowed to borrow any more books, then it will have a C<noissues> key
with a true value.

The possible flags are:

=head3 CHARGES

=over 4

=item Shows the patron's credit or debt, if any.

=back

=head3 GNA

=over 4

=item (Gone, no address.) Set if the patron has left without giving a
forwarding address.

=back

=head3 LOST

=over 4

=item Set if the patron's card has been reported as lost.

=back

=head3 DBARRED

=over 4

=item Set if the patron has been debarred.

=back

=head3 NOTES

=over 4

=item Any additional notes about the patron.

=back

=head3 ODUES

=over 4

=item Set if the patron has overdue items. This flag has several keys:

C<$flags-E<gt>{ODUES}{itemlist}> is a reference-to-array listing the
overdue items. Its elements are references-to-hash, each describing an
overdue item. The keys are selected fields from the issues, biblio,
biblioitems, and items tables of the Koha database.

C<$flags-E<gt>{ODUES}{itemlist}> is a string giving a text listing of
the overdue items, one per line.

=back

=head3 WAITING

=over 4

=item Set if any items that the patron has reserved are available.

C<$flags-E<gt>{WAITING}{itemlist}> is a reference-to-array listing the
available items. Each element is a reference-to-hash whose keys are
fields from the reserves table of the Koha database.

=back

C<$borrower-E<gt>{authflags}> is a hash giving more detailed information
about the top-level permissions flags set for the borrower.  For example,
if a user has the "editcatalogue" permission,
C<$borrower-E<gt>{authflags}-E<gt>{editcatalogue}> will exist and have
the value "1".

=cut

sub GetMemberDetails {
    my ( $borrowernumber, $cardnumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $query;
    my $sth;
    if ($borrowernumber) {
        $sth = $dbh->prepare("select borrowers.*,category_type,categories.description from borrowers left join categories on borrowers.categorycode=categories.categorycode where  borrowernumber=?");
        $sth->execute($borrowernumber);
    }
    elsif ($cardnumber) {
        $sth = $dbh->prepare("select borrowers.*,category_type,categories.description from borrowers left join categories on borrowers.categorycode=categories.categorycode where cardnumber=?");
        $sth->execute($cardnumber);
    }
    else {
        return undef;
    }
    my $borrower = $sth->fetchrow_hashref;
    my ($amount) = GetMemberAccountRecords( $borrowernumber);
    $borrower->{'amountoutstanding'} = $amount;
    # FIXME - patronflags calls GetMemberAccountRecords... just have patronflags return $amount
    my $flags = patronflags( $borrower);
    my $accessflagshash;

    $sth = $dbh->prepare("select bit,flag from userflags");
    $sth->execute;
    while ( my ( $bit, $flag ) = $sth->fetchrow ) {
        if ( $borrower->{'flags'} && $borrower->{'flags'} & 2**$bit ) {
            $accessflagshash->{$flag} = 1;
        }
    }
    $sth->finish;
    $borrower->{'flags'}     = $flags;
    $borrower->{'authflags'} = $accessflagshash;

    # find out how long the membership lasts
    $sth =
      $dbh->prepare(
        "select enrolmentperiod from categories where categorycode = ?");
    $sth->execute( $borrower->{'categorycode'} );
    my $enrolment = $sth->fetchrow;
    $borrower->{'enrolmentperiod'} = $enrolment;
    return ($borrower);    #, $flags, $accessflagshash);
}

=head2 patronflags

 Not exported

 NOTE!: If you change this function, be sure to update the POD for
 &GetMemberDetails.

 $flags = &patronflags($patron);

 $flags->{CHARGES}
        {message}    Message showing patron's credit or debt
       {noissues}    Set if patron owes >$5.00
         {GNA}            Set if patron gone w/o address
        {message}    "Borrower has no valid address"
        {noissues}    Set.
        {LOST}        Set if patron's card reported lost
        {message}    Message to this effect
        {noissues}    Set.
        {DBARRED}        Set is patron is debarred
        {message}    Message to this effect
        {noissues}    Set.
         {NOTES}        Set if patron has notes
        {message}    Notes about patron
         {ODUES}        Set if patron has overdue books
        {message}    "Yes"
        {itemlist}    ref-to-array: list of overdue books
        {itemlisttext}    Text list of overdue items
         {WAITING}        Set if there are items available that the
                patron reserved
        {message}    Message to this effect
        {itemlist}    ref-to-array: list of available items

=cut
# FIXME rename this function.
sub patronflags {
    my %flags;
    my ( $patroninformation) = @_;
    my $dbh=C4::Context->dbh;
    my ($amount) = GetMemberAccountRecords( $patroninformation->{'borrowernumber'});
    if ( $amount > 0 ) {
        my %flaginfo;
        my $noissuescharge = C4::Context->preference("noissuescharge");
        $flaginfo{'message'} = sprintf "Patron owes \$%.02f", $amount;
        $flaginfo{'amount'} = sprintf "%.02f",$amount;
        if ( $amount > $noissuescharge ) {
            $flaginfo{'noissues'} = 1;
        }
        $flags{'CHARGES'} = \%flaginfo;
    }
    elsif ( $amount < 0 ) {
        my %flaginfo;
        $flaginfo{'message'} = sprintf "Patron has credit of \$%.02f", -$amount;
        $flags{'CREDITS'} = \%flaginfo;
    }
    if (   $patroninformation->{'gonenoaddress'}
        && $patroninformation->{'gonenoaddress'} == 1 )
    {
        my %flaginfo;
        $flaginfo{'message'}  = 'Borrower has no valid address.';
        $flaginfo{'noissues'} = 1;
        $flags{'GNA'}         = \%flaginfo;
    }
    if ( $patroninformation->{'lost'} && $patroninformation->{'lost'} == 1 ) {
        my %flaginfo;
        $flaginfo{'message'}  = 'Borrower\'s card reported lost.';
        $flaginfo{'noissues'} = 1;
        $flags{'LOST'}        = \%flaginfo;
    }
    if (   $patroninformation->{'debarred'}
        && $patroninformation->{'debarred'} == 1 )
    {
        my %flaginfo;
        $flaginfo{'message'}  = 'Borrower is Debarred.';
        $flaginfo{'noissues'} = 1;
        $flags{'DBARRED'}     = \%flaginfo;
    }
    if (   $patroninformation->{'borrowernotes'}
        && $patroninformation->{'borrowernotes'} )
    {
        my %flaginfo;
        $flaginfo{'message'} = "$patroninformation->{'borrowernotes'}";
        $flags{'NOTES'}      = \%flaginfo;
    }
    my ( $odues, $itemsoverdue ) =
      checkoverdues( $patroninformation->{'borrowernumber'}, $dbh );
    if ( $odues > 0 ) {
        my %flaginfo;
        $flaginfo{'message'}  = "Yes";
        $flaginfo{'itemlist'} = $itemsoverdue;
        foreach ( sort { $a->{'date_due'} cmp $b->{'date_due'} }
            @$itemsoverdue )
        {
            $flaginfo{'itemlisttext'} .=
              "$_->{'date_due'} $_->{'barcode'} $_->{'title'} \n";
        }
        $flags{'ODUES'} = \%flaginfo;
    }
    my @itemswaiting = C4::Reserves::GetReservesFromBorrowernumber( $patroninformation->{'borrowernumber'},'W' );
    my $nowaiting = scalar @itemswaiting;
    if ( $nowaiting > 0 ) {
        my %flaginfo;
        $flaginfo{'message'}  = "Reserved items available";
        $flaginfo{'itemlist'} = \@itemswaiting;
        $flags{'WAITING'}     = \%flaginfo;
    }
    return ( \%flags );
}


=head2 GetMember

  $borrower = &GetMember($information, $type);

Looks up information about a patron (borrower) by either card number
,firstname, or borrower number, depending on $type value.
If C<$type> == 'cardnumber', C<&GetBorrower>
searches by cardnumber then by firstname if not found in cardnumber; 
otherwise, it searches by borrowernumber.

C<&GetBorrower> returns a reference-to-hash whose keys are the fields of
the C<borrowers> table in the Koha database.

=cut

#'
sub GetMember {
    my ( $information, $type ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth;
    my $select = "
SELECT borrowers.*, categories.category_type, categories.description
FROM borrowers 
LEFT JOIN categories on borrowers.categorycode=categories.categorycode 
";
    if (defined($type) and ( $type eq 'cardnumber' || $type eq 'firstname'|| $type eq 'userid'|| $type eq 'borrowernumber' ) ){
        $information = uc $information;
        $sth = $dbh->prepare("$select WHERE $type=?");
    } else {
        $sth = $dbh->prepare("$select WHERE borrowernumber=?");
    }
    $sth->execute($information);
    my $data = $sth->fetchrow_hashref;
    ($data) and return ($data);

    if (defined($type) and ($type eq 'cardnumber' || $type eq 'firstname')) {    # otherwise, try with firstname
        $sth = $dbh->prepare("$select WHERE firstname like ?");
        $sth->execute($information);
        $data = $sth->fetchrow_hashref;
        ($data) and return ($data);
    }
    return undef;        
}

=head2 GetMemberIssuesAndFines

  ($overdue_count, $issue_count, $total_fines) = &GetMemberIssuesAndFines($borrowernumber);

Returns aggregate data about items borrowed by the patron with the
given borrowernumber.

C<&GetMemberIssuesAndFines> returns a three-element array.  C<$overdue_count> is the
number of overdue items the patron currently has borrowed. C<$issue_count> is the
number of books the patron currently has borrowed.  C<$total_fines> is
the total fine currently due by the borrower.

=cut

#'
sub GetMemberIssuesAndFines {
    my ( $borrowernumber ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT COUNT(*) FROM issues WHERE borrowernumber = ?";

    $debug and warn $query."\n";
    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    my $issue_count = $sth->fetchrow_arrayref->[0];
    $sth->finish;

    $sth = $dbh->prepare(
        "SELECT COUNT(*) FROM issues 
         WHERE borrowernumber = ? 
         AND date_due < now()"
    );
    $sth->execute($borrowernumber);
    my $overdue_count = $sth->fetchrow_arrayref->[0];
    $sth->finish;

    $sth = $dbh->prepare("SELECT SUM(amountoutstanding) FROM accountlines WHERE borrowernumber = ?");
    $sth->execute($borrowernumber);
    my $total_fines = $sth->fetchrow_arrayref->[0];
    $sth->finish;

    return ($overdue_count, $issue_count, $total_fines);
}

sub columns(;$) {
    return @{C4::Context->dbh->selectcol_arrayref("SHOW columns from borrowers")};
}

=head2

=head2 ModMember

=over 4

my $success = ModMember(borrowernumber => $borrowernumber, [ field => value ]... );

Modify borrower's data.  All date fields should ALREADY be in ISO format.

return :
true on success, or false on failure

=back

=cut

sub ModMember {
    my (%data) = @_;
    my $dbh = C4::Context->dbh;
    my $iso_re = C4::Dates->new()->regexp('iso');
    foreach (qw(dateofbirth dateexpiry dateenrolled)) {
        if (my $tempdate = $data{$_}) {                                 # assignment, not comparison
            ($tempdate =~ /$iso_re/) and next;                          # Congatulations, you sent a valid ISO date.
            warn "ModMember given $_ not in ISO format ($tempdate)";
            my $tempdate2 = format_date_in_iso($tempdate);
            if (!$tempdate2 or $tempdate2 eq '0000-00-00') {
                warn "ModMember cannot convert '$tempdate' (from syspref to ISO)";
                next;
            }
            $data{$_} = $tempdate2;
        }
    }
    if (!$data{'dateofbirth'}){
        delete $data{'dateofbirth'};
    }
    my @columns = &columns;
    my %hashborrowerfields = (map {$_=>1} @columns);
    my $query = "UPDATE borrowers SET \n";
    my $sth;
    my @parameters;  
    
    # test to know if you must update or not the borrower password
    if (exists $data{password}) {
        if ($data{password} eq '****' or $data{password} eq '') {
            delete $data{password};
        } else {
            $data{password} = md5_base64($data{password});
        }
    }
    my @badkeys;
    foreach (keys %data) {  
        next if ($_ eq 'borrowernumber' or $_ eq 'flags');
        if ($hashborrowerfields{$_}){
            $query .= " $_=?, "; 
            push @parameters,$data{$_};
        } else {
            push @badkeys, $_;
            delete $data{$_};
        }
    }
    (@badkeys) and warn scalar(@badkeys) . " Illegal key(s) passed to ModMember: " . join(',',@badkeys);
    $query =~ s/, $//;
    $query .= " WHERE borrowernumber=?";
    push @parameters, $data{'borrowernumber'};
    $debug and print STDERR "$query (executed w/ arg: $data{'borrowernumber'})";
    $sth = $dbh->prepare($query);
    my $execute_success = $sth->execute(@parameters);
    $sth->finish;

# ok if its an adult (type) it may have borrowers that depend on it as a guarantor
# so when we update information for an adult we should check for guarantees and update the relevant part
# of their records, ie addresses and phone numbers
    my $borrowercategory= GetBorrowercategory( $data{'category_type'} );
    if ( exists  $borrowercategory->{'category_type'} && $borrowercategory->{'category_type'} eq ('A' || 'S') ) {
        # is adult check guarantees;
        UpdateGuarantees(%data);
    }
    logaction("MEMBERS", "MODIFY", $data{'borrowernumber'}, "$query (executed w/ arg: $data{'borrowernumber'})") 
        if C4::Context->preference("BorrowersLog");

    return $execute_success;
}


=head2

=head2 AddMember

  $borrowernumber = &AddMember(%borrower);

insert new borrower into table
Returns the borrowernumber

=cut

#'
sub AddMember {
    my (%data) = @_;
    my $dbh = C4::Context->dbh;
    $data{'userid'} = '' unless $data{'password'};
    $data{'password'} = md5_base64( $data{'password'} ) if $data{'password'};
    
    # WE SHOULD NEVER PASS THIS SUBROUTINE ANYTHING OTHER THAN ISO DATES
    # IF YOU UNCOMMENT THESE LINES YOU BETTER HAVE A DARN COMPELLING REASON
#    $data{'dateofbirth'}  = format_date_in_iso( $data{'dateofbirth'} );
#    $data{'dateenrolled'} = format_date_in_iso( $data{'dateenrolled'});
#    $data{'dateexpiry'}   = format_date_in_iso( $data{'dateexpiry'}  );
    # This query should be rewritten to use "?" at execute.
    if (!$data{'dateofbirth'}){
        undef ($data{'dateofbirth'});
    }
    my $query =
        "insert into borrowers set cardnumber=" . $dbh->quote( $data{'cardnumber'} )
      . ",surname="     . $dbh->quote( $data{'surname'} )
      . ",firstname="   . $dbh->quote( $data{'firstname'} )
      . ",title="       . $dbh->quote( $data{'title'} )
      . ",othernames="  . $dbh->quote( $data{'othernames'} )
      . ",initials="    . $dbh->quote( $data{'initials'} )
      . ",streetnumber=". $dbh->quote( $data{'streetnumber'} )
      . ",streettype="  . $dbh->quote( $data{'streettype'} )
      . ",address="     . $dbh->quote( $data{'address'} )
      . ",address2="    . $dbh->quote( $data{'address2'} )
      . ",zipcode="     . $dbh->quote( $data{'zipcode'} )
      . ",city="        . $dbh->quote( $data{'city'} )
      . ",phone="       . $dbh->quote( $data{'phone'} )
      . ",email="       . $dbh->quote( $data{'email'} )
      . ",mobile="      . $dbh->quote( $data{'mobile'} )
      . ",phonepro="    . $dbh->quote( $data{'phonepro'} )
      . ",opacnote="    . $dbh->quote( $data{'opacnote'} )
      . ",guarantorid=" . $dbh->quote( $data{'guarantorid'} )
      . ",dateofbirth=" . $dbh->quote( $data{'dateofbirth'} )
      . ",branchcode="  . $dbh->quote( $data{'branchcode'} )
      . ",categorycode=" . $dbh->quote( $data{'categorycode'} )
      . ",dateenrolled=" . $dbh->quote( $data{'dateenrolled'} )
      . ",contactname=" . $dbh->quote( $data{'contactname'} )
      . ",borrowernotes=" . $dbh->quote( $data{'borrowernotes'} )
      . ",dateexpiry="  . $dbh->quote( $data{'dateexpiry'} )
      . ",contactnote=" . $dbh->quote( $data{'contactnote'} )
      . ",B_address="   . $dbh->quote( $data{'B_address'} )
      . ",B_zipcode="   . $dbh->quote( $data{'B_zipcode'} )
      . ",B_city="      . $dbh->quote( $data{'B_city'} )
      . ",B_phone="     . $dbh->quote( $data{'B_phone'} )
      . ",B_email="     . $dbh->quote( $data{'B_email'} )
      . ",password="    . $dbh->quote( $data{'password'} )
      . ",userid="      . $dbh->quote( $data{'userid'} )
      . ",sort1="       . $dbh->quote( $data{'sort1'} )
      . ",sort2="       . $dbh->quote( $data{'sort2'} )
      . ",contacttitle=" . $dbh->quote( $data{'contacttitle'} )
      . ",emailpro="    . $dbh->quote( $data{'emailpro'} )
      . ",contactfirstname=" . $dbh->quote( $data{'contactfirstname'} )
      . ",sex="         . $dbh->quote( $data{'sex'} )
      . ",fax="         . $dbh->quote( $data{'fax'} )
      . ",relationship=" . $dbh->quote( $data{'relationship'} )
      . ",B_streetnumber=" . $dbh->quote( $data{'B_streetnumber'} )
      . ",B_streettype=" . $dbh->quote( $data{'B_streettype'} )
      . ",gonenoaddress=" . $dbh->quote( $data{'gonenoaddress'} )
      . ",lost="        . $dbh->quote( $data{'lost'} )
      . ",debarred="    . $dbh->quote( $data{'debarred'} )
      . ",ethnicity="   . $dbh->quote( $data{'ethnicity'} )
      . ",ethnotes="    . $dbh->quote( $data{'ethnotes'} ) 
      . ",altcontactsurname="   . $dbh->quote( $data{'altcontactsurname'} ) 
      . ",altcontactfirstname="     . $dbh->quote( $data{'altcontactfirstname'} ) 
      . ",altcontactaddress1="  . $dbh->quote( $data{'altcontactaddress1'} ) 
      . ",altcontactaddress2="  . $dbh->quote( $data{'altcontactaddress2'} ) 
      . ",altcontactaddress3="  . $dbh->quote( $data{'altcontactaddress3'} ) 
      . ",altcontactzipcode="   . $dbh->quote( $data{'altcontactzipcode'} ) 
      . ",altcontactphone="     . $dbh->quote( $data{'altcontactphone'} ) ;
    $debug and print STDERR "AddMember SQL: ($query)\n";
    my $sth = $dbh->prepare($query);
    #   print "Executing SQL: $query\n";
    $sth->execute();
    $sth->finish;
    $data{'borrowernumber'} = $dbh->{'mysql_insertid'};     # unneeded w/ autoincrement ?  
    # mysql_insertid is probably bad.  not necessarily accurate and mysql-specific at best.
    
    logaction("MEMBERS", "CREATE", $data{'borrowernumber'}, "") if C4::Context->preference("BorrowersLog");
    
    # check for enrollment fee & add it if needed
    $sth = $dbh->prepare("SELECT enrolmentfee FROM categories WHERE categorycode=?");
    $sth->execute($data{'categorycode'});
    my ($enrolmentfee) = $sth->fetchrow;
    if ($enrolmentfee && $enrolmentfee > 0) {
        # insert fee in patron debts
        manualinvoice($data{'borrowernumber'}, '', '', 'A', $enrolmentfee);
    }
    return $data{'borrowernumber'};
}

sub Check_Userid {
    my ($uid,$member) = @_;
    my $dbh = C4::Context->dbh;
    # Make sure the userid chosen is unique and not theirs if non-empty. If it is not,
    # Then we need to tell the user and have them create a new one.
    my $sth =
      $dbh->prepare(
        "SELECT * FROM borrowers WHERE userid=? AND borrowernumber != ?");
    $sth->execute( $uid, $member );
    if ( ( $uid ne '' ) && ( my $row = $sth->fetchrow_hashref ) ) {
        return 0;
    }
    else {
        return 1;
    }
}

sub Generate_Userid {
  my ($borrowernumber, $firstname, $surname) = @_;
  my $newuid;
  my $offset = 0;
  do {
    $firstname =~ s/[[:digit:][:space:][:blank:][:punct:][:cntrl:]]//g;
    $surname =~ s/[[:digit:][:space:][:blank:][:punct:][:cntrl:]]//g;
    $newuid = lc("$firstname.$surname");
    $newuid .= $offset unless $offset == 0;
    $offset++;

   } while (!Check_Userid($newuid,$borrowernumber));

   return $newuid;
}

sub changepassword {
    my ( $uid, $member, $digest ) = @_;
    my $dbh = C4::Context->dbh;

#Make sure the userid chosen is unique and not theirs if non-empty. If it is not,
#Then we need to tell the user and have them create a new one.
    my $resultcode;
    my $sth =
      $dbh->prepare(
        "SELECT * FROM borrowers WHERE userid=? AND borrowernumber != ?");
    $sth->execute( $uid, $member );
    if ( ( $uid ne '' ) && ( my $row = $sth->fetchrow_hashref ) ) {
        $resultcode=0;
    }
    else {
        #Everything is good so we can update the information.
        $sth =
          $dbh->prepare(
            "update borrowers set userid=?, password=? where borrowernumber=?");
        $sth->execute( $uid, $digest, $member );
        $resultcode=1;
    }
    
    logaction("MEMBERS", "CHANGE PASS", $member, "") if C4::Context->preference("BorrowersLog");
    return $resultcode;    
}



=head2 fixup_cardnumber

Warning: The caller is responsible for locking the members table in write
mode, to avoid database corruption.

=cut

use vars qw( @weightings );
my @weightings = ( 8, 4, 6, 3, 5, 2, 1 );

sub fixup_cardnumber ($) {
    my ($cardnumber) = @_;
    my $autonumber_members = C4::Context->boolean_preference('autoMemberNum') || 0;

    # Find out whether member numbers should be generated
    # automatically. Should be either "1" or something else.
    # Defaults to "0", which is interpreted as "no".

    #     if ($cardnumber !~ /\S/ && $autonumber_members) {
    ($autonumber_members) or return $cardnumber;
    my $checkdigit = C4::Context->preference('checkdigit');
    my $dbh = C4::Context->dbh;
    if ( $checkdigit and $checkdigit eq 'katipo' ) {

        # if checkdigit is selected, calculate katipo-style cardnumber.
        # otherwise, just use the max()
        # purpose: generate checksum'd member numbers.
        # We'll assume we just got the max value of digits 2-8 of member #'s
        # from the database and our job is to increment that by one,
        # determine the 1st and 9th digits and return the full string.
        my $sth = $dbh->prepare(
            "select max(substring(borrowers.cardnumber,2,7)) as new_num from borrowers"
        );
        $sth->execute;
        my $data = $sth->fetchrow_hashref;
        $cardnumber = $data->{new_num};
        if ( !$cardnumber ) {    # If DB has no values,
            $cardnumber = 1000000;    # start at 1000000
        } else {
            $cardnumber += 1;
        }

        my $sum = 0;
        for ( my $i = 0 ; $i < 8 ; $i += 1 ) {
            # read weightings, left to right, 1 char at a time
            my $temp1 = $weightings[$i];

            # sequence left to right, 1 char at a time
            my $temp2 = substr( $cardnumber, $i, 1 );

            # mult each char 1-7 by its corresponding weighting
            $sum += $temp1 * $temp2;
        }

        my $rem = ( $sum % 11 );
        $rem = 'X' if $rem == 10;

        return "V$cardnumber$rem";
     } else {

     # MODIFIED BY JF: mysql4.1 allows casting as an integer, which is probably
     # better. I'll leave the original in in case it needs to be changed for you
     # my $sth=$dbh->prepare("select max(borrowers.cardnumber) from borrowers");
        my $sth = $dbh->prepare(
            "select max(cast(cardnumber as signed)) from borrowers"
        );
        $sth->execute;
        my ($result) = $sth->fetchrow;
        return $result + 1;
    }
    return $cardnumber;     # just here as a fallback/reminder 
}

=head2 GetGuarantees

  ($num_children, $children_arrayref) = &GetGuarantees($parent_borrno);
  $child0_cardno = $children_arrayref->[0]{"cardnumber"};
  $child0_borrno = $children_arrayref->[0]{"borrowernumber"};

C<&GetGuarantees> takes a borrower number (e.g., that of a patron
with children) and looks up the borrowers who are guaranteed by that
borrower (i.e., the patron's children).

C<&GetGuarantees> returns two values: an integer giving the number of
borrowers guaranteed by C<$parent_borrno>, and a reference to an array
of references to hash, which gives the actual results.

=cut

#'
sub GetGuarantees {
    my ($borrowernumber) = @_;
    my $dbh              = C4::Context->dbh;
    my $sth              =
      $dbh->prepare(
"select cardnumber,borrowernumber, firstname, surname from borrowers where guarantorid=?"
      );
    $sth->execute($borrowernumber);

    my @dat;
    my $data = $sth->fetchall_arrayref({}); 
    $sth->finish;
    return ( scalar(@$data), $data );
}

=head2 UpdateGuarantees

  &UpdateGuarantees($parent_borrno);
  

C<&UpdateGuarantees> borrower data for an adult and updates all the guarantees
with the modified information

=cut

#'
sub UpdateGuarantees {
    my (%data) = @_;
    my $dbh = C4::Context->dbh;
    my ( $count, $guarantees ) = GetGuarantees( $data{'borrowernumber'} );
    for ( my $i = 0 ; $i < $count ; $i++ ) {

        # FIXME
        # It looks like the $i is only being returned to handle walking through
        # the array, which is probably better done as a foreach loop.
        #
        my $guaquery = qq|UPDATE borrowers 
              SET address='$data{'address'}',fax='$data{'fax'}',
                  B_city='$data{'B_city'}',mobile='$data{'mobile'}',city='$data{'city'}',phone='$data{'phone'}'
              WHERE borrowernumber='$guarantees->[$i]->{'borrowernumber'}'
        |;
        my $sth3 = $dbh->prepare($guaquery);
        $sth3->execute;
        $sth3->finish;
    }
}
=head2 GetPendingIssues

  my $issues = &GetPendingIssues($borrowernumber);

Looks up what the patron with the given borrowernumber has borrowed.

C<&GetPendingIssues> returns a
reference-to-array where each element is a reference-to-hash; the
keys are the fields from the C<issues>, C<biblio>, and C<items> tables.
The keys include C<biblioitems> fields except marc and marcxml.

=cut

#'
sub GetPendingIssues {
    my ($borrowernumber) = @_;
    # must avoid biblioitems.* to prevent large marc and marcxml fields from killing performance
    # FIXME: namespace collision: each table has "timestamp" fields.  Which one is "timestamp" ?
    # FIXME: circ/ciculation.pl tries to sort by timestamp!
    # FIXME: C4::Print::printslip tries to sort by timestamp!
    # FIXME: namespace collision: other collisions possible.
    # FIXME: most of this data isn't really being used by callers.
    my $sth = C4::Context->dbh->prepare(
   "SELECT issues.*,
            items.*,
           biblio.*,
           biblioitems.volume,
           biblioitems.number,
           biblioitems.itemtype,
           biblioitems.isbn,
           biblioitems.issn,
           biblioitems.publicationyear,
           biblioitems.publishercode,
           biblioitems.volumedate,
           biblioitems.volumedesc,
           biblioitems.lccn,
           biblioitems.url,
           issues.timestamp AS timestamp,
           issues.renewals  AS renewals,
            items.renewals  AS totalrenewals
    FROM   issues
    LEFT JOIN items       ON items.itemnumber       =      issues.itemnumber
    LEFT JOIN biblio      ON items.biblionumber     =      biblio.biblionumber
    LEFT JOIN biblioitems ON items.biblioitemnumber = biblioitems.biblioitemnumber
    WHERE
      borrowernumber=?
    ORDER BY issues.issuedate"
    );
    $sth->execute($borrowernumber);
    my $data = $sth->fetchall_arrayref({});
    my $today = C4::Dates->new->output('iso');
    foreach (@$data) {
        $_->{date_due} or next;
        ($_->{date_due} lt $today) and $_->{overdue} = 1;
    }
    return $data;
}

=head2 GetAllIssues

  ($count, $issues) = &GetAllIssues($borrowernumber, $sortkey, $limit);

Looks up what the patron with the given borrowernumber has borrowed,
and sorts the results.

C<$sortkey> is the name of a field on which to sort the results. This
should be the name of a field in the C<issues>, C<biblio>,
C<biblioitems>, or C<items> table in the Koha database.

C<$limit> is the maximum number of results to return.

C<&GetAllIssues> returns a two-element array. C<$issues> is a
reference-to-array, where each element is a reference-to-hash; the
keys are the fields from the C<issues>, C<biblio>, C<biblioitems>, and
C<items> tables of the Koha database. C<$count> is the number of
elements in C<$issues>

=cut

#'
sub GetAllIssues {
    my ( $borrowernumber, $order, $limit ) = @_;

    #FIXME: sanity-check order and limit
    my $dbh   = C4::Context->dbh;
    my $count = 0;
    my $query =
  "SELECT *,issues.renewals AS renewals,items.renewals AS totalrenewals,items.timestamp AS itemstimestamp 
  FROM issues 
  LEFT JOIN items on items.itemnumber=issues.itemnumber
  LEFT JOIN biblio ON items.biblionumber=biblio.biblionumber
  LEFT JOIN biblioitems ON items.biblioitemnumber=biblioitems.biblioitemnumber
  WHERE borrowernumber=? 
  UNION ALL
  SELECT *,old_issues.renewals AS renewals,items.renewals AS totalrenewals,items.timestamp AS itemstimestamp 
  FROM old_issues 
  LEFT JOIN items on items.itemnumber=old_issues.itemnumber
  LEFT JOIN biblio ON items.biblionumber=biblio.biblionumber
  LEFT JOIN biblioitems ON items.biblioitemnumber=biblioitems.biblioitemnumber
  WHERE borrowernumber=? 
  order by $order";
    if ( $limit != 0 ) {
        $query .= " limit $limit";
    }

    #print $query;
    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber, $borrowernumber);
    my @result;
    my $i = 0;
    while ( my $data = $sth->fetchrow_hashref ) {
        $result[$i] = $data;
        $i++;
        $count++;
    }

    # get all issued items for borrowernumber from oldissues table
    # large chunk of older issues data put into table oldissues
    # to speed up db calls for issuing items
    if ( C4::Context->preference("ReadingHistory") ) {
        # FIXME oldissues (not to be confused with old_issues) is
        # apparently specific to HLT.  Not sure if the ReadingHistory
        # syspref is still required, as old_issues by design
        # is no longer checked with each loan.
        my $query2 = "SELECT * FROM oldissues
                      LEFT JOIN items ON items.itemnumber=oldissues.itemnumber
                      LEFT JOIN biblio ON items.biblionumber=biblio.biblionumber
                      LEFT JOIN biblioitems ON items.biblioitemnumber=biblioitems.biblioitemnumber
                      WHERE borrowernumber=? 
                      ORDER BY $order";
        if ( $limit != 0 ) {
            $limit = $limit - $count;
            $query2 .= " limit $limit";
        }

        my $sth2 = $dbh->prepare($query2);
        $sth2->execute($borrowernumber);

        while ( my $data2 = $sth2->fetchrow_hashref ) {
            $result[$i] = $data2;
            $i++;
        }
        $sth2->finish;
    }
    $sth->finish;

    return ( $i, \@result );
}


=head2 GetMemberAccountRecords

  ($total, $acctlines, $count) = &GetMemberAccountRecords($borrowernumber);

Looks up accounting data for the patron with the given borrowernumber.

C<&GetMemberAccountRecords> returns a three-element array. C<$acctlines> is a
reference-to-array, where each element is a reference-to-hash; the
keys are the fields of the C<accountlines> table in the Koha database.
C<$count> is the number of elements in C<$acctlines>. C<$total> is the
total amount outstanding for all of the account lines.

=cut

#'
sub GetMemberAccountRecords {
    my ($borrowernumber,$date) = @_;
    my $dbh = C4::Context->dbh;
    my @acctlines;
    my $numlines = 0;
    my $strsth      = qq(
                        SELECT * 
                        FROM accountlines 
                        WHERE borrowernumber=?);
    my @bind = ($borrowernumber);
    if ($date && $date ne ''){
            $strsth.=" AND date < ? ";
            push(@bind,$date);
    }
    $strsth.=" ORDER BY date desc,timestamp DESC";
    my $sth= $dbh->prepare( $strsth );
    $sth->execute( @bind );
    my $total = 0;
    while ( my $data = $sth->fetchrow_hashref ) {
		my $biblio = GetBiblioFromItemNumber($data->{itemnumber}) if $data->{itemnumber};
		$data->{biblionumber} = $biblio->{biblionumber};
	        $data->{title} = $biblio->{title};
        $acctlines[$numlines] = $data;
        $numlines++;
        $total += int(100 * $data->{'amountoutstanding'}); # convert float to integer to avoid round-off errors
    }
    $total /= 100;
    $sth->finish;
    return ( $total, \@acctlines,$numlines);
}

=head2 GetBorNotifyAcctRecord

  ($count, $acctlines, $total) = &GetBorNotifyAcctRecord($params,$notifyid);

Looks up accounting data for the patron with the given borrowernumber per file number.

(FIXME - I'm not at all sure what this is about.)

C<&GetBorNotifyAcctRecord> returns a three-element array. C<$acctlines> is a
reference-to-array, where each element is a reference-to-hash; the
keys are the fields of the C<accountlines> table in the Koha database.
C<$count> is the number of elements in C<$acctlines>. C<$total> is the
total amount outstanding for all of the account lines.

=cut

sub GetBorNotifyAcctRecord {
    my ( $borrowernumber, $notifyid ) = @_;
    my $dbh = C4::Context->dbh;
    my @acctlines;
    my $numlines = 0;
    my $sth = $dbh->prepare(
            "SELECT * 
                FROM accountlines 
                WHERE borrowernumber=? 
                    AND notify_id=? 
                    AND amountoutstanding != '0' 
                ORDER BY notify_id,accounttype
                ");
#                    AND (accounttype='FU' OR accounttype='N' OR accounttype='M'OR accounttype='A'OR accounttype='F'OR accounttype='L' OR accounttype='IP' OR accounttype='CH' OR accounttype='RE' OR accounttype='RL')

    $sth->execute( $borrowernumber, $notifyid );
    my $total = 0;
    while ( my $data = $sth->fetchrow_hashref ) {
        $acctlines[$numlines] = $data;
        $numlines++;
        $total += int(100 * $data->{'amountoutstanding'});
    }
    $total /= 100;
    $sth->finish;
    return ( $total, \@acctlines, $numlines );
}

=head2 checkuniquemember (OUEST-PROVENCE)

  ($result,$categorycode)  = &checkuniquemember($collectivity,$surname,$firstname,$dateofbirth);

Checks that a member exists or not in the database.

C<&result> is nonzero (=exist) or 0 (=does not exist)
C<&categorycode> is from categorycode table
C<&collectivity> is 1 (= we add a collectivity) or 0 (= we add a physical member)
C<&surname> is the surname
C<&firstname> is the firstname (only if collectivity=0)
C<&dateofbirth> is the date of birth in ISO format (only if collectivity=0)

=cut

# FIXME: This function is not legitimate.  Multiple patrons might have the same first/last name and birthdate.
# This is especially true since first name is not even a required field.

sub checkuniquemember {
    my ( $collectivity, $surname, $firstname, $dateofbirth ) = @_;
    my $dbh = C4::Context->dbh;
    my $request = ($collectivity) ?
        "SELECT borrowernumber,categorycode FROM borrowers WHERE surname=? " :
            ($dateofbirth) ?
            "SELECT borrowernumber,categorycode FROM borrowers WHERE surname=? and firstname=?  and dateofbirth=?" :
            "SELECT borrowernumber,categorycode FROM borrowers WHERE surname=? and firstname=?";
    my $sth = $dbh->prepare($request);
    if ($collectivity) {
        $sth->execute( uc($surname) );
    } elsif($dateofbirth){
        $sth->execute( uc($surname), ucfirst($firstname), $dateofbirth );
    }else{
        $sth->execute( uc($surname), ucfirst($firstname));
    }
    my @data = $sth->fetchrow;
    $sth->finish;
    ( $data[0] ) and return $data[0], $data[1];
    return 0;
}

sub checkcardnumber {
    my ($cardnumber,$borrowernumber) = @_;
    my $dbh = C4::Context->dbh;
    my $query = "SELECT * FROM borrowers WHERE cardnumber=?";
    $query .= " AND borrowernumber <> ?" if ($borrowernumber);
  my $sth = $dbh->prepare($query);
  if ($borrowernumber) {
   $sth->execute($cardnumber,$borrowernumber);
  } else { 
     $sth->execute($cardnumber);
  } 
    if (my $data= $sth->fetchrow_hashref()){
        return 1;
    }
    else {
        return 0;
    }
    $sth->finish();
}  


=head2 getzipnamecity (OUEST-PROVENCE)

take all info from table city for the fields city and  zip
check for the name and the zip code of the city selected

=cut

sub getzipnamecity {
    my ($cityid) = @_;
    my $dbh      = C4::Context->dbh;
    my $sth      =
      $dbh->prepare(
        "select city_name,city_zipcode from cities where cityid=? ");
    $sth->execute($cityid);
    my @data = $sth->fetchrow;
    return $data[0], $data[1];
}


=head2 getdcity (OUEST-PROVENCE)

recover cityid  with city_name condition

=cut

sub getidcity {
    my ($city_name) = @_;
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("select cityid from cities where city_name=? ");
    $sth->execute($city_name);
    my $data = $sth->fetchrow;
    return $data;
}


=head2 GetExpiryDate 

  $expirydate = GetExpiryDate($categorycode, $dateenrolled);

Calculate expiry date given a categorycode and starting date.  Date argument must be in ISO format.
Return date is also in ISO format.

=cut

sub GetExpiryDate {
    my ( $categorycode, $dateenrolled ) = @_;
    my $enrolmentperiod = 12;   # reasonable default
    if ($categorycode) {
        my $dbh = C4::Context->dbh;
        my $sth = $dbh->prepare("select enrolmentperiod from categories where categorycode=?");
        $sth->execute($categorycode);
        $enrolmentperiod = $sth->fetchrow;
    }
    # die "GetExpiryDate: for enrollmentperiod $enrolmentperiod (category '$categorycode') starting $dateenrolled.\n";
    my @date = split /-/,$dateenrolled;
    return sprintf("%04d-%02d-%02d", Add_Delta_YM(@date,0,$enrolmentperiod));
}

=head2 checkuserpassword (OUEST-PROVENCE)

check for the password and login are not used
return the number of record 
0=> NOT USED 1=> USED

=cut

sub checkuserpassword {
    my ( $borrowernumber, $userid, $password ) = @_;
    $password = md5_base64($password);
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare(
"Select count(*) from borrowers where borrowernumber !=? and userid =? and password=? "
      );
    $sth->execute( $borrowernumber, $userid, $password );
    my $number_rows = $sth->fetchrow;
    return $number_rows;

}

=head2 GetborCatFromCatType

  ($codes_arrayref, $labels_hashref) = &GetborCatFromCatType();

Looks up the different types of borrowers in the database. Returns two
elements: a reference-to-array, which lists the borrower category
codes, and a reference-to-hash, which maps the borrower category codes
to category descriptions.

=cut

#'
sub GetborCatFromCatType {
    my ( $category_type, $action ) = @_;
	# FIXME - This API  seems both limited and dangerous. 
    my $dbh     = C4::Context->dbh;
    my $request = qq|   SELECT categorycode,description 
            FROM categories 
            $action
            ORDER BY categorycode|;
    my $sth = $dbh->prepare($request);
	if ($action) {
        $sth->execute($category_type);
    }
    else {
        $sth->execute();
    }

    my %labels;
    my @codes;

    while ( my $data = $sth->fetchrow_hashref ) {
        push @codes, $data->{'categorycode'};
        $labels{ $data->{'categorycode'} } = $data->{'description'};
    }
    $sth->finish;
    return ( \@codes, \%labels );
}

=head2 GetBorrowercategory

  $hashref = &GetBorrowercategory($categorycode);

Given the borrower's category code, the function returns the corresponding
data hashref for a comprehensive information display.
  
  $arrayref_hashref = &GetBorrowercategory;
If no category code provided, the function returns all the categories.

=cut

sub GetBorrowercategory {
    my ($catcode) = @_;
    my $dbh       = C4::Context->dbh;
    if ($catcode){
        my $sth       =
        $dbh->prepare(
    "SELECT description,dateofbirthrequired,upperagelimit,category_type 
    FROM categories 
    WHERE categorycode = ?"
        );
        $sth->execute($catcode);
        my $data =
        $sth->fetchrow_hashref;
        $sth->finish();
        return $data;
    } 
    return;  
}    # sub getborrowercategory

=head2 GetBorrowercategoryList
 
  $arrayref_hashref = &GetBorrowercategoryList;
If no category code provided, the function returns all the categories.

=cut

sub GetBorrowercategoryList {
    my $dbh       = C4::Context->dbh;
    my $sth       =
    $dbh->prepare(
    "SELECT * 
    FROM categories 
    ORDER BY description"
        );
    $sth->execute;
    my $data =
    $sth->fetchall_arrayref({});
    $sth->finish();
    return $data;
}    # sub getborrowercategory

=head2 ethnicitycategories

  ($codes_arrayref, $labels_hashref) = &ethnicitycategories();

Looks up the different ethnic types in the database. Returns two
elements: a reference-to-array, which lists the ethnicity codes, and a
reference-to-hash, which maps the ethnicity codes to ethnicity
descriptions.

=cut

#'

sub ethnicitycategories {
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("Select code,name from ethnicity order by name");
    $sth->execute;
    my %labels;
    my @codes;
    while ( my $data = $sth->fetchrow_hashref ) {
        push @codes, $data->{'code'};
        $labels{ $data->{'code'} } = $data->{'name'};
    }
    $sth->finish;
    return ( \@codes, \%labels );
}

=head2 fixEthnicity

  $ethn_name = &fixEthnicity($ethn_code);

Takes an ethnicity code (e.g., "european" or "pi") and returns the
corresponding descriptive name from the C<ethnicity> table in the
Koha database ("European" or "Pacific Islander").

=cut

#'

sub fixEthnicity {
    my $ethnicity = shift;
    return unless $ethnicity;
    my $dbh       = C4::Context->dbh;
    my $sth       = $dbh->prepare("Select name from ethnicity where code = ?");
    $sth->execute($ethnicity);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    return $data->{'name'};
}    # sub fixEthnicity

=head2 GetAge

  $dateofbirth,$date = &GetAge($date);

this function return the borrowers age with the value of dateofbirth

=cut

#'
sub GetAge{
    my ( $date, $date_ref ) = @_;

    if ( not defined $date_ref ) {
        $date_ref = sprintf( '%04d-%02d-%02d', Today() );
    }

    my ( $year1, $month1, $day1 ) = split /-/, $date;
    my ( $year2, $month2, $day2 ) = split /-/, $date_ref;

    my $age = $year2 - $year1;
    if ( $month1 . $day1 > $month2 . $day2 ) {
        $age--;
    }

    return $age;
}    # sub get_age

=head2 get_institutions
  $insitutions = get_institutions();

Just returns a list of all the borrowers of type I, borrownumber and name

=cut

#'
sub get_institutions {
    my $dbh = C4::Context->dbh();
    my $sth =
      $dbh->prepare(
"SELECT borrowernumber,surname FROM borrowers WHERE categorycode=? ORDER BY surname"
      );
    $sth->execute('I');
    my %orgs;
    while ( my $data = $sth->fetchrow_hashref() ) {
        $orgs{ $data->{'borrowernumber'} } = $data;
    }
    $sth->finish();
    return ( \%orgs );

}    # sub get_institutions

=head2 add_member_orgs

  add_member_orgs($borrowernumber,$borrowernumbers);

Takes a borrowernumber and a list of other borrowernumbers and inserts them into the borrowers_to_borrowers table

=cut

#'
sub add_member_orgs {
    my ( $borrowernumber, $otherborrowers ) = @_;
    my $dbh   = C4::Context->dbh();
    my $query =
      "INSERT INTO borrowers_to_borrowers (borrower1,borrower2) VALUES (?,?)";
    my $sth = $dbh->prepare($query);
    foreach my $otherborrowernumber (@$otherborrowers) {
        $sth->execute( $borrowernumber, $otherborrowernumber );
    }
    $sth->finish();

}    # sub add_member_orgs

=head2 GetCities (OUEST-PROVENCE)

  ($id_cityarrayref, $city_hashref) = &GetCities();

Looks up the different city and zip in the database. Returns two
elements: a reference-to-array, which lists the zip city
codes, and a reference-to-hash, which maps the name of the city.
WHERE =>OUEST PROVENCE OR EXTERIEUR

=cut

sub GetCities {

    #my ($type_city) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = qq|SELECT cityid,city_zipcode,city_name 
        FROM cities 
        ORDER BY city_name|;
    my $sth = $dbh->prepare($query);

    #$sth->execute($type_city);
    $sth->execute();
    my %city;
    my @id;
    #    insert empty value to create a empty choice in cgi popup
    push @id, " ";
    $city{""} = "";
    while ( my $data = $sth->fetchrow_hashref ) {
        push @id, $data->{'city_zipcode'}."|".$data->{'city_name'};
        $city{ $data->{'city_zipcode'}."|".$data->{'city_name'} } = $data->{'city_name'};
    }

#test to know if the table contain some records if no the function return nothing
    my $id = @id;
    $sth->finish;
    if ( $id == 1 ) {
        # all we have is the one blank row
        return ();
    }
    else {
        unshift( @id, "" );
        return ( \@id, \%city );
    }
}

=head2 GetSortDetails (OUEST-PROVENCE)

  ($lib) = &GetSortDetails($category,$sortvalue);

Returns the authorized value  details
C<&$lib>return value of authorized value details
C<&$sortvalue>this is the value of authorized value 
C<&$category>this is the value of authorized value category

=cut

sub GetSortDetails {
    my ( $category, $sortvalue ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = qq|SELECT lib 
        FROM authorised_values 
        WHERE category=?
        AND authorised_value=? |;
    my $sth = $dbh->prepare($query);
    $sth->execute( $category, $sortvalue );
    my $lib = $sth->fetchrow;
    return ($lib) if ($lib);
    return ($sortvalue) unless ($lib);
}

=head2 DeleteBorrower 

  () = &DeleteBorrower($member);

delete all data fo borrowers and add record to deletedborrowers table
C<&$member>this is the borrowernumber

=cut

sub MoveMemberToDeleted {
    my ($member) = @_;
    my $dbh = C4::Context->dbh;
    my $query;
    $query = qq|SELECT * 
          FROM borrowers 
          WHERE borrowernumber=?|;
    my $sth = $dbh->prepare($query);
    $sth->execute($member);
    my @data = $sth->fetchrow_array;
    $sth->finish;
    $sth =
      $dbh->prepare( "INSERT INTO deletedborrowers VALUES ("
          . ( "?," x ( scalar(@data) - 1 ) )
          . "?)" );
    $sth->execute(@data);
    $sth->finish;
}

=head2 DelMember

DelMember($borrowernumber);

This function remove directly a borrower whitout writing it on deleteborrower.
+ Deletes reserves for the borrower

=cut

sub DelMember {
    my $dbh            = C4::Context->dbh;
    my $borrowernumber = shift;
    #warn "in delmember with $borrowernumber";
    return unless $borrowernumber;    # borrowernumber is mandatory.

    my $query = qq|DELETE 
          FROM  reserves 
          WHERE borrowernumber=?|;
    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    $sth->finish;
    $query = "
       DELETE
       FROM borrowers
       WHERE borrowernumber = ?
   ";
    $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    $sth->finish;
    logaction("MEMBERS", "DELETE", $borrowernumber, "") if C4::Context->preference("BorrowersLog");
    return $sth->rows;
}

=head2 ExtendMemberSubscriptionTo (OUEST-PROVENCE)

    $date = ExtendMemberSubscriptionTo($borrowerid, $date);

Extending the subscription to a given date or to the expiry date calculated on ISO date.
Returns ISO date.

=cut

sub ExtendMemberSubscriptionTo {
    my ( $borrowerid,$date) = @_;
    my $dbh = C4::Context->dbh;
    my $borrower = GetMember($borrowerid,'borrowernumber');
    unless ($date){
      $date=POSIX::strftime("%Y-%m-%d",localtime());
      my $borrower = GetMember($borrowerid,'borrowernumber');
      $date = GetExpiryDate( $borrower->{'categorycode'}, $date );
    }
    my $sth = $dbh->do(<<EOF);
UPDATE borrowers 
SET  dateexpiry='$date' 
WHERE borrowernumber='$borrowerid'
EOF
    # add enrolmentfee if needed
    $sth = $dbh->prepare("SELECT enrolmentfee FROM categories WHERE categorycode=?");
    $sth->execute($borrower->{'categorycode'});
    my ($enrolmentfee) = $sth->fetchrow;
    if ($enrolmentfee && $enrolmentfee > 0) {
        # insert fee in patron debts
        manualinvoice($borrower->{'borrowernumber'}, '', '', 'A', $enrolmentfee);
    }
    return $date if ($sth);
    return 0;
}

=head2 GetRoadTypes (OUEST-PROVENCE)

  ($idroadtypearrayref, $roadttype_hashref) = &GetRoadTypes();

Looks up the different road type . Returns two
elements: a reference-to-array, which lists the id_roadtype
codes, and a reference-to-hash, which maps the road type of the road .

=cut

sub GetRoadTypes {
    my $dbh   = C4::Context->dbh;
    my $query = qq|
SELECT roadtypeid,road_type 
FROM roadtype 
ORDER BY road_type|;
    my $sth = $dbh->prepare($query);
    $sth->execute();
    my %roadtype;
    my @id;

    #    insert empty value to create a empty choice in cgi popup

    while ( my $data = $sth->fetchrow_hashref ) {

        push @id, $data->{'roadtypeid'};
        $roadtype{ $data->{'roadtypeid'} } = $data->{'road_type'};
    }

#test to know if the table contain some records if no the function return nothing
    my $id = @id;
    $sth->finish;
    if ( $id eq 0 ) {
        return ();
    }
    else {
        unshift( @id, "" );
        return ( \@id, \%roadtype );
    }
}



=head2 GetTitles (OUEST-PROVENCE)

  ($borrowertitle)= &GetTitles();

Looks up the different title . Returns array  with all borrowers title

=cut

sub GetTitles {
    my @borrowerTitle = split /,|\|/,C4::Context->preference('BorrowersTitles');
    unshift( @borrowerTitle, "" );
    my $count=@borrowerTitle;
    if ($count == 1){
        return ();
    }
    else {
        return ( \@borrowerTitle);
    }
}

=head2 GetPatronImage

    my ($imagedata, $dberror) = GetPatronImage($cardnumber);

Returns the mimetype and binary image data of the image for the patron with the supplied cardnumber.

=cut

sub GetPatronImage {
    my ($cardnumber) = @_;
    warn "Cardnumber passed to GetPatronImage is $cardnumber" if $debug;
    my $dbh = C4::Context->dbh;
    my $query = 'SELECT mimetype, imagefile FROM patronimage WHERE cardnumber = ?';
    my $sth = $dbh->prepare($query);
    $sth->execute($cardnumber);
    my $imagedata = $sth->fetchrow_hashref;
    my $dberror = $sth->errstr;
    warn "Database error!" if $sth->errstr;
    $sth->finish;
    return $imagedata, $dberror;
}

=head2 PutPatronImage

    PutPatronImage($cardnumber, $mimetype, $imgfile);

Stores patron binary image data and mimetype in database.
NOTE: This function is good for updating images as well as inserting new images in the database.

=cut

sub PutPatronImage {
    my ($cardnumber, $mimetype, $imgfile) = @_;
    warn "Parameters passed in: Cardnumber=$cardnumber, Mimetype=$mimetype, " . ($imgfile ? "Imagefile" : "No Imagefile") if $debug;
    my $dbh = C4::Context->dbh;
    my $query = "INSERT INTO patronimage (cardnumber, mimetype, imagefile) VALUES (?,?,?) ON DUPLICATE KEY UPDATE imagefile = ?;";
    my $sth = $dbh->prepare($query);
    $sth->execute($cardnumber,$mimetype,$imgfile,$imgfile);
    warn "Error returned inserting $cardnumber.$mimetype." if $sth->errstr;
    my $dberror = $sth->errstr;
    $sth->finish;
    return $dberror;
}

=head2 RmPatronImage

    my ($dberror) = RmPatronImage($cardnumber);

Removes the image for the patron with the supplied cardnumber.

=cut

sub RmPatronImage {
    my ($cardnumber) = @_;
    warn "Cardnumber passed to GetPatronImage is $cardnumber" if $debug;
    my $dbh = C4::Context->dbh;
    my $query = "DELETE FROM patronimage WHERE cardnumber = ?;";
    my $sth = $dbh->prepare($query);
    $sth->execute($cardnumber);
    my $dberror = $sth->errstr;
    warn "Database error!" if $sth->errstr;
    $sth->finish;
    return $dberror;
}

=head2 GetRoadTypeDetails (OUEST-PROVENCE)

  ($roadtype) = &GetRoadTypeDetails($roadtypeid);

Returns the description of roadtype
C<&$roadtype>return description of road type
C<&$roadtypeid>this is the value of roadtype s

=cut

sub GetRoadTypeDetails {
    my ($roadtypeid) = @_;
    my $dbh          = C4::Context->dbh;
    my $query        = qq|
SELECT road_type 
FROM roadtype 
WHERE roadtypeid=?|;
    my $sth = $dbh->prepare($query);
    $sth->execute($roadtypeid);
    my $roadtype = $sth->fetchrow;
    return ($roadtype);
}

=head2 GetBorrowersWhoHaveNotBorrowedSince

&GetBorrowersWhoHaveNotBorrowedSince($date)

this function get all borrowers who haven't borrowed since the date given on input arg.
      
=cut

sub GetBorrowersWhoHaveNotBorrowedSince {
### TODO : It could be dangerous to delete Borrowers who have just been entered and who have not yet borrowed any book. May be good to add a dateexpiry or dateenrolled filter.      
       
                my $filterdate = shift||POSIX::strftime("%Y-%m-%d",localtime());
    my $filterbranch = shift || 
                        ((C4::Context->preference('IndependantBranches') 
                             && C4::Context->userenv 
                             && C4::Context->userenv->{flags}!=1 
                             && C4::Context->userenv->{branch})
                         ? C4::Context->userenv->{branch}
                         : "");  
    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT borrowers.borrowernumber,max(issues.timestamp) as latestissue
        FROM   borrowers
        JOIN   categories USING (categorycode)
        LEFT JOIN issues ON borrowers.borrowernumber = issues.borrowernumber
        WHERE  category_type <> 'S'
   ";
    my @query_params;
    if ($filterbranch && $filterbranch ne ""){ 
        $query.=" AND borrowers.branchcode= ?";
        push @query_params,$filterbranch;
    }    
    $query.=" GROUP BY borrowers.borrowernumber";
    if ($filterdate){ 
        $query.=" HAVING latestissue <? OR latestissue IS NULL";
        push @query_params,$filterdate;
    }
    warn $query if $debug;
    my $sth = $dbh->prepare($query);
    if (scalar(@query_params)>0){  
        $sth->execute(@query_params);
    } 
    else {
        $sth->execute;
    }      
    
    my @results;
    while ( my $data = $sth->fetchrow_hashref ) {
        push @results, $data;
    }
    return \@results;
}

=head2 GetBorrowersWhoHaveNeverBorrowed

$results = &GetBorrowersWhoHaveNeverBorrowed

this function get all borrowers who have never borrowed.

I<$result> is a ref to an array which all elements are a hasref.

=cut

sub GetBorrowersWhoHaveNeverBorrowed {
    my $filterbranch = shift || 
                        ((C4::Context->preference('IndependantBranches') 
                             && C4::Context->userenv 
                             && C4::Context->userenv->{flags}!=1 
                             && C4::Context->userenv->{branch})
                         ? C4::Context->userenv->{branch}
                         : "");  
    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT borrowers.borrowernumber,max(timestamp) as latestissue
        FROM   borrowers
          LEFT JOIN issues ON borrowers.borrowernumber = issues.borrowernumber
        WHERE issues.borrowernumber IS NULL
   ";
    my @query_params;
    if ($filterbranch && $filterbranch ne ""){ 
        $query.=" AND borrowers.branchcode= ?";
        push @query_params,$filterbranch;
    }
    warn $query if $debug;
  
    my $sth = $dbh->prepare($query);
    if (scalar(@query_params)>0){  
        $sth->execute(@query_params);
    } 
    else {
        $sth->execute;
    }      
    
    my @results;
    while ( my $data = $sth->fetchrow_hashref ) {
        push @results, $data;
    }
    return \@results;
}

=head2 GetBorrowersWithIssuesHistoryOlderThan

$results = &GetBorrowersWithIssuesHistoryOlderThan($date)

this function get all borrowers who has an issue history older than I<$date> given on input arg.

I<$result> is a ref to an array which all elements are a hashref.
This hashref is containt the number of time this borrowers has borrowed before I<$date> and the borrowernumber.

=cut

sub GetBorrowersWithIssuesHistoryOlderThan {
    my $dbh  = C4::Context->dbh;
    my $date = shift ||POSIX::strftime("%Y-%m-%d",localtime());
    my $filterbranch = shift || 
                        ((C4::Context->preference('IndependantBranches') 
                             && C4::Context->userenv 
                             && C4::Context->userenv->{flags}!=1 
                             && C4::Context->userenv->{branch})
                         ? C4::Context->userenv->{branch}
                         : "");  
    my $query = "
       SELECT count(borrowernumber) as n,borrowernumber
       FROM old_issues
       WHERE returndate < ?
         AND borrowernumber IS NOT NULL 
    "; 
    my @query_params;
    push @query_params, $date;
    if ($filterbranch){
        $query.="   AND branchcode = ?";
        push @query_params, $filterbranch;
    }    
    $query.=" GROUP BY borrowernumber ";
    warn $query if $debug;
    my $sth = $dbh->prepare($query);
    $sth->execute(@query_params);
    my @results;

    while ( my $data = $sth->fetchrow_hashref ) {
        push @results, $data;
    }
    return \@results;
}

=head2 GetBorrowersNamesAndLatestIssue

$results = &GetBorrowersNamesAndLatestIssueList(@borrowernumbers)

this function get borrowers Names and surnames and Issue information.

I<@borrowernumbers> is an array which all elements are borrowernumbers.
This hashref is containt the number of time this borrowers has borrowed before I<$date> and the borrowernumber.

=cut

sub GetBorrowersNamesAndLatestIssue {
    my $dbh  = C4::Context->dbh;
    my @borrowernumbers=@_;  
    my $query = "
       SELECT surname,lastname, phone, email,max(timestamp)
       FROM borrowers 
         LEFT JOIN issues ON borrowers.borrowernumber=issues.borrowernumber
       GROUP BY borrowernumber
   ";
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my $results = $sth->fetchall_arrayref({});
    return $results;
}

=head2 DebarMember

=over 4

my $success = DebarMember( $borrowernumber );

marks a Member as debarred, and therefore unable to checkout any more
items.

return :
true on success, false on failure

=back

=cut

sub DebarMember {
    my $borrowernumber = shift;

    return unless defined $borrowernumber;
    return unless $borrowernumber =~ /^\d+$/;

    return ModMember( borrowernumber => $borrowernumber,
                      debarred       => 1 );
    
}

END { }    # module clean-up code here (global destructor)

1;

__END__

=head1 AUTHOR

Koha Team

=cut
