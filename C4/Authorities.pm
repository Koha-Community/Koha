package C4::Authorities;

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
use DBI;
use C4::Context;
use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

=head1 NAME

C4::Accounts - Functions for dealing with Koha authorities

=head1 SYNOPSIS

  use C4::Authorities;

=head1 DESCRIPTION

The functions in this module deal with the authorities table in koha.
It contains every functions to manage/find authorities.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(	&newauthority
						&searchauthority
						&delauthority
						&modauthority
						&SearchDeeper
					);

=item newauthority

  $id = &newauthority($dbh,$category,$stdlib,$freelib,$father,$level,$hierarchy);

  adds an authority entry in the db.
  It calculates the level of the authority with the authoritysep and the complete hierarchy.

C<$dbh> is a DBI::db handle for the Koha database.
C<$category> is the category of the entry
C<$stdlib> is the authority form to be created
C<$freelib> is a free form for the authority
C<$father> is the father in case of creation of a thesaurus sub-entry
C<$level> is the level of the entry (1 being the 1st thasaurus level)
C<$hierarchy> is the id of all the fathers of the enty.

Note :
 you can safely pass a full hierarchy without testing the existence of the father.
 As many father, grand-father... as needed are created.

 Usually, this function is called with '',1,'' as the 3 lasts parameters.
 if not provided, it's the default value.

 The function is recursive

 The function uses the authoritysep defined in systempreferences table to split the lib.

=cut

