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
use C4::Date;
use Date::Manip;
use ZOOM;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.02;

=head1 NAME

C4::Search - Functions for searching the Koha MARC catalog

=head1 FUNCTIONS

This module provides the searching facilities for the Koha MARC catalog

=cut

@ISA = qw(Exporter);
@EXPORT = qw(&catalogsearch &findseealso &findsuggestion &getMARCnotes &getMARCsubjects);

=head1 findsuggestion($dbh,$values);

=head2 $dbh is a link to the DB handler.

use C4::Context;
my $dbh =C4::Context->dbh;

=head2 $values is a word

Searches words with the same soundex, ordered by frequency of use.
Useful to suggest other searches to the users.

=cut

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

=head1 findseealso($dbh,$fields);

=head2 $dbh is a link to the DB handler.

use C4::Context;
my $dbh =C4::Context->dbh;

=head2 $fields is a reference to the fields array

This function modify the @$fields array and add related fields to search on.

=cut

sub findseealso {
	my ($dbh, $fields) = @_;
	my $tagslib = MARCgettagslib ($dbh,1);
	for (my $i=0;$i<=$#{$fields};$i++) {
		next unless @$fields[$i];
		my ($tag) =substr(@$fields[$i],1,3);
		my ($subfield) =substr(@$fields[$i],4,1);
		@$fields[$i].=','.$tagslib->{$tag}->{$subfield}->{seealso} if ($tagslib->{$tag}->{$subfield}->{seealso});
	}
}

=head1  my ($count, @results) = catalogsearch($dbh, $tags, $and_or, $excluding, $operator, $value, $offset,$length,$orderby,$sqlstring);

=head2 $dbh is a link to the DB handler.

use C4::Context;
my $dbh =C4::Context->dbh;

$tags,$and_or, $excluding, $operator, $value are references to array

=head2 $tags

contains the list of tags+subfields (for example : $@tags[0] = '200a')
A field can be a list of fields : '200f','700a','700b','701a','701b'

Example

=head2 $and_or

contains  a list of strings containing and or or. The 1st value is useless.

=head2 $excluding

contains 0 or 1. If 1, then the request is negated.

=head2 $operator

contains contains,=,start,>,>=,<,<= the = and start work on the complete subfield. The contains operator works on every word in the subfield.

examples :
contains home, search home anywhere.
= home, search a string being home.

=head2 $value

contains the value to search
If it contains a * or a %, then the search is partial.

=head2 $offset and $length

returns $length results, beginning at $offset

=head2 $orderby

define the field used to order the request. Any field in the biblio/biblioitem tables can be used. DESC is possible too

(for example title, title DESC,...)

=head2 $sqlstring

optional argument containing an sql string to be used in the 'where' statement. see usage in opac-search.pl.

=head2 $extratables

optional argument containing extra tables to search. Used in conjunction with $sqlstring. See usage in opac-search.pl.
String... so ',items,issues,reserves' allows the items, issues and reserves tables to be used.in a where.

=head2 RETURNS

returns an array containing hashes. The hash contains all biblio & biblioitems fields and a reference to an item hash. The "item hash contains one line for each callnumber & the number of items related to the callnumber.

=cut
=head2 my $marcurlsarray = &getMARCurls($dbh,$bibid,$marcflavour);

Returns a reference to an array containing all the URLS stored in the MARC database for the given bibid.
$marcflavour ("MARC21" or "UNIMARC") isn't used in this version because both flavours of MARC use the same subfield for URLS (but eventually when we get the lables working we'll need to change this.

