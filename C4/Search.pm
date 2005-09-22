package C4::Search;

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
use C4::Reserves2;
	# FIXME - C4::Search uses C4::Reserves2, which uses C4::Search.
	# So Perl complains that all of the functions here get redefined.
use C4::Date;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = do { my @v = '$Revision$' =~ /\d+/g;
          shift(@v) . "." . join("_", map {sprintf "%03d", $_ } @v); };

=head1 NAME

C4::Search - Functions for searching the Koha catalog and other databases

=head1 SYNOPSIS

  use C4::Search;

  my ($count, @results) = catalogsearch($env, $type, $search, $num, $offset);

=head1 DESCRIPTION

This module provides the searching facilities for the Koha catalog and
other databases.

C<&catalogsearch> is a front end to all the other searches. Depending
on what is passed to it, it calls the appropriate search function.

=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
	&catalogsearch &KeywordSearch &CatSearch &subsearch
);
# make all your functions, whether exported or not;

=item catalogsearch

  ($count, @results) = &catalogsearch($env, $type, $search, $num, $offset);

This is primarily a front-end to other, more specialized catalog
search functions: if C<$search-E<gt>{itemnumber}> or
C<$search-E<gt>{isbn}> is given, C<&catalogsearch> uses a precise
C<&CatSearch>. If $search->{subject} is given, it runs a subject
C<&CatSearch>. If C<$search-E<gt>{keyword}> is given, it runs a
C<&KeywordSearch>. Otherwise, it runs a loose C<&CatSearch>.

If C<$env-E<gt>{itemcount}> is 1, then C<&catalogsearch> also counts
the items for each result, and adds several keys:

=over 4

=item C<itemcount>

The total number of copies of this book.

=item C<locationhash>

This is a reference-to-hash; the keys are the names of branches where
this book may be found, and the values are the number of copies at
that branch.

=item C<location>

A descriptive string saying where the book is located, and how many
copies there are, if greater than 1.

=item C<subject2>

The book's subject, with spaces replaced with C<%20>, presumably for
HTML.

=back

=cut
#'
sub catalogsearch {
	my ($env,$type,$search,$num,$offset)=@_;
	my $dbh = C4::Context->dbh;
	#  foreach my $key (%$search){
	#    $search->{$key}=$dbh->quote($search->{$key});
	#  }
	my ($count,@results);
	if ($search->{'itemnumber'} ne '' || $search->{'isbn'} ne ''){
		print STDERR "Doing a precise search\n";
		($count,@results)=CatSearch($env,'precise',$search,$num,$offset);
	} elsif ($search->{'subject'} ne ''){
		($count,@results)=CatSearch($env,'subject',$search,$num,$offset);
	} elsif ($search->{'keyword'} ne ''){
		($count,@results)=&KeywordSearch($env,'keyword',$search,$num,$offset);
	} else {
		($count,@results)=CatSearch($env,'loose',$search,$num,$offset);

	}
	if ($env->{itemcount} eq '1') {
		foreach my $data (@results){
			my ($counts) = itemcount2($env, $data->{'biblionumber'}, 'intra');
			my $subject2=$data->{'subject'};
			$subject2=~ s/ /%20/g;
			$data->{'itemcount'}=$counts->{'total'};
			my $totalitemcounts=0;
			foreach my $key (keys %$counts){
				if ($key ne 'total'){	# FIXME - Should ignore 'order', too.
					#$data->{'location'}.="$key $counts->{$key} ";
					$totalitemcounts+=$counts->{$key};
					$data->{'locationhash'}->{$key}=$counts->{$key};
				}
			}
			my $locationtext='';
			my $locationtextonly='';
			my $notavailabletext='';
			foreach (sort keys %{$data->{'locationhash'}}) {
				if ($_ eq 'notavailable') {
					$notavailabletext="Not available";
					my $c=$data->{'locationhash'}->{$_};
					$data->{'not-available-p'}=$totalitemcounts;
					if ($totalitemcounts>1) {
					$notavailabletext.=" ($c)";
					$data->{'not-available-plural-p'}=1;
					}
				} else {
					$locationtext.="$_";
					my $c=$data->{'locationhash'}->{$_};
					if ($_ eq 'Item Lost') {
					$data->{'lost-p'}=$totalitemcounts;
					$data->{'lost-plural-p'}=1
							if $totalitemcounts > 1;
					} elsif ($_ eq 'Withdrawn') {
					$data->{'withdrawn-p'}=$totalitemcounts;
					$data->{'withdrawn-plural-p'}=1
							if $totalitemcounts > 1;
					} elsif ($_ eq 'On Loan') {
					$data->{'on-loan-p'}=$totalitemcounts;
					$data->{'on-loan-plural-p'}=1
							if $totalitemcounts > 1;
					} else {
					$locationtextonly.=$_;
					$locationtextonly.=" ($c), "
							if $totalitemcounts>1;
					}
					if ($totalitemcounts>1) {
					$locationtext.=" ($c), ";
					}
				}
			}
			if ($notavailabletext) {
				$locationtext.=$notavailabletext;
			} else {
				$locationtext=~s/, $//;
			}
			$data->{'location'}=$locationtext;
			$data->{'location-only'}=$locationtextonly;
			$data->{'subject2'}=$subject2;
			$data->{'use-location-flags-p'}=1; # XXX
		}
	}
	return ($count,@results);
}

