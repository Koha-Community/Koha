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
use C4::Biblio;

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
@EXPORT = qw(&catalogsearch &findseealso &findsuggestion);

# make all your functions, whether exported or not;

sub findsuggestion {
	my ($dbh,$values) = @_;
	my $sth = $dbh->prepare("SELECT count( * ) AS total, word FROM marc_word WHERE sndx_word = soundex( ? ) AND word <> ? GROUP BY word ORDER BY total DESC");
	my @results;
	for(my $i = 0 ; $i <= $#{$values} ; $i++) {
		if (length(@$values[$i]) >=5) {
			$sth->execute(@$values[$i],@$values[$i]);
			my $resfound = 1;
			my @resline;
			while ((my ($count,$word) = $sth->fetchrow) and $resfound <=10) {
				push @results, "@$values[$i]|$word|$count";
#				$results{@$values[$i]} = \@resline;
				$resfound++;
			}
		}
	}
	return \@results;
}
sub findseealso {
	my ($dbh, $fields) = @_;
	my $tagslib = MARCgettagslib ($dbh,1);
	for (my $i=0;$i<=$#{$fields};$i++) {
		my ($tag) =substr(@$fields[$i],1,3);
		my ($subfield) =substr(@$fields[$i],4,1);
		@$fields[$i].=','.$tagslib->{$tag}->{$subfield}->{seealso} if ($tagslib->{$tag}->{$subfield}->{seealso});
	}
}

# marcsearch : search in the MARC biblio table.
# everything is choosen by the user : what to search, the conditions...