=cut
sub catalogsearch {
	my ($dbh, $tags, $and_or, $excluding, $operator, $value, $offset,$length,$orderby,$desc_or_asc,$sqlstring, $extratables) = @_;

# the item.notforloan contains an integer. Every value <>0 means "book unavailable for loan".
# but each library can have it's own table of meaning for each value. Get them
# 1st search if there is a list of authorised values connected to items.notforloan
	my $sth = $dbh->prepare('select authorised_value from marc_subfield_structure where kohafield="items.notforloan"');
	$sth->execute;
	my %notforloanstatus;
	my ($authorised_valuecode) = $sth->fetchrow;
	if ($authorised_valuecode) {
		$sth = $dbh->prepare("select authorised_value,lib from authorised_values where category=?");
		$sth->execute($authorised_valuecode);
		while (my ($authorised_value,$lib) = $sth->fetchrow) {
			$notforloanstatus{$authorised_value} = $lib?$lib:$authorised_value;
		}
	}
	my $subtitle; # Added by JF for Subtitles

	# prepare the query to find item status
	my $sth_itemCN;
	if (C4::Context->preference('hidelostitem')) {
		$sth_itemCN = $dbh->prepare("select items.* from items where biblionumber=? and (itemlost = 0 or itemlost is NULL)");
	} else {
		$sth_itemCN = $dbh->prepare("select items.* from items where biblionumber=?");
	}
	# prepare the query to find date_due where applicable
	my $sth_issue = $dbh->prepare("select date_due,returndate from issues where itemnumber=?");
	my $sth_itemtype = $dbh->prepare("select itemtypes.description,itemtypes.notforloan,itemtypes.imageurl from itemtypes where itemtype=?");
	
	# prepare the query to find subtitles
	my $sth_subtitle = $dbh->prepare("SELECT subtitle FROM bibliosubtitle WHERE biblionumber=?"); # Added BY JF for Subtitles

	#
	# now, do stupid things, that have to be modified for 3.0 :
	# retrieve the 1st MARC tag.
	# find the matching non-MARC field
	# find bib1 attribute. This way, we will be MARC-independant (as title is in 200$a in UNIMARC and 245ùa in MARC21, we use "title" !)
	# the best method to do this would probably to add a "bib1 attribute" column to marc_subfield_structure
	# (or a CQL attribute name if we don't want to build bib1 requests)
	# for instance, we manage only author / title / isbn. Any other field is considered as a keyword/anywhere search
	#
	my $tagslib = MARCgettagslib($dbh,$1,'');
	my $query='';
	for(my $i = 0 ; $i <= $#{$value} ; $i++){
		# 1st split on , then remove ' in the 1st, the find koha field
		my @x = split /,/, @$tags[$i];
		$x[0] =~ s/'//g if $x[0];
		$x[0] =~ /(...)(.)/ if $x[0];
		my ($tag,$subfield) = ($1,$2);
		if (@$value[$i]) { # if there is something to search, build the request
			# if $query already contains something, add @and
			$query .= " and " if ($query);
			my $field = $tagslib->{$tag}->{$subfield}->{kohafield};
			if ($field eq 'biblio.author') {
				$query .= "Author all \"".@$value[$i]."\"";
			} elsif ($field eq 'biblio.title') {
				$query .= "Title all \"".@$value[$i]."\"";
			} elsif ($field eq 'biblioitems.isbn') {
				$query .= "Isbn= ".@$value[$i];
			} else {
			        my @spacedout=split(/ /,@$value[$i]);
			        my $text = join(" and ",@spacedout);
				$query .= "$text";
			}
		}
# 		warn "$i : ".@$tags[$i]. "=> $tag / $subfield = ".$tagslib->{$tag}->{$subfield}->{kohafield};
	}
	warn "QUERY : $query";
	my $Zconn = C4::Context->Zconn or die "unable to set Zconn";
	my $q = new ZOOM::Query::CQL2RPN( $query, $Zconn);
	my $rs = $Zconn->search($q);
	my $numresults=$rs->size();
	if ($numresults eq 0) {
		warn "no records found\n";
	} else {
		warn "$numresults records found, retrieving them (max 80)\n";
	}
	my $result='';
	my $scantimerstart=time();
	my @finalresult = ();
	my @CNresults=();
	my $totalitems=0;
	$offset=1 unless $offset;
	# calculate max offset
	my $maxrecordnum = $offset+$length<$numresults?$offset+$length:($numresults);
	for (my $i=$offset-1; $i <= $maxrecordnum-1; $i++) {
		# get the MARC record (in XML)...
		# warn "REC $i = ".$rs->record($i)->raw();
# FIXME : it's a silly way to do things : XML => MARC::Record => hash. We had better developping a XML=> hash (in biblio.pm)
		my $record = MARC::Record->new_from_xml($rs->record($i)->raw());
		# transform it into a meaningul hash
		my $line = MARCmarc2koha($dbh,$record);
		my $biblionumber=$line->{biblionumber};
        # Return subtitles first ADDED BY JF
#                 $sth_subtitle->execute($biblionumber);
#                 my $subtitle_here.= $sth_subtitle->fetchrow." ";
#                 chop $subtitle_here;
#                 $subtitle = $subtitle_here;
#               warn "Here's the Biblionumber ".$biblionumber;
#                warn "and here's the subtitle: ".$subtitle_here;

        # /ADDED BY JF
		# search itemtype information
		$sth_itemtype->execute($line->{itemtype});
		my ($itemtype_description,$itemtype_notforloan,$itemtype_imageurl) = $sth_itemtype->fetchrow;
		$line->{description} = $itemtype_description;
		$line->{imageurl} = $itemtype_imageurl;
		$line->{notforloan} = $itemtype_notforloan;
		$sth_itemCN->execute($biblionumber);
		my @CNresults = ();
		my $notforloan=1; # to see if there is at least 1 item that can be issued
		while (my $item = $sth_itemCN->fetchrow_hashref) {
			# parse the result, putting holdingbranch & itemcallnumber in separate array
			# then all other fields in the main array
			
			# search if item is on loan
			my $date_due;
			$sth_issue->execute($item->{itemnumber});
			while (my $loan = $sth_issue->fetchrow_hashref) {
				if ($loan->{date_due} and !$loan->{returndate}) {
					$date_due = $loan->{date_due};
				}
			}
			# store this item
			my %lineCN;
			$lineCN{holdingbranch} = $item->{holdingbranch};
			$lineCN{itemcallnumber} = $item->{itemcallnumber};
			$lineCN{location} = $item->{location};
			$lineCN{date_due} = format_date($date_due);
			$lineCN{notforloan} = $notforloanstatus{$line->{notforloan}} if ($line->{notforloan}); # setting not forloan if itemtype is not for loan
			$lineCN{notforloan} = $notforloanstatus{$item->{notforloan}} if ($item->{notforloan}); # setting not forloan it this item is not for loan
			$notforloan=0 unless ($item->{notforloan} or $item->{wthdrawn} or $item->{itemlost});
			push @CNresults,\%lineCN;
			$totalitems++;
		}
		# save the biblio in the final array, with item and item issue status
		my %newline;
		%newline = %$line;
		$newline{totitem} = $totalitems;
		# if $totalitems == 0, check if it's being ordered.
		if ($totalitems == 0) {
			my $sth = $dbh->prepare("select count(*) from aqorders where biblionumber=? and datecancellationprinted is NULL");
			$sth->execute($biblionumber);
			my ($ordered) = $sth->fetchrow;
			$newline{onorder} = 1 if $ordered;
		}
		$newline{biblionumber} = $biblionumber;
		$newline{norequests} = 0;
		$newline{norequests} = 1 if ($line->{notforloan}); # itemtype not issuable
		$newline{norequests} = 1 if (!$line->{notforloan} && $notforloan); # itemtype issuable but all items not issuable for instance
                $newline{subtitle} = $subtitle;  # put the subtitle in ADDED BY JF

		my @CNresults2= @CNresults;
		$newline{CN} = \@CNresults2;
		$newline{'even'} = 1 if $#finalresult % 2 == 0;
		$newline{'odd'} = 1 if $#finalresult % 2 == 1;
		$newline{'timestamp'} = format_date($newline{timestamp});
		@CNresults = ();
		push @finalresult, \%newline;
		$totalitems=0;
	}
	my $nbresults = $#finalresult+1;
	return (\@finalresult, $nbresults);
}

