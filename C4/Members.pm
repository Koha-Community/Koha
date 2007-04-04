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

# $Id$

use strict;
require Exporter;
use C4::Context;
use C4::Date;
use Digest::MD5 qw(md5_base64);
use Date::Calc qw/Today Add_Delta_YM/;
use C4::Log; # logaction
use C4::Accounts;
use C4::Overdues;
use C4::Reserves2;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

$VERSION = do { my @v = '$Revision$' =~ /\d+/g; shift(@v) . "." . join( "_", map { sprintf "%03d", $_ } @v ); };

=head1 NAME

C4::Members - Perl Module containing convenience functions for member handling

=head1 SYNOPSIS

use C4::Members;

=head1 DESCRIPTION

This module contains routines for adding, modifying and deleting members/patrons/borrowers 

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);

@EXPORT = qw(
  &BornameSearch &GetMember &GetMemberDetails
  &borrdata &borrdata2
  &fixup_cardnumber &findguarantees &findguarantor &GuarantornameSearch
  &modmember &newmember &changepassword &borrissues &allissues
  &checkuniquemember &getzipnamecity &getidcity &getguarantordata &getcategorytype
  &DeleteBorrower
  &calcexpirydate &checkuserpassword
  &getboracctrecord
  &GetborCatFromCatType &getborrowercategory
  &fixEthnicity
  &ethnicitycategories &get_institutions add_member_orgs
  &get_age &GetBorrowersFromSurname &GetBranchCodeFromBorrowers
  &GetFlagsAndBranchFromBorrower
  &GetCities &GetRoadTypes &GetRoadTypeDetails &GetBorNotifyAcctRecord
  &GetMembeReregistration
  &GetSortDetails
  &GetBorrowersTitles	
  &GetBorrowersWhoHaveNotBorrowedSince
  &GetBorrowersWhoHaveNeverBorrowed
  &GetBorrowersWithIssuesHistoryOlderThan
);

=item BornameSearch

  ($count, $borrowers) = &BornameSearch($env, $searchstring, $type);

Looks up patrons (borrowers) by name.

C<$env> is ignored.

BUGFIX 499: C<$type> is now used to determine type of search.
if $type is "simple", search is performed on the first letter of the
surname only.

C<$searchstring> is a space-separated list of search terms. Each term
must match the beginning a borrower's surname, first name, or other
name.

C<&BornameSearch> returns a two-element list. C<$borrowers> is a
reference-to-array; each element is a reference-to-hash, whose keys
are the fields of the C<borrowers> table in the Koha database.
C<$count> is the number of elements in C<$borrowers>.

=cut

