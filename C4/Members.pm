# -*- tab-width: 8 -*-

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
use Date::Calc qw/Today/;
use C4::Biblio;
use C4::Stats;
use C4::Reserves2;
use C4::Koha;
use C4::Accounts2;
use C4::Circulation::Circ2;
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

#'

@ISA    = qw(Exporter);

@EXPORT = qw(
&allissues
&add_member_orgs
&borrdata 
&borrdata2 
&borrdata3
&BornameSearch 
&borrissues
&borrowercard_active
&borrowercategories
&change_user_pass
&checkuniquemember 
&calcexpirydate 
&checkuserpassword

&ethnicitycategories 
&fixEthnicity
&fixup_cardnumber 
&findguarantees 
&findguarantor  
&fixupneu_cardnumber

&getmember 
&getMemberPhoto 
&get_institutions
&getzipnamecity 
&getidcity 
&getguarantordata 
&getcategorytype
&getboracctrecord
&getborrowercategory
&getborrowercategoryinfo
&get_age 
&getpatroninformation
&GetBorrowersFromSurname 
&GetBranchCodeFromBorrowers
&GetFlagsAndBranchFromBorrower
&GuarantornameSearch
&NewBorrowerNumber 
&modmember 
&newmember 
	);


=head2 borrowercategories

  ($codes_arrayref, $labels_hashref) = &borrowercategories();

Looks up the different types of borrowers in the database. Returns two
elements: a reference-to-array, which lists the borrower category
codes, and a reference-to-hash, which maps the borrower category codes
to category descriptions.

=cut
#'

sub borrowercategories {
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("Select categorycode,description from categories order by description");
    $sth->execute;
    my %labels;
    my @codes;
    while (my $data=$sth->fetchrow_hashref){
      push @codes,$data->{'categorycode'};
      $labels{$data->{'categorycode'}}=$data->{'description'};
    }
    $sth->finish;
    return(\@codes,\%labels);
}

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
sub BornameSearch  {
	my ($env,$searchstring,$orderby,$type)=@_;
	my $dbh = C4::Context->dbh;
	my $query = ""; my $count; 
	my @data;
	my @bind=();

	if($type eq "simple")	# simple search for one letter only
	{
		$query="Select * from borrowers where surname like '$searchstring%' order by $orderby";
#		@bind=("$searchstring%");
	}
	else	# advanced search looking in surname, firstname and othernames
	{
### Try to determine whether numeric like cardnumber
	if ($searchstring+1>1) {
	$query="Select * from borrowers where  cardnumber  like '$searchstring%' ";

	}else{
	
	my @words=split / /,$searchstring;
	foreach my $word(@words){
	$word="+".$word;
	
	}
	$searchstring=join " ",@words;
	
		$query="Select * from borrowers where  MATCH(surname,firstname,othernames) AGAINST('$searchstring'  in boolean mode)";

	}
		$query=$query." order by $orderby";
	}

	my $sth=$dbh->prepare($query);
#	warn "Q $orderby : $query";
	$sth->execute();
	my @results;
	my $cnt=$sth->rows;
	while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
	}
	#  $sth->execute;
	$sth->finish;
	return ($cnt,\@results);
}
=head2 getpatroninformation

  ($borrower, $flags) = &getpatroninformation($env, $borrowernumber, $cardnumber);
Looks up a patron and returns information about him or her. If
C<$borrowernumber> is true (nonzero), C<&getpatroninformation> looks
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

Shows the patron's credit or debt, if any.

=back

=head3 GNA

=over 4

(Gone, no address.) Set if the patron has left without giving a
forwarding address.

=back

=head3 LOST

=over 4

Set if the patron's card has been reported as lost.

=back

=head3 DBARRED

=over 4

Set if the patron has been debarred.

=back

=head3 NOTES

=over 4

Any additional notes about the patron.

=back

=head3 ODUES

=over 4

Set if the patron has overdue items. This flag has several keys:

C<$flags-E<gt>{ODUES}{itemlist}> is a reference-to-array listing the
overdue items. Its elements are references-to-hash, each describing an
overdue item. The keys are selected fields from the issues, biblio,
biblioitems, and items tables of the Koha database.

C<$flags-E<gt>{ODUES}{itemlist}> is a string giving a text listing of
the overdue items, one per line.

