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

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.02;

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
@EXPORT = qw(&CatSearch &BornameSearch &ItemInfo &KeywordSearch &subsearch
&itemdata &bibdata &GetItems &borrdata &itemnodata &itemcount
&borrdata2 &NewBorrowerNumber &bibitemdata &borrissues
&getboracctrecord &ItemType &itemissues &subject &subtitle
&addauthor &bibitems &barcodes &findguarantees &allissues
&findguarantor &getwebsites &getwebbiblioitems &catalogsearch &itemcount2
&isbnsearch &breedingsearch);
# make all your functions, whether exported or not;

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
  my $query="select cardnumber,borrowernumber from borrowers where
  guarantor='$bornum'";
  my $sth=$dbh->prepare($query);
  $sth->execute;

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
  my $query="select guarantor from borrowers where
  borrowernumber='$bornum'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $query="Select * from borrowers where
  borrowernumber='$data->{'guarantor'}'";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
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
	#  print STDERR "Doing a search \n";
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
			my $notavailabletext='';
			foreach (sort keys %{$data->{'locationhash'}}) {
				if ($_ eq 'notavailable') {
					$notavailabletext="Not available";
					my $c=$data->{'locationhash'}->{$_};
					if ($totalitemcounts>1) {
					$notavailabletext.=" ($c)";
					}
				} else {
					$locationtext.="$_";
					my $c=$data->{'locationhash'}->{$_};
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
			$data->{'subject2'}=$subject2;
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
  $search->{'keyword'}=~ s/'/\\'/;
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
    foreach my $field (qw(title notes seriestitle))
    {
      push @subclauses,
	"$field LIKE '\Q$keyword\E%' OR $field LIKE '% \Q$keyword\E%'";
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
  $sth->execute;
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
  $query = "SELECT biblionumber FROM bibliosubtitle WHERE ";
  foreach my $keyword (@key)
  {
    push @clauses,
	"subtitle LIKE '\Q$keyword\E%' OR subtitle like '% \Q$keyword\E%'";
  }
  $query .= "(" . join(") AND (", @clauses) . ")";

  $sth=$dbh->prepare($query);
  $sth->execute;
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
  $query = "SELECT biblionumber FROM biblioitems WHERE ";
  foreach my $keyword (@key)
  {
    push @clauses,
	"notes LIKE '\Q$keyword\E%' OR notes like '% \Q$keyword\E%'";
  }
  $query .= "(" . join(") AND (", @clauses) . ")";

  $sth=$dbh->prepare($query);
  $sth->execute;
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
  like '%$search->{'keyword'}%' group by biblionumber");
  $sth->execute;

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
      biblio.biblionumber='$res[$i2]' and
      biblio.biblionumber=biblioitems.biblionumber ";
      if ($search->{'class'} ne ''){	# FIXME - Redundant
      my @temp=split(/\|/,$search->{'class'});
      my $count=@temp;
      $query.= "and ( itemtype='$temp[0]'";
      for (my $i=1;$i<$count;$i++){
        $query.=" or itemtype='$temp[$i]'";
      }
      $query.=")";
      }
       my $sth=$dbh->prepare($query);
       #    print $query;
       $sth->execute;
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
    biblio.biblionumber='$res[$i2+$offset]' and
    biblio.biblionumber=biblioitems.biblionumber ";

    if ($search->{'dewey'} ne ''){
      $query.= "and (dewey like '$search->{'dewey'}%') ";
    }

    my $sth=$dbh->prepare($query);
#    print $query;
    $sth->execute;
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

sub KeywordSearch2 {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = C4::Context->dbh;
  $search->{'keyword'}=~ s/ +$//;
  $search->{'keyword'}=~ s/'/\\'/;
  my @key=split(' ',$search->{'keyword'});
  my $count=@key;
  my $i=1;
  my @results;
  my $query ="Select * from biblio,bibliosubtitle,biblioitems where
  biblio.biblionumber=biblioitems.biblionumber and
  biblio.biblionumber=bibliosubtitle.biblionumber and
  (((title like '$key[0]%' or title like '% $key[0]%')";
  while ($i < $count){
    $query .= " and (title like '$key[$i]%' or title like '% $key[$i]%')";
    $i++;
  }
  $query.= ") or ((subtitle like '$key[0]%' or subtitle like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.= " and (subtitle like '$key[$i]%' or subtitle like '% $key[$i]%')";
  }
  $query.= ") or ((seriestitle like '$key[0]%' or seriestitle like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.=" and (seriestitle like '$key[$i]%' or seriestitle like '% $key[$i]%')";
  }
  $query.= ") or ((biblio.notes like '$key[0]%' or biblio.notes like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.=" and (biblio.notes like '$key[$i]%' or biblio.notes like '% $key[$i]%')";
  }
  $query.= ") or ((biblioitems.notes like '$key[0]%' or biblioitems.notes like '% $key[0]%')";
  for ($i=1;$i<$count;$i++){
    $query.=" and (biblioitems.notes like '$key[$i]%' or biblioitems.notes like '% $key[$i]%')";
  }
  if ($search->{'keyword'} =~ /new zealand/i){
    $query.= "or (title like 'nz%' or title like '% nz %' or title like '% nz' or subtitle like 'nz%'
    or subtitle like '% nz %' or subtitle like '% nz' or author like 'nz %'
    or author like '% nz %' or author like '% nz')"
  }
  if ($search->{'keyword'} eq  'nz' || $search->{'keyword'} eq 'NZ' ||
  $search->{'keyword'} =~ /nz /i || $search->{'keyword'} =~ / nz /i ||
  $search->{'keyword'} =~ / nz/i){
    $query.= "or (title like 'new zealand%' or title like '% new zealand %'
    or title like '% new zealand' or subtitle like 'new zealand%' or
    subtitle like '% new zealand %'
    or subtitle like '% new zealand' or author like 'new zealand%'
    or author like '% new zealand %' or author like '% new zealand' or
    seriestitle like 'new zealand%' or seriestitle like '% new zealand %'
    or seriestitle like '% new zealand')"
  }
  $query .= "))";
  if ($search->{'class'} ne ''){
    my @temp=split(/\|/,$search->{'class'});
    my $count=@temp;
    $query.= "and ( itemtype='$temp[0]'";
    for (my $i=1;$i<$count;$i++){
      $query.=" or itemtype='$temp[$i]'";
     }
  $query.=")";
  }
  if ($search->{'dewey'} ne ''){
    $query.= "and (dewey like '$search->{'dewey'}%') ";
  }
   $query.="group by biblio.biblionumber";
   #$query.=" order by author,title";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $i=0;
  while (my $data=$sth->fetchrow_hashref){
#    my $sti=$dbh->prepare("select dewey,subclass from biblioitems where biblionumber=$data->{'biblionumber'}
#    ");
#    $sti->execute;
#    my ($dewey, $subclass) = $sti->fetchrow;
    my $dewey=$data->{'dewey'};
    my $subclass=$data->{'subclass'};
    $dewey=~s/\.*0*$//;
    ($dewey == 0) && ($dewey='');
    ($dewey) && ($dewey.=" $subclass");
#    $sti->finish;
    $results[$i]="$data->{'author'}\t$data->{'title'}\t$data->{'biblionumber'}\t$data->{'copyrightdate'}\t$dewey";
#      print $results[$i];
    $i++;
  }
  $sth->finish;
  $sth=$dbh->prepare("Select biblionumber from bibliosubject where subject
  like '%$search->{'keyword'}%' group by biblionumber");
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $query="Select * from biblio,biblioitems where
    biblio.biblionumber=$data->{'biblionumber'} and
    biblio.biblionumber=biblioitems.biblionumber ";
    if ($search->{'class'} ne ''){
      my @temp=split(/\|/,$search->{'class'});
      my $count=@temp;
      $query.= " and ( itemtype='$temp[0]'";
      for (my $i=1;$i<$count;$i++){
        $query.=" or itemtype='$temp[$i]'";
      }
      $query.=")";

    }
    if ($search->{'dewey'} ne ''){
      $query.= "and (dewey like '$search->{'dewey'}%') ";
    }
    my $sth2=$dbh->prepare($query);
    $sth2->execute;
#    print $query;
    while (my $data2=$sth2->fetchrow_hashref){
      my $dewey= $data2->{'dewey'};
      my $subclass=$data2->{'subclass'};
      $dewey=~s/\.*0*$//;
      ($dewey == 0) && ($dewey='');
      ($dewey) && ($dewey.=" $subclass") ;
#      $sti->finish;
       $results[$i]="$data2->{'author'}\t$data2->{'title'}\t$data2->{'biblionumber'}\t$data2->{'copyrightdate'}\t$dewey";
#      print $results[$i];
      $i++;
    }
    $sth2->finish;
  }
  my $i2=1;
  @results=sort @results;
  my @res;
  $count=@results;
  $i=1;
  if ($count > 0){
    $res[0]=$results[0];
  }
  while ($i2 < $count){
    if ($results[$i2] ne $res[$i-1]){
      $res[$i]=$results[$i2];
      $i++;
    }
    $i2++;
  }
  $i2=0;
  my @res2;
  $count=@res;
  while ($i2 < $num && $i2 < $count){
    $res2[$i2]=$res[$i2+$offset];
#    print $res2[$i2];
    $i2++;
  }
  $sth->finish;
#  $i--;
#  $i++;
  return($i,@res2);
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
	warn "type = $type";
	my $dbh = C4::Context->dbh;
	my $query = '';
	my @results;

	# Why not just use quotemeta to escape all questionable characters,
	# not just single-quotes? Because that would also escape spaces,
	# which would cause titles/authors/illustrators with a space to
	# become unsearchable (Bug 197)

	for my $field ('title', 'author', 'illustrator') {
	    $search->{$field} =~ s/['"]/\\\1/g;
	}

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
							((biblio.author like '$key[0]%' or biblio.author like '% $key[0]%' or
							additionalauthors.author like '$key[0]%' or additionalauthors.author
							like '% $key[0]%'
								)";
			while ($i < $count){
					$query .= " and (
									biblio.author like '$key[$i]%' or biblio.author like '% $key[$i]%' or
									additionalauthors.author like '$key[$i]%' or additionalauthors.author like '% $key[$i]%'
									)";
				$i++;
			}
			$query .= ")";
			if ($search->{'title'} ne ''){
				my @key=split(' ',$search->{'title'});
				my $count=@key;
				my $i=0;
				$query.= " and (((title like '$key[0]%' or title like '% $key[0]%' or title like '% $key[0]')";
				while ($i<$count){
					$query .= " and (title like '$key[$i]%' or title like '% $key[$i]%' or title like '% $key[$i]')";
					$i++;
				}
				$query.=") or ((seriestitle like '$key[0]%' or seriestitle like '% $key[0]%' or seriestitle like '% $key[0]')";
				for ($i=1;$i<$count;$i++){
					$query.=" and (seriestitle like '$key[$i]%' or seriestitle like '% $key[$i]%')";
					}
				$query.=") or ((unititle like '$key[0]%' or unititle like '% $key[0]%' or unititle like '% $key[0]')";
				for ($i=1;$i<$count;$i++){
					$query.=" and (unititle like '$key[$i]%' or unititle like '% $key[$i]%')";
					}
				$query .= "))";
				#$query=$query. " and (title like '%$search->{'title'}%'
				#or seriestitle like '%$search->{'title'}%')";
			}
			if ($search->{'abstract'} ne ''){
				$query.= " and (abstract like '%$search->{'abstract'}%')";
			}
			if ($search->{'date-before'} ne ''){
				$query.= " and (copyrightdate like '%$search->{'date-before'}%')";
			}
			$query.=" group by biblio.biblionumber";
		} else {
			if ($search->{'title'} ne '') {
				if ($search->{'ttype'} eq 'exact'){
					$query="select * from biblio
					where
					(biblio.title='$search->{'title'}' or (biblio.unititle = '$search->{'title'}'
					or biblio.unititle like '$search->{'title'} |%' or
					biblio.unititle like '%| $search->{'title'} |%' or
					biblio.unititle like '%| $search->{'title'}') or
					(biblio.seriestitle = '$search->{'title'}' or
					biblio.seriestitle like '$search->{'title'} |%' or
					biblio.seriestitle like '%| $search->{'title'} |%' or
					biblio.seriestitle like '%| $search->{'title'}')
					)";
				} else {
					my @key=split(' ',$search->{'title'});
					my $count=@key;
					my $i=1;
					$query="select biblio.biblionumber,author,title,unititle,notes,abstract,serial,seriestitle,copyrightdate,timestamp,subtitle from biblio
					left join bibliosubtitle on
					biblio.biblionumber=bibliosubtitle.biblionumber
					where
					(((title like '$key[0]%' or title like '% $key[0]%' or title like '% $key[0]')";
					while ($i<$count){
						$query .= " and (title like '$key[$i]%' or title like '% $key[$i]%' or title like '% $key[$i]')";
						$i++;
					}
					$query.=") or ((subtitle like '$key[0]%' or subtitle like '% $key[0]%' or subtitle like '% $key[0]')";
					for ($i=1;$i<$count;$i++){
						$query.=" and (subtitle like '$key[$i]%' or subtitle like '% $key[$i]%' or subtitle like '% $key[$i]')";
					}
					$query.=") or ((seriestitle like '$key[0]%' or seriestitle like '% $key[0]%' or seriestitle like '% $key[0]')";
					for ($i=1;$i<$count;$i++){
						$query.=" and (seriestitle like '$key[$i]%' or seriestitle like '% $key[$i]%')";
					}
					$query.=") or ((unititle like '$key[0]%' or unititle like '% $key[0]%' or unititle like '% $key[0]')";
					for ($i=1;$i<$count;$i++){
						$query.=" and (unititle like '$key[$i]%' or unititle like '% $key[$i]%')";
					}
					$query .= "))";
				}
				if ($search->{'abstract'} ne ''){
					$query.= " and (abstract like '%$search->{'abstract'}%')";
				}
				if ($search->{'date-before'} ne ''){
					$query.= " and (copyrightdate like '%$search->{'date-before'}%')";
				}
			} elsif ($search->{'class'} ne ''){
				$query="select * from biblioitems,biblio where biblio.biblionumber=biblioitems.biblionumber";
				my @temp=split(/\|/,$search->{'class'});
				my $count=@temp;
				$query.= " and ( itemtype='$temp[0]'";
				for (my $i=1;$i<$count;$i++){
					$query.=" or itemtype='$temp[$i]'";
				}
				$query.=")";
				if ($search->{'illustrator'} ne ''){
					$query.=" and illus like '%".$search->{'illustrator'}."%' ";
				}
				if ($search->{'dewey'} ne ''){
					$query.=" and biblioitems.dewey like '$search->{'dewey'}%'";
				}
			} elsif ($search->{'dewey'} ne ''){
				$query="select * from biblioitems,biblio
				where biblio.biblionumber=biblioitems.biblionumber
				and biblioitems.dewey like '$search->{'dewey'}%'";
			} elsif ($search->{'illustrator'} ne '') {
					$query="select * from biblioitems,biblio
				where biblio.biblionumber=biblioitems.biblionumber
				and biblioitems.illus like '%".$search->{'illustrator'}."%'";
			} elsif ($search->{'publisher'} ne ''){
				$query.= "Select * from biblio,biblioitems where biblio.biblionumber
				=biblioitems.biblionumber and (publishercode like '%$search->{'publisher'}%')";
			} elsif ($search->{'abstract'} ne ''){
				$query.= "Select * from biblio where abstract like '%$search->{'abstract'}%'";
			} elsif ($search->{'date-before'} ne ''){
				$query.= "Select * from biblio where copyrightdate like '%$search->{'date-before'}%'";
			}
			$query .=" group by biblio.biblionumber";
		}
	}
	if ($type eq 'subject'){
		# FIXME - Subject search is badly broken. The query defined by
		# $query returns a single item (the subject), but later code
		# expects a ref-to-hash with all sorts of stuff in it.
		# Also, the count of items (biblios?) with the given subject is
		# wrong.

		my @key=split(' ',$search->{'subject'});
		my $count=@key;
		my $i=1;
		$query="select distinct(subject) from bibliosubject where( subject like
		'$key[0]%' or subject like '% $key[0]%' or subject like '% $key[0]' or subject like '%($key[0])%')";
		while ($i<$count){
			$query.=" and (subject like '$key[$i]%' or subject like '% $key[$i]%'
			or subject like '% $key[$i]'
			or subject like '%($key[$i])%')";
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
			and barcode='$search2'";
					# FIXME - .= <<EOT;
		}
		if ($search->{'isbn'} ne ''){
			my $search2=uc $search->{'isbn'};
			my $query1 = "select * from biblioitems where isbn='$search2'";
			my $sth1=$dbh->prepare($query1);
		#	print STDERR "$query1\n";
			$sth1->execute;
			my $i2=0;
			while (my $data=$sth1->fetchrow_hashref) {
				$query="select * from biblioitems,biblio where
					biblio.biblionumber = $data->{'biblionumber'}
					and biblioitems.biblionumber = biblio.biblionumber";
				my $sth=$dbh->prepare($query);
				$sth->execute;
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
			$query .= " order by subject";
		}
	}
	my $sth=$dbh->prepare($query);
	$sth->execute;
	my $count=1;
	my $i=0;
	my $limit= $num+$offset;
	while (my $data=$sth->fetchrow_hashref){
		my $query="select dewey,subclass,publishercode from biblioitems where biblionumber=$data->{'biblionumber'}";
		if ($search->{'class'} ne ''){
			my @temp=split(/\|/,$search->{'class'});
			my $count=@temp;
			$query.= " and ( itemtype='$temp[0]'";
			for (my $i=1;$i<$count;$i++){
			$query.=" or itemtype='$temp[$i]'";
			}
			$query.=")";
		}
		if ($search->{'dewey'} ne ''){
			$query.=" and dewey='$search->{'dewey'}' ";
		}
		if ($search->{'illustrator'} ne ''){
			$query.=" and illus like '%".$search->{'illustrator'}."%' ";
		}
		if ($search->{'publisher'} ne ''){
			$query.= " and (publishercode like '%$search->{'publisher'}%')";
		}
		warn $query;
		my $sti=$dbh->prepare($query);
		$sti->execute;
		my $dewey;
		my $subclass;
		my $true=0;
		my $publishercode;
		my $bibitemdata;
		if ($bibitemdata = $sti->fetchrow_hashref() || $type eq 'subject'){
			$true=1;
			$dewey=$bibitemdata->{'dewey'};
			$subclass=$bibitemdata->{'subclass'};
			$publishercode=$bibitemdata->{'publishercode'};
		}
		#  print STDERR "$dewey $subclass $publishercode\n";
		# FIXME - The Dewey code is a string, not a number.
		$dewey=~s/\.*0*$//;
		($dewey == 0) && ($dewey='');
		($dewey) && ($dewey.=" $subclass");
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

sub updatesearchstats{
  my ($dbh,$query)=@_;

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
  $subject=$dbh->quote($subject);
  my $query="Select * from biblio,bibliosubject where
  biblio.biblionumber=bibliosubject.biblionumber and
  bibliosubject.subject=$subject group by biblio.biblionumber
  order by biblio.title";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $i=0;
#  print $query;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]="$data->{'title'}\t$data->{'author'}\t$data->{'biblionumber'}";
    $i++;
  }
  $sth->finish;
  return(@results);
}

=item ItemInfo

  @results = &ItemInfo($env, $biblionumber, $type);

Returns information about books with the given biblionumber.

C<$type> may be either C<intra> or anything else. If it is not set to
C<intra>, then the search will exclude lost, very overdue, and
withdrawn items.

C<$env> is ignored.

C<&ItemInfo> returns a list of references-to-hash. Each element
contains a number of keys. Most of them are table items from the
C<biblio>, C<biblioitems>, C<items>, and C<itemtypes> tables in the
Koha database. Other keys include:

=over 4

=item C<$data-E<gt>{branchname}>

The name (not the code) of the branch to which the book belongs.

=item C<$data-E<gt>{datelastseen}>

This is simply C<items.datelastseen>, except that while the date is
stored in YYYY-MM-DD format in the database, here it is converted to
DD/MM/YYYY format. A NULL date is returned as C<//>.

=item C<$data-E<gt>{datedue}>

=item C<$data-E<gt>{class}>

This is the concatenation of C<biblioitems.classification>, the book's
Dewey code, and C<biblioitems.subclass>.

=item C<$data-E<gt>{ocount}>

I think this is the number of copies of the book available.

=item C<$data-E<gt>{order}>

If this is set, it is set to C<One Order>.

=back

=cut
#'
sub ItemInfo {
    my ($env,$biblionumber,$type) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT * FROM items, biblio, biblioitems, itemtypes
                  WHERE items.biblionumber = ?
                    AND biblioitems.biblioitemnumber = items.biblioitemnumber
                    AND biblioitems.itemtype = itemtypes.itemtype
                    AND biblio.biblionumber = items.biblionumber";
  if ($type ne 'intra'){
    $query .= " and ((items.itemlost<>1 and items.itemlost <> 2)
    or items.itemlost is NULL)
    and (wthdrawn <> 1 or wthdrawn is NULL)";
  }
  $query .= " order by items.dateaccessioned desc";
    #warn $query;
  my $sth=$dbh->prepare($query);
  $sth->execute($biblionumber);
  my $i=0;
  my @results;
#  print $query;
  while (my $data=$sth->fetchrow_hashref){
    my $iquery = "Select * from issues
    where itemnumber = '$data->{'itemnumber'}'
    and returndate is null";
    my $datedue = '';
    my $isth=$dbh->prepare($iquery);
    $isth->execute;
    if (my $idata=$isth->fetchrow_hashref){
      # FIXME - The date ought to be properly parsed, and printed
      # according to local convention.
      my @temp=split('-',$idata->{'date_due'});
      $datedue = "$temp[2]/$temp[1]/$temp[0]";
    }
    if ($data->{'itemlost'} eq '2'){
        $datedue='Very Overdue';
    }
    if ($data->{'itemlost'} eq '1'){
        $datedue='Lost';
    }
    if ($data->{'wthdrawn'} eq '1'){
	$datedue="Cancelled";
    }
    if ($datedue eq ''){
	$datedue="Available";
	my ($restype,$reserves)=CheckReserves($data->{'itemnumber'});
	if ($restype){
	    $datedue=$restype;
	}
    }
    $isth->finish;
#get branch information.....
    my $bquery = "SELECT * FROM branches
                          WHERE branchcode = '$data->{'holdingbranch'}'";
    my $bsth=$dbh->prepare($bquery);
    $bsth->execute;
    if (my $bdata=$bsth->fetchrow_hashref){
	$data->{'branchname'} = $bdata->{'branchname'};
    }

    my $class = $data->{'classification'};
    my $dewey = $data->{'dewey'};
    $dewey =~ s/0+$//;
    if ($dewey eq "000.") { $dewey = "";};	# FIXME - "000" is general
						# books about computer science
    if ($dewey < 10){$dewey='00'.$dewey;}
    if ($dewey < 100 && $dewey > 10){$dewey='0'.$dewey;}
    if ($dewey <= 0){
      $dewey='';
    }
    $dewey=~ s/\.$//;
    $class .= $dewey;
    if ($dewey ne ''){
      $class .= $data->{'subclass'};
    }
 #   $results[$i]="$data->{'title'}\t$data->{'barcode'}\t$datedue\t$data->{'branchname'}\t$data->{'dewey'}";
    # FIXME - If $data->{'datelastseen'} is NULL, perhaps it'd be prettier
    # to leave it empty, rather than convert it to "//".
    # Also ideally this should use the local format for displaying dates.
    my @temp=split('-',$data->{'datelastseen'});
    my $date="$temp[2]/$temp[1]/$temp[0]";
    $data->{'datelastseen'}=$date;
    $data->{'datedue'}=$datedue;
    $data->{'class'}=$class;
    $results[$i]=$data;
    $i++;
  }
 $sth->finish;
  my $query2="Select * from aqorders where biblionumber=$biblionumber";
  my $sth2=$dbh->prepare($query2);
  $sth2->execute;
  my $data;
  my $ocount;
  if ($data=$sth2->fetchrow_hashref){
    $ocount=$data->{'quantity'} - $data->{'quantityreceived'};
    if ($ocount > 0){
      $data->{'ocount'}=$ocount;
      $data->{'order'}="One Order";
      $results[$i]=$data;
    }
  }
  $sth2->finish;

  return(@results);
}