sub catalogsearch {
	my ($dbh, $tags, $and_or, $excluding, $operator, $value, $offset,$length,$orderby) = @_;
	# build the sql request. She will look like :
	# select m1.bibid
	#		from marc_subfield_table as m1, marc_subfield_table as m2
	#		where m1.bibid=m2.bibid and
	#		(m1.subfieldvalue like "Des%" and m2.subfieldvalue like "27%")

	# last minute stripping out of stuff
	# doesn't work @$value =~ s/\'/ /;
	# @$value = map { $_ =~ s/\'/ /g } @$value;
	
	# "Normal" statements
	my @normal_tags = ();
	my @normal_and_or = ();
	my @normal_operator = ();
	my @normal_value = ();
	# Extracts the NOT statements from the list of statements
	my @not_tags = ();
	my @not_and_or = ();
	my @not_operator = ();
	my @not_value = ();
	my $any_not = 0;
	$orderby = "biblio.title" unless $orderby;
	
	#last minute stripping out of ' and ,
	foreach $_ (@$value) {
	$_=~ s/\'/ /g;
	$_=~ s/\,/ /g;
	}
	
	for(my $i = 0 ; $i <= $#{$value} ; $i++)
	{
		# replace * by %
		@$value[$i] =~ s/\*/%/g;
		if(@$excluding[$i])	# NOT statements
		{
			$any_not = 1;
			if(@$operator[$i] eq "contains")
			{
				foreach my $word (split(/ /, @$value[$i]))	# if operator is contains, splits the words in separate requests
				{
					# remove the "%" for small word (3 letters. (note : the >4 is due to the % at the end)
					warn "word : $word";
					$word =~ s/%//g unless length($word)>4;
					unless (C4::Context->stopwords->{uc($word)}) {	#it's NOT a stopword => use it. Otherwise, ignore
						push @not_tags, @$tags[$i];
						push @not_and_or, "or"; # as request is negated, finds "foo" or "bar" if final request is NOT "foo" and "bar"
						push @not_operator, @$operator[$i];
						push @not_value, $word;
					}
				}
			}
			else
			{
				push @not_tags, @$tags[$i];
				push @not_and_or, "or"; # as request is negated, finds "foo" or "bar" if final request is NOT "foo" and "bar"
				push @not_operator, @$operator[$i];
				push @not_value, @$value[$i];
			}
		}
		else	# NORMAL statements
		{
			if(@$operator[$i] eq "contains") # if operator is contains, splits the words in separate requests
			{
				foreach my $word (split(/ /, @$value[$i]))
				{
					# remove the "%" for small word (3 letters. (note : the >4 is due to the % at the end)
					warn "word : $word";
					$word =~ s/%//g unless length($word)>4;
					unless (C4::Context->stopwords->{uc($word)}) {	#it's NOT a stopword => use it. Otherwise, ignore
						my $tag = substr(@$tags[$i],0,3);
						my $subf = substr(@$tags[$i],3,1);
						push @normal_tags, @$tags[$i];
						push @normal_and_or, "and";	# assumes "foo" and "bar" if "foo bar" is entered
						push @normal_operator, @$operator[$i];
						push @normal_value, $word;
					}
				}
			}
			else
			{
				push @normal_tags, @$tags[$i];
				push @normal_and_or, @$and_or[$i];
				push @normal_operator, @$operator[$i];
				push @normal_value, @$value[$i];
			}
		}
	}

	# Finds the basic results without the NOT requests
	my ($sql_tables, $sql_where1, $sql_where2) = create_request($dbh,\@normal_tags, \@normal_and_or, \@normal_operator, \@normal_value);

	my $sth;
	if ($sql_where2) {
		$sth = $dbh->prepare("select distinct m1.bibid from biblio,biblioitems,marc_biblio,$sql_tables where biblio.biblionumber=marc_biblio.biblionumber and biblio.biblionumber=biblioitems.biblionumber and m1.bibid=marc_biblio.bibid and $sql_where2 and ($sql_where1) order by $orderby");
		warn "Q2 : select distinct m1.bibid from biblio,biblioitems,marc_biblio,$sql_tables where biblio.biblionumber=marc_biblio.biblionumber and biblio.biblionumber=biblioitems.biblionumber and m1.bibid=marc_biblio.bibid and $sql_where2 and ($sql_where1) order by $orderby term is  @$value";
	} else {
		$sth = $dbh->prepare("select distinct m1.bibid from biblio,biblioitems,marc_biblio,$sql_tables where biblio.biblionumber=marc_biblio.biblionumber and biblio.biblionumber=biblioitems.biblionumber and m1.bibid=marc_biblio.bibid and $sql_where1 order by $orderby");
		warn "Q : select distinct m1.bibid from biblio,biblioitems,marc_biblio,$sql_tables where biblio.biblionumber=marc_biblio.biblionumber and biblio.biblionumber=biblioitems.biblionumber and m1.bibid=marc_biblio.bibid and $sql_where1 order by $orderby";
	}
	$sth->execute();
	my @result = ();

	# Processes the NOT if any and there are results
	my ($not_sql_tables, $not_sql_where1, $not_sql_where2);

	if( ($sth->rows) && $any_not )	# some results to tune up and some NOT statements
	{
		($not_sql_tables, $not_sql_where1, $not_sql_where2) = create_request($dbh,\@not_tags, \@not_and_or, \@not_operator, \@not_value);

		my @tmpresult;

		while (my ($bibid) = $sth->fetchrow) {
			push @tmpresult,$bibid;
		}
		my $sth_not;
		warn "NOT : select distinct m1.bibid from $not_sql_tables where $not_sql_where2 and ($not_sql_where1)";
		if ($not_sql_where2) {
			$sth_not = $dbh->prepare("select distinct m1.bibid from $not_sql_tables where $not_sql_where2 and ($not_sql_where1)");
		} else {
			$sth_not = $dbh->prepare("select distinct m1.bibid from $not_sql_tables where $not_sql_where1");
		}
		$sth_not->execute();

		if($sth_not->rows)
		{
			my %not_bibids = ();
			while(my $bibid = $sth_not->fetchrow()) {
				$not_bibids{$bibid} = 1;	# populates the hashtable with the bibids matching the NOT statement
			}

			foreach my $bibid (@tmpresult)
			{
				if(!$not_bibids{$bibid})
				{
					push @result, $bibid;
				}
			}
		}
		$sth_not->finish();
	}
	else	# no NOT statements
	{
		while (my ($bibid) = $sth->fetchrow) {
			push @result,$bibid;
		}
	}

	# we have bibid list. Now, loads title and author from [offset] to [offset]+[length]
	my $counter = $offset;
	$sth = $dbh->prepare("SELECT biblio.*, biblioitems.*, items.*,marc_biblio.bibid
							FROM biblio, marc_biblio 
							LEFT JOIN items on items.biblionumber = biblio.biblionumber
							LEFT JOIN biblioitems on biblio.biblionumber = biblioitems.biblionumber
							WHERE biblio.biblionumber = marc_biblio.biblionumber AND bibid = ?
							GROUP BY items.biblionumber, items.holdingbranch, items.itemcallnumber");
	my @finalresult = ();
	my @CNresults=();
	my $oldbiblionumber=0;
	my $totalitems=0;
	my $oldline;
# 	my ($biblionumber,$author,$title,$holdingbranch, $itemcallnumber, $bibid);
	my ($oldbibid, $oldauthor, $oldtitle,$oldbiblionumber);
	while (($counter <= $#result) && ($counter <= ($offset + $length))) {
		$sth->execute($result[$counter]);
		while (my $line = $sth->fetchrow_hashref) {
			# parse the result, putting holdingbranch & itemcallnumber in separate array
			# then all other fields in the main array
			if ($oldbiblionumber && ($oldbiblionumber ne $line->{biblionumber})) {
				my %newline;
				%newline = %$oldline;
				$newline{totitem} = $totalitems;
				$newline{biblionumber} = $oldbiblionumber;
				my @CNresults2= @CNresults;
				$newline{CN} = \@CNresults2;
			    $newline{'even'} = 1 if $#finalresult % 2 == 0;
				$newline{'odd'} = 1 if $#finalresult % 2 == 1;
				@CNresults = ();
				push @finalresult, \%newline;
				$totalitems=0;
			}
			$oldbiblionumber = $line->{biblionumber};
			$totalitems++ if ($line->{holdingbranch});
			$oldline = $line;
			# item callnumber & branch
			my %lineCN;
			$lineCN{holdingbranch} = $line->{holdingbranch};
			$lineCN{itemcallnumber} = $line->{itemcallnumber};
			push @CNresults,\%lineCN;
		}
		$counter++;
	}
# add the last line, that is not reached byt the loop / if ($oldbiblionumber...)
	my %newline;
	if ($oldline) {
		%newline = %$oldline;
		$newline{totitem} = $totalitems;
		$newline{biblionumber} = $oldbiblionumber;
		my @CNresults2= @CNresults;
		$newline{CN} = \@CNresults2;
		$newline{'even'} = 1 if $counter % 2 == 0;
		$newline{'odd'} = 1 if $counter % 2 == 1;
		@CNresults = ();
		my @CNresults2= @CNresults;
		$newline{CN} = \@CNresults2;
		@CNresults = ();
		push @finalresult, \%newline;
	}
	my $nbresults = $#result + 1;
	return (\@finalresult, $nbresults);
}

# Creates the SQL Request

sub create_request {
	my ($dbh,$tags, $and_or, $operator, $value) = @_;

	my $sql_tables; # will contain marc_subfield_table as m1,...
	my $sql_where1; # will contain the "true" where
	my $sql_where2 = "("; # will contain m1.bibid=m2.bibid
	my $nb_active=0; # will contain the number of "active" entries. an entry is active if a value is provided.
	my $nb_table=1; # will contain the number of table. ++ on each entry EXCEPT when an OR  is provided.

	for(my $i=0; $i<=@$value;$i++) {
		if (@$value[$i]) {
			$nb_active++;
			if ($nb_active==1) {
				if (@$operator[$i] eq "start") {
					$sql_tables .= "marc_subfield_table as m$nb_table,";
					$sql_where1 .= "(m1.subfieldvalue like ".$dbh->quote("@$value[$i]");
					if (@$tags[$i]) {
						$sql_where1 .=" and m1.tag+m1.subfieldcode in (@$tags[$i])";
					}
					$sql_where1.=")";
				} elsif (@$operator[$i] eq "contains") {
					$sql_tables .= "marc_word as m$nb_table,";
					$sql_where1 .= "(m1.word  like ".$dbh->quote("@$value[$i]");
					if (@$tags[$i]) {
						 $sql_where1 .=" and m1.tagsubfield in (@$tags[$i])";
					}
					$sql_where1.=")";
				} else {
					$sql_tables .= "marc_subfield_table as m$nb_table,";
					$sql_where1 .= "(m1.subfieldvalue @$operator[$i] ".$dbh->quote("@$value[$i]");
					if (@$tags[$i]) {
						 $sql_where1 .=" and m1.tag+m1.subfieldcode in (@$tags[$i])";
					}
					$sql_where1.=")";
				}
			} else {
				if (@$operator[$i] eq "start") {
					$nb_table++;
					$sql_tables .= "marc_subfield_table as m$nb_table,";
					$sql_where1 .= "@$and_or[$i] (m$nb_table.subfieldvalue like ".$dbh->quote("@$value[$i]");
					if (@$tags[$i]) {
					 	$sql_where1 .=" and m$nb_table.tag+m$nb_table.subfieldcode in (@$tags[$i])";
					}
					$sql_where1.=")";
					$sql_where2 .= "m1.bibid=m$nb_table.bibid and ";
				} elsif (@$operator[$i] eq "contains") {
					if (@$and_or[$i] eq 'and') {
						$nb_table++;
						$sql_tables .= "marc_word as m$nb_table,";
						$sql_where1 .= "@$and_or[$i] (m$nb_table.word like ".$dbh->quote("@$value[$i]");
						if (@$tags[$i]) {
							$sql_where1 .=" and m$nb_table.tagsubfield in(@$tags[$i])";
						}
						$sql_where1.=")";
						$sql_where2 .= "m1.bibid=m$nb_table.bibid and ";
					} else {
						$sql_where1 .= "@$and_or[$i] (m$nb_table.word like ".$dbh->quote("@$value[$i]");
						if (@$tags[$i]) {
							$sql_where1 .="  and m$nb_table.tagsubfield in (@$tags[$i])";
						}
						$sql_where1.=")";
						$sql_where2 .= "m1.bibid=m$nb_table.bibid and ";
					}
				} else {
					$nb_table++;
					$sql_tables .= "marc_subfield_table as m$nb_table,";
					$sql_where1 .= "@$and_or[$i] (m$nb_table.subfieldvalue @$operator[$i] ".$dbh->quote(@$value[$i]);
					if (@$tags[$i]) {
					 	$sql_where1 .="  and m$nb_table.tag+m$nb_table.subfieldcode in (@$tags[$i])";
					}
					$sql_where2 .= "m1.bibid=m$nb_table.bibid and ";
					$sql_where1.=")";
				}
			}
		}
	}

	if($sql_where2 ne "(")	# some datas added to sql_where2, processing
	{
		$sql_where2 = substr($sql_where2, 0, (length($sql_where2)-5)); # deletes the trailing ' and '
		$sql_where2 .= ")";
	}
	else	# no sql_where2 statement, deleting '('
	{
		$sql_where2 = "";
	}
	chop $sql_tables;	# deletes the trailing ','
	return ($sql_tables, $sql_where1, $sql_where2);
}


END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