=back

=head3 WAITING

=over 4

Set if any items that the patron has reserved are available.

C<$flags-E<gt>{WAITING}{itemlist}> is a reference-to-array listing the
available items. Each element is a reference-to-hash whose keys are
fields from the reserves table of the Koha database.

=back

=back

=cut

sub getpatroninformation {
# returns
	my ($env, $borrowernumber,$cardnumber) = @_;
	my $dbh = C4::Context->dbh;
	my $query;
	my $sth;
	if ($borrowernumber) {
		$sth = $dbh->prepare("select * from borrowers where borrowernumber=?");
		$sth->execute($borrowernumber);
	} elsif ($cardnumber) {
		$sth = $dbh->prepare("select * from borrowers where cardnumber=?");
		$sth->execute($cardnumber);
	} else {
		$env->{'apierror'} = "invalid borrower information passed to getpatroninformation subroutine";
		return();
	}
	my $borrower = $sth->fetchrow_hashref;
	my $amount = C4::Accounts2::checkaccount($env, $borrowernumber, $dbh);
	$borrower->{'amountoutstanding'} = $amount;
	my $flags = C4::Circulation::Circ2::patronflags($env, $borrower, $dbh);
	my $accessflagshash;
 
	$sth=$dbh->prepare("select bit,flag from userflags");
	$sth->execute;
	while (my ($bit, $flag) = $sth->fetchrow) {
		if ($borrower->{'flags'} & 2**$bit) {
		$accessflagshash->{$flag}=1;
		}
	}
	$sth->finish;
	$borrower->{'flags'}=$flags;
	$borrower->{'authflags'} = $accessflagshash;
	return ($borrower); #, $flags, $accessflagshash);
}

=item getmember

  $borrower = &getmember($cardnumber, $borrowernumber);

Looks up information about a patron (borrower) by either card number
or borrower number. If $borrowernumber is specified, C<&borrdata>
searches by borrower number; otherwise, it searches by card number.

C<&getmember> returns a reference-to-hash whose keys are the fields of
the C<borrowers> table in the Koha database.

=cut

=head3 GetFlagsAndBranchFromBorrower

=over 4

($flags, $homebranch) = GetFlagsAndBranchFromBorrower($loggedinuser);

this function read on the database to get flags and homebranch for a user
given on input arg.

return : 
it returns the $flags & the homebranch in scalar context.

=back

=cut



=item borrissues

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
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from issues,biblio,items where borrowernumber=?
   and items.itemnumber=issues.itemnumber
	and items.biblionumber=biblio.biblionumber
	and issues.returndate is NULL order by date_due");
    $sth->execute($bornum);
  my @result;
  while (my $data = $sth->fetchrow_hashref) {
    push @result, $data;
  }
  $sth->finish;
  return(scalar(@result), \@result);
}

=item allissues

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
  my ($bornum,$order,$limit)=@_;
  #FIXME: sanity-check order and limit
  my $dbh = C4::Context->dbh;
  my $query="Select * from issues,biblio,items
  where borrowernumber=? and
  items.itemnumber=issues.itemnumber and
  items.biblionumber=biblio.biblionumber order by $order";
  if ($limit !=0){
    $query.=" limit $limit";
  }
  #print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute($bornum);
  my @result;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $result[$i]=$data;;
    $i++;
  }
  $sth->finish;
  return($i,\@result);
}


