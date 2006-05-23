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
use Date::Manip;
use C4::Date;
use Digest::MD5 qw(md5_base64);

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

$VERSION = do { my @v = '$Revision$' =~ /\d+/g; shift(@v) . "." . join("_", map {sprintf "%03d", $_ } @v); };

=head1 NAME

C4::Members - Perl Module containing convenience functions for member handling

=head1 SYNOPSIS


=head1 DESCRIPTION


=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw();

@EXPORT = qw(
	&BornameSearch &getmember &borrdata &borrdata2 &fixup_cardnumber &findguarantees &findguarantor &GuarantornameSearch &NewBorrowerNumber &modmember &newmember &changepassword &borrissues &allissues
	&checkuniquemember &getzipnamecity &getidcity &getguarantordata &getcategorytype
	&calcexpirydate &checkuserpassword
	&getboracctrecord
	&borrowercategories &getborrowercategory
	&fixEthnicity
	&ethnicitycategories get_institutions
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
sub BornameSearch  {
	my ($env,$searchstring,$orderby,$type)=@_;
	my $dbh = C4::Context->dbh;
	my $query = ""; my $count; my @data;
	my @bind=();

	if($type eq "simple")	# simple search for one letter only
	{
		$query="Select * from borrowers where surname like ? order by $orderby";
		@bind=("$searchstring%");
	}
	else	# advanced search looking in surname, firstname and othernames
	{
		@data=split(' ',$searchstring);
		$count=@data;
		$query="Select * from borrowers
		where ((surname like ? or surname like ?
		or firstname  like ? or firstname like ?
		or othernames like ? or othernames like ?)
		";
		@bind=("$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%");
		for (my $i=1;$i<$count;$i++){
		        $query=$query." and (".
		        " surname like ? or surname like ?
                        or firstname  like ? or firstname like ?
		        or othernames like ? or othernames like ?)";
		        push(@bind,"$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%");
					# FIXME - .= <<EOT;
		}
		$query=$query.") or cardnumber like ?
		order by $orderby";
		push(@bind,$searchstring);
					# FIXME - .= <<EOT;
	}

	my $sth=$dbh->prepare($query);
#	warn "Q $orderby : $query";
	$sth->execute(@bind);
	my @results;
	my $cnt=$sth->rows;
	while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
	}
	#  $sth->execute;
	$sth->finish;
	return ($cnt,\@results);
}

=item getmember

  $borrower = &getmember($cardnumber, $borrowernumber);

Looks up information about a patron (borrower) by either card number
or borrower number. If $borrowernumber is specified, C<&borrdata>
searches by borrower number; otherwise, it searches by card number.

C<&getmember> returns a reference-to-hash whose keys are the fields of
the C<borrowers> table in the Koha database.