=head2 my $marcnotesarray = &getMARCnotes($dbh,$bibid,$marcflavour);

Returns a reference to an array containing all the notes stored in the MARC database for the given bibid.
$marcflavour ("MARC21" or "UNIMARC") determines which tags are used for retrieving subjects.

=cut

sub getMARCnotes {
        my ($dbh, $bibid, $marcflavour) = @_;
	my ($mintag, $maxtag);
	if ($marcflavour eq "MARC21") {
	        $mintag = "500";
		$maxtag = "599";
	} else {           # assume unimarc if not marc21
		$mintag = "300";
		$maxtag = "399";
	}

	my $sth=$dbh->prepare("SELECT subfieldvalue,tag FROM marc_subfield_table WHERE bibid=? AND tag BETWEEN ? AND ? ORDER BY tagorder");

	$sth->execute($bibid,$mintag,$maxtag);

	my @marcnotes;
	my $note = "";
	my $tag = "";
	my $marcnote;

	while (my $data=$sth->fetchrow_arrayref) {
		my $value=$data->[0];
		my $thistag=$data->[1];
		if ($value=~/\.$/) {
		        $value=$value . "  ";
		}
		if ($thistag ne $tag && $note ne "") {
		        $marcnote = {marcnote => $note,};
			push @marcnotes, $marcnote;
			$note=$value;
			$tag=$thistag;
		}
		if ($note ne $value) {
		        $note = $note." ".$value;
		}
	}

	if ($note) {
	        $marcnote = {marcnote => $note};
		push @marcnotes, $marcnote;   #load last tag into array
	}

	$sth->finish;

	my $marcnotesarray=\@marcnotes;
	return $marcnotesarray;
}  # end getMARCnotes