=item KeywordSearch

  $search = { "keyword"	=> "One or more keywords",
	      "class"	=> "VID|CD",	# Limit search to fiction and CDs
	      "dewey"	=> "813",
	 };
  ($count, @results) = &KeywordSearch($env, $type, $search, $num, $offset);

C<&KeywordSearch> searches the catalog by keyword: given a string
(C<$search-E<gt>{"keyword"}> consisting of a space-separated list of
keywords, it looks for books that contain any of those keywords in any
of a number of places.

C<&KeywordSearch> looks for keywords in the book title (and subtitle),
series name, notes (both C<biblio.notes> and C<biblioitems.notes>),
and subjects.

C<$search-E<gt>{"class"}> can be set to a C<|> (pipe)-separated list of
item class codes (e.g., "F" for fiction, "JNF" for junior nonfiction,
etc.). In this case, the search will be restricted to just those
classes.

If C<$search-E<gt>{"class"}> is not specified, you may specify
C<$search-E<gt>{"dewey"}>. This will restrict the search to that
particular Dewey Decimal Classification category. Setting
C<$search-E<gt>{"dewey"}> to "513" will return books about arithmetic,
whereas setting it to "5" will return all books with Dewey code 5I<xx>
(Science and Mathematics).

C<$env> and C<$type> are ignored.

C<$offset> and C<$num> specify the subset of results to return.
C<$num> specifies the number of results to return, and C<$offset> is
the number of the first result. Thus, setting C<$offset> to 100 and
C<$num> to 5 will return results 100 through 104 inclusive.

=cut
#'
sub KeywordSearch {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = C4::Context->dbh;
  $search->{'keyword'}=~ s/ +$//;
  my @key=split(' ',$search->{'keyword'});
		# FIXME - Naive users might enter comma-separated
		# words, e.g., "training, animal". Ought to cope with
		# this.
  my $count=@key;
  my $i=1;
  my %biblionumbers;		# Set of biblionumbers returned by the
				# various searches.

  # FIXME - Ought to filter the stopwords out of the list of keywords.
  #	@key = map { !defined($stopwords{$_}) } @key;

  # FIXME - The way this code is currently set up, it looks for all of
  # the keywords first in (title, notes, seriestitle), then in the
  # subtitle, then in the subject. Thus, if you look for keywords
  # "science fiction", this search won't find a book with
  #	title    = "How to write fiction"
  #	subtitle = "A science-based approach"
  # Is this the desired effect? If not, then the first SQL query
  # should look in the biblio, subtitle, and subject tables all at
  # once. The way the first query is built can accomodate this easily.

  # Look for keywords in table 'biblio'.

  # Build an SQL query that finds each of the keywords in any of the
  # title, biblio.notes, or seriestitle. To do this, we'll build up an
  # array of clauses, one for each keyword.
  my $query;			# The SQL query
  my @clauses = ();		# The search clauses
  my @bind = ();		# The term bindings

  $query = <<EOT;		# Beginning of the query
	SELECT	biblionumber
	FROM	biblio
	WHERE
EOT
  foreach my $keyword (@key)
  {
    my @subclauses = ();	# Subclauses, one for each field we're
				# searching on

    # For each field we're searching on, create a subclause that'll
    # match the current keyword in the current field.
    foreach my $field (qw(title notes seriestitle author))
    {
      push @subclauses,
	"$field LIKE ? OR $field LIKE ?";
	  push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
    }
    # (Yes, this could have been done as
    #	@subclauses = map {...} qw(field1 field2 ...)
    # )but I think this way is more readable.

    # Construct the current clause by joining the subclauses.
    push @clauses, "(" . join(")\n\tOR (", @subclauses) . ")";
  }
  # Now join all of the clauses together and append to the query.
  $query .= "(" . join(")\nAND (", @clauses) . ")";

  # FIXME - Perhaps use $sth->bind_columns() ? Documented as the most
  # efficient way to fetch data.
  my $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
	$biblionumbers{$_} = 1;		# Add these results to the set
    }
  }
  $sth->finish;

  # Now look for keywords in the 'bibliosubtitle' table.

  # Again, we build a list of clauses from the keywords.
  @clauses = ();
  @bind = ();
  $query = "SELECT biblionumber FROM bibliosubtitle WHERE ";
  foreach my $keyword (@key)
  {
    push @clauses,
	"subtitle LIKE ? OR subtitle like ?";
	push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
  }
  $query .= "(" . join(") AND (", @clauses) . ")";

  $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
	$biblionumbers{$_} = 1;		# Add these results to the set
    }
  }
  $sth->finish;

  # Look for the keywords in the notes for individual items
  # ('biblioitems.notes')

  # Again, we build a list of clauses from the keywords.
  @clauses = ();
  @bind = ();
  $query = "SELECT biblionumber FROM biblioitems WHERE ";
  foreach my $keyword (@key)
  {
    push @clauses,
	"notes LIKE ? OR notes like ?";
	push(@bind,"\Q$keyword\E%","% \Q$keyword\E%");
  }
  $query .= "(" . join(") AND (", @clauses) . ")";

  $sth=$dbh->prepare($query);
  $sth->execute(@bind);
  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
	$biblionumbers{$_} = 1;		# Add these results to the set
    }
  }
  $sth->finish;

  # Look for keywords in the 'bibliosubject' table.

  # FIXME - The other queries look for words in the desired field that
  # begin with the individual keywords the user entered. This one
  # searches for the literal string the user entered. Is this the
  # desired effect?
  # Note in particular that spaces are retained: if the user typed
  #	science  fiction
  # (with two spaces), this won't find the subject "science fiction"
  # (one space). Likewise, a search for "%" will return absolutely
  # everything.
  # If this isn't the desired effect, see the previous searches for
  # how to do it.

  $sth=$dbh->prepare("Select biblionumber from bibliosubject where subject
  like ? group by biblionumber");
  $sth->execute("%$search->{'keyword'}%");

  while (my @res = $sth->fetchrow_array) {
    for (@res)
    {
	$biblionumbers{$_} = 1;		# Add these results to the set
    }
  }
  $sth->finish;

  my $i2=0;
  my $i3=0;
  my $i4=0;

  my @res2;
  my @res = keys %biblionumbers;
  $count=@res;

  $i=0;
#  print "count $count";
  if ($search->{'class'} ne ''){
    while ($i2 <$count){
      my $query="select * from biblio,biblioitems where
      biblio.biblionumber=? and
      biblio.biblionumber=biblioitems.biblionumber ";
      my @bind = ($res[$i2]);
      if ($search->{'class'} ne ''){	# FIXME - Redundant
      my @temp=split(/\|/,$search->{'class'});
      my $count=@temp;
      $query.= "and ( itemtype=?";
      push(@bind,$temp[0]);
      for (my $i=1;$i<$count;$i++){
        $query.=" or itemtype=?";
        push(@bind,$temp[$i]);
      }
      $query.=")";
      }
       my $sth=$dbh->prepare($query);
       #    print $query;
       $sth->execute(@bind);
       if (my $data2=$sth->fetchrow_hashref){
         my $dewey= $data2->{'dewey'};
         my $subclass=$data2->{'subclass'};
         # FIXME - This next bit is bogus, because it assumes that the
         # Dewey code is a floating-point number. It isn't. It's
         # actually a string that mainly consists of numbers. In
         # particular, "4" is not a valid Dewey code, although "004"
         # is ("Data processing; Computer science"). Likewise, zeros
         # after the decimal are significant ("575" is not the same as
         # "575.0"; the latter is more specific). And "000" is a
         # perfectly good Dewey code ("General works; computer
         # science") and should not be interpreted to mean "this
         # database entry does not have a Dewey code". That's what
         # NULL is for.
         $dewey=~s/\.*0*$//;
         ($dewey == 0) && ($dewey='');
         ($dewey) && ($dewey.=" $subclass") ;
          $sth->finish;
	  my $end=$offset +$num;
	  if ($i4 <= $offset){
	    $i4++;
	  }
#	  print $i4;
	  if ($i4 <=$end && $i4 > $offset){
	    $data2->{'dewey'}=$dewey;
	    $res2[$i3]=$data2;

#	    $res2[$i3]="$data2->{'author'}\t$data2->{'title'}\t$data2->{'biblionumber'}\t$data2->{'copyrightdate'}\t$dewey";
            $i3++;
            $i4++;
#	    print "in here $i3<br>";
	  } else {
#	    print $end;
	  }
	  $i++;
        }
     $i2++;
     }
     $count=$i;

   } else {
  # $search->{'class'} was not specified

  # FIXME - This is bogus: it makes a separate query for each
  # biblioitem, and returns results in apparently random order. It'd
  # be much better to combine all of the previous queries into one big
  # one (building it up a little at a time, of course), and have that
  # big query select all of the desired fields, instead of just
  # 'biblionumber'.

  while ($i2 < $num && $i2 < $count){
    my $query="select * from biblio,biblioitems where
    biblio.biblionumber=? and
    biblio.biblionumber=biblioitems.biblionumber ";
    my @bind=($res[$i2+$offset]);

    if ($search->{'dewey'} ne ''){
      $query.= "and (dewey like ?)";
      push(@bind,"$search->{'dewey'}%");
    }

    my $sth=$dbh->prepare($query);
#    print $query;
    $sth->execute(@bind);
    if (my $data2=$sth->fetchrow_hashref){
        my $dewey= $data2->{'dewey'};
        my $subclass=$data2->{'subclass'};
	$dewey=~s/\.*0*$//;
        ($dewey == 0) && ($dewey='');
        ($dewey) && ($dewey.=" $subclass") ;
        $sth->finish;
	$data2->{'dewey'}=$dewey;

	$res2[$i]=$data2;
#	$res2[$i]="$data2->{'author'}\t$data2->{'title'}\t$data2->{'biblionumber'}\t$data2->{'copyrightdate'}\t$dewey";
        $i++;
    }
    $i2++;

  }
  }

  #$count=$i;
  return($count,@res2);
}