=item GetItems

  @results = &GetItems($env, $biblionumber);

Returns information about books with the given biblionumber.

C<$env> is ignored.

C<&GetItems> returns an array of strings. Each element is a
tab-separated list of values: biblioitemnumber, itemtype,
classification, Dewey number, subclass, ISBN, volume, number, and
itemdata.

Itemdata, in turn, is a string of the form
"I<barcode>C<[>I<holdingbranch>C<[>I<flags>" where I<flags> contains
the string C<NFL> if the item is not for loan, and C<LOST> if the item
is lost.

=cut
#'
sub GetItems {
   my ($env,$biblionumber)=@_;
   #debug_msg($env,"GetItems");
   my $dbh = C4::Context->dbh;
   my $query = "Select * from biblioitems where (biblionumber = $biblionumber)";
   #debug_msg($env,$query);
   my $sth=$dbh->prepare($query);
   $sth->execute;
   #debug_msg($env,"executed query");
   my $i=0;
   my @results;
   while (my $data=$sth->fetchrow_hashref) {
      #debug_msg($env,$data->{'biblioitemnumber'});
      my $dewey = $data->{'dewey'};
      $dewey =~ s/0+$//;
      my $line = $data->{'biblioitemnumber'}."\t".$data->{'itemtype'};
      $line .= "\t$data->{'classification'}\t$dewey";
      $line .= "\t$data->{'subclass'}\t$data->{isbn}";
      $line .= "\t$data->{'volume'}\t$data->{number}";
      my $isth= $dbh->prepare("select * from items where biblioitemnumber = $data->{'biblioitemnumber'}");
      $isth->execute;
      while (my $idata = $isth->fetchrow_hashref) {
        my $iline = $idata->{'barcode'}."[".$idata->{'holdingbranch'}."[";
	if ($idata->{'notforloan'} == 1) {
	  $iline .= "NFL ";
	}
	if ($idata->{'itemlost'} == 1) {
	  $iline .= "LOST ";
	}
        $line .= "\t$iline";
      }
      $isth->finish;
      $results[$i] = $line;
      $i++;
   }
   $sth->finish;
   return(@results);
}

