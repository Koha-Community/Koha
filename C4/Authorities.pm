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
@EXPORT = qw(&newauthority &searchauthority
					);
# FIXME - This is never used

=item newauthority

  $id = &newauthority($dbh,$hash);

  adds an authority entry in the db.
  It calculates the level of the authority with the authoritysep and the complete hierarchy.

C<$dbh> is a DBI::db handle for the Koha database.

C<$hash> is a hash containing freelib,stdlib,category and father.

=cut
sub newauthority  {
}

=item SearchAuthority

  $id = &SearchAuthority($dbh,$category,$toponly,$branch,$searchstring,$type);

  searches for an authority

C<$dbh> is a DBI::db handle for the Koha database.

C<$category> is the category of the authority

C<$toponly> if set, returns only one level of entries. If unset, returns the main level and the sub entries.

C<$branch> can contain a branch hierarchy. For example, if C<$branch> contains 1024|2345, SearchAuthority will return only
entries beginning by 1024|2345

C<$searchstring> contains a string. Only entries beginning by C<$searchstring> are returned


=cut
sub searchauthority  {
	my ($env,$category,$toponly,$branch,$searchstring)=@_;
	my $dbh = C4::Context->dbh;
	$searchstring=~ s/\'/\\\'/g;
	my $query="Select distinct stdlib,id,hierarchy,level from bibliothesaurus where (category like \"$category%\")";
	$query .= " and hierarchy='$branch'" if ($branch && $toponly);
	$query .= " and hierarchy like \"$branch%\"" if ($branch && !$toponly);
	$query .= " and hierarchy=''" if (!$branch & $toponly);
	$query .= " and stdlib like \"$searchstring%\"" if ($searchstring);
	$query .= " order by category,stdlib";
	my $sth=$dbh->prepare($query);
	$sth->execute;
	my @results;
	my $cnt=0;
	my $old_stdlib="";
	while (my $data=$sth->fetchrow_hashref){
	if ($old_stdlib ne $data->{'stdlib'}) {
		$cnt ++;
		push(@results,$data);
	}
	$old_stdlib = $data->{'stdlib'};
	}
	$sth->finish;
	return ($cnt,\@results);
}


END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 SEE ALSO

=cut