=item CatSearch

  ($count, @results) = &CatSearch($env, $type, $search, $num, $offset);

C<&CatSearch> searches the Koha catalog. It returns a list whose first
element is the number of returned results, and whose subsequent
elements are the results themselves.

Each returned element is a reference-to-hash. Most of the keys are
simply the fields from the C<biblio> table in the Koha database, but
the following keys may also be present:

=over 4

=item C<illustrator>

The book's illustrator.

=item C<publisher>

The publisher.

=back

C<$env> is ignored.

C<$type> may be C<subject>, C<loose>, or C<precise>. This controls the
high-level behavior of C<&CatSearch>, as described below.

In many cases, the description below says that a certain field in the
database must match the search string. In these cases, it means that
the beginning of some word in the field must match the search string.
Thus, an author search for "sm" will return books whose author is
"John Smith" or "Mike Smalls", but not "Paul Grossman", since the "sm"
does not occur at the beginning of a word.

Note that within each search mode, the criteria are and-ed together.
That is, if you perform a loose search on the author "Jerome" and the
title "Boat", the search will only return books by Jerome containing
"Boat" in the title.

It is not possible to cross modes, e.g., set the author to "Asimov"
and the subject to "Math" in hopes of finding books on math by Asimov.

=head2 Loose search

If C<$type> is set to C<loose>, the following search criteria may be
used:

=over 4

=item C<$search-E<gt>{author}>

The search string is a space-separated list of words. Each word must
match either the C<author> or C<additionalauthors> field.

=item C<$search-E<gt>{title}>

Each word in the search string must match the book title. If no author
is specified, the book subtitle will also be searched.

=item C<$search-E<gt>{abstract}>

Searches for the given search string in the book's abstract.

=item C<$search-E<gt>{'date-before'}>

Searches for books whose copyright date matches the search string.
That is, setting C<$search-E<gt>{'date-before'}> to "1985" will find
books written in 1985, and setting it to "198" will find books written
between 1980 and 1989.

=item C<$search-E<gt>{title}>

Searches by title are also affected by the value of
C<$search-E<gt>{"ttype"}>; if it is set to C<exact>, then the book
title, (one of) the series titleZ<>(s), or (one of) the unititleZ<>(s) must
match the search string exactly (the subtitle is not searched).

If C<$search-E<gt>{"ttype"}> is set to anything other than C<exact>,
each word in the search string must match the title, subtitle,
unititle, or series title.

=item C<$search-E<gt>{class}>

Restricts the search to certain item classes. The value of
C<$search-E<gt>{"class"}> is a | (pipe)-separated list of item types.
Thus, setting it to "F" restricts the search to fiction, and setting
it to "CD|CAS" will only look in compact disks and cassettes.

