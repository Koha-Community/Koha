package C4::SearchMarc;

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

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.02;

=head1 NAME

C4::Search - Functions for searching the Koha MARC catalog

=head1 SYNOPSIS

  use C4::Search;

  my ($count, @results) = catalogsearch();

=head1 DESCRIPTION

This module provides the searching facilities for the Koha MARC catalog

C<&catalogsearch> is a front end to all the other searches. Depending
on what is passed to it, it calls the appropriate search function.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&catalogsearch);
# make all your functions, whether exported or not;

# marcsearch : search in the MARC biblio table.
# everything is choosen by the user : what to search, the conditions...

sub catalogsearch {
	my ($dbh, $tags, $subfields, $and_or, $excluding, $operator, $value, $offset,$length) = @_;
	# build the sql request. She will look like :
	# select m1.bibid
	#		from marc_subfield_table as m1, marc_subfield_table as m2
	#		where m1.bibid=m2.bibid and
	#		(m1.subfieldvalue like "Des%" and m2.subfieldvalue like "27%")

	my $sql_tables; # will contain marc_subfield_table as m1,...
	my $sql_where1; # will contain the "true" where
	my $sql_where2; # will contain m1.bibid=m2.bibid
	my $nb_active=0; # will contain the number of "active" entries. and entry is active is a value is provided.
	my $nb_table=1; # will contain the number of table. ++ on each entry EXCEPT when an OR  is provided.

	for(my $i=0; $i<=@$value;$i++) {
		if (@$value[$i]) {
			$nb_active++;
			if ($nb_active==1) {
				if (@$operator[$i] eq "start") {
					$sql_tables .= "marc_subfield_table as m$nb_table,";
					$sql_where1 .= "@$excluding[$i](m1.subfieldvalue like '@$value[$i]%'";
					if (@$tags[$i]) {
						$sql_where1 .=" and m1.tag=@$tags[$i] and m1.subfieldcode='@$subfields[$i]'";
					}
					$sql_where1.=")";
				} elsif (@$operator[$i] eq "contains") {
					$sql_tables .= "marc_word as m$nb_table,";
					$sql_where1 .= "@$excluding[$i](m1.word  like '@$value[$i]%'";
					if (@$tags[$i]) {
						 $sql_where1 .=" and m1.tag=@$tags[$i] and m1.subfieldid='@$subfields[$i]'";
					}
					$sql_where1.=")";
				} else {
					$sql_tables .= "marc_subfield_table as m$nb_table,";
					$sql_where1 .= "@$excluding[$i](m1.subfieldvalue @$operator[$i] '@$value[$i]' ";
					if (@$tags[$i]) {
						 $sql_where1 .=" and m1.tag=@$tags[$i] and m1.subfieldcode='@$subfields[$i]'";
					}
					$sql_where1.=")";
				}
			} else {
				if (@$operator[$i] eq "start") {
					$nb_table++;
					$sql_tables .= "marc_subfield_table as m$nb_table,";
					$sql_where1 .= "@$and_or[$i] @$excluding[$i](m$nb_table.subfieldvalue like '@$value[$i]%'";
					if (@$tags[$i]) {
						 $sql_where1 .=" and m$nb_table.tag=@$tags[$i] and m$nb_table.subfieldcode='@$subfields[$i])";
					}
					$sql_where1.=")";
					$sql_where2 .= "m1.bibid=m$nb_table.bibid";
				} elsif (@$operator[$i] eq "contains") {
					if (@$and_or[$i] eq 'and') {
						$nb_table++;
						$sql_tables .= "marc_word as m$nb_table,";
						$sql_where1 .= "@$and_or[$i] @$excluding[$i](m$nb_table.word like '@$value[$i]%'";
						if (@$tags[$i]) {
							$sql_where1 .="  and m$nb_table.tag=@$tags[$i] and m$nb_table.subfieldid='@$subfields[$i]'";
						}
						$sql_where1.=")";
						$sql_where2 .= "m1.bibid=m$nb_table.bibid";
					} else {
						$sql_where1 .= "@$and_or[$i] @$excluding[$i](m$nb_table.word like '@$value[$i]%'";
						if (@$tags[$i]) {
							$sql_where1 .="  and m$nb_table.tag=@$tags[$i] and m$nb_table.subfieldid='@$subfields[$i]'";
						}
						$sql_where1.=")";
						$sql_where2 .= "m1.bibid=m$nb_table.bibid";
					}
				} else {
					$nb_table++;
					$sql_tables .= "marc_subfield_table as m$nb_table,";
					$sql_where1 .= "@$and_or[$i] @$excluding[$i](m$nb_table.subfieldvalue @$operator[$i] '@$value[$i]'";
					if (@$tags[$i]) {
						 $sql_where1 .="  and m$nb_table.tag=@$tags[$i] and m$nb_table.subfieldcode='@$subfields[$i]'";
					}
					$sql_where2 .= "m1.bibid=m$nb_table.bibid";
					$sql_where1.=")";
				}
			}
		}
	}
	chop $sql_tables;
	my $sth;
	if ($sql_where2) {
		$sth = $dbh->prepare("select distinct m1.bibid from $sql_tables where $sql_where2 and ($sql_where1)");
	} else {
		$sth = $dbh->prepare("select distinct m1.bibid from $sql_tables where $sql_where1");
	}
	$sth->execute;
	my @result;
	while (my ($bibid) = $sth->fetchrow) {
		push @result,$bibid;
	}
	# we have bibid list. Now, loads title and author from [offset] to [offset]+[length]
	my $counter = $offset;
	$sth = $dbh->prepare("select author,title from biblio,marc_biblio where biblio.biblionumber=marc_biblio.biblionumber and bibid=?");
	my @finalresult = ();
	while ($counter <= ($offset + $length)) {
		$sth->execute($result[$counter]);
		my ($author,$title) = $sth->fetchrow;
		my %line;
		$line{bibid}=$result[$counter];
		$line{author}=$author;
		$line{title}=$title;
		push @finalresult, \%line;
		$counter++;
	}
	return @finalresult;
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