#'
#used by member enquiries from the intranet
#called by member.pl
sub BornameSearch {
    my ( $env, $searchstring, $orderby, $type ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "";
    my $count;
    my @data;
    my @bind = ();

    if ( $type eq "simple" )    # simple search for one letter only
    {
        $query =
          "SELECT * FROM borrowers
                  LEFT JOIN categories ON borrowers.categorycode=categories.categorycode
                  WHERE surname LIKE ? ORDER BY $orderby";
        @bind = ("$searchstring%");
    }
    else    # advanced search looking in surname, firstname and othernames
    {
        @data  = split( ' ', $searchstring );
        $count = @data;
        $query = "SELECT * FROM borrowers
                    LEFT JOIN categories ON borrowers.categorycode=categories.categorycode
		WHERE ((surname LIKE ? OR surname LIKE ?
		OR firstname  LIKE ? OR firstname LIKE ?
		OR othernames LIKE ? OR othernames LIKE ?)
		";
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
        $query = $query . ") OR cardnumber LIKE ?
		order by $orderby";
        push( @bind, $searchstring );

        # FIXME - .= <<EOT;
    }

    my $sth = $dbh->prepare($query);

    #	warn "Q $orderby : $query";
    $sth->execute(@bind);
    my @results;
    my $cnt = $sth->rows;
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
    }

    #  $sth->execute;
    $sth->finish;
    return ( $cnt, \@results );
}

=head3 GetFlagsAndBranchFromBorrower

=over 4

($flags, $homebranch) = GetFlagsAndBranchFromBorrower($loggedinuser);

this function read on the database to get flags and homebranch for a user
given on input arg.

return : 
it returns the $flags & the homebranch in scalar context.

=back

=cut

sub GetFlagsAndBranchFromBorrower {
    my $loggedinuser = @_;
    my $dbh          = C4::Context->dbh;
    my $query        = "
       SELECT flags, branchcode
       FROM   borrowers
       WHERE  borrowernumber = ? 
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($loggedinuser);

    return $sth->fetchrow;
}

=item GetMember

  $borrower = &GetMember($cardnumber, $borrowernumber);

Looks up information about a patron (borrower) by either card number
or borrower number. If $borrowernumber is specified, C<&borrdata>
searches by borrower number; otherwise, it searches by card number.

C<&GetMember> returns a reference-to-hash whose keys are the fields of
the C<borrowers> table in the Koha database.

=cut

sub GetMember {
    my ( $cardnumber, $borrowernumber ) = @_;
    $cardnumber = uc $cardnumber;
    my $dbh = C4::Context->dbh;
    my $sth;
    if ( $borrowernumber eq '' ) {
        $sth = $dbh->prepare("Select * from borrowers where cardnumber=?");
        $sth->execute($cardnumber);
    }
    else {
        $sth = $dbh->prepare("Select * from borrowers where borrowernumber=?");
        $sth->execute($borrowernumber);
    }
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    if ($data) {
        return ($data);
    }
    else {    # try with firstname
        if ($cardnumber) {
            my $sth =
              $dbh->prepare("select * from borrowers where firstname=?");
            $sth->execute($cardnumber);
            my $data = $sth->fetchrow_hashref;
            $sth->finish;
            return ($data);
        }
    }
    return undef;
}

=head2 GetMemberDetails

($borrower, $flags) = &GetMemberDetails($borrowernumber, $cardnumber);

Looks up a patron and returns information about him or her. If
C<$borrowernumber> is true (nonzero), C<&GetMemberDetails> looks
up the borrower by number; otherwise, it looks up the borrower by card
number.

C<$env> is effectively ignored, but should be a reference-to-hash.

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

=cut

sub GetMemberDetails {
    my ( $borrowernumber, $cardnumber ) = @_;
    my $dbh = C4::Context->dbh;
    my $query;
    my $sth;
    if ($borrowernumber) {
        $sth = $dbh->prepare("select * from borrowers where borrowernumber=?");
        $sth->execute($borrowernumber);
    }
    elsif ($cardnumber) {
        $sth = $dbh->prepare("select * from borrowers where cardnumber=?");
        $sth->execute($cardnumber);
    }
    else {
        return undef;
    }
    my $borrower = $sth->fetchrow_hashref;
    my $amount = C4::Accounts::checkaccount( $borrowernumber, $dbh );
    $borrower->{'amountoutstanding'} = $amount;
    my $flags = patronflags( $borrower, $dbh );
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

 $flags = &patronflags($env, $patron, $dbh);

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

sub patronflags {
    my %flags;
    my ( $patroninformation, $dbh ) = @_;
    my $amount =
      C4::Accounts::checkaccount( $patroninformation->{'borrowernumber'}, $dbh );
    if ( $amount > 0 ) {
        my %flaginfo;
        my $noissuescharge = C4::Context->preference("noissuescharge");
        $flaginfo{'message'} = sprintf "Patron owes \$%.02f", $amount;
        if ( $amount > $noissuescharge ) {
            $flaginfo{'noissues'} = 1;
        }
        $flags{'CHARGES'} = \%flaginfo;
    }
    elsif ( $amount < 0 ) {
        my %flaginfo;
        $flaginfo{'message'} = sprintf "Patron has credit of \$%.02f", -$amount;
        $flags{'CHARGES'} = \%flaginfo;
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
    my $itemswaiting =
      C4::Reserves2::GetWaitingReserves( $patroninformation->{'borrowernumber'} );
    my $nowaiting = scalar @$itemswaiting;
    if ( $nowaiting > 0 ) {
        my %flaginfo;
        $flaginfo{'message'}  = "Reserved items available";
        $flaginfo{'itemlist'} = $itemswaiting;
        $flags{'WAITING'}     = \%flaginfo;
    }
    return ( \%flags );
}


=item borrdata

  $borrower = &borrdata($cardnumber, $borrowernumber);

Looks up information about a patron (borrower) by either card number
or borrower number. If $borrowernumber is specified, C<&borrdata>
searches by borrower number; otherwise, it searches by card number.

C<&borrdata> returns a reference-to-hash whose keys are the fields of
the C<borrowers> table in the Koha database.

=cut

#'
sub borrdata {
    my ( $cardnumber, $borrowernumber ) = @_;
    $cardnumber = uc $cardnumber;
    my $dbh = C4::Context->dbh;
    my $sth;
    if ( $borrowernumber eq '' ) {
        $sth =
          $dbh->prepare(
"Select borrowers.*,categories.category_type from borrowers left join categories on borrowers.categorycode=categories.categorycode where cardnumber=?"
          );
        $sth->execute($cardnumber);
    }
    else {
        $sth =
          $dbh->prepare(
"Select borrowers.*,categories.category_type from borrowers left join categories on borrowers.categorycode=categories.categorycode where borrowernumber=?"
          );
        $sth->execute($borrowernumber);
    }
    my $data = $sth->fetchrow_hashref;

    $sth->finish;
    if ($data) {
        return ($data);
    }
    elsif ($cardnumber) {    # try with firstname
        my $sth =
              $dbh->prepare(
"Select borrowers.*,categories.category_type from borrowers left join categories on borrowers.categorycode=categories.categorycode  where firstname=?"
            );
            $sth->execute($cardnumber);
            my $data = $sth->fetchrow_hashref;
            $sth->finish;
            return ($data);
    }
    else {
        return undef;        
    }
}

=item borrdata2

  ($borrowed, $due, $fine) = &borrdata2($env, $borrowernumber);

Returns aggregate data about items borrowed by the patron with the
given borrowernumber.

C<$env> is ignored.

C<&borrdata2> returns a three-element array. C<$borrowed> is the
number of books the patron currently has borrowed. C<$due> is the
number of overdue items the patron currently has borrowed. C<$fine> is
the total fine currently due by the borrower.

=cut

#'
sub borrdata2 {
    my ( $env, $borrowernumber ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query =
      "Select count(*) from issues where borrowernumber='$borrowernumber' and
    returndate is NULL";

    # print $query;
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    $sth = $dbh->prepare(
        "Select count(*) from issues where
    borrowernumber='$borrowernumber' and date_due < now() and returndate is NULL"
    );
    $sth->execute;
    my $data2 = $sth->fetchrow_hashref;
    $sth->finish;
    $sth = $dbh->prepare(
        "Select sum(amountoutstanding) from accountlines where
    borrowernumber='$borrowernumber'"
    );
    $sth->execute;
    my $data3 = $sth->fetchrow_hashref;
    $sth->finish;

    return ( $data2->{'count(*)'}, $data->{'count(*)'},
        $data3->{'sum(amountoutstanding)'} );
}

sub modmember {
    my (%data) = @_;
    my $dbh = C4::Context->dbh;
    $data{'dateofbirth'}  = format_date_in_iso( $data{'dateofbirth'} );
    $data{'dateexpiry'}   = format_date_in_iso( $data{'dateexpiry'} );
    $data{'dateenrolled'} = format_date_in_iso( $data{'dateenrolled'} );

    #  	warn "num user".$data{'borrowernumber'};
    my $query;
    my $sth;
    $data{'userid'} = '' if ( $data{'password'} eq '' );

    # test to know if u must update or not the borrower password
    if ( $data{'password'} eq '****' ) {

        $query = "UPDATE borrowers SET 
		cardnumber  = ?,surname = ?,firstname = ?,title = ?,othernames = ?,initials = ?,
		streetnumber = ?,streettype = ?,address = ?,address2 = ?,city = ?,zipcode = ?,
		email = ?,phone = ?,mobile = ?,fax = ?,emailpro = ?,phonepro = ?,B_streetnumber = ?,
		B_streettype = ?,B_address = ?,B_city = ?,B_zipcode = ?,B_email = ?,B_phone = ?,dateofbirth = ?,branchcode = ?,
		categorycode = ?,dateenrolled = ?,dateexpiry = ?,gonenoaddress = ?,lost = ?,debarred = ?,contactname = ?,
		contactfirstname = ?,contacttitle = ?,guarantorid = ?,borrowernotes = ?,relationship =  ?,ethnicity = ?,
		ethnotes = ?,sex = ?,userid = ?,opacnote = ?,contactnote = ?,sort1 = ?,sort2 = ? 
		WHERE borrowernumber=$data{'borrowernumber'}";
        $sth = $dbh->prepare($query);
        $sth->execute(
            $data{'cardnumber'},       $data{'surname'},
            $data{'firstname'},        $data{'title'},
            $data{'othernames'},       $data{'initials'},
            $data{'streetnumber'},     $data{'streettype'},
            $data{'address'},          $data{'address2'},
            $data{'city'},             $data{'zipcode'},
            $data{'email'},            $data{'phone'},
            $data{'mobile'},           $data{'fax'},
            $data{'emailpro'},         $data{'phonepro'},
            $data{'B_streetnumber'},   $data{'B_streettype'},
            $data{'B_address'},        $data{'B_city'},
            $data{'B_zipcode'},        $data{'B_email'},
            $data{'B_phone'},          $data{'dateofbirth'},
            $data{'branchcode'},       $data{'categorycode'},
            $data{'dateenrolled'},     $data{'dateexpiry'},
            $data{'gonenoaddress'},    $data{'lost'},
            $data{'debarred'},         $data{'contactname'},
            $data{'contactfirstname'}, $data{'contacttitle'},
            $data{'guarantorid'},      $data{'borrowernotes'},
            $data{'relationship'},     $data{'ethnicity'},
            $data{'ethnotes'},         $data{'sex'},
            $data{'userid'},           $data{'opacnote'},
            $data{'contactnote'},      $data{'sort1'},
            $data{'sort2'}
        );
    }
    else {

        ( $data{'password'} = md5_base64( $data{'password'} ) )
          if ( $data{'password'} ne '' );
        $query = "UPDATE borrowers SET 
		cardnumber  = ?,surname = ?,firstname = ?,title = ?,othernames = ?,initials = ?,
		streetnumber = ?,streettype = ?,address = ?,address2 = ?,city = ?,zipcode = ?,
		email = ?,phone = ?,mobile = ?,fax = ?,emailpro = ?,phonepro = ?,B_streetnumber = ?,
		B_streettype = ?,B_address = ?,B_city = ?,B_zipcode = ?,B_email = ?,B_phone = ?,dateofbirth = ?,branchcode = ?,
		categorycode = ?,dateenrolled = ?,dateexpiry = ?,gonenoaddress = ?,lost = ?,debarred = ?,contactname = ?,
		contactfirstname = ?,contacttitle = ?,guarantorid = ?,borrowernotes = ?,relationship =  ?,ethnicity = ?,
		ethnotes = ?,sex = ?,password = ?,userid = ?,opacnote = ?,contactnote = ?,sort1 = ?,sort2 = ? 
		WHERE borrowernumber=$data{'borrowernumber'}";
        $sth = $dbh->prepare($query);
        $sth->execute(
            $data{'cardnumber'},       $data{'surname'},
            $data{'firstname'},        $data{'title'},
            $data{'othernames'},       $data{'initials'},
            $data{'streetnumber'},     $data{'streettype'},
            $data{'address'},          $data{'address2'},
            $data{'city'},             $data{'zipcode'},
            $data{'email'},            $data{'phone'},
            $data{'mobile'},           $data{'fax'},
            $data{'emailpro'},         $data{'phonepro'},
            $data{'B_streetnumber'},   $data{'B_streettype'},
            $data{'B_address'},        $data{'B_city'},
            $data{'B_zipcode'},        $data{'B_email'},
            $data{'B_phone'},          $data{'dateofbirth'},
            $data{'branchcode'},       $data{'categorycode'},
            $data{'dateenrolled'},     $data{'dateexpiry'},
            $data{'gonenoaddress'},    $data{'lost'},
            $data{'debarred'},         $data{'contactname'},
            $data{'contactfirstname'}, $data{'contacttitle'},
            $data{'guarantorid'},      $data{'borrowernotes'},
            $data{'relationship'},     $data{'ethnicity'},
            $data{'ethnotes'},         $data{'sex'},
            $data{'password'},         $data{'userid'},
            $data{'opacnote'},         $data{'contactnote'},
            $data{'sort1'},            $data{'sort2'}
        );
    }
    $sth->finish;

# ok if its an adult (type) it may have borrowers that depend on it as a guarantor
# so when we update information for an adult we should check for guarantees and update the relevant part
# of their records, ie addresses and phone numbers
    my ( $category_type, undef ) = getcategorytype( $data{'category_type'} );
    if ( $category_type eq 'A' ) {

        # is adult check guarantees;
        updateguarantees(%data);

    }
    &logaction(C4::Context->userenv->{'number'},"MEMBERS","MODIFY",$data{'borrowernumber'},"") 
        if C4::Context->preference("BorrowersLog");
}

sub newmember {
    my (%data) = @_;
    my $dbh = C4::Context->dbh;
    $data{'userid'} = '' unless $data{'password'};
    $data{'password'} = md5_base64( $data{'password'} ) if $data{'password'};
    $data{'dateofbirth'} = format_date_in_iso( $data{'dateofbirth'} );
    $data{'dateenrolled'} = format_date_in_iso( $data{'dateenrolled'} );
    $data{'dateexpiry'}   = format_date_in_iso( $data{'dateexpiry'} );
    my $query =
        "insert into borrowers set cardnumber="
      . $dbh->quote( $data{'cardnumber'} )
      . ",surname="
      . $dbh->quote( $data{'surname'} )
      . ",firstname="
      . $dbh->quote( $data{'firstname'} )
      . ",title="
      . $dbh->quote( $data{'title'} )
      . ",othernames="
      . $dbh->quote( $data{'othernames'} )
      . ",initials="
      . $dbh->quote( $data{'initials'} )
      . ",streetnumber="
      . $dbh->quote( $data{'streetnumber'} )
      . ",streettype="
      . $dbh->quote( $data{'streettype'} )
      . ",address="
      . $dbh->quote( $data{'address'} )
      . ",address2="
      . $dbh->quote( $data{'address2'} )
      . ",zipcode="
      . $dbh->quote( $data{'zipcode'} )
      . ",city="
      . $dbh->quote( $data{'city'} )
      . ",phone="
      . $dbh->quote( $data{'phone'} )
      . ",email="
      . $dbh->quote( $data{'email'} )
      . ",mobile="
      . $dbh->quote( $data{'mobile'} )
      . ",phonepro="
      . $dbh->quote( $data{'phonepro'} )
      . ",opacnote="
      . $dbh->quote( $data{'opacnote'} )
      . ",guarantorid="
      . $dbh->quote( $data{'guarantorid'} )
      . ",dateofbirth="
      . $dbh->quote( $data{'dateofbirth'} )
      . ",branchcode="
      . $dbh->quote( $data{'branchcode'} )
      . ",categorycode="
      . $dbh->quote( $data{'categorycode'} )
      . ",dateenrolled="
      . $dbh->quote( $data{'dateenrolled'} )
      . ",contactname="
      . $dbh->quote( $data{'contactname'} )
      . ",borrowernotes="
      . $dbh->quote( $data{'borrowernotes'} )
      . ",dateexpiry="
      . $dbh->quote( $data{'dateexpiry'} )
      . ",contactnote="
      . $dbh->quote( $data{'contactnote'} )
      . ",B_address="
      . $dbh->quote( $data{'B_address'} )
      . ",B_zipcode="
      . $dbh->quote( $data{'B_zipcode'} )
      . ",B_city="
      . $dbh->quote( $data{'B_city'} )
      . ",B_phone="
      . $dbh->quote( $data{'B_phone'} )
      . ",B_email="
      . $dbh->quote( $data{'B_email'}, )
      . ",password="
      . $dbh->quote( $data{'password'} )
      . ",userid="
      . $dbh->quote( $data{'userid'} )
      . ",sort1="
      . $dbh->quote( $data{'sort1'} )
      . ",sort2="
      . $dbh->quote( $data{'sort2'} )
      . ",contacttitle="
      . $dbh->quote( $data{'contacttitle'} )
      . ",emailpro="
      . $dbh->quote( $data{'emailpro'} )
      . ",contactfirstname="
      . $dbh->quote( $data{'contactfirstname'} ) . ",sex="
      . $dbh->quote( $data{'sex'} ) . ",fax="
      . $dbh->quote( $data{'fax'} )
      . ",relationship="
      . $dbh->quote( $data{'relationship'} )
      . ",B_streetnumber="
      . $dbh->quote( $data{'B_streetnumber'} )
      . ",B_streettype="
      . $dbh->quote( $data{'B_streettype'} )
      . ",gonenoaddress="
      . $dbh->quote( $data{'gonenoaddress'} )
      . ",lost="
      . $dbh->quote( $data{'lost'} )
      . ",debarred="
      . $dbh->quote( $data{'debarred'} )
      . ",ethnicity="
      . $dbh->quote( $data{'ethnicity'} )
      . ",ethnotes="
      . $dbh->quote( $data{'ethnotes'} );

    my $sth = $dbh->prepare($query);
    $sth->execute;
    $sth->finish;
    $data{'borrowernumber'} = $dbh->{'mysql_insertid'};
    
    &logaction(C4::Context->userenv->{'number'},"MEMBERS","CREATE",$data{'borrowernumber'},"") 
        if C4::Context->preference("BorrowersLog");
        
    return $data{'borrowernumber'};
}

sub changepassword {
    my ( $uid, $member, $digest ) = @_;
    my $dbh = C4::Context->dbh;

#Make sure the userid chosen is unique and not theirs if non-empty. If it is not,
#Then we need to tell the user and have them create a new one.
    my $sth =
      $dbh->prepare(
        "select * from borrowers where userid=? and borrowernumber != ?");
    $sth->execute( $uid, $member );
    if ( ( $uid ne '' ) && ( $sth->fetchrow ) ) {
        return 0;
    }
    else {

        #Everything is good so we can update the information.
        $sth =
          $dbh->prepare(
            "update borrowers set userid=?, password=? where borrowernumber=?");
        $sth->execute( $uid, $digest, $member );
        return 1;
    }
    
    &logaction(C4::Context->userenv->{'number'},"MEMBERS","CHANGE PASS",$member,"") 
        if C4::Context->preference("BorrowersLog");
}

sub getmemberfromuserid {
    my ($userid) = @_;
    my $dbh      = C4::Context->dbh;
    my $sth      = $dbh->prepare("select * from borrowers where userid=?");
    $sth->execute($userid);
    return $sth->fetchrow_hashref;
}

sub updateguarantees {
    my (%data) = @_;
    my $dbh = C4::Context->dbh;
    my ( $count, $guarantees ) = findguarantees( $data{'borrowernumber'} );
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

=item fixup_cardnumber

Warning: The caller is responsible for locking the members table in write
mode, to avoid database corruption.

=cut

use vars qw( @weightings );
my @weightings = ( 8, 4, 6, 3, 5, 2, 1 );

sub fixup_cardnumber ($) {
    my ($cardnumber) = @_;
    my $autonumber_members = C4::Context->boolean_preference('autoMemberNum');
    $autonumber_members = 0 unless defined $autonumber_members;

    # Find out whether member numbers should be generated
    # automatically. Should be either "1" or something else.
    # Defaults to "0", which is interpreted as "no".

    #     if ($cardnumber !~ /\S/ && $autonumber_members) {
    if ($autonumber_members) {
        my $dbh = C4::Context->dbh;
        if ( C4::Context->preference('checkdigit') eq 'katipo' ) {

            # if checkdigit is selected, calculate katipo-style cardnumber.
            # otherwise, just use the max()
            # purpose: generate checksum'd member numbers.
            # We'll assume we just got the max value of digits 2-8 of member #'s
            # from the database and our job is to increment that by one,
            # determine the 1st and 9th digits and return the full string.
            my $sth =
              $dbh->prepare(
                "select max(substring(borrowers.cardnumber,2,7)) from borrowers"
              );
            $sth->execute;

            my $data = $sth->fetchrow_hashref;
            $cardnumber = $data->{'max(substring(borrowers.cardnumber,2,7))'};
            $sth->finish;
            if ( !$cardnumber ) {    # If DB has no values,
                $cardnumber = 1000000;    # start at 1000000
            }
            else {
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

            $cardnumber = "V$cardnumber$rem";
        }
        else {

     # MODIFIED BY JF: mysql4.1 allows casting as an integer, which is probably
     # better. I'll leave the original in in case it needs to be changed for you
            my $sth =
              $dbh->prepare(
                "select max(cast(cardnumber as signed)) from borrowers");

      #my $sth=$dbh->prepare("select max(borrowers.cardnumber) from borrowers");

            $sth->execute;

            my ($result) = $sth->fetchrow;
            $sth->finish;
            $cardnumber = $result + 1;
        }
    }
    return $cardnumber;
}

=head2 findguarantees

  ($num_children, $children_arrayref) = &findguarantees($parent_borrno);
  $child0_cardno = $children_arrayref->[0]{"cardnumber"};
  $child0_borrno = $children_arrayref->[0]{"borrowernumber"};

C<&findguarantees> takes a borrower number (e.g., that of a patron
with children) and looks up the borrowers who are guaranteed by that
borrower (i.e., the patron's children).

C<&findguarantees> returns two values: an integer giving the number of
borrowers guaranteed by C<$parent_borrno>, and a reference to an array
of references to hash, which gives the actual results.

=cut

#'
sub findguarantees {
    my ($borrowernumber) = @_;
    my $dbh              = C4::Context->dbh;
    my $sth              =
      $dbh->prepare(
"select cardnumber,borrowernumber, firstname, surname from borrowers where guarantorid=?"
      );
    $sth->execute($borrowernumber);

    my @dat;
    while ( my $data = $sth->fetchrow_hashref ) {
        push @dat, $data;
    }
    $sth->finish;
    return ( scalar(@dat), \@dat );
}

=head2 findguarantor

  $guarantor = &findguarantor($borrower_no);
  $guarantor_cardno = $guarantor->{"cardnumber"};
  $guarantor_surname = $guarantor->{"surname"};
  ...

C<&findguarantor> takes a borrower number (presumably that of a child
patron), finds the guarantor for C<$borrower_no> (the child's parent),
and returns the record for the guarantor.

C<&findguarantor> returns a reference-to-hash. Its keys are the fields
from the C<borrowers> database table;

=cut

#'
sub findguarantor {
    my ($borrowernumber) = @_;
    my $dbh              = C4::Context->dbh;
    my $sth              =
      $dbh->prepare("select guarantorid from borrowers where borrowernumber=?");
    $sth->execute($borrowernumber);
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    $sth = $dbh->prepare("Select * from borrowers where borrowernumber=?");
    $sth->execute( $data->{'guarantorid'} );
    $data = $sth->fetchrow_hashref;
    $sth->finish;
    return ($data);
}

=item GuarantornameSearch

  ($count, $borrowers) = &GuarantornameSearch($env, $searchstring, $type);

Looks up guarantor  by name.

C<$env> is ignored.

BUGFIX 499: C<$type> is now used to determine type of search.
if $type is "simple", search is performed on the first letter of the
surname only.

C<$searchstring> is a space-separated list of search terms. Each term
must match the beginning a borrower's surname, first name, or other
name.

C<&GuarantornameSearch> returns a two-element list. C<$borrowers> is a
reference-to-array; each element is a reference-to-hash, whose keys
are the fields of the C<borrowers> table in the Koha database.
C<$count> is the number of elements in C<$borrowers>.

return all info from guarantor =>only category_type A

=cut

#'
#used by member enquiries from the intranet
#called by guarantor_search.pl
sub GuarantornameSearch {
    my ( $env, $searchstring, $orderby, $type ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "";
    my $count;
    my @data;
    my @bind = ();

    if ( $type eq "simple" )    # simple search for one letter only
    {
        $query =
"Select * from borrowers,categories  where borrowers.categorycode=categories.categorycode and category_type='A'  and  surname like ? order by $orderby";
        @bind = ("$searchstring%");
    }
    else    # advanced search looking in surname, firstname and othernames
    {
        @data  = split( ' ', $searchstring );
        $count = @data;
        $query = "Select * from borrowers,categories
		where ((surname like ? or surname like ?
		or firstname  like ? or firstname like ?
		or othernames like ? or othernames like ?) and borrowers.categorycode=categories.categorycode and category_type='A' 
		";
        @bind = (
            "$data[0]%", "% $data[0]%", "$data[0]%", "% $data[0]%",
            "$data[0]%", "% $data[0]%"
        );
        for ( my $i = 1 ; $i < $count ; $i++ ) {
            $query = $query . " and (" . " surname like ? or surname like ?
                        or firstname  like ? or firstname like ?
		        or othernames like ? or othernames like ?)";
            push( @bind,
                "$data[$i]%",   "% $data[$i]%", "$data[$i]%",
                "% $data[$i]%", "$data[$i]%",   "% $data[$i]%" );

            # FIXME - .= <<EOT;
        }
        $query = $query . ") or cardnumber like ?
		order by $orderby";
        push( @bind, $searchstring );

        # FIXME - .= <<EOT;
    }

    my $sth = $dbh->prepare($query);
    $sth->execute(@bind);
    my @results;
    my $cnt = $sth->rows;
    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
    }

    #  $sth->execute;
    $sth->finish;
    return ( $cnt, \@results );
}

=head2 borrissues

  ($count, $issues) = &borrissues($borrowernumber);

Looks up what the patron with the given borrowernumber has borrowed.

C<&borrissues> returns a two-element array. C<$issues> is a
reference-to-array, where each element is a reference-to-hash; the
keys are the fields from the C<issues>, C<biblio>, and C<items> tables
in the Koha database. C<$count> is the number of elements in
C<$issues>.

=cut

#'
sub borrissues {
    my ($borrowernumber) = @_;
    my $dbh              = C4::Context->dbh;
    my $sth              = $dbh->prepare(
        "Select * from issues,biblio,items where borrowernumber=?
   and items.itemnumber=issues.itemnumber
	and items.biblionumber=biblio.biblionumber
	and issues.returndate is NULL order by date_due"
    );
    $sth->execute($borrowernumber);
    my @result;
    while ( my $data = $sth->fetchrow_hashref ) {
        push @result, $data;
    }
    $sth->finish;
    return ( scalar(@result), \@result );
}

=head2 allissues

  ($count, $issues) = &allissues($borrowernumber, $sortkey, $limit);

Looks up what the patron with the given borrowernumber has borrowed,
and sorts the results.

C<$sortkey> is the name of a field on which to sort the results. This
should be the name of a field in the C<issues>, C<biblio>,
C<biblioitems>, or C<items> table in the Koha database.

C<$limit> is the maximum number of results to return.

C<&allissues> returns a two-element array. C<$issues> is a
reference-to-array, where each element is a reference-to-hash; the
keys are the fields from the C<issues>, C<biblio>, C<biblioitems>, and
C<items> tables of the Koha database. C<$count> is the number of
elements in C<$issues>

=cut

#'
sub allissues {
    my ( $borrowernumber, $order, $limit ) = @_;

    #FIXME: sanity-check order and limit
    my $dbh   = C4::Context->dbh;
    my $count = 0;
    my $query =
"Select *,items.timestamp AS itemstimestamp from issues,biblio,items,biblioitems
  where borrowernumber=? and
  items.biblioitemnumber=biblioitems.biblioitemnumber and
  items.itemnumber=issues.itemnumber and
  items.biblionumber=biblio.biblionumber order by $order";
    if ( $limit != 0 ) {
        $query .= " limit $limit";
    }

    #print $query;
    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
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
        my $query2 = "SELECT * FROM oldissues,biblio,items,biblioitems
                      WHERE borrowernumber=? 
                      AND items.biblioitemnumber=biblioitems.biblioitemnumber
                      AND items.itemnumber=oldissues.itemnumber
                      AND items.biblionumber=biblio.biblionumber
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

=head2 getboracctrecord

  ($count, $acctlines, $total) = &getboracctrecord($env, $borrowernumber);

Looks up accounting data for the patron with the given borrowernumber.

C<$env> is ignored.

(FIXME - I'm not at all sure what this is about.)

C<&getboracctrecord> returns a three-element array. C<$acctlines> is a
reference-to-array, where each element is a reference-to-hash; the
keys are the fields of the C<accountlines> table in the Koha database.
C<$count> is the number of elements in C<$acctlines>. C<$total> is the
total amount outstanding for all of the account lines.

=cut

#'
sub getboracctrecord {
    my ( $env, $params ) = @_;
    my $dbh = C4::Context->dbh;
    my @acctlines;
    my $numlines = 0;
    my $sth      = $dbh->prepare(
        "Select * from accountlines where
borrowernumber=? order by date desc,timestamp desc"
    );

    $sth->execute( $params->{'borrowernumber'} );
    my $total = 0;
    while ( my $data = $sth->fetchrow_hashref ) {

        #FIXME before reinstating: insecure?
        #      if ($data->{'itemnumber'} ne ''){
        #        $query="Select * from items,biblio where items.itemnumber=
        #	'$data->{'itemnumber'}' and biblio.biblionumber=items.biblionumber";
        #	my $sth2=$dbh->prepare($query);
        #	$sth2->execute;
        #	my $data2=$sth2->fetchrow_hashref;
        #	$sth2->finish;
        #	$data=$data2;
        #     }
        $acctlines[$numlines] = $data;
        $numlines++;
        $total += $data->{'amountoutstanding'};
    }
    $sth->finish;
    return ( $numlines, \@acctlines, $total );
}

=head2 GetBorNotifyAcctRecord

  ($count, $acctlines, $total) = &GetBorNotifyAcctRecord($env, $params,$notifyid);

Looks up accounting data for the patron with the given borrowernumber per file number.

C<$env> is ignored.

(FIXME - I'm not at all sure what this is about.)

C<&GetBorNotifyAcctRecord> returns a three-element array. C<$acctlines> is a
reference-to-array, where each element is a reference-to-hash; the
keys are the fields of the C<accountlines> table in the Koha database.
C<$count> is the number of elements in C<$acctlines>. C<$total> is the
total amount outstanding for all of the account lines.

=cut

sub GetBorNotifyAcctRecord {
    my ( $env, $params, $notifyid ) = @_;
    my $dbh = C4::Context->dbh;
    my @acctlines;
    my $numlines = 0;
    my $query    = qq|	SELECT * 
			FROM accountlines 
			WHERE borrowernumber=? 
			AND notify_id=? 
			AND (accounttype='FU' OR accounttype='N' OR accounttype='M'OR accounttype='A'OR accounttype='F'OR accounttype='L' OR accounttype='IP' OR accounttype='CH' OR accounttype='RE' OR accounttype='RL')
			AND amountoutstanding != '0' 
			ORDER BY notify_id,accounttype
		|;
    my $sth = $dbh->prepare($query);

    $sth->execute( $params->{'borrowernumber'}, $notifyid );
    my $total = 0;
    while ( my $data = $sth->fetchrow_hashref ) {
        $acctlines[$numlines] = $data;
        $numlines++;
        $total += $data->{'amountoutstanding'};
    }
    $sth->finish;
    return ( $numlines, \@acctlines, $total );
}

=head2 checkuniquemember (OUEST-PROVENCE)

  $result = &checkuniquemember($collectivity,$surname,$categorycode,$firstname,$dateofbirth);

Checks that a member exists or not in the database.

C<&result> is 1 (=exist) or 0 (=does not exist)
C<&collectivity> is 1 (= we add a collectivity) or 0 (= we add a physical member)
C<&surname> is the surname
C<&categorycode> is from categorycode table
C<&firstname> is the firstname (only if collectivity=0)
C<&dateofbirth> is the date of birth (only if collectivity=0)

=cut

sub checkuniquemember {
    my ( $collectivity, $surname, $firstname, $dateofbirth ) = @_;
    my $dbh = C4::Context->dbh;
    my $request;
    if ($collectivity) {

# 				$request="select count(*) from borrowers where surname=? and categorycode=?";
        $request =
          "select borrowernumber,categorycode from borrowers where surname=? ";
    }
    else {

# 				$request="select count(*) from borrowers where surname=? and categorycode=? and firstname=? and dateofbirth=?";
        $request =
"select borrowernumber,categorycode from borrowers where surname=?  and firstname=? and dateofbirth=?";
    }
    my $sth = $dbh->prepare($request);
    if ($collectivity) {
        $sth->execute( uc($surname) );
    }
    else {
        $sth->execute( uc($surname), ucfirst($firstname), $dateofbirth );
    }
    my @data = $sth->fetchrow;
    if ( $data[0] ) {
        $sth->finish;
        return $data[0], $data[1];

        #
    }
    else {
        $sth->finish;
        return 0;
    }
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

=head2 updatechildguarantor (OUEST-PROVENCE)

check for title,firstname,surname,adress,zip code and city  from guarantor to 
guarantorchild

=cut

#'

sub getguarantordata {
    my ($borrowerid) = @_;
    my $dbh          = C4::Context->dbh;
    my $sth          =
      $dbh->prepare(
"Select title,firstname,surname,streetnumber,address,streettype,address2,zipcode,city,phone,phonepro,mobile,email,emailpro,fax  from borrowers where borrowernumber =? "
      );
    $sth->execute($borrowerid);
    my $guarantor_data = $sth->fetchrow_hashref;
    $sth->finish;
    return $guarantor_data;
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

=head2 getcategorytype (OUEST-PROVENCE)

check for the category_type with categorycode
and return the category_type 

=cut

sub getcategorytype {
    my ($categorycode) = @_;
    my $dbh            = C4::Context->dbh;
    my $sth            =
      $dbh->prepare(
"Select category_type,description from categories where categorycode=?  "
      );
    $sth->execute($categorycode);
    my ( $category_type, $description ) = $sth->fetchrow;
    return $category_type, $description;
}

sub calcexpirydate {
    my ( $categorycode, $dateenrolled ) = @_;
    my $dbh = C4::Context->dbh;
    my $sth =
      $dbh->prepare(
        "select enrolmentperiod from categories where categorycode=?");
    $sth->execute($categorycode);
    my ($enrolmentperiod) = $sth->fetchrow;
    $enrolmentperiod = 12 unless ($enrolmentperiod);
#     warn "Avant format_date_in_iso :".$dateenrolled;
#     $dateenrolled=format_date_in_iso($dateenrolled);
#     warn "Apres format_date_in_iso :".$dateenrolled;
    my @date=split /-/,format_date_in_iso($dateenrolled);
    @date=Add_Delta_YM($date[0],$date[1],$date[2],0,$enrolmentperiod);
    return sprintf("%04d-%02d-%02d",$date[0],$date[1],$date[2]);
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
    my $dbh     = C4::Context->dbh;
    my $request = qq|	SELECT categorycode,description 
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

=head2 getborrowercategory

  $description,$dateofbirthrequired,$upperagelimit,$category_type = &getborrowercategory($categorycode);

Given the borrower's category code, the function returns the corresponding
description , dateofbirthrequired , upperagelimit and category type for a comprehensive information display.

=cut

sub getborrowercategory {
    my ($catcode) = @_;
    my $dbh       = C4::Context->dbh;
    my $sth       =
      $dbh->prepare(
"SELECT description,dateofbirthrequired,upperagelimit,category_type FROM categories WHERE categorycode = ?"
      );
    $sth->execute($catcode);
    my ( $description, $dateofbirthrequired, $upperagelimit, $category_type ) =
      $sth->fetchrow();
    $sth->finish();
    return ( $description, $dateofbirthrequired, $upperagelimit,
        $category_type );
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

=head2 get_age

  $dateofbirth,$date = &get_age($date);

this function return the borrowers age with the value of dateofbirth

=cut

#'
sub get_age {
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

=head2 GetBorrowersFromSurname

=over 4

\@resutlts = GetBorrowersFromSurname($surname)
this function get the list of borrower names like $surname.
return :
the table of results in @results

=back

=cut

sub GetBorrowersFromSurname {
    my ($searchstring) = @_;
    my $dbh = C4::Context->dbh;
    $searchstring =~ s/\'/\\\'/g;
    my @data  = split( ' ', $searchstring );
    my $count = @data;
    my $query = qq|
        SELECT   surname,firstname
        FROM     borrowers
        WHERE    (surname like ?)
        ORDER BY surname
    |;
    my $sth = $dbh->prepare($query);
    $sth->execute("$data[0]%");
    my @results;
    $count = 0;

    while ( my $data = $sth->fetchrow_hashref ) {
        push( @results, $data );
        $count++;
    }
    $sth->finish;
    return ( $count, \@results );
}

=head2 citycaracteristiques (OUEST-PROVENCE)

  ($id_cityarrayref, $city_hashref) = &citycaracteristic();

Looks up the different city and zip in the database. Returns two
elements: a reference-to-array, which lists the zip city
codes, and a reference-to-hash, which maps the name of the city.
WHERE =>OUEST PROVENCE OR EXTERIEUR

=cut

sub GetCities {

    #my ($type_city) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = qq|SELECT cityid,city_name 
		FROM cities 
		ORDER BY city_name|;
    my $sth = $dbh->prepare($query);

    #$sth->execute($type_city);
    $sth->execute();
    my %city;
    my @id;

    #    insert empty value to create a empty choice in cgi popup

    while ( my $data = $sth->fetchrow_hashref ) {

        push @id, $data->{'cityid'};
        $city{ $data->{'cityid'} } = $data->{'city_name'};
    }

#test to know if the table contain some records if no the function return nothing
    my $id = @id;
    $sth->finish;
    if ( $id eq 0 ) {
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
    return ($lib);
}

=head2 DeleteBorrower 

  () = &DeleteBorrower($member);

delete all data fo borrowers and add record to deletedborrowers table
C<&$member>this is the borrowernumber

=cut

sub DeleteBorrower {
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
      $dbh->prepare( "Insert into deletedborrowers values ("
          . ( "?," x ( scalar(@data) - 1 ) )
          . "?)" );
    $sth->execute(@data);
    $sth->finish;
    $query = qq|DELETE 
 		  FROM borrowers 
 		  WHERE borrowernumber=?|;
    $sth = $dbh->prepare($query);
    $sth->execute($member);
    $sth->finish;
    $query = qq|DELETE 
 		  FROM  reserves 
 		  WHERE borrowernumber=?|;
    $sth = $dbh->prepare($query);
    $sth->execute($member);
    $sth->finish;
    
    # logging to action_log
    &logaction(C4::Context->userenv->{'number'},"MEMBERS","DELETE",$member,"") 
        if C4::Context->preference("BorrowersLog");
}

=head2 DelBorrowerCompletly

DelBorrowerCompletly($borrowernumber);

This function remove directly a borrower whitout writing it on deleteborrower.

=cut

sub DelBorrowerCompletly {
    my $dbh            = C4::Context->dbh;
    my $borrowernumber = shift;
    return unless $borrowernumber;    # date is mandatory.
    my $query = "
       DELETE *
       FROM borrowers
       WHERE borrowernumber = ?
   ";
    my $sth = $dbh->prepare($query);
    $sth->execute($borrowernumber);
    return $sth->rows;
}

=head2 member_reregistration (OUEST-PROVENCE)

automatic reregistration in borrowers table 
with dateexpiry .

=cut

sub GetMembeReregistration {
    my ( $categorycode, $borrowerid ) = @_;
    my $dbh = C4::Context->dbh;
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) =
      localtime(time);
    $mon++;
    $year = $year + 1900;
    if ( $mon < '10' ) {
        $mon = "0" . $mon;
    }
    if ( $mday < '10' ) {
        $mday = "0" . $mday;
    }
    my $today = sprintf("%04d-%02d-%02d",$year,$mon,$mday);
    my $dateexpiry = calcexpirydate( $categorycode, $today );
    my $query      = qq|   UPDATE borrowers 
			SET  dateexpiry='$dateexpiry' 
			WHERE borrowernumber='$borrowerid'|;
    my $sth = $dbh->prepare($query);
    $sth->execute;
    $sth->finish;
    return $dateexpiry;
}

=head2 GetRoadTypes (OUEST-PROVENCE)

  ($idroadtypearrayref, $roadttype_hashref) = &GetRoadTypes();

Looks up the different road type . Returns two
elements: a reference-to-array, which lists the id_roadtype
codes, and a reference-to-hash, which maps the road type of the road .


=cut

sub GetRoadTypes {
    my $dbh   = C4::Context->dbh;
    my $query = qq|SELECT roadtypeid,road_type 
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



=head2 GetBorrowersTitles (OUEST-PROVENCE)

  ($borrowertitle)= &GetBorrowersTitles();

Looks up the different title . Returns array  with all borrowers title

=cut

sub GetBorrowersTitles {
    my @borrowerTitle = split /,|\|/,C4::Context->preference('BorrowersTitles');
    unshift( @borrowerTitle, "" );
    return ( \@borrowerTitle);
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
    my $query        = qq|SELECT road_type 
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
    my $date = shift;
    return unless $date;    # date is mandatory.
    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT borrowers.borrowernumber,max(timestamp)
        FROM   borrowers
          LEFT JOIN issues ON borrowers.borrowernumber = issues.borrowernumber
        WHERE issues.borrowernumber IS NOT NULL
        GROUP BY borrowers.borrowernumber
   ";
    my $sth = $dbh->prepare($query);
    $sth->execute;
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
    my $dbh   = C4::Context->dbh;
    my $query = "
        SELECT borrowers.borrowernumber,max(timestamp)
        FROM   borrowers
          LEFT JOIN issues ON borrowers.borrowernumber = issues.borrowernumber
        WHERE issues.borrowernumber IS NULL
   ";
    my $sth = $dbh->prepare($query);
    $sth->execute;
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
    my $date = shift;
    return unless $date;    # date is mandatory.
    my $query = "
       SELECT count(borrowernumber) as n,borrowernumber
       FROM issues
       WHERE returndate < ?
         AND borrowernumber IS NOT NULL 
       GROUP BY borrowernumber
   ";
    my $sth = $dbh->prepare($query);
    $sth->execute($date);
    my @results;

    while ( my $data = $sth->fetchrow_hashref ) {
        push @results, $data;
    }
    return \@results;
}

END { }    # module clean-up code here (global destructor)

1;

__END__

=back

=head1 AUTHOR

Koha Team

=cut