=item C<$search-E<gt>{dewey}>

Searches for books whose Dewey Decimal Classification code matches the
search string. That is, setting C<$search-E<gt>{"dewey"}> to "5" will
search for all books in 5I<xx> (Science and mathematics), setting it
to "54" will search for all books in 54I<x> (Chemistry), and setting
it to "546" will search for books on inorganic chemistry.

=item C<$search-E<gt>{publisher}>

Searches for books whose publisher contains the search string (unlike
other search criteria, C<$search-E<gt>{publisher}> is a string, not a
set of words.

=back

=head2 Subject search

If C<$type> is set to C<subject>, the following search criterion may
be used:

=over 4

=item C<$search-E<gt>{subject}>

The search string is a space-separated list of words, each of which
must match the book's subject.

Special case: if C<$search-E<gt>{subject}> is set to C<nz>,
C<&CatSearch> will search for books whose subject is "New Zealand".
However, setting C<$search-E<gt>{subject}> to C<"nz football"> will
search for books on "nz" and "football", not books on "New Zealand"
and "football".

=back

=head2 Precise search

If C<$type> is set to C<precise>, the following search criteria may be
used:

=over 4

=item C<$search-E<gt>{item}>

Searches for books whose barcode exactly matches the search string.

=item C<$search-E<gt>{isbn}>

Searches for books whose ISBN exactly matches the search string.

=back

For a loose search, if an author was specified, the results are
ordered by author and title. If no author was specified, the results
are ordered by title.

For other (non-loose) searches, if a subject was specified, the
results are ordered alphabetically by subject.

In all other cases (e.g., loose search by keyword), the results are
not ordered.

=cut
#'
sub CatSearch  {
	my ($env,$type,$search,$num,$offset)=@_;
	my $dbh = C4::Context->dbh;
	my $query = '';
	my @bind = ();
	my @results;

	my $title = lc($search->{'title'});

	if ($type eq 'loose') {
		if ($search->{'author'} ne ''){
			my @key=split(' ',$search->{'author'});
			my $count=@key;
			my $i=1;
			$query="select *,biblio.author,biblio.biblionumber from
							biblio
							left join additionalauthors
							on additionalauthors.biblionumber =biblio.biblionumber
							where
							((biblio.author like ? or biblio.author like ? or
							additionalauthors.author like ? or additionalauthors.author
							like ?
								)";
			@bind=("$key[0]%","% $key[0]%","$key[0]%","% $key[0]%");
			while ($i < $count){
					$query .= " and (
									biblio.author like ? or biblio.author like ? or
									additionalauthors.author like ? or additionalauthors.author like ?
									)";
					push(@bind,"$key[$i]%","% $key[$i]%","$key[$i]%","% $key[$i]%");
				$i++;
			}
			$query .= ")";
			if ($search->{'title'} ne ''){
				my @key=split(' ',$search->{'title'});
				my $count=@key;
				my $i=0;
				$query.= " and (((title like ? or title like ?)";
				push(@bind,"$key[0]%","% $key[0]%");
				while ($i<$count){
					$query .= " and (title like ? or title like ?)";
					push(@bind,"$key[$i]%","% $key[$i]%");
					$i++;
				}
				$query.=") or ((seriestitle like ? or seriestitle like ?)";
				push(@bind,"$key[0]%","% $key[0]%");
				for ($i=1;$i<$count;$i++){
					$query.=" and (seriestitle like ? or seriestitle like ?)";
					push(@bind,"$key[$i]%","% $key[$i]%");
					}
				$query.=") or ((unititle like ? or unititle like ?)";
				push(@bind,"$key[0]%","% $key[0]%");
				for ($i=1;$i<$count;$i++){
					$query.=" and (unititle like ? or unititle like ?)";
					push(@bind,"$key[$i]%","% $key[$i]%");
					}
				$query .= "))";
			}
			if ($search->{'abstract'} ne ''){
				$query.= " and (abstract like ?)";
				push(@bind,"%$search->{'abstract'}%");
			}
			if ($search->{'date-before'} ne ''){
				$query.= " and (copyrightdate like ?)";
				push(@bind,"%$search->{'date-before'}%");
			}
			$query.=" group by biblio.biblionumber";
		} else {
			if ($search->{'title'} ne '') {
				if ($search->{'ttype'} eq 'exact'){
					$query="select * from biblio
					where
					(biblio.title=? or (biblio.unititle = ?
					or biblio.unititle like ? or
					biblio.unititle like ? or
					biblio.unititle like ?) or
					(biblio.seriestitle = ? or
					biblio.seriestitle like ? or
					biblio.seriestitle like ? or
					biblio.seriestitle like ?)
					)";
					@bind=($search->{'title'},$search->{'title'},"$search->{'title'} |%","%| $search->{'title'} |%","%| $search->{'title'}",$search->{'title'},"$search->{'title'} |%","%| $search->{'title'} |%","%| $search->{'title'}");
				} else {
					my @key=split(' ',$search->{'title'});
					my $count=@key;
					my $i=1;
					$query="select biblio.biblionumber,author,title,unititle,notes,abstract,serial,seriestitle,copyrightdate,timestamp,subtitle from biblio
					left join bibliosubtitle on
					biblio.biblionumber=bibliosubtitle.biblionumber
					where
					(((title like ? or title like ?)";
					@bind=("$key[0]%","% $key[0]%");
					while ($i<$count){
						$query .= " and (title like ? or title like ?)";
						push(@bind,"$key[$i]%","% $key[$i]%");
						$i++;
					}
					$query.=") or ((subtitle like ? or subtitle like ?)";
					push(@bind,"$key[0]%","% $key[0]%");
					for ($i=1;$i<$count;$i++){
						$query.=" and (subtitle like ? or subtitle like ?)";
						push(@bind,"$key[$i]%","% $key[$i]%");
					}
					$query.=") or ((seriestitle like ? or seriestitle like ?)";
					push(@bind,"$key[0]%","% $key[0]%");
					for ($i=1;$i<$count;$i++){
						$query.=" and (seriestitle like ? or seriestitle like ?)";
						push(@bind,"$key[$i]%","% $key[$i]%");
					}
					$query.=") or ((unititle like ? or unititle like ?)";
					push(@bind,"$key[0]%","% $key[0]%");
					for ($i=1;$i<$count;$i++){
						$query.=" and (unititle like ? or unititle like ?)";
						push(@bind,"$key[$i]%","% $key[$i]%");
					}
					$query .= "))";
				}
				if ($search->{'abstract'} ne ''){
					$query.= " and (abstract like ?)";
					push(@bind,"%$search->{'abstract'}%");
				}
				if ($search->{'date-before'} ne ''){
					$query.= " and (copyrightdate like ?)";
					push(@bind,"%$search->{'date-before'}%");
				}
			} elsif ($search->{'class'} ne ''){
				$query="select * from biblioitems,biblio where biblio.biblionumber=biblioitems.biblionumber";
				my @temp=split(/\|/,$search->{'class'});
				my $count=@temp;
				$query.= " and ( itemtype= ?)";
				@bind=($temp[0]);
				for (my $i=1;$i<$count;$i++){
					$query.=" or itemtype=?";
					push(@bind,$temp[$i]);
				}
				$query.=")";
				if ($search->{'illustrator'} ne ''){
					$query.=" and illus like ?";
					push(@bind,"%".$search->{'illustrator'}."%");
				}
				if ($search->{'dewey'} ne ''){
					$query.=" and biblioitems.dewey like ?";
					push(@bind,"$search->{'dewey'}%");
				}
			} elsif ($search->{'dewey'} ne ''){
				$query="select * from biblioitems,biblio
				where biblio.biblionumber=biblioitems.biblionumber
				and biblioitems.dewey like ?";
				@bind=("$search->{'dewey'}%");
			} elsif ($search->{'illustrator'} ne '') {
					$query="select * from biblioitems,biblio
				where biblio.biblionumber=biblioitems.biblionumber
				and biblioitems.illus like ?";
					@bind=("%".$search->{'illustrator'}."%");
			} elsif ($search->{'publisher'} ne ''){
				$query = "Select * from biblio,biblioitems where biblio.biblionumber
				=biblioitems.biblionumber and (publishercode like ?)";
				@bind=("%$search->{'publisher'}%");
			} elsif ($search->{'abstract'} ne ''){
				$query = "Select * from biblio where abstract like ?";
				@bind=("%$search->{'abstract'}%");
			} elsif ($search->{'date-before'} ne ''){
				$query = "Select * from biblio where copyrightdate like ?";
				@bind=("%$search->{'date-before'}%");
			}
			$query .=" group by biblio.biblionumber";
		}
	}
	if ($type eq 'subject'){
		my @key=split(' ',$search->{'subject'});
		my $count=@key;
		my $i=1;
		$query="select * from bibliosubject, biblioitems where
(bibliosubject.biblionumber = biblioitems.biblionumber) and ( subject like ? or subject like ? or subject like ?)";
		@bind=("$key[0]%","% $key[0]%","%($key[0])%");
		while ($i<$count){
			$query.=" and (subject like ? or subject like ? or subject like ?)";
			push(@bind,"$key[$i]%","% $key[$i]%","%($key[$i])%");
			$i++;
		}

		# FIXME - Wouldn't it be better to fix the database so that if a
		# book has a subject "NZ", then it also gets added the subject
		# "New Zealand"?
		# This can also be generalized by adding a table of subject
		# synonyms to the database: just declare "NZ" to be a synonym for
		# "New Zealand", "SF" a synonym for both "Science fiction" and
		# "Fantastic fiction", etc.

		if (lc($search->{'subject'}) eq 'nz'){
			$query.= " or (subject like 'NEW ZEALAND %' or subject like '% NEW ZEALAND %'
			or subject like '% NEW ZEALAND' or subject like '%(NEW ZEALAND)%' ) ";
		} elsif ( $search->{'subject'} =~ /^nz /i || $search->{'subject'} =~ / nz /i || $search->{'subject'} =~ / nz$/i){
			$query=~ s/ nz/ NEW ZEALAND/ig;
			$query=~ s/nz /NEW ZEALAND /ig;
			$query=~ s/\(nz\)/\(NEW ZEALAND\)/gi;
		}
	}
	if ($type eq 'precise'){
		if ($search->{'itemnumber'} ne ''){
			$query="select * from items,biblio ";
			my $search2=uc $search->{'itemnumber'};
			$query=$query." where
			items.biblionumber=biblio.biblionumber
			and barcode=?";
			@bind=($search2);
					# FIXME - .= <<EOT;
		}
		if ($search->{'isbn'} ne ''){
			my $search2=uc $search->{'isbn'};
			my $sth1=$dbh->prepare("select * from biblioitems where isbn=?");
			$sth1->execute($search2);
			my $i2=0;
			while (my $data=$sth1->fetchrow_hashref) {
				my $sth=$dbh->prepare("select * from biblioitems,biblio where
					biblio.biblionumber = ?
					and biblioitems.biblionumber = biblio.biblionumber");
				$sth->execute($data->{'biblionumber'});
				# FIXME - There's already a $data in this scope.
				my $data=$sth->fetchrow_hashref;
				my ($dewey, $subclass) = ($data->{'dewey'}, $data->{'subclass'});
				# FIXME - The following assumes that the Dewey code is a
				# floating-point number. It isn't: it's a string.
				$dewey=~s/\.*0*$//;
				($dewey == 0) && ($dewey='');
				($dewey) && ($dewey.=" $subclass");
				$data->{'dewey'}=$dewey;
				$results[$i2]=$data;
			#           $results[$i2]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}\t$dewey\t$data->{'isbn'}\t$data->{'itemtype'}";
				$i2++;
				$sth->finish;
			}
			$sth1->finish;
		}
	}
	if ($type ne 'precise' && $type ne 'subject'){
		if ($search->{'author'} ne ''){
			$query .= " order by biblio.author,title";
		} else {
			$query .= " order by title";
		}
	} else {
		if ($type eq 'subject'){
			$query .= " group by subject ";
		}
	}
	my $sth=$dbh->prepare($query);
	$sth->execute(@bind);
	my $count=1;
	my $i=0;
	my $limit= $num+$offset;
	while (my $data=$sth->fetchrow_hashref){
		my $query="select classification,dewey,subclass,publishercode from biblioitems where biblionumber=?";
		my @bind=($data->{'biblionumber'});
		if ($search->{'class'} ne ''){
			my @temp=split(/\|/,$search->{'class'});
			my $count=@temp;
			$query.= " and ( itemtype= ?";
			push(@bind,$temp[0]);
			for (my $i=1;$i<$count;$i++){
			$query.=" or itemtype=?";
			push(@bind,$temp[$i]);
			}
			$query.=")";
		}
		if ($search->{'dewey'} ne ''){
			$query.=" and dewey=? ";
			push(@bind,$search->{'dewey'});
		}
		if ($search->{'illustrator'} ne ''){
			$query.=" and illus like ?";
			push(@bind,"%$search->{'illustrator'}%");
		}
		if ($search->{'publisher'} ne ''){
			$query.= " and (publishercode like ?)";
			push(@bind,"%$search->{'publisher'}%");
		}
		my $sti=$dbh->prepare($query);
		$sti->execute(@bind);
		my $classification;
		my $dewey;
		my $subclass;
		my $true=0;
		my $publishercode;
		my $bibitemdata;
		if ($bibitemdata = $sti->fetchrow_hashref()){
			$true=1;
			$classification=$bibitemdata->{'classification'};
			$dewey=$bibitemdata->{'dewey'};
			$subclass=$bibitemdata->{'subclass'};
			$publishercode=$bibitemdata->{'publishercode'};
		}
		#  print STDERR "$dewey $subclass $publishercode\n";
		# FIXME - The Dewey code is a string, not a number.
		$dewey=~s/\.*0*$//;
		($dewey == 0) && ($dewey='');
		($dewey) && ($dewey.=" $subclass");
		$data->{'classification'}=$classification;
		$data->{'dewey'}=$dewey;
		$data->{'publishercode'}=$publishercode;
		$sti->finish;
		if ($true == 1){
			if ($count > $offset && $count <= $limit){
				$results[$i]=$data;
				$i++;
			}
			$count++;
		}
	}
	$sth->finish;
	$count--;
	return($count,@results);
}

=item subsearch

  @results = &subsearch($env, $subject);

Searches for books that have a subject that exactly matches
C<$subject>.

C<&subsearch> returns an array of results. Each element of this array
is a string, containing the book's title, author, and biblionumber,
separated by tabs.

C<$env> is ignored.

=cut
#'
sub subsearch {
  my ($env,$subject)=@_;
  my $dbh = C4::Context->dbh;
  my $sth=$dbh->prepare("Select * from biblio,bibliosubject where
  biblio.biblionumber=bibliosubject.biblionumber and
  bibliosubject.subject=? group by biblio.biblionumber
  order by biblio.title");
  $sth->execute($subject);
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    push @results, $data;
    $i++;
  }
  $sth->finish;
  return(@results);
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