=cut
#'
sub getmember {
  my ($cardnumber,$bornum)=@_;
  $cardnumber = uc $cardnumber;
  my $dbh = C4::Context->dbh;
  my $sth;
  if ($bornum eq ''){
    $sth=$dbh->prepare("Select * from borrowers where cardnumber=?");
    $sth->execute($cardnumber);
  } else {
    $sth=$dbh->prepare("Select * from borrowers where borrowernumber=?");
  $sth->execute($bornum);
  }
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  if ($data) {
  	return($data);
	} else { # try with firstname
		if ($cardnumber) {
			my $sth=$dbh->prepare("select * from borrowers where firstname=?");
			$sth->execute($cardnumber);
			my $data=$sth->fetchrow_hashref;
			$sth->finish;
			return($data);
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
  my ($cardnumber,$bornum)=@_;
  $cardnumber = uc $cardnumber;
  my $dbh = C4::Context->dbh;
  my $sth;
  if ($bornum eq ''){
    $sth=$dbh->prepare("Select borrowers.*,categories.category_type from borrowers left join categories on borrowers.categorycode=categories.categorycode where cardnumber=?");
    $sth->execute($cardnumber);
  } else {
    $sth=$dbh->prepare("Select borrowers.*,categories.category_type from borrowers left join categories on borrowers.categorycode=categories.categorycode where borrowernumber=?");
  $sth->execute($bornum);
  }
  my $data=$sth->fetchrow_hashref;
  warn "DATA".$data->{category_type};
  $sth->finish;
  if ($data) {
  	return($data);
	} else { # try with firstname
		if ($cardnumber) {
			my $sth=$dbh->prepare("Select borrowers.*,categories.category_type from borrowers left join categories on borrowers.categorycode=categories.categorycode  where firstname=?");
			$sth->execute($cardnumber);
			my $data=$sth->fetchrow_hashref;
			$sth->finish;
			return($data);
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
  my ($env,$bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select count(*) from issues where borrowernumber='$bornum' and
    returndate is NULL";
    # print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $sth=$dbh->prepare("Select count(*) from issues where
    borrowernumber='$bornum' and date_due < now() and returndate is NULL");
  $sth->execute;
  my $data2=$sth->fetchrow_hashref;
  $sth->finish;
  $sth=$dbh->prepare("Select sum(amountoutstanding) from accountlines where
    borrowernumber='$bornum'");
  $sth->execute;
  my $data3=$sth->fetchrow_hashref;
  $sth->finish;

return($data2->{'count(*)'},$data->{'count(*)'},$data3->{'sum(amountoutstanding)'});
}

sub modmember {
	my (%data) = @_;
	my $dbh = C4::Context->dbh;
	$data{'dateofbirth'}=format_date_in_iso($data{'dateofbirth'});
	$data{'expiry'}=format_date_in_iso($data{'expiry'});
	my $query="update borrowers set title='$data{'title'}',expiry='$data{'expiry'}',
	cardnumber='$data{'cardnumber'}',sex='$data{'sex'}',ethnotes='$data{'ethnicnotes'}',
	streetaddress='$data{'streetaddress'}',faxnumber='$data{'faxnumber'}',firstname='$data{'firstname'}',
	altnotes='$data{'altnotes'}',dateofbirth='$data{'dateofbirth'}',contactname='$data{'contactname'}',
	emailaddress='$data{'emailaddress'}',streetcity='$data{'streetcity'}',
	altrelationship='$data{'altrelationship'}',othernames='$data{'othernames'}',phoneday='$data{'phoneday'}',
	categorycode='$data{'categorycode'}',city='$data{'city'}',area='$data{'area'}',phone='$data{'phone'}',
	borrowernotes='$data{'borrowernotes'}',altphone='$data{'altphone'}',surname='$data{'surname'}',
	initials='$data{'initials'}',physstreet='$data{'physstreet'}',ethnicity='$data{'ethnicity'}',
	gonenoaddress='$data{'gna'}',lost='$data{'lost'}',debarred='$data{'debarred'}',
	textmessaging='$data{'textmessaging'}', branchcode = '$data{'branchcode'}',
	zipcode = '$data{'zipcode'}',homezipcode='$data{'homezipcode'}', sort1='$data{'sort1'}', sort2='$data{'sort2'}'
	where borrowernumber=$data{'borrowernumber'}";
	my $sth=$dbh->prepare($query);
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
	$data{'userid'}='' unless $data{'password'};
	$data{'password'}=md5_base64($data{'password'}) if $data{'password'};
	$data{'dateofbirth'}=format_date_in_iso($data{'dateofbirth'});
	$data{'dateenrolled'}=format_date_in_iso($data{'dateenrolled'});
	$data{expiry}=format_date_in_iso($data{expiry});
my $query="insert into borrowers set cardnumber=".$dbh->quote($data{'cardnumber'}).
									",surname=".$dbh->quote($data{'surname'}).
									",firstname=".$dbh->quote($data{'firstname'}).
									",title=".$dbh->quote($data{'title'}).
									",othernames=".$dbh->quote($data{'othernames'}).
									",initials=".$dbh->quote($data{'initials'}).
									",streetnumber=".$dbh->quote($data{'streetnumber'}).
									",streettype=".$dbh->quote($data{'streettype'}).
									",address=".$dbh->quote($data{'address'}).
									",address2=".$dbh->quote($data{'address2'}).
									",zipcode=".$dbh->quote($data{'zipcode'}).
									",city=".$dbh->quote($data{'city'}).
									",phone=".$dbh->quote($data{'phone'}).
									",email=".$dbh->quote($data{'email'}).
									",mobile=".$dbh->quote($data{'mobile'}).
									",phonepro=".$dbh->quote($data{'phonepro'}).
									",opacnote=".$dbh->quote($data{'opacnote'}).
									",guarantorid=".$dbh->quote($data{'guarantorid'}).
									",dateofbirth=".$dbh->quote($data{'dateofbirth'}).
									",branchcode=".$dbh->quote($data{'branchcode'}).
									",categorycode=".$dbh->quote($data{'categorycode'}).
									",dateenrolled=".$dbh->quote($data{'dateenrolled'}).
									",contactname=".$dbh->quote($data{'contactname'}).
									",borrowernotes=".$dbh->quote($data{'borrowernotes'}).
									",dateexpiry=".$dbh->quote($data{'dateexpiry'}).
									",contactnote=".$dbh->quote($data{'contactnote'}).
									",b_address=".$dbh->quote($data{'b_address'}).
									",b_zipcode=".$dbh->quote($data{'b_zipcode'}).
									",b_city=".$dbh->quote($data{'b_city'}).
									",b_phone=".$dbh->quote($data{'b_phone'}).
									",b_email=".$dbh->quote($data{'b_email'},).
									",password=".$dbh->quote($data{'password'}).
									",userid=".$dbh->quote($data{'userid'}).
									",sort1=".$dbh->quote($data{'sort1'}).
									",sort2=".$dbh->quote($data{'sort2'}).
									",contacttitle=".$dbh->quote($data{'contacttitle'}).
									",emailpro=".$dbh->quote($data{'emailpro'}).
									",contactfirstname=".$dbh->quote($data{'contactfirstname'}).
									",sex=".$dbh->quote($data{'sex'}).
									",fax=".$dbh->quote($data{'fax'}).
									",flags=".$dbh->quote($data{'flags'}).
									",relationship=".$dbh->quote($data{'relationship'})
									;
	my $sth=$dbh->prepare($query);
	$sth->execute;
	$sth->finish;
	$data{'borrowerid'} =$dbh->{'mysql_insertid'};
	return $data{'borrowerid'};
}

sub changepassword {
	my ($uid,$member,$digest) = @_;
	my $dbh = C4::Context->dbh;
	#Make sure the userid chosen is unique and not theirs if non-empty. If it is not,
	#Then we need to tell the user and have them create a new one.
	my $sth=$dbh->prepare("select * from borrowers where userid=? and borrowernumber != ?");
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

sub getmemberfromuserid {
	my ($userid) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("select * from borrowers where userid=?");
	$sth->execute($userid);
	return $sth->fetchrow_hashref;
}
sub updateguarantees {
	my (%data) = @_;
	my $dbh = C4::Context->dbh;
	my ($count,$guarantees)=findguarantees($data{'borrowernumber'});
	for (my $i=0;$i<$count;$i++){
		# FIXME
		# It looks like the $i is only being returned to handle walking through
		# the array, which is probably better done as a foreach loop.
		#
		my $guaquery="update borrowers set streetaddress='$data{'address'}',faxnumber='$data{'faxnumber'}',
		streetcity='$data{'streetcity'}',phoneday='$data{'phoneday'}',city='$data{'city'}',area='$data{'area'}',phone='$data{'phone'}'
		,streetaddress='$data{'address'}'
		where borrowernumber='$guarantees->[$i]->{'borrowernumber'}'";
		my $sth3=$dbh->prepare($guaquery);
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
my @weightings = (8,4,6,3,5,2,1);

sub fixup_cardnumber ($) {
    my($cardnumber) = @_;
    my $autonumber_members = C4::Context->boolean_preference('autoMemberNum');
    $autonumber_members = 0 unless defined $autonumber_members;
    # Find out whether member numbers should be generated
    # automatically. Should be either "1" or something else.
    # Defaults to "0", which is interpreted as "no".

#     if ($cardnumber !~ /\S/ && $autonumber_members) {
    if ($autonumber_members) {
		my $dbh = C4::Context->dbh;
		if (C4::Context->preference('checkdigit') eq 'katipo') {
			# if checkdigit is selected, calculate katipo-style cardnumber.
			# otherwise, just use the max()
			# purpose: generate checksum'd member numbers.
			# We'll assume we just got the max value of digits 2-8 of member #'s
			# from the database and our job is to increment that by one,
			# determine the 1st and 9th digits and return the full string.
			my $sth=$dbh->prepare("select max(substring(borrowers.cardnumber,2,7)) from borrowers");
			$sth->execute;
		
			my $data=$sth->fetchrow_hashref;
			$cardnumber=$data->{'max(substring(borrowers.cardnumber,2,7))'};
			$sth->finish;
			if (! $cardnumber) { 			# If DB has no values,
				$cardnumber = 1000000;		# start at 1000000
			} else {
				$cardnumber += 1;
			}
		
			my $sum = 0;
			for (my $i = 0; $i < 8; $i += 1) {
				# read weightings, left to right, 1 char at a time
				my $temp1 = $weightings[$i];
		
				# sequence left to right, 1 char at a time
				my $temp2 = substr($cardnumber,$i,1);
		
				# mult each char 1-7 by its corresponding weighting
				$sum += $temp1 * $temp2;
			}
		
			my $rem = ($sum%11);
			$rem = 'X' if $rem == 10;
		
			$cardnumber="V$cardnumber$rem";
		} else {
			# MODIFIED BY JF: mysql4.1 allows casting as an integer, which is probably
            # better. I'll leave the original in in case it needs to be changed for you
            my $sth=$dbh->prepare("select max(cast(cardnumber as signed)) from borrowers");
            #my $sth=$dbh->prepare("select max(borrowers.cardnumber) from borrowers");

			$sth->execute;
		
			my ($result)=$sth->fetchrow;
			$sth->finish;
			$cardnumber=$result+1;
		}
	}
    return $cardnumber;
}

sub findguarantees {
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select cardnumber,borrowernumber from borrowers where
  guarantorid=?");
  $sth->execute($bornum);
  my @dat;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $dat[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@dat);
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
  my $sth=$dbh->prepare("Select * from borrowers where borrowernumber=?");
  $sth->execute($bornum);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
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
sub GuarantornameSearch  {
	my ($env,$searchstring,$orderby,$type)=@_;
	my $dbh = C4::Context->dbh;
	my $query = ""; my $count; my @data;
	my @bind=();

	if($type eq "simple")	# simple search for one letter only
	{
		$query="Select * from borrowers,categories  where borrowers.categorycode=categories.categorycode and category_type='A'  and  surname like ? order by $orderby";
		@bind=("$searchstring%");
	}
	else	# advanced search looking in surname, firstname and othernames
	{
		@data=split(' ',$searchstring);
		$count=@data;
		$query="Select * from borrowers,categories
		where ((surname like ? or surname like ?
		or firstname  like ? or firstname like ?
		or othernames like ? or othernames like ?) and borrowers.categorycode=categories.categorycode and category_type='A' 
		";
		@bind=("$data[0]%","% $data[0]%","$data[0]%","% $data[0]%","$data[0]%","% $data[0]%");
		for (my $i=1;$i<$count;$i++){
		        $query=$query." and (".
		        " surname like ? or surname like ?
                        or firstname  like ? or firstname like ?
		        or othernames like ? or othernames like ?)";
		        push(@bind,"$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%","$data[$i]%","% $data[$i]%");
					# FIXME - .= <<EOT;
		}
		$query=$query.") or cardnumber like ?
		order by $orderby";
		push(@bind,$searchstring);
					# FIXME - .= <<EOT;
	}

	my $sth=$dbh->prepare($query);
	$sth->execute(@bind);
	my @results;
	my $cnt=$sth->rows;
	while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
	}
	#  $sth->execute;
	$sth->finish;
	return ($cnt,\@results);
}

=item NewBorrowerNumber

  $num = &NewBorrowerNumber();

Allocates a new, unused borrower number, and returns it.

=cut
#'
# FIXME - This is identical to C4::Circulation::Borrower::NewBorrowerNumber.
# Pick one and stick with it. Preferably use the other one. This function
# doesn't belong in C4::Search.
sub NewBorrowerNumber {
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select max(borrowernumber) from borrowers");
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $data->{'max(borrowernumber)'}++;
  return($data->{'max(borrowernumber)'});
}

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
  my $query="Select * from issues,biblio,items,biblioitems
  where borrowernumber=? and
  items.biblioitemnumber=biblioitems.biblioitemnumber and
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

=item getboracctrecord

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
   return ($numlines,\@acctlines,$total);
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

sub checkuniquemember{
	my ($collectivity,$surname,$firstname,$dateofbirth)=@_;
	my $dbh = C4::Context->dbh;
	my $request;
	if ($collectivity ) {
# 				$request="select count(*) from borrowers where surname=? and categorycode=?";
		$request="select borrowernumber,categorycode from borrowers where surname=? ";
	} else {
# 				$request="select count(*) from borrowers where surname=? and categorycode=? and firstname=? and dateofbirth=?";
		$request="select borrowernumber,categorycode from borrowers where surname=?  and firstname=? and dateofbirth=?";
	}
	my $sth=$dbh->prepare($request);
	if ($collectivity) {
		$sth->execute(uc($surname));
	} else {
		$sth->execute(uc($surname),ucfirst($firstname),$dateofbirth);
	}
	my @data= $sth->fetchrow; 
	if ($data[0]){
		$sth->finish;
	return $data[0],$data[1];				
# 			
	}else{
		$sth->finish;
	return 0;
	}
}

=head2 getzipnamecity (OUEST-PROVENCE)

take all info from table city for the fields city and  zip
check for the name and the zip code of the city selected

=cut
sub getzipnamecity {
	my ($cityid)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select city_name,city_zipcode from cities where cityid=? ");
	$sth->execute($cityid);
	my @data = $sth->fetchrow;
	return $data[0],$data[1];
}

=head2 updatechildguarantor (OUEST-PROVENCE)

check for title,firstname,surname,adress,zip code and city  from guarantor to 
guarantorchild

=cut
sub getguarantordata{
	my ($borrowerid)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("Select title,firstname,surname,streetnumber,address,streettype,address2,zipcode,city,phone,phonepro,mobile,email,emailpro  from borrowers where borrowernumber =? ");
	$sth->execute($borrowerid);
	my $guarantor_data=$sth->fetchrow_hashref;
	$sth->finish;  
	return $guarantor_data;			
}

=head2 getdcity (OUEST-PROVENCE)
recover cityid  with city_name condition
=cut
sub getidcity {
	my ($city_name)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select cityid from cities where city_name=? ");
	$sth->execute($city_name);
	my $data = $sth->fetchrow;
	return $data;
}


=head2 getcategorytype (OUEST-PROVENCE)

check for the category_type with categorycode
and return the category_type 

=cut
sub getcategorytype {
			my ($categorycode)=@_;
			my $dbh = C4::Context->dbh;
			my $sth=$dbh->prepare("Select category_type,description from categories where categorycode=?  ");
			$sth->execute($categorycode);
			my ($category_type,$description) = $sth->fetchrow;
			return $category_type,$description;
}

sub calcexpirydate {
	my ($categorycode,$dateenrolled)=@_;
	my $dbh=C4::Context->dbh;
	my $sth = $dbh->prepare("select enrolmentperiod from categories where categorycode=?");
	$sth->execute($categorycode);
	my ($enrolmentperiod) = $sth->fetchrow;
	$enrolmentperiod = 12 unless ($enrolmentperiod);
	return format_date_in_iso(&DateCalc($dateenrolled,"$enrolmentperiod months"));
}

=head2 checkuserpassword (OUEST-PROVENCE)

check for the password and login are not used
return the number of record 
0=> NOT USED 1=> USED

=cut
sub checkuserpassword{
			my ($borrowerid,$userid,$password)=@_;
			$password=md5_base64($password);
			my $dbh = C4::Context->dbh;
			my $sth=$dbh->prepare("Select count(*) from borrowers where borrowernumber !=? and userid =? and password=? ");
			$sth->execute($borrowerid,$userid,$password);
			my $number_rows=$sth->fetchrow;
  return $number_rows;			
			
}

=head2 borrowercategories

  ($codes_arrayref, $labels_hashref) = &borrowercategories();

Looks up the different types of borrowers in the database. Returns two
elements: a reference-to-array, which lists the borrower category
codes, and a reference-to-hash, which maps the borrower category codes
to category descriptions.

=cut
#'
sub borrowercategories {
	my ($category_type,$action)=@_;
	my $dbh = C4::Context->dbh;
	my $request;
	$request="Select categorycode,description from categories where category_type=? order by categorycode"; 	
	my $sth=$dbh->prepare($request);
	$sth->execute($category_type);
	my %labels;
	my @codes;
	while (my $data=$sth->fetchrow_hashref){
		push @codes,$data->{'categorycode'};
		$labels{$data->{'categorycode'}}=$data->{'description'};
	}
	$sth->finish;
	return(\@codes,\%labels);
}

=item getborrowercategory

  $description = &getborrowercategory($categorycode);

Given the borrower's category code, the function returns the corresponding
description for a comprehensive information display.

=cut

sub getborrowercategory
{
	my ($catcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT description FROM categories WHERE categorycode = ?");
	$sth->execute($catcode);
	my $description = $sth->fetchrow();
	$sth->finish();
	return $description;
} # sub getborrowercategory


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
    my $sth=$dbh->prepare("Select code,name from ethnicity order by name");
    $sth->execute;
    my %labels;
    my @codes;
    while (my $data=$sth->fetchrow_hashref){
      push @codes,$data->{'code'};
      $labels{$data->{'code'}}=$data->{'name'};
    }
    $sth->finish;
    return(\@codes,\%labels);
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
    my $dbh = C4::Context->dbh;
    my $sth=$dbh->prepare("Select name from ethnicity where code = ?");
    $sth->execute($ethnicity);
    my $data=$sth->fetchrow_hashref;
    $sth->finish;
    return $data->{'name'};
} # sub fixEthnicity

=head2 get_institutions
  
  $insitutions = get_institutions();

Just returns a list of all the borrowers of type I, borrownumber and name
  
=cut
#'

sub get_institutions {
    my $dbh = C4::Context->dbh();
    my $sth = $dbh->prepare("SELECT borrowernumber,surname FROM borrowers WHERE categorycode=? ORDER BY surname");
    $sth->execute('I');
    my %orgs;
    while (my $data = $sth->fetchrow_hashref()){
	$orgs{$data->{'borrowernumber'}}=$data;
    }
    $sth->finish();
    return(\%orgs);

} # sub get_institutions
1;
