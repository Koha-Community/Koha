package C4::Suggestions;

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

  use C4::Suggestions;

=head1 DESCRIPTION

The functions in this module deal with the suggestions :
* in OPAC
* in librarian interface

A suggestion is done in the OPAC. It has the status "ASKED"
When a librarian manages the suggestion, he can set the status to "REJECTED" or "ORDERED".
When a book is ordered and arrived in the library, the status becomes "AVAILABLE"
All suggestions of a borrower by the borrower itself.
Suggestions done by other can be seen when not "AVAILABLE"

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(	&newsuggestion
				&searchsuggestion
				&delsuggestion
			);

=item SearchSuggestion

  (\@array) = &SearchSuggestion($user)

  searches for a suggestion

C<$user> is the user code (used as suggestor filter)

return :
C<\@array> : the suggestions found. Array of hash.
Note the status is stored twice :
* in the status field
* as parameter ( for example ASKED => 1, or REJECTED => 1) . This is for template & translation purposes.

=cut
sub searchsuggestion  {
	my ($user,$author,$title,$publishercode,$status,$suggestedbyme)=@_;
	my $dbh = C4::Context->dbh;
	my $query="Select suggestions.*,
						U1.surname as surnamesuggestedby,U1.firstname as firstnamesuggestedby,
						U2.surname as surnamemanagedby,U2.firstname as firstnamemanagedby 
						from suggestions,borrowers as U1 
						left join borrowers as U2  on managedby=U2.borrowernumber
						where suggestedby=U1.borrowernumber";
	my @sql_params;
	if ($author) {
		push @sql_params,"%".$author."%";
		$query .= " and author like ?";
	}
	if ($title) {
		push @sql_params,"%".$title."%";
		$query .= " and suggestions.title like ?";
	}
	if ($publishercode) {
		push @sql_params,"%".$publishercode."%";
		$query .= " and publishercode like ?";
	}
	if ($status) {
		push @sql_params,$status;
		$query .= " and status=?";
	}
	if ($suggestedbyme) {
		push @sql_params,$user;
		$query .= " and suggestedby=?";
	} else {
		$query .= " and managedby is NULL";
	}
	my $sth=$dbh->prepare($query);
	$sth->execute(@sql_params);
	my @results;
	my $even=1; # the even variable is used to set even / odd lines, for highlighting
	while (my $data=$sth->fetchrow_hashref){
			$data->{$data->{status}} = 1;
			if ($even) {
				$even=0;
				$data->{even}=1;
			} else {
				$even=1;
			}
			push(@results,$data);
	}
	return (\@results);
}

sub newsuggestion {
	my ($borrowernumber,$title,$author,$publishercode,$note) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("insert into suggestions (suggestedby,title,author,publishercode,note) values (?,?,?,?,?)");
	$sth->execute($borrowernumber,$title,$author,$publishercode,$note);
}

sub delsuggestion {
	my ($borrowernumber,$suggestionnumber) = @_;
	my $dbh = C4::Context->dbh;
	# check that the suggestion comes from the suggestor
	my $sth = $dbh->prepare("select suggestedby from suggestions where suggestionnumber=?");
	$sth->execute($suggestionnumber);
	my ($suggestedby) = $sth->fetchrow;
	if ($suggestedby eq $borrowernumber) {
		$sth = $dbh->prepare("delete from suggestions where suggestionnumber=?");
		$sth->execute($suggestionnumber);
	}
}

=back

=head1 SEE ALSO

=cut