sub borrdata3 {
## NEU specific. used in Reserve section issues
  my ($env,$bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select count(*) from  reserveissue as r where r.borrowernumber='$bornum' 
     and rettime is null";
    # print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $sth=$dbh->prepare("Select count(*),timediff(now(),  duetime  ) as elapsed, hour(timediff(now(),  duetime  )) as hours, MINUTE(timediff(now(),  duetime  )) as min from 
    reserveissue as r where  r.borrowernumber='$bornum' and rettime is null and duetime< now() group by r.borrowernumber");
  $sth->execute;

  my $data2=$sth->fetchrow_hashref;
my $resfine;
my $rescharge=C4::Context->preference('resmaterialcharge');
	if (!$rescharge){
	$rescharge=1;
	}
	if ($data2->{'elapsed'}>0){
	 $resfine=($data2->{'hours'}+$data2->{'min'}/60)*$rescharge;
	$resfine=sprintf  ("%.1f",$resfine);
	}
  $sth->finish;
  $sth=$dbh->prepare("Select sum(amountoutstanding) from accountlines where
    borrowernumber='$bornum'");
  $sth->execute;
  my $data3=$sth->fetchrow_hashref;
  $sth->finish;


return($data2->{'count(*)'},$data->{'count(*)'},$data3->{'sum(amountoutstanding)'},$resfine);
}
=item getboracctrecord

  ($count, $acctlines, $total) = &getboracctrecord($env, $borrowernumber);

Looks up accounting data for the patron with the given borrowernumber.

C<$env> is ignored.


C<&getboracctrecord> returns a three-element array. C<$acctlines> is a
reference-to-array, where each element is a reference-to-hash; the
keys are the fields of the C<accountlines> table in the Koha database.
C<$count> is the number of elements in C<$acctlines>. C<$total> is the
total amount outstanding for all of the account lines.

=cut
#'
sub getboracctrecord {
   my ($env,$params) = @_;
   my $dbh = C4::Context->dbh;
   my @acctlines;
   my $numlines=0;
   my $sth=$dbh->prepare("Select * from accountlines where
borrowernumber=? order by date desc,timestamp desc");
#   print $query;
   $sth->execute($params->{'borrowernumber'});
   my $total=0;
   while (my $data=$sth->fetchrow_hashref){
      $acctlines[$numlines] = $data;
      $numlines++;
      $total += $data->{'amountoutstanding'};
   }
   $sth->finish;
   return ($numlines,\@acctlines,$total);
}

sub getborrowercategory{
	my ($catcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT description FROM categories WHERE categorycode = ?");
	$sth->execute($catcode);
	my $description = $sth->fetchrow();
	$sth->finish();
	return $description;
} # sub getborrowercategory

sub getborrowercategoryinfo{
	my ($catcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT * FROM categories WHERE categorycode = ?");
	$sth->execute($catcode);
	my $category = $sth->fetchrow_hashref;
	$sth->finish();
	return $category;
} # sub getborrowercategoryinfo


sub GetFlagsAndBranchFromBorrower {
    my $loggedinuser = @_;
    my $dbh = C4::Context->dbh;
    my $query = "
       SELECT flags, branchcode
       FROM   borrowers
       WHERE  borrowernumber = ? 
    ";
    my $sth = $dbh->prepare($query);
    $sth->execute($loggedinuser);

    return $sth->fetchrow;
}


sub getmember {
    my ( $cardnumber, $bornum ) = @_;
    $cardnumber = uc $cardnumber;
    my $dbh = C4::Context->dbh;
    my $sth;
    if ( $bornum eq '' ) {
        $sth = $dbh->prepare("Select * from borrowers where cardnumber=?");
        $sth->execute($cardnumber);
    } else {
        $sth = $dbh->prepare("Select * from borrowers where borrowernumber=?");
        $sth->execute($bornum);
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
    my ( $cardnumber, $bornum ) = @_;
    $cardnumber = uc $cardnumber;
    my $dbh = C4::Context->dbh;
    my $sth;
    if ( $bornum eq '' ) {
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
        $sth->execute($bornum);
    }
    my $data = $sth->fetchrow_hashref;
#     warn "DATA" . $data->{category_type};
    $sth->finish;
    if ($data) {
        return ($data);
    }
    else {    # try with firstname
        if ($cardnumber) {
            my $sth =
              $dbh->prepare(
"Select borrowers.*,categories.category_type from borrowers left join categories on borrowers.categorycode=categories.categorycode  where firstname=?"
              );
            $sth->execute($cardnumber);
            my $data = $sth->fetchrow_hashref;
            $sth->finish;
            return ($data);
        }
    }
    return undef;
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
    my ( $env, $bornum ) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select count(*) from issues where borrowernumber='$bornum' and
    returndate is NULL";

    # print $query;
    my $sth = $dbh->prepare($query);
    $sth->execute;
    my $data = $sth->fetchrow_hashref;
    $sth->finish;
    $sth = $dbh->prepare(
        "Select count(*) from issues where
    borrowernumber='$bornum' and date_due < now() and returndate is NULL"
    );
    $sth->execute;
    my $data2 = $sth->fetchrow_hashref;
    $sth->finish;
    $sth = $dbh->prepare(
        "Select sum(amountoutstanding) from accountlines where
    borrowernumber='$bornum'"
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
	$data{'dateofbirth'}=format_date_in_iso($data{'dateofbirth'});


	$data{'joining'}=format_date_in_iso($data{'joining'});
	
	if ($data{'expiry'} eq '') {
	
		my $sth = $dbh->prepare("select enrolmentperiod from categories where categorycode=?");
		$sth->execute($data{'categorycode'});
		my ($enrolmentperiod) = $sth->fetchrow;
		$enrolmentperiod = 12 unless ($enrolmentperiod);
		$data{'expiry'} = &DateCalc($data{'joining'},"$enrolmentperiod years");
	}
	$data{'expiry'}=format_date_in_iso($data{'expiry'});
	my $query= "UPDATE borrowers SET 
					cardnumber		= '$data{'cardnumber'}'		,
					surname			= '$data{'surname'}'		,
					firstname		= '$data{'firstname'}'		,
					title			= '$data{'title'}'			,
					initials		= '$data{'initials'}'		,
					dateofbirth		= '$data{'dateofbirth'}'	,
					sex				= '$data{'sex'}'			,
					streetaddress	= '$data{'streetaddress'}'	,
					streetcity		= '$data{'streetcity'}'		,	
					zipcode			= '$data{'zipcode'}'		,
					phoneday		= '$data{'phoneday'}'		,
					physstreet		= '$data{'physstreet'}'		,	
					city			= '$data{'city'}'			,
					homezipcode		= '$data{'homezipcode'}'	,
					phone			= '$data{'phone'}'			,
					emailaddress	= '$data{'emailaddress'}'	,
					faxnumber		= '$data{'faxnumber'}'		,
					textmessaging	= '$data{'textmessaging'}'	,			 
					categorycode	= '$data{'categorycode'}'	,
					branchcode		= '$data{'branchcode'}'		,
					borrowernotes	= '$data{'borrowernotes'}'	,
					ethnicity		= '$data{'ethnicity'}'		,
					ethnotes		= '$data{'ethnotes'}'		,
					expiry			= '$data{'expiry'}'			,
					dateenrolled	= '$data{'joining'}'		,
					sort1			= '$data{'sort1'}'			, 
					sort2			= '$data{'sort2'}'			,	
					debarred		= '$data{'debarred'}'		,
					lost			= '$data{'lost'}'			,
					gonenoaddress   = '$data{'gna'}'			
			WHERE borrowernumber = $data{'borrowernumber'}";
	my $sth = $dbh->prepare($query);
	$sth->execute;
	$sth->finish;
	# ok if its an adult (type) it may have borrowers that depend on it as a guarantor
	# so when we update information for an adult we should check for guarantees and update the relevant part
	# of their records, ie addresses and phone numbers
	if ($data{'categorycode'} eq 'A' || $data{'categorycode'} eq 'W'){
		# is adult check guarantees;
		updateguarantees(%data);
	}
}

sub newmember {
	my (%data) = @_;
	my $dbh = C4::Context->dbh;
	$data{'dateofbirth'}=format_date_in_iso($data{'dateofbirth'});
	$data{'joining'} = &ParseDate("today") unless $data{'joining'};
	$data{'joining'}=format_date_in_iso($data{'joining'});
	# if expirydate is not set, calculate it from borrower category subscription duration
	unless ($data{'expiry'}) {
		my $sth = $dbh->prepare("select enrolmentperiod from categories where categorycode=?");
		$sth->execute($data{'categorycode'});
		my ($enrolmentperiod) = $sth->fetchrow;
		$enrolmentperiod = 12 unless ($enrolmentperiod);
		$data{'expiry'} = &DateCalc($data{'joining'},"$enrolmentperiod years");
	}
	$data{'expiry'}=format_date_in_iso($data{'expiry'});
	my $query= "INSERT INTO borrowers (
							cardnumber,
							surname,
							firstname,
							title,
							initials,
							dateofbirth,
							sex,
							streetaddress,
							streetcity,
							zipcode,
							phoneday,
							physstreet,
							city,
							homezipcode,
							phone,
							emailaddress,
							faxnumber,
							textmessaging,
							categorycode,
							branchcode,
							borrowernotes,
							ethnicity,
							ethnotes,
							expiry,
							dateenrolled,
							sort1,
							sort2
								) 
				VALUES (
							'$data{'cardnumber'}',
							'$data{'surname'}',
							'$data{'firstname'}',
							'$data{'title'}',
							'$data{'initials'}',
							'$data{'dateofbirth'}',
							'$data{'sex'}',
							
							'$data{'streetaddress'}',
							'$data{'streetcity'}',
							'$data{'zipcode'}',
							'$data{'phoneday'}',
							
							'$data{'physstreet'}',
							'$data{'city'}',
							'$data{'homezipcode'}',
							'$data{'phone'}',

							'$data{'emailaddress'}',
							'$data{'faxnumber'}',
							'$data{'textmessaging'}',

							'$data{'categorycode'}',
							'$data{'branchcode'}',
							'$data{'borrowernotes'}',
							'$data{'ethnicity'}',
							'$data{'ethnotes'}',
							'$data{'expiry'}',
							'$data{'joining'}',
							'$data{'sort1'}',
							'$data{'sort2'}'
							)";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	$sth->finish;
	$data{'bornum'} =$dbh->{'mysql_insertid'};
	return $data{'bornum'};
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
    return format_date_in_iso(
        &DateCalc( $dateenrolled, "$enrolmentperiod months" ) );
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
        my $guaquery =
"update borrowers set streetaddress='$data{'address'}',faxnumber='$data{'faxnumber'}',
		streetcity='$data{'streetcity'}',phoneday='$data{'phoneday'}',city='$data{'city'}',area='$data{'area'}',phone='$data{'phone'}'
		,streetaddress='$data{'address'}'
		where borrowernumber='$guarantees->[$i]->{'borrowernumber'}'";
        my $sth3 = $dbh->prepare($guaquery);
        $sth3->execute;
        $sth3->finish;
    }
}
################################################################################

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
my $rem;
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

             $rem = ( $sum % 11 );
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

	$cardnumber="V$cardnumber$rem";
    }
    return $cardnumber;
}
}
sub fixupneu_cardnumber{
    my($cardnumber,$categorycode) = @_;
    my $autonumber_members = C4::Context->boolean_preference('autoMemberNum');
    $autonumber_members = 0 unless defined $autonumber_members;
    # Find out whether member numbers should be generated
    # automatically. Should be either "1" or something else.
    # Defaults to "0", which is interpreted as "no".
my $dbh = C4::Context->dbh;
my $sth;
    if (! $cardnumber  && $autonumber_members && $categorycode) {
	if ($categorycode eq "A" || $categorycode eq "W" || $categorycode eq "C"){
	 $sth=$dbh->prepare("select max(borrowers.cardnumber) from borrowers where borrowers.cardnumber like '5%' ");
	}elsif ($categorycode eq "L"){	
	 $sth=$dbh->prepare("select max(borrowers.cardnumber) from borrowers where borrowers.cardnumber like '10%' ");
	}elsif ($categorycode eq "F" || $categorycode eq "E")	{
	 $sth=$dbh->prepare("select max(borrowers.cardnumber) from borrowers where borrowers.cardnumber like '30%' ");
	}elsif ($categorycode eq "N"){	
	 $sth=$dbh->prepare("select max(borrowers.cardnumber) from borrowers where borrowers.cardnumber like '40%' ");
	}else{
	 $sth=$dbh->prepare("select max(borrowers.cardnumber) from borrowers where borrowers.cardnumber like '6%' ");
	}
	$sth->execute;

	my $data=$sth->fetchrow_hashref;
	$cardnumber=$data->{'max(borrowers.cardnumber)'};
	$sth->finish;

	# purpose: generate checksum'd member numbers.
	# We'll assume we just got the max value of digits 2-8 of member #'s
	# from the database and our job is to increment that by one,
	# determine the 1st and 9th digits and return the full string.

	if (! $cardnumber) { 			# If DB has no values,
	 if ($categorycode eq "A" || $categorycode eq "W" || $categorycode eq "C"){   $cardnumber = 5000000;}	
	 elsif ($categorycode eq "L"){   $cardnumber = 1000000;}
	 elsif ($categorycode  eq "F"){   $cardnumber = 3000000;}
	else{$cardnumber = 6000000;}	
	# start at 1000000 or 3000000 or 5000000
	} else {
	    $cardnumber += 1;
	}

	
    }
    return $cardnumber;
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


=item findguarantees

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
sub findguarantees{
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select cardnumber,borrowernumber, firstname, surname from borrowers where guarantor=?");
  $sth->execute($bornum);

  my @dat;
  while (my $data = $sth->fetchrow_hashref)
  {
    push @dat, $data;
  }
  $sth->finish;
  return (scalar(@dat), \@dat);
}

=item findguarantor

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
sub findguarantor{
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select guarantor from borrowers where borrowernumber=?");
  $sth->execute($bornum);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $sth=$dbh->prepare("Select * from borrowers where borrowernumber=?");
  $sth->execute($data->{'guarantor'});
  $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

sub borrowercard_active {
	my ($bornum) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT expiry FROM borrowers WHERE (borrowernumber = ?) AND (NOW() <= expiry)");
	$sth->execute($bornum);
	if (my $data=$sth->fetchrow_hashref){	
	return ('1');
	}else{
	return ('0');
	}
}

# Search the member photo, in case that photo doesn´t exists, return a default photo.for NEU
sub getMemberPhoto {
	my $cardnumber = shift @_;
 my $htdocs = C4::Context->config('opacdir');
my $dirname = $htdocs."/htdocs/uploaded-files/users-photo/";
#	my $dirname = "$ENV{'DOCUMENT_ROOT'}/uploaded-files/users-photo";
	opendir(DIR, $dirname) or die "Can't open directory $dirname: $!";
	while (defined(my $file = readdir(DIR))) {
	   if ($file =~ /^$cardnumber\..+/){
		   return "/uploaded-files/users-photo/$file";
	   }
	}
	closedir(DIR);
	return "http://cc.neu.edu.tr/stdpictures/".$cardnumber.".jpg";
}

sub change_user_pass {
	my ($uid,$member,$digest) = @_;
	my $dbh = C4::Context->dbh;
	#Make sure the userid chosen is unique and not theirs if non-empty. If it is not,
	#Then we need to tell the user and have them create a new one.
	my $sth=$dbh->prepare("select * from borrowers where userid=? and borrowernumber <> ?");
	$sth->execute($uid,$member);
	if ( ($uid ne '') && ($sth->fetchrow) ) {
		
		return 0;
    } else {
		#Everything is good so we can update the information.
		$sth=$dbh->prepare("update borrowers set userid=?, password=? where borrowernumber=?");
    		$sth->execute($uid, $digest, $member);
		return 1;
	}
}






# # A better approach might be to set borrowernumber autoincrement and 
# 
 sub NewBorrowerNumber {
   my $dbh = C4::Context->dbh;
   my $sth=$dbh->prepare("Select max(borrowernumber) from borrowers");
   $sth->execute;
   my $data=$sth->fetchrow_hashref;
   $sth->finish;
   $data->{'max(borrowernumber)'}++;
   return($data->{'max(borrowernumber)'});
 }

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

sub fixEthnicity($) {

    my $ethnicity = shift;
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
    my ($date, $date_ref) = @_;

    if (not defined $date_ref) {
        $date_ref = sprintf('%04d-%02d-%02d', Today());
    }

    my ($year1, $month1, $day1) = split /-/, $date;
    my ($year2, $month2, $day2) = split /-/, $date_ref;

    my $age = $year2 - $year1;
    if ($month1.$day1 > $month2.$day2) {
        $age--;
    }

    return $age;
}# sub get_age



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
    foreach my $bornum (@$otherborrowers) {
        $sth->execute( $borrowernumber, $bornum );
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
sub GetBorrowersFromSurname  {
    my ($searchstring)=@_;
    my $dbh = C4::Context->dbh;
    $searchstring=~ s/\'/\\\'/g;
    my @data=split(' ',$searchstring);
    my $count=@data;
    my $query = qq|
        SELECT   surname,firstname
        FROM     borrowers
        WHERE    (surname like ?)
        ORDER BY surname
    |;
    my $sth=$dbh->prepare($query);
    $sth->execute("$data[0]%");
    my @results;
    my $count = 0;
    while (my $data=$sth->fetchrow_hashref){
         push(@results,$data);
         $count++;
    }
     $sth->finish;
     return ($count,\@results);
}

1;
