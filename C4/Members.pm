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

use strict;
require Exporter;
use C4::Context;
use Date::Manip;
use C4::Date;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

$VERSION = 0.01;

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
	&getmember &fixup_cardnumber &findguarantees &modmember &newmember &changepassword
    );

	
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


sub modmember {
	my (%data) = @_;
	my $dbh = C4::Context->dbh;
	$data{'dateofbirth'}=format_date_in_iso($data{'dateofbirth'});
	$data{'joining'}=format_date_in_iso($data{'joining'});
	$data{'expiry'}=format_date_in_iso($data{'expiry'});
	my $query="update borrowers set title='$data{'title'}',expiry='$data{'expiry'}',
	cardnumber='$data{'cardnumber'}',sex='$data{'sex'}',ethnotes='$data{'ethnicnotes'}',
	streetaddress='$data{'address'}',faxnumber='$data{'faxnumber'}',firstname='$data{'firstname'}',
	altnotes='$data{'altnotes'}',dateofbirth='$data{'dateofbirth'}',contactname='$data{'contactname'}',
	emailaddress='$data{'emailaddress'}',dateenrolled='$data{'joining'}',streetcity='$data{'streetcity'}',
	altrelationship='$data{'altrelationship'}',othernames='$data{'othernames'}',phoneday='$data{'phoneday'}',
	categorycode='$data{'categorycode'}',city='$data{'city'}',area='$data{'area'}',phone='$data{'phone'}',
	borrowernotes='$data{'borrowernotes'}',altphone='$data{'altphone'}',surname='$data{'surname'}',
	initials='$data{'initials'}',physstreet='$data{'streetaddress'}',ethnicity='$data{'ethnicity'}',
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
	$data{'dateofbirth'}=format_date_in_iso($data{'dateofbirth'});
	$data{'joining'}=format_date_in_iso($data{'joining'});
	$data{'expiry'}=format_date_in_iso($data{'expiry'});
# 	$data{'borrowernumber'}=NewBorrowerNumber();
	my $query="insert into borrowers (title,expiry,cardnumber,sex,ethnotes,streetaddress,faxnumber,
	firstname,altnotes,dateofbirth,contactname,emailaddress,textmessaging,dateenrolled,streetcity,
	altrelationship,othernames,phoneday,categorycode,city,area,phone,borrowernotes,altphone,surname,
	initials,ethnicity,physstreet,branchcode,zipcode,homezipcode,sort1,sort2) values ('$data{'title'}','$data{'expiry'}','$data{'cardnumber'}',
	'$data{'sex'}','$data{'ethnotes'}','$data{'address'}','$data{'faxnumber'}',
	'$data{'firstname'}','$data{'altnotes'}','$data{'dateofbirth'}','$data{'contactname'}','$data{'emailaddress'}','$data{'textmessaging'}',
	'$data{'joining'}','$data{'streetcity'}','$data{'altrelationship'}','$data{'othernames'}',
	'$data{'phoneday'}','$data{'categorycode'}','$data{'city'}','$data{'area'}','$data{'phone'}',
	'$data{'borrowernotes'}','$data{'altphone'}','$data{'surname'}','$data{'initials'}',
	'$data{'ethnicity'}','$data{'streetaddress'}','$data{'branchcode'}','$data{'zipcode'}','$data{'homezipcode'}','$data{'sort1'}','$data{'sort2'}')";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	$sth->finish;
	$data{borrowernumber} =$dbh->{'mysql_insertid'};
	return $data{borrowernumber};
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

    if ($cardnumber !~ /\S/ && $autonumber_members) {
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("select max(substring(borrowers.cardnumber,2,7)) from borrowers");
	$sth->execute;

	my $data=$sth->fetchrow_hashref;
	$cardnumber=$data->{'max(substring(borrowers.cardnumber,2,7))'};
	$sth->finish;

	# purpose: generate checksum'd member numbers.
	# We'll assume we just got the max value of digits 2-8 of member #'s
	# from the database and our job is to increment that by one,
	# determine the 1st and 9th digits and return the full string.

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
    }
    return $cardnumber;
}

sub findguarantees {
  my ($bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("select cardnumber,borrowernumber from borrowers where
  guarantor=?");
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

# =item NewBorrowerNumber
# 
#   $num = &NewBorrowerNumber();
# 
# Allocates a new, unused borrower number, and returns it.
# 
# =cut
# #'
# # FIXME - This is identical to C4::Search::NewBorrowerNumber.
# # Pick one (preferably this one) and stick with it.
# 
# # FIXME - Race condition: this function just says what the next unused
# # number is, but doesn't allocate it. Hence, two clients adding
# # patrons at the same time could get the same new borrower number and
# # clobber each other.
# # A better approach might be to set borrowernumber autoincrement and 
# 
# sub NewBorrowerNumber {
#   my $dbh = C4::Context->dbh;
#   my $sth=$dbh->prepare("Select max(borrowernumber) from borrowers");
#   $sth->execute;
#   my $data=$sth->fetchrow_hashref;
#   $sth->finish;
#   $data->{'max(borrowernumber)'}++;
#   return($data->{'max(borrowernumber)'});
# }

1;