=item itemdata

  $item = &itemdata($barcode);

Looks up the item with the given barcode, and returns a
reference-to-hash containing information about that item. The keys of
the hash are the fields from the C<items> and C<biblioitems> tables in
the Koha database.

=cut
#'
sub itemdata {
  my ($barcode)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from items,biblioitems where barcode='$barcode'
  and items.biblioitemnumber=biblioitems.biblioitemnumber";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

=item bibdata

  $data = &bibdata($biblionumber, $type);

Returns information about the book with the given biblionumber.

C<$type> is ignored.

C<&bibdata> returns a reference-to-hash. The keys are the fields in
the C<biblio>, C<biblioitems>, and C<bibliosubtitle> tables in the
Koha database.

In addition, C<$data-E<gt>{subject}> is the list of the book's
subjects, separated by C<" , "> (space, comma, space).

If there are multiple biblioitems with the given biblionumber, only
the first one is considered.

=cut
#'
sub bibdata {
    my ($bibnum, $type) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select *, biblio.notes
    from biblio, biblioitems
    left join bibliosubtitle on
    biblio.biblionumber = bibliosubtitle.biblionumber
    where biblio.biblionumber = $bibnum
    and biblioitems.biblionumber = $bibnum";
    my $sth   = $dbh->prepare($query);
    my $data;

    $sth->execute;
    $data  = $sth->fetchrow_hashref;
    $sth->finish;

    $query = "Select * from bibliosubject where biblionumber = '$bibnum'";
    $sth   = $dbh->prepare($query);
    $sth->execute;
    while (my $dat = $sth->fetchrow_hashref){
        $data->{'subject'} .= " , $dat->{'subject'}";
    } # while

    $sth->finish;
    return($data);
} # sub bibdata

=item bibitemdata

  $itemdata = &bibitemdata($biblioitemnumber);

Looks up the biblioitem with the given biblioitemnumber. Returns a
reference-to-hash. The keys are the fields from the C<biblio>,
C<biblioitems>, and C<itemtypes> tables in the Koha database, except
that C<biblioitems.notes> is given as C<$itemdata-E<gt>{bnotes}>.

=cut
#'
sub bibitemdata {
    my ($bibitem) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select *,biblioitems.notes as bnotes from biblio, biblioitems,itemtypes
where biblio.biblionumber = biblioitems.biblionumber
and biblioitemnumber = $bibitem
and biblioitems.itemtype = itemtypes.itemtype";
    my $sth   = $dbh->prepare($query);
    my $data;

    $sth->execute;

    $data = $sth->fetchrow_hashref;

    $sth->finish;
    return($data);
} # sub bibitemdata

=item subject

  ($count, $subjects) = &subject($biblionumber);

Looks up the subjects of the book with the given biblionumber. Returns
a two-element list. C<$subjects> is a reference-to-array, where each
element is a subject of the book, and C<$count> is the number of
elements in C<$subjects>.

=cut
#'
sub subject {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from bibliosubject where biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}

=item addauthor

  ($count, $authors) = &addauthors($biblionumber);

Looks up the additional authors for the book with the given
biblionumber.

Returns a two-element list. C<$authors> is a reference-to-array, where
each element is an additional author, and C<$count> is the number of
elements in C<$authors>.

=cut
#'
sub addauthor {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from additionalauthors where biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}

=item subtitle

  ($count, $subtitles) = &subtitle($biblionumber);

Looks up the subtitles for the book with the given biblionumber.

Returns a two-element list. C<$subtitles> is a reference-to-array,
where each element is a subtitle, and C<$count> is the number of
elements in C<$subtitles>.

=cut
#'
sub subtitle {
  my ($bibnum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from bibliosubtitle where biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  return($i,\@results);
}

=item itemissues

  @issues = &itemissues($biblioitemnumber, $biblio);

Looks up information about who has borrowed the bookZ<>(s) with the
given biblioitemnumber.

C<$biblio> is ignored.

C<&itemissues> returns an array of references-to-hash. The keys
include the fields from the C<items> table in the Koha database.
Additional keys include:

=over 4

=item C<date_due>

If the item is currently on loan, this gives the due date.

If the item is not on loan, then this is either "Available" or
"Cancelled", if the item has been withdrawn.

=item C<card>

If the item is currently on loan, this gives the card number of the
patron who currently has the item.

=item C<timestamp0>, C<timestamp1>, C<timestamp2>

These give the timestamp for the last three times the item was
borrowed.

=item C<card0>, C<card1>, C<card2>

The card number of the last three patrons who borrowed this item.

=item C<borrower0>, C<borrower1>, C<borrower2>

The borrower number of the last three patrons who borrowed this item.

=back

=cut
#'
sub itemissues {
    my ($bibitem, $biblio)=@_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select * from items where
items.biblioitemnumber = '$bibitem'";
    # FIXME - If this function die()s, the script will abort, and the
    # user won't get anything; depending on how far the script has
    # gotten, the user might get a blank page. It would be much better
    # to at least print an error message. The easiest way to do this
    # is to set $SIG{__DIE__}.
    my $sth   = $dbh->prepare($query)
      || die $dbh->errstr;
    my $i     = 0;
    my @results;

    $sth->execute
      || die $sth->errstr;

    while (my $data = $sth->fetchrow_hashref) {
        # Find out who currently has this item.
        # FIXME - Wouldn't it be better to do this as a left join of
        # some sort? Currently, this code assumes that if
        # fetchrow_hashref() fails, then the book is on the shelf.
        # fetchrow_hashref() can fail for any number of reasons (e.g.,
        # database server crash), not just because no items match the
        # search criteria.
        my $query2 = "select * from issues,borrowers
where itemnumber = $data->{'itemnumber'}
and returndate is NULL
and issues.borrowernumber = borrowers.borrowernumber";
        my $sth2   = $dbh->prepare($query2);

        $sth2->execute;
        if (my $data2 = $sth2->fetchrow_hashref) {
            $data->{'date_due'} = $data2->{'date_due'};
            $data->{'card'}     = $data2->{'cardnumber'};
        } else {
            if ($data->{'wthdrawn'} eq '1') {
                $data->{'date_due'} = 'Cancelled';
            } else {
                $data->{'date_due'} = 'Available';
            } # else
        } # else

        $sth2->finish;

        # Find the last 3 people who borrowed this item.
        $query2 = "select * from issues, borrowers
						where itemnumber = ?
									and issues.borrowernumber = borrowers.borrowernumber
									and returndate is not NULL
									order by returndate desc,timestamp desc";
warn "$query2";
        $sth2 = $dbh->prepare($query2) || die $dbh->errstr;
        $sth2->execute($data->{'itemnumber'}) || die $sth2->errstr;
        for (my $i2 = 0; $i2 < 2; $i2++) { # FIXME : error if there is less than 3 pple borrowing this item
            if (my $data2 = $sth2->fetchrow_hashref) {
                $data->{"timestamp$i2"} = $data2->{'timestamp'};
                $data->{"card$i2"}      = $data2->{'cardnumber'};
                $data->{"borrower$i2"}  = $data2->{'borrowernumber'};
            } # if
        } # for

        $sth2->finish;
        $results[$i] = $data;
        $i++;
    }

    $sth->finish;
    return(@results);
}

=item itemnodata

  $item = &itemnodata($env, $dbh, $biblioitemnumber);

Looks up the item with the given biblioitemnumber.

C<$env> and C<$dbh> are ignored.

C<&itemnodata> returns a reference-to-hash whose keys are the fields
from the C<biblio>, C<biblioitems>, and C<items> tables in the Koha
database.

=cut
#'
sub itemnodata {
  my ($env,$dbh,$itemnumber) = @_;
  $dbh = C4::Context->dbh;
  my $query="Select * from biblio,items,biblioitems
    where items.itemnumber = '$itemnumber'
    and biblio.biblionumber = items.biblionumber
    and biblioitems.biblioitemnumber = items.biblioitemnumber";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

=item BornameSearch

  ($count, $borrowers) = &BornameSearch($env, $searchstring, $type);

Looks up patrons (borrowers) by name.

C<$env> and C<$type> are ignored.

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
  my ($env,$searchstring,$type)=@_;
  my $dbh = C4::Context->dbh;
  $searchstring=~ s/\'/\\\'/g;
  my @data=split(' ',$searchstring);
  my $count=@data;
  my $query="Select * from borrowers
  where ((surname like \"$data[0]%\" or surname like \"% $data[0]%\"
  or firstname  like \"$data[0]%\" or firstname like \"% $data[0]%\"
  or othernames like \"$data[0]%\" or othernames like \"% $data[0]%\")
  ";
  for (my $i=1;$i<$count;$i++){
    $query=$query." and (surname like \"$data[$i]%\" or surname like \"% $data[$i]%\"
    or firstname  like \"$data[$i]%\" or firstname like \"% $data[$i]%\"
    or othernames like \"$data[$i]%\" or othernames like \"% $data[$i]%\")";
			# FIXME - .= <<EOT;
  }
  $query=$query.") or cardnumber = \"$searchstring\"
  order by surname,firstname";
			# FIXME - .= <<EOT;
#  print $query,"\n";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $cnt=0;
  while (my $data=$sth->fetchrow_hashref){
    push(@results,$data);
    $cnt ++;
  }
#  $sth->execute;
  $sth->finish;
  return ($cnt,\@results);
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
  my $query;
  if ($bornum eq ''){
    $query="Select * from borrowers where cardnumber='$cardnumber'";
  } else {
      $query="Select * from borrowers where borrowernumber='$bornum'";
  }
  #print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
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
  my $query;
  $query="Select * from issues,biblio,items where borrowernumber='$bornum' and
items.itemnumber=issues.itemnumber and
items.biblionumber=biblio.biblionumber and issues.returndate is NULL order
by date_due";
  #print $query;
  my $sth=$dbh->prepare($query);
    $sth->execute;
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
  my $dbh = C4::Context->dbh;
  my $query;
  $query="Select * from issues,biblio,items,biblioitems
  where borrowernumber='$bornum' and
  items.biblioitemnumber=biblioitems.biblioitemnumber and
  items.itemnumber=issues.itemnumber and
  items.biblionumber=biblio.biblionumber";
  $query.=" order by $order";
  if ($limit !=0){
    $query.=" limit $limit";
  }
  #print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @result;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $result[$i]=$data;;
    $i++;
  }
  $sth->finish;
  return($i,\@result);
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
   my $query= "Select * from accountlines where
borrowernumber=? order by date desc,timestamp desc";
   my $sth=$dbh->prepare($query);
#   print $query;
   $sth->execute($params->{'borrowernumber'});
   my $total=0;
   while (my $data=$sth->fetchrow_hashref){
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

=item itemcount

  ($count, $lcount, $nacount, $fcount, $scount, $lostcount,
  $mending, $transit,$ocount) =
    &itemcount($env, $biblionumber, $type);

Counts the number of items with the given biblionumber, broken down by
category.

C<$env> is ignored.

If C<$type> is not set to C<intra>, lost, very overdue, and withdrawn
items will not be counted.

C<&itemcount> returns a nine-element list:

C<$count> is the total number of items with the given biblionumber.

C<$lcount> is the number of items at the Levin branch.

C<$nacount> is the number of items that are neither borrowed, lost,
nor withdrawn (and are therefore presumably on a shelf somewhere).

C<$fcount> is the number of items at the Foxton branch.

C<$scount> is the number of items at the Shannon branch.

C<$lostcount> is the number of lost and very overdue items.

C<$mending> is the number of items at the Mending branch (being
mended?).

C<$transit> is the number of items at the Transit branch (in transit
between branches?).

C<$ocount> is the number of items that haven't arrived yet
(aqorders.quantity - aqorders.quantityreceived).

=cut
#'

# FIXME - There's also a &C4::Biblio::itemcount.
# Since they're all exported, acqui/acquire.pl doesn't compile with -w.
sub itemcount {
  my ($env,$bibnum,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from items where
  biblionumber=$bibnum ";
  if ($type ne 'intra'){
    $query.=" and ((itemlost <>1 and itemlost <> 2) or itemlost is NULL) and
    (wthdrawn <> 1 or wthdrawn is NULL)";
  }
  my $sth=$dbh->prepare($query);
  #  print $query;
  $sth->execute;
  my $count=0;
  my $lcount=0;
  my $nacount=0;
  my $fcount=0;
  my $scount=0;
  my $lostcount=0;
  my $mending=0;
  my $transit=0;
  my $ocount=0;
  while (my $data=$sth->fetchrow_hashref){
    $count++;
    my $query2="select * from issues,items where issues.itemnumber=
    '$data->{'itemnumber'}' and returndate is NULL
    and items.itemnumber=issues.itemnumber and ((items.itemlost <>1 and
    items.itemlost <> 2) or items.itemlost is NULL)
    and (wthdrawn <> 1 or wthdrawn is NULL)";

    my $sth2=$dbh->prepare($query2);
    $sth2->execute;
    if (my $data2=$sth2->fetchrow_hashref){
       $nacount++;
    } else {
      if ($data->{'holdingbranch'} eq 'C' || $data->{'holdingbranch'} eq 'LT'){
        $lcount++;
      }
      if ($data->{'holdingbranch'} eq 'F' || $data->{'holdingbranch'} eq 'FP'){
        $fcount++;
      }
      if ($data->{'holdingbranch'} eq 'S' || $data->{'holdingbranch'} eq 'SP'){
        $scount++;
      }
      if ($data->{'itemlost'} eq '1'){
        $lostcount++;
      }
      if ($data->{'itemlost'} eq '2'){
        $lostcount++;
      }
      if ($data->{'holdingbranch'} eq 'FM'){
        $mending++;
      }
      if ($data->{'holdingbranch'} eq 'TR'){
        $transit++;
      }
    }
    $sth2->finish;
  }
#  if ($count == 0){
    my $query2="Select * from aqorders where biblionumber=$bibnum";
    my $sth2=$dbh->prepare($query2);
    $sth2->execute;
    if (my $data=$sth2->fetchrow_hashref){
      $ocount=$data->{'quantity'} - $data->{'quantityreceived'};
    }
#    $count+=$ocount;
    $sth2->finish;
  $sth->finish;
  return ($count,$lcount,$nacount,$fcount,$scount,$lostcount,$mending,$transit,$ocount);
}

=item itemcount2

  $counts = &itemcount2($env, $biblionumber, $type);

Counts the number of items with the given biblionumber, broken down by
category.

C<$env> is ignored.

C<$type> may be either C<intra> or anything else. If it is not set to
C<intra>, then the search will exclude lost, very overdue, and
withdrawn items.

C<$&itemcount2> returns a reference-to-hash, with the following fields:

=over 4

=item C<total>

The total number of items with this biblionumber.

=item C<order>

The number of items on order (aqorders.quantity -
aqorders.quantityreceived).

=item I<branchname>

For each branch that has at least one copy of the book, C<$counts>
will have a key with the branch name, giving the number of copies at
that branch.

=back

=cut
#'
sub itemcount2 {
  my ($env,$bibnum,$type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select * from items,branches where
  biblionumber=$bibnum and items.holdingbranch=branches.branchcode";
  if ($type ne 'intra'){
    $query.=" and ((itemlost <>1 and itemlost <> 2) or itemlost is NULL) and
    (wthdrawn <> 1 or wthdrawn is NULL)";
  }
  my $sth=$dbh->prepare($query);
  #  print $query;
  $sth->execute;
  my %counts;
  $counts{'total'}=0;
  while (my $data=$sth->fetchrow_hashref){
    $counts{'total'}++;

    my $status;
    for my $test (
      [
	'Item Lost',
	'select * from items
	  where itemnumber=?
	    and not ((items.itemlost <>1 and items.itemlost <> 2)
		      or items.itemlost is NULL)'
      ], [
	'Withdrawn',
	'select * from items
	  where itemnumber=? and not (wthdrawn <> 1 or wthdrawn is NULL)'
      ], [
	'On Loan', "select * from issues,items
	  where issues.itemnumber=? and returndate is NULL
	    and items.itemnumber=issues.itemnumber"
      ],
    ) {
	my($testlabel, $query2) = @$test;

	my $sth2=$dbh->prepare($query2);
	$sth2->execute($data->{'itemnumber'});

	# FIXME - fetchrow_hashref() can fail for any number of reasons
	# (e.g., a database server crash). Perhaps use a left join of some
	# sort for this?
	$status = $testlabel if $sth2->fetchrow_hashref;
	$sth2->finish;
    last if defined $status;
    }
    $status = $data->{'branchname'} unless defined $status;
    $counts{$status}++;
  }
  my $query2="Select * from aqorders where biblionumber=$bibnum and
  datecancellationprinted is NULL and quantity > quantityreceived";
  my $sth2=$dbh->prepare($query2);
  $sth2->execute;
  if (my $data=$sth2->fetchrow_hashref){
      $counts{'order'}=$data->{'quantity'} - $data->{'quantityreceived'};
  }
  $sth2->finish;
  $sth->finish;
  return (\%counts);
}

=item ItemType

  $description = &ItemType($itemtype);

Given an item type code, returns the description for that type.

=cut
#'

# FIXME - I'm pretty sure that after the initial setup, the list of
# item types doesn't change very often. Hence, it seems slow and
# inefficient to make yet another database call to look up information
# that'll only change every few months or years.
#
# Much better, I think, to automatically build a Perl file that can be
# included in those scripts that require it, e.g.:
#	@itemtypes = qw( ART BCD CAS CD F ... );
#	%itemtypedesc = (
#		ART	=> "Art Prints",
#		BCD	=> "CD-ROM from book",
#		CD	=> "Compact disc (WN)",
#		F	=> "Free Fiction",
#		...
#	);
# The web server can then run a cron job to rebuild this file from the
# database every hour or so.
#
# The same thing goes for branches, book funds, book sellers, currency
# rates, printers, stopwords, and perhaps others.
sub ItemType {
  my ($type)=@_;
  my $dbh = C4::Context->dbh;
  my $query="select description from itemtypes where itemtype='$type'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $dat=$sth->fetchrow_hashref;
  $sth->finish;
  return ($dat->{'description'});
}

=item bibitems

  ($count, @results) = &bibitems($biblionumber);

Given the biblionumber for a book, C<&bibitems> looks up that book's
biblioitems (different publications of the same book, the audio book
and film versions, etc.).

C<$count> is the number of elements in C<@results>.

C<@results> is an array of references-to-hash; the keys are the fields
of the C<biblioitems> and C<itemtypes> tables of the Koha database. In
addition, C<itemlost> indicates the availability of the item: if it is
"2", then all copies of the item are long overdue; if it is "1", then
all copies are lost; otherwise, there is at least one copy available.

=cut
#'
sub bibitems {
    my ($bibnum) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "SELECT biblioitems.*,
                        itemtypes.*,
                        MIN(items.itemlost)        as itemlost,
                        MIN(items.dateaccessioned) as dateaccessioned
                          FROM biblioitems, itemtypes, items
                         WHERE biblioitems.biblionumber     = ?
                           AND biblioitems.itemtype         = itemtypes.itemtype
                           AND biblioitems.biblioitemnumber = items.biblioitemnumber
                      GROUP BY items.biblioitemnumber";
    my $sth   = $dbh->prepare($query);
    my $count = 0;
    my @results;
    $sth->execute($bibnum);
    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
        $count++;
    } # while
    $sth->finish;
    return($count, @results);
} # sub bibitems

=item barcodes

  @barcodes = &barcodes($biblioitemnumber);

Given a biblioitemnumber, looks up the corresponding items.

Returns an array of references-to-hash; the keys are C<barcode> and
C<itemlost>.

The returned items include very overdue items, but not lost ones.

=cut
#'
sub barcodes{
    #called from request.pl
    my ($biblioitemnumber)=@_;
    my $dbh = C4::Context->dbh;
    my $query="SELECT barcode, itemlost, holdingbranch FROM items
                           WHERE biblioitemnumber = ?
                             AND (wthdrawn <> 1 OR wthdrawn IS NULL)";
    my $sth=$dbh->prepare($query);
    $sth->execute($biblioitemnumber);
    my @barcodes;
    my $i=0;
    while (my $data=$sth->fetchrow_hashref){
	$barcodes[$i]=$data;
	$i++;
    }
    $sth->finish;
    return(@barcodes);
}

=item getwebsites

  ($count, @websites) = &getwebsites($biblionumber);

Looks up the web sites pertaining to the book with the given
biblionumber.

C<$count> is the number of elements in C<@websites>.

C<@websites> is an array of references-to-hash; the keys are the
fields from the C<websites> table in the Koha database.

=cut
#'
sub getwebsites {
    my ($biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select * from websites where biblionumber = $biblionumber";
    my $sth   = $dbh->prepare($query);
    my $count = 0;
    my @results;

    $sth->execute;
    while (my $data = $sth->fetchrow_hashref) {
        # FIXME - The URL scheme shouldn't be stripped off, at least
        # not here, since it's part of the URL, and will be useful in
        # constructing a link to the site. If you don't want the user
        # to see the "http://" part, strip that off when building the
        # HTML code.
        $data->{'url'} =~ s/^http:\/\///;	# FIXME - Leaning toothpick
						# syndrome
        $results[$count] = $data;
    	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub getwebsites

=item getwebbiblioitems

  ($count, @results) = &getwebbiblioitems($biblionumber);

Given a book's biblionumber, looks up the web versions of the book
(biblioitems with itemtype C<WEB>).

C<$count> is the number of items in C<@results>. C<@results> is an
array of references-to-hash; the keys are the items from the
C<biblioitems> table of the Koha database.

=cut
#'
sub getwebbiblioitems {
    my ($biblionumber) = @_;
    my $dbh   = C4::Context->dbh;
    my $query = "Select * from biblioitems where biblionumber = $biblionumber
and itemtype = 'WEB'";
    my $sth   = $dbh->prepare($query);
    my $count = 0;
    my @results;

    $sth->execute;
    while (my $data = $sth->fetchrow_hashref) {
        $data->{'url'} =~ s/^http:\/\///;
        $results[$count] = $data;
        $count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub getwebbiblioitems


=item breedingsearch

  ($count, @results) = &breedingsearch($title);

C<$count> is the number of items in C<@results>. C<@results> is an
array of references-to-hash; the keys are the items from the
C<marc_breeding> table of the Koha database.

=cut

sub breedingsearch {
	my ($title,$isbn) = @_;
	my $dbh   = C4::Context->dbh;
	my $count = 0;
	my $query;
	my $sth;
	my @results;

	$query = "Select id,file,isbn,title,author from marc_breeding where ";
	if ($title) {
		$query .= "title like \"$title%\"";
	}
	if ($title && $isbn) {
		$query .= " and ";
	}
	if ($isbn) {
		$query .= "isbn like \"$isbn%\"";
	}
	$sth   = $dbh->prepare($query);
	$sth->execute;
	while (my $data = $sth->fetchrow_hashref) {
			$results[$count] = $data;
			$count++;
	} # while

	$sth->finish;
	return($count, @results);
} # sub breedingsearch

=item isbnsearch

  ($count, @results) = &isbnsearch($isbn,$title);

Given an isbn and/or a title, returns the biblios having it.
Used in acqui.simple, isbnsearch.pl only

C<$count> is the number of items in C<@results>. C<@results> is an
array of references-to-hash; the keys are the items from the
C<biblioitems> table of the Koha database.

=cut

sub isbnsearch {
    my ($isbn,$title) = @_;
    my $dbh   = C4::Context->dbh;
    my $count = 0;
    my $query;
    my $sth;
    my @results;

    $query = "Select distinct biblio.* from biblio, biblioitems where
				biblio.biblionumber = biblioitems.biblionumber";
	if ($isbn) {
		$query .= " and isbn=".$dbh->quote($isbn);
	}
	if ($title) {
		$query .= " and title like ".$dbh->quote($title."%");
	}
	warn $query;
    $sth   = $dbh->prepare($query);

    $sth->execute;
    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub isbnsearch

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