=head2 my $marcsubjctsarray = &getMARCsubjects($dbh,$bibid,$marcflavour);

Returns a reference to an array containing all the subjects stored in the MARC database for the given bibid.
$marcflavour ("MARC21" or "UNIMARC") determines which tags are used for retrieving subjects.

=cut

sub getMARCsubjects {
    my ($dbh, $bibid, $marcflavour) = @_;
	my ($mintag, $maxtag);
	if ($marcflavour eq "MARC21") {
	        $mintag = "600";
		$maxtag = "699";
	} else {           # assume unimarc if not marc21
		$mintag = "600";
		$maxtag = "699";
	}
	my $sth=$dbh->prepare("SELECT `subfieldvalue`,`subfieldcode`,`tagorder`,`tag` FROM `marc_subfield_table` WHERE `bibid`= ? AND `subfieldcode` NOT IN ('2','4','6','8') AND `tag` BETWEEN ? AND ? ORDER BY `tagorder`,`subfieldorder`");
	# Subfield exclusion for $2, $4, $6, $8 protects against searching for
	# variant data in otherwise invariant authorised subject headings when all
	# returned subfields are used to form a query for matching subjects.  One
	# example is the use of $2 in MARC 21 where the value of $2 changes for
	# different editions of the thesaurus used, even where the subject heading
	# is otherwise the same.  There is certainly a better fix for many cases
	# where the value of the subfield may be parsed for the invariant data.  
	# More complete display values may also be separated from query values
	# containing only the actual invariant authorised subject headings.  More
	# coding is required for careful value parsing, or display and query
	# separation; instead of blanket subfield exclusion.
	# 
	# As implemented, $3 is passed and might still pose a problem.  Passing $3
	# could have benefits for some proper use of $3 for UNIMARC, however, might
	# restrict query usage to a given material type.  -- thd

	$sth->execute($bibid,$mintag,$maxtag);

	my @marcsubjcts;
	my $subject = "";
	my $marcsubjct;
	my $field9;
	my $activetagorder=0;
	my $lasttag;
	my ($subfieldvalue,$subfieldcode,$tagorder,$tag);
	while (($subfieldvalue,$subfieldcode,$tagorder,$tag)=$sth->fetchrow) {
		$lasttag=$tag if $tag;
		if ($activetagorder && $tagorder != $activetagorder) {
			$subject=~ s/ -- $//;
			$marcsubjct = {MARCSUBJCT => $subject,
							link => $tag."9",
							linkvalue => $field9,
							};
			push @marcsubjcts, $marcsubjct;
			$subject='';
			$tag='';
			$field9='';
		}
		if ($subfieldcode eq 9) {
			$field9=$subfieldvalue;
		} elsif ($subfieldcode eq (3 || 5)) {
			$subject .= $subfieldvalue . " ";
		} else {
			$subject .= $subfieldvalue . " -- ";
		}
		$activetagorder=$tagorder;
	}
	$subject=~ s/ -- $//;
	$marcsubjct = {MARCSUBJCT => $subject,
					link => $lasttag."9",
					linkvalue => $field9,
					};
	push @marcsubjcts, $marcsubjct;

	$sth->finish;

	my $marcsubjctsarray=\@marcsubjcts;
        return $marcsubjctsarray;
}  #end getMARCsubjects

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