sub newauthority  {
	my ($dbh,$category,$stdlib,$freelib,$father,$level,$hierarchy)=@_;
	exit unless ($stdlib);
	$level=1 unless $level;
	$freelib = $stdlib unless ($freelib);
	my $dbh = C4::Context->dbh;
	my $sth1b=$dbh->prepare("select id from bibliothesaurus where freelib=? and hierarchy=? and category=?");
	my $sth2 =$dbh->prepare("insert into bibliothesaurus (category,stdlib,freelib,father,level,hierarchy) values (?,?,?,?,?,?)");
	$freelib=$stdlib unless ($freelib);
	my $authoritysep = C4::Context->preference('authoritysep');
	my @Thierarchy = split(/$authoritysep/,$stdlib);
	#---- split freelib. If not same structure as stdlib (different number of authoritysep),
	#---- then, drop it => we will use stdlib to build hiearchy, freelib will be used only for last occurence.
	my @Fhierarchy = split(/$authoritysep/,$freelib);
	if ($#Fhierarchy eq 0) {
		$#Fhierarchy=-1;
	}
	for (my $xi=0;$xi<$#Thierarchy;$xi++) {
		$Thierarchy[$xi] =~ s/^\s+//;
		$Thierarchy[$xi] =~ s/\s+$//;
		my $x = &newauthority($dbh,$category,$Thierarchy[$xi],$Fhierarchy[$xi]?$Fhierarchy[$xi]:$Thierarchy[$xi],$father,$level,$hierarchy);
		$father .= $Thierarchy[$xi]." $authoritysep ";
		$hierarchy .= "$x|" if ($x);
		$level++;
	}
	my $id;
	if ($#Thierarchy >=0) {
		# free form
		$hierarchy='' unless $hierarchy;
		$sth1b->execute($freelib,$hierarchy,$category);
		($id) = $sth1b->fetchrow;
		unless ($id) {
			$Thierarchy[$#Thierarchy] =~ s/^\s+//;
			$Thierarchy[$#Thierarchy] =~ s/\s+$//;
			$Fhierarchy[$#Fhierarchy] =~ s/^\s+// if ($#Fhierarchy>=0);
			$Fhierarchy[$#Fhierarchy] =~ s/\s+$// if ($#Fhierarchy>=0);
			$freelib =~ s/\s+$//;
			$sth2->execute($category,$Thierarchy[$#Thierarchy],$#Fhierarchy==$#Thierarchy?$Fhierarchy[$#Fhierarchy]:$freelib,$father,$level,$hierarchy);
		} else {
		}
		# authority form
		$sth1b->execute($Thierarchy[$#Thierarchy],$hierarchy,$category);
		($id) = $sth1b->fetchrow;
		unless ($id) {
			$Thierarchy[$#Thierarchy] =~ s/^\s+//;
			$Thierarchy[$#Thierarchy] =~ s/\s+$//;
			$sth1b->execute($stdlib,$hierarchy,$category);
			($id) = $sth1b->fetchrow;
			unless ($id) {
				$sth2->execute($category,$Thierarchy[$#Thierarchy],$Thierarchy[$#Thierarchy],$father,$level,$hierarchy);
			}
		}
	}
	return $id;
}

=item ModAuthority

  $id = &ModAuthority($dbh,$id,$freelib);

  modify a free lib

 C<$dbh> is a DBI::db handle for the Koha database.
 C<$id> is the entry id
 C<$freelib> is the new freelib

=cut
sub modauthority {
	my ($dbh,$id,$freelib) = @_;
	my $sth = $dbh->prepare("update bibliothesaurus set freelib=? where id=?");
	$sth->execute($freelib,$id);
}

=item SearchAuthority

  ($count, \@array) = &SearchAuthority($dbh,$category,$branch,$searchstring,$type,$offset,$pagesize);

  searches for an authority

C<$dbh> is a DBI::db handle for the Koha database.

C<$category> is the category of the authority

C<$branch> can contain a branch hierarchy. For example, if C<$branch> contains 1024|2345, SearchAuthority will return only
entries beginning by 1024|2345

C<$searchstring> contains a string. Only entries beginning by C<$searchstring> are returned

return :
C<$count> : the number of authorities found
C<\@array> : the authorities found. The array contains stdlib,freelib,father,id,hierarchy and level

=cut
sub searchauthority  {
	my ($env,$category,$branch,$searchstring,$offset,$pagesize)=@_;
	$offset=0 unless ($offset);
#	warn "==> ($env,$category,$branch,$searchstring,$offset,$pagesize)";
	my $dbh = C4::Context->dbh;
	my $query="Select stdlib,freelib,father,id,hierarchy,level from bibliothesaurus where category=?";
	my @bind=($category);
	if ($branch) {
		$query .= " and hierarchy=?";
		push(@bind,$branch);
		}
	if ($searchstring) {
		$query .= " and match (category,freelib) AGAINST (?)";
		push(@bind,$searchstring);
		}
#	$query .= " and freelib like \"$searchstring%\"" if ($searchstring);
	$query .= " order by category,freelib limit ?,?";
	push(@bind,$offset,($pagesize*4));
# 	warn "q : $query";
	my $sth=$dbh->prepare($query);
	$sth->execute(@bind);
	my @results;
	my $old_stdlib="";
	while (my $data=$sth->fetchrow_hashref){
			push(@results,$data);
	}
	$sth->finish;
	$query="Select count(*) from bibliothesaurus where category =?";
	@bind=($category);
	if ($branch) {
		$query .= " and hierarchy=?";
		push(@bind,$branch);
		}
	if ($searchstring) {
		$query .= " and stdlib like ?";
		push(@bind,"$searchstring%");
		}
	$sth=$dbh->prepare($query);
	$sth->execute(@bind);
	my ($cnt) = $sth->fetchrow;
	$cnt = $pagesize+1 if ($cnt>$pagesize);
	$sth->finish();
	return ($cnt,\@results);
}

=item SearchDeeper

 @array = &SearchAuthority($dbh,$category,$father);

  Finds everything depending on the parameter.

C<$dbh> is a DBI::db handle for the Koha database.

C<$category> is the category of the authority

C<$father> Is the string "father".

return :
@array : the authorities found. The array contains stdlib,freelib,father,id,hierarchy and level

For example :
Geography -- Europe is the father and the result is : France and Germany if there is
Geography -- Europe -- France and Geography -- Europe -- Germany in the thesaurus


=cut
sub SearchDeeper  {
	my ($category,$father)=@_;
	my $dbh = C4::Context->dbh;
	my $sth=$dbh->prepare("Select distinct level,stdlib,father from bibliothesaurus where category =? and father =? order by category,stdlib");
	$sth->execute($category,"$father --");
	my @results;
	while (my ($level,$stdlib,$father)=$sth->fetchrow){
			my %line;
			$line{level} = $level;
			$line{stdlib}= $stdlib;
			$line{father} = $father;
			push(@results,\%line);
	}
	$sth->finish;
	return (@results);
}


=item delauthority

  $id = &delauthority($id);

  delete an authority and all it's "childs" and "related"

C<$id> is the id of the authority

=cut
sub delauthority {
	my ($id) = @_;
	my $dbh = C4::Context->dbh;
	# we must delete : - the id, every sons from the id.
	# to do this, we can : reconstruct the full hierarchy of the id and delete with hierarchy as a key.
	my $sth=$dbh->prepare("select hierarchy from bibliothesaurus where id=?");
	$sth->execute($id);
	my ($hierarchy) = $sth->fetchrow;
	if ($hierarchy) {
		$dbh->do("delete from bibliothesaurus where hierarchy like '$hierarchy|$id|%'");
#		warn("delete from bibliothesaurus where hierarchy like '$hierarchy|$id|%'");
	} else {
		$dbh->do("delete from bibliothesaurus where hierarchy like '$id|%'");
#		warn("delete from bibliothesaurus where hierarchy like '$id|%'");
	}
#	warn("delete from bibliothesaurus where id='$id|'");
	$dbh->do("delete from bibliothesaurus where id='$id|'");
}
END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 SEE ALSO

=cut
