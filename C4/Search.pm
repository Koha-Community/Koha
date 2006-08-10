package C4::Search;

# Copyright 2000-2002 Katipo Communications
# New functions added 22-09-2005 Tumer Garip tgarip@neu.edu.tr
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
use C4::Biblio;
use C4::Koha;
use Date::Calc;
use MARC::File::XML;
use MARC::File::USMARC;
use MARC::Record;

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

&CatSearch &BornameSearch &ItemInfo &KeywordSearch &subsearch
&itemdata &bibdata &GetItems &borrdata &itemnodata &itemcount
&borrdata2 &borrdata3 &NewBorrowerNumber &bibitemdata &borrissues
&getboracctrecord &ItemType &itemissues &subject &subtitle
&addauthor &bibitems &barcodes &findguarantees &allissues
&findseealso &findguarantor &getwebsites &getwebbiblioitems &itemcount2 &FindDuplicate
&isbnsearch &getbranchname &getborrowercategory &getborrowercategoryinfo 

&searchZOOM &catalogsearch &catalogsearch3 &CatSearch3 &catalogsearch4 &searchResults

&getRecords &buildQuery

&getMARCnotes &getMARCsubjects &getMARCurls);
# make all your functions, whether exported or not;

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
        my ($tag) =substr(@$fields[$i],1,3);
        my ($subfield) =substr(@$fields[$i],4,1);
        @$fields[$i].=','.$tagslib->{$tag}->{$subfield}->{seealso} if ($tagslib->{$tag}->{$subfield}->{seealso});
    }
}

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
  my $sth=$dbh->prepare("select cardnumber,borrowernumber, firstname, surname from borrowers where guarantor=?");
  $sth->execute($bornum);

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
  my $sth=$dbh->prepare("select guarantor from borrowers where borrowernumber=?");
  $sth->execute($bornum);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $sth=$dbh->prepare("Select * from borrowers where borrowernumber=?");
  $sth->execute($data->{'guarantor'});
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
    my ($dbh, $tags, $and_or, $excluding, $operator, $value, $offset,$length,$orderby,$desc_or_asc) = @_;

    # used for the new API
    my ($search_or_scan,$type,$query,$num,$startfrom,$then_sort_by);

    $search_or_scan = 'search';
    $then_sort_by = '';
    my $number_of_results = $length; # num of results to return
    $startfrom = $offset; # offset
    my $ccl_query;
    for (my $i = 0 ; $i <= $#{$value} ; $i++) {
        $ccl_query.= @$value[$i];
    }
    my ($error,$count,$facets,@results) = searchZOOM('search','ccl',$ccl_query,$number_of_results,$startfrom,$then_sort_by);

    my @result = ();
    my $subtitle; # Added by JF for Subtitles

    # find bibids from results
    #put them in @result
    foreach my $rec (@results) {
        my $record = MARC::Record->new_from_usmarc($rec);
        my $oldbiblio = MARCmarc2koha($dbh,$record,'');
        push @result, $oldbiblio->{'biblionumber'}; #FIXME bibid?
    }
    # we have bibid list. Now, loads title and author from [offset] to [offset]+[length]
    my $counter = $offset;
    # HINT : biblionumber as bn is important. The hash is fills biblionumber with items.biblionumber.
    # so if you dont' has an item, you get a not nice empty value.
    my $sth = $dbh->prepare("SELECT biblio.biblionumber as bn,biblioitems.*,biblio.*, itemtypes.notforloan,itemtypes.description
                            FROM biblio
                            LEFT JOIN biblioitems on biblio.biblionumber = biblioitems.biblionumber
                            LEFT JOIN itemtypes on itemtypes.itemtype=biblioitems.itemtype
                            WHERE biblio.biblionumber = ?"); #marc_biblio.biblionumber AND bibid = ?");
        my $sth_subtitle = $dbh->prepare("SELECT subtitle FROM bibliosubtitle WHERE biblionumber=?"); # Added BY JF for Subtitles
    my @finalresult = ();
    my @CNresults=();
    my $totalitems=0;
    my $oldline;
    my ($oldbibid, $oldauthor, $oldtitle);
    my $sth_itemCN;
    if (C4::Context->preference('hidelostitems')) {
        $sth_itemCN = $dbh->prepare("select items.* from items where biblionumber=? and (itemlost = 0 or itemlost is NULL) order by homebranch");
    } else {
        $sth_itemCN = $dbh->prepare("select items.* from items where biblionumber=? order by homebranch");
    }
    my $sth_issue = $dbh->prepare("select date_due,returndate from issues where itemnumber=?");
    # parse all biblios between start & end.
    #while (($counter <= $#result) && ($counter <= ($offset + $length))) { #FIXME, do all of them
    while ($counter <= $#result) {
        # search & parse all items & note itemcallnumber
        #warn $result[$counter];
        $sth->execute($result[$counter]);
        my $continue=1;
        my $line = $sth->fetchrow_hashref;
        my $biblionumber=$line->{bn};
        # Return subtitles first ADDED BY JF
                $sth_subtitle->execute($biblionumber);
                my $subtitle_here.= $sth_subtitle->fetchrow." ";
                chop $subtitle_here;
                $subtitle = $subtitle_here;
#               warn "Here's the Biblionumber ".$biblionumber;
#                warn "and here's the subtitle: ".$subtitle_here;

        # /ADDED BY JF

#       $continue=0 unless $line->{bn};
#       my $lastitemnumber;
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
            #$lineCN{notforloan} = $notforloanstatus{$line->{notforloan}} if ($line->{notforloan}); # setting not forloan if itemtype is not for loan
            #$lineCN{notforloan} = $notforloanstatus{$item->{notforloan}} if ($item->{notforloan}); # setting not forloan it this item is not for loan
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
        $counter++;
    }
    my $nbresults = $#result+1;
    return (\@finalresult, $nbresults);
}


sub add_html_bold_fields {
	my ($type, $data, $search) = @_;
	
	my %reference = ('additionalauthors' => 'author',
					'publishercode' => 'publisher',
					'subtitle' => 'title'
					);

	foreach my $key ('title', 'author', 'additionalauthors', 'publishercode', 'publicationyear', 'subject', 'subtitle') {
		my $new_key; 
		if ($key eq 'additionalauthors') {
			$new_key = 'additionalauthors';
		} else {
			$new_key = 'bold_' . $key;
			$data->{$new_key} = $data->{$key};
		}
	
		my $key1;
		if ($reference{$key}) {
			$key1 = $reference{$key};
		} else {
			$key1 = $key;
		}

		my @keys;
		my $i = 1;
		if ($type eq 'keyword') {
		my $newkey=$search->{'keyword'};
		$newkey=~s /\++//g;
			@keys = split " ", $newkey;
		} else {
			while ($search->{"field_value$i"}) {
				my $newkey=$search->{"field_value$i"};
				$newkey=~s /\++//g;
				push @keys, $newkey;
				$i++;
			}
		}
		my $count = @keys;
		for ($i = 0; $i < $count ; $i++) {
			if ($key eq 'additionalauthors') {
				my $j = 0;
				foreach (@{$data->{$new_key}}) {
					if (!$data->{$new_key}->[$j]->{'bold_value'}) {
						$data->{$new_key}->[$j]->{'bold_value'} = $data->{$new_key}->[$j]->{'value'};
					}
					if ( ($data->{$new_key}->[$j]->{'value'} =~ /($keys[$i])/i) && (lc($keys[$i]) ne 'b') ) {
						my $word = $1;
						$data->{$new_key}->[$j]->{'bold_value'} =~ s/$word/<b>$word<\/b>/;
					}
					$j++;
				}
			} else {
				if (($data->{$new_key} =~ /($keys[$i])/i) && (lc($keys[$i]) ne 'b') ) {
					my $word = $1;
					$data->{$new_key} =~ s/$word/<b>$word<\/b>/;
				}
			}
		}
	}


}

sub catalogsearch3 {
	my ($search,$num,$offset) = @_;
	my $dbh = C4::Context->dbh;
	my ($count,@results);

	if ($search->{'itemnumber'} ne '' || $search->{'isbn'} ne ''|| $search->{'biblionumber'} ne ''){
		($count,@results) = CatSearch3('precise',$search,$num,$offset);
	} elsif ($search->{'keyword'} ne ''){
		($count,@results) = CatSearch3('keyword',$search,$num,$offset);
	} elsif ($search->{'recently_items'} ne '') {
		($count,@results) = CatSearch3('recently_items',$search,$num,$offset);
	} else {
		($count,@results) = CatSearch3('loose',$search,$num,$offset);
	}

	
	return ($count,@results);
}

sub CatSearch3  {

	my ($type,$search,$num,$offset)=@_;
	my $dbh = C4::Context->dbh;
	my $query = '';			#to make the query statement
	my $count_query = '';	#to count total results
	my @params = ();		#to collect the params
	my @results;			#to retrieve the results
	
	# 1) do a search by barcode or isbn
	if ($type eq 'precise') {
	
			if ($search->{'itemnumber'} ne ''){
			$query = "SELECT biblionumber FROM items WHERE (barcode = ?)";
			push @params, $search->{'itemnumber'};
			
			} elsif ($search->{'isbn'} ne '') {
			$query = "SELECT biblionumber FROM biblioitems WHERE (isbn like ?)";
			push @params, $search->{'isbn'};
			}else {
			$query = "SELECT biblionumber FROM biblioitems WHERE (biblionumber = ?)";
			push @params, $search->{'biblionumber'};
			}
		
		#add branch condition
		if ($search->{'branch'} ne '') {
			$query.= " AND (  holdingbranch like ? ) ";
			my $keys = $search->{'branch'};
			push @params, $keys;
		}

	# 2) do a search by keyword
	} elsif ($type eq 'keyword') {
		my $keys = $search->{'keyword'};
		my @words = split / /, $keys;
		
		#parse the keywords
		my $keyword;
		if ($search->{'ttype'} eq 'exact') {
			for (my $i = 0; $i < @words ;$i++) {
				if ($i + 1 == @words) {
					$words[$i] = '+' . $words[$i] . '*';
				} else {
					$words[$i] = '+' . $words[$i];
				}
			}
		} else {
			for (my $i = 0; $i < @words ;$i++) {
				$words[$i] =  $words[$i] . '*';
			}
		}	 
		$keyword = join " ", @words;

		#Builds the SQL
		$query = "(SELECT DISTINCT B.biblionumber AS biblionumber ,( MATCH (title,seriestitle,unititle,B.author,subject,publishercode,itemcallnumber) AGAINST(? in BOOLEAN MODE) ) as Relevance
						FROM biblio AS B
						LEFT JOIN biblioitems AS BI ON (B.biblionumber = BI.biblionumber)
						LEFT JOIN items AS I ON (BI.biblionumber = I.biblionumber) 
						LEFT JOIN additionalauthors AA1 ON (B.biblionumber = AA1.biblionumber)	
						LEFT JOIN bibliosubject AS BS1 ON (B.biblionumber = BS1.biblionumber)
						LEFT JOIN bibliosubtitle AS BSU1 ON (B.biblionumber = BSU1.biblionumber) 
					where	MATCH (title,seriestitle,unititle,B.author,subject,publishercode,itemcallnumber) AGAINST (? IN BOOLEAN MODE) ";

		push @params,$keyword;
		push @params,$keyword;
		#search by class 
		if ($search->{'class'} ne '') {
			$query .= " AND ( itemtype = ? ) ";
			push @params, $search->{'class'};
		}
		#search by branch 
		if ($search->{'branch'} ne '') {
			$query .= " AND ( items.holdingbranch like ? ) ";
			push @params, $search->{'branch'};
		}
	if ($search->{'stack'} ne '') {
			$query .= " AND ( items.stack = ?  ) ";
			push @params, $search->{'stack'};
		}
		#search by publication year 
		if ($search->{'date_from'} ne '') {
	        $query .= " AND ( biblioitems.publicationyear >= ?) ";
			push @params, $search->{'date_from'};
    		if ($search->{'date_to'} ne '') {
    			        $query .= " AND ( biblioitems.publicationyear <= ?) ";
				push @params, $search->{'date_to'};
			
			}		
		}
		$query .= ")";

	
		

	# 3) search the items acquired recently (in the last $search->{'range'} days)
	} elsif ($type eq 'recently_items') {
		my $keys;
		if ($search->{'range'}) {
			$keys = $search->{'range'};
		} else {
			$keys = 30;
		}
		$query = "SELECT B.biblionumber FROM biblio AS B
							LEFT JOIN biblioitems AS BI ON (B.biblionumber = BI.biblionumber)
							
						WHERE 
							(TO_DAYS( NOW( ) ) - TO_DAYS( B.timestamp ))<?"; 
		#search by class
		push @params, $keys;
		if ($search->{'class'} ne '') {
			$query .= " AND ( BI.itemtype = ? ) ";
			push @params, $search->{'class'};
		}
		$query.= " ORDER BY title ";

	# 4) do a loose search
	} else {
			
			my ($condition1, $condition2, $condition3) = ('','','');
			my $count_params = 0;
			
				
			#search_field 1			
			if ($search->{'field_name1'} eq 'all') { 
				$condition1.= " ( MATCH (title,seriestitle,unititle,B.author,subject,publishercode,itemcallnumber) AGAINST(? in BOOLEAN MODE) ) ";
				
				$count_params = 1;
			} elsif ($search->{'field_name1'} eq 'author') {
				$condition1.= " (  MATCH (B.author) AGAINST(? in BOOLEAN MODE)  ) ";
				$count_params = 1;
			} elsif ($search->{'field_name1'} eq 'title') {
				$condition1.= " (  MATCH (title,seriestitle,unititle) AGAINST(? in BOOLEAN MODE ) ) ";
				$count_params = 1;
			} elsif ($search->{'field_name1'} eq 'subject') {
				$condition1.= " ( ( MATCH (subject) AGAINST(? in BOOLEAN MODE) ) ) ";
				$count_params = 1;
			} elsif ($search->{'field_name1'} eq 'publisher') {
				$condition1.= " ( MATCH (publishercode) AGAINST(? in BOOLEAN MODE )) ";
				$count_params = 1;
			} elsif ($search->{'field_name1'} eq 'publicationyear') {
				$condition1.= " ( MATCH (publicationyear) AGAINST(? in BOOLEAN MODE )) ";
				$count_params = 1;
			} elsif ($search->{'field_name1'} eq 'callno') {
				$condition1.= "  ( MATCH (itemcallnumber) AGAINST(? in BOOLEAN MODE ))  ";
				$count_params = 1;
			}
			
					if ($search->{'ttype1'}  eq 'exact') {
					push @params,"\"".$search->{'field_value1'}."\"";
					push @params, "\"".$search->{'field_value1'}."\"";
					} else {
					my $keys = $search->{'field_value1'};
					my @words = split / /, $keys;
					#parse the keywords
					my $keyword;		
						for (my $i = 0; $i < @words ;$i++) {
						$words[$i] = '+'. $words[$i] . '*';
						}
					$keyword = join " ", @words;	
					push @params, $keyword;
					push @params, $keyword;

					}

			$query = " SELECT DISTINCT B.biblionumber AS biblionumber ,$condition1 as Relevance
						FROM biblio AS B
						LEFT JOIN biblioitems AS BI ON (B.biblionumber = BI.biblionumber)
						LEFT JOIN items AS I ON (BI.biblionumber = I.biblionumber) 
						LEFT JOIN additionalauthors AA1 ON (B.biblionumber = AA1.biblionumber)	
						LEFT JOIN bibliosubject AS BS1 ON (B.biblionumber = BS1.biblionumber)
						LEFT JOIN bibliosubtitle AS BSU1 ON (B.biblionumber = BSU1.biblionumber) ";	
			

			#search_field 2
			if ( ($search->{'field_value1'}) && ($search->{'field_value2'}) ) {
			if ($search->{'field_name2'} eq 'all') { 
				$condition2.= "  MATCH (title,seriestitle,unititle,B.author,subject,publishercode,itemcallnumber) AGAINST( ? in BOOLEAN MODE) ) ";
				
				$count_params = 1;
			} elsif ($search->{'field_name2'} eq 'author') {
				$condition2.= "  MATCH (B.author,AA1.author) AGAINST( ? in BOOLEAN MODE)  ) ";
				$count_params = 1;
			} elsif ($search->{'field_name2'} eq 'title') {
				$condition2.= "   MATCH (title,seriestitle,unititle) AGAINST( ? in BOOLEAN MODE ) ) ";
				$count_params = 1;
			} elsif ($search->{'field_name2'} eq 'subject') {
				$condition2.= "   MATCH (subject) AGAINST(? in BOOLEAN MODE) )  ";
				$count_params = 1;
			} elsif ($search->{'field_name2'} eq 'publisher') {
				$condition2.= " MATCH (publishercode) AGAINST(? in BOOLEAN MODE )) ";
				$count_params = 1;
			} elsif ($search->{'field_name2'} eq 'publicationyear') {
				$condition2.= "  MATCH (publicationyear) AGAINST(? in BOOLEAN MODE )) ";
				$count_params = 1;
			} elsif ($search->{'field_name2'} eq 'callno') {
				$condition2.= "   MATCH (itemcallnumber) AGAINST(? in BOOLEAN MODE ))  ";
				$count_params = 1;
			}
					if ($search->{'op1'} eq "not"){
					$search->{'op1'}="and (not ";
					}else{
					$search->{'op1'}.=" (";
					}
					
					if ($search->{'ttype2'}  eq 'exact') {
					push @params, "\"".$search->{'field_value2'}."\"";
					} else {
					my $keys = $search->{'field_value2'};
					my @words = split / /, $keys;
					#parse the keywords
					my $keyword;	
						for (my $i = 0; $i < @words ;$i++) {
						$words[$i] = "+". $words[$i] . '*';
						}
					$keyword = join " ", @words;	
					push @params, $keyword;
					}

			}

			#search_field 3
			if ( ($search->{'field_value2'}) && ($search->{'field_value3'}) ) {
			
				if ($search->{'field_name3'} eq 'all') { 
				$condition3.= " MATCH (title,seriestitle,unititle,B.author,subject,publishercode,itemcallnumber) AGAINST(? in BOOLEAN MODE ) ) ";
				
				$count_params = 1;
			} elsif ($search->{'field_name3'} eq 'author') {
				$condition3.= "   MATCH (B.author,AA1.author) AGAINST(? in BOOLEAN MODE)  ) ";
				$count_params = 1;
			} elsif ($search->{'field_name3'} eq 'title') {
				$condition3.= "   MATCH (title,seriestitle,unititle) AGAINST(? in BOOLEAN MODE) ) ";
				$count_params = 1;
			} elsif ($search->{'field_name3'} eq 'subject') {
				$condition3.= "  MATCH (subject) AGAINST(? in BOOLEAN MODE ) )  ";
				$count_params = 1;
			} elsif ($search->{'field_name3'} eq 'publisher') {
				$condition3.= "  MATCH (publishercode) AGAINST(? in BOOLEAN MODE )) ";
				$count_params = 1;
			} elsif ($search->{'field_name3'} eq 'publicationyear') {
				$condition3.= "  MATCH (publicationyear) AGAINST(? in BOOLEAN MODE )) ";
				$count_params = 1;
			} elsif ($search->{'field_name3'} eq 'callno') {
				$condition3.= "   MATCH (itemcallnumber) AGAINST(? in BOOLEAN MODE ))  ";
				$count_params = 1;
			}
				if ($search->{'op2'} eq "not"){
					$search->{'op2'}="and (not ";
					}else{
					$search->{'op2'}.=" (";
					}
					if ($search->{'ttype3'}  eq 'exact') {
					push @params, "\"".$search->{'field_value3'}."\"";
				} else {
					my $keys = $search->{'field_value3'};
					my @words = split / /, $keys;
					#parse the keywords
					my $keyword;	
						
						for (my $i = 0; $i < @words ;$i++) {
						$words[$i] = "+". $words[$i] . '*';
						}
					$keyword = join " ", @words;	
					push @params, $keyword;
				}
			}

			$query.= " WHERE ";
			if (($condition1 ne '') && ($condition2 ne '') && ($condition3 ne '')) {
				if ($search->{'op1'} eq $search->{'op2'}) {
					$query.= " ( $condition1 $search->{'op1'} $condition2 $search->{'op2'} $condition3 ) ";
				} elsif ( $search->{'op1'} eq "and (" ) {
					$query.= " ( $condition1 $search->{'op1'} ( $condition2 $search->{'op2'} $condition3 ) ) ";
				} else {
					$query.= " ( ( $condition1 $search->{'op1'} $condition2 ) $search->{'op2'} $condition3 ) ";
				}
			} elsif ( ($condition1 ne '') && ($condition2 ne '') ) {
				$query.= " ( $condition1 $search->{'op1'} $condition2 ) ";
			} else {
				$query.= " ( $condition1 ) ";
			}
			
			#search by class 
			if ($search->{'class'} ne ''){
				$query.= " AND ( itemtype = ? ) ";
				my $keys = $search->{'class'};
				push @params, $search->{'class'};
			}
			#search by branch 
			if ($search->{'branch'} ne '') {
				$query.= " AND   I.holdingbranch like ?  ";
				my $keys = $search->{'branch'};
				push @params, $keys, $keys;
			}
			#search by publication year 
			if ($search->{'date_from'} ne '') {
				$query .= " AND ( BI.publicationyear >= ?) ";
				push @params, $search->{'date_from'};
				if ($search->{'date_to'} ne '') {
							$query .= " AND ( BI.publicationyear <= ?) ";
					push @params, $search->{'date_to'};
				
				}		
			}
			if ($search->{'order'} eq "1=1003 i<"){
			$query.= " ORDER BY b.author ";
			}elsif ($search->{'order'} ge "1=9 i<"){
			$query.= " ORDER BY lcsort ";
			}elsif ($search->{'order'} eq "1=4 i<"){
			$query.= " ORDER BY title ";
			}else{
			$query.=" ORDER BY Relevance DESC";
			}
	}
	
#warn "$query,@params,";
	$count_query = $query;	
	warn "QUERY:".$count_query;
 	#execute the query and returns just the results between $num and $num + $offset
	my $limit = $num + $offset;
	my $startfrom = $offset;
	my $sth = $dbh->prepare($query);
	
	$sth->execute(@params);

    my $i = 0;
#Build brancnames hash
#find branchname
#get branch information.....
my %branches;
		my $bsth=$dbh->prepare("SELECT branchcode,branchname FROM branches");
		$bsth->execute();
		while (my $bdata=$bsth->fetchrow_hashref){
			$branches{$bdata->{'branchcode'}}= $bdata->{'branchname'};

		}

#Building shelving hash
my %shelves;
#find shelvingname
my $stackstatus = $dbh->prepare('select authorised_value from marc_subfield_structure where kohafield="items.stack"');
		$stackstatus->execute;
		
		my ($authorised_valuecode) = $stackstatus->fetchrow;
		if ($authorised_valuecode) {
			$stackstatus = $dbh->prepare("select lib,authorised_value from authorised_values where category=? ");
			$stackstatus->execute($authorised_valuecode);
			
			while (my $lib = $stackstatus->fetchrow_hashref){
			$shelves{$lib->{'authorised_value'}} = $lib->{'lib'};
			}
		}

#search item field code
        my $sth3 =
          $dbh->prepare(
	"select tagfield from marc_subfield_structure where kohafield like 'items.itemnumber'"
        );
	 $sth3->execute;
	 my ($itemtag) = $sth3->fetchrow;
## find column names of items related to MARC
	my $sth2=$dbh->prepare("SHOW COLUMNS from items");
	$sth2->execute;
	my %subfieldstosearch;
	while ((my $column)=$sth2->fetchrow){
	my ($tagfield,$tagsubfield) = &MARCfind_marc_from_kohafield($dbh,"items.".$column,"");
	$subfieldstosearch{$column}=$tagsubfield;
	}
my $toggle;
my $even;
#proccess just the results to show
	while (my( $data,$rel) = $sth->fetchrow)  {
		if (($i >= $startfrom) && ($i < $limit)) {
	
		my $marcrecord=MARCgetbiblio($dbh,$data);
		my $oldbiblio=MARCmarc2koha($dbh,$marcrecord,'');
			

			&add_html_bold_fields($type, $oldbiblio, $search);
if ($i % 2) {
		$toggle="#ffffcc";
	} else {
		$toggle="white";
	}
	$oldbiblio->{'toggle'}=$toggle;

       
       
 my @fields = $marcrecord->field($itemtag);
my @items;
 my $item;
my %counts;
$counts{'total'}=0;

#	
##Loop for each item field
     foreach my $field (@fields) {
       foreach my $code ( keys %subfieldstosearch ) {

$item->{$code}=$field->subfield($subfieldstosearch{$code});
}

my $status;

$item->{'branchname'}=$branches{$item->{'holdingbranch'}};
$item->{'shelves'}=$shelves{$item->{stack}};
$status="Lost" if ($item->{'itemlost'}>0);
$status="Withdrawn" if ($item->{'wthdrawn'}>0) ;
if ($search->{'from'} eq "intranet"){
$search->{'avoidquerylog'}=1;
$status="Due:".format_date($item->{'onloan'}) if ($item->{'onloan'}>0);
 $status = $item->{'holdingbranch'}."-".$item->{'stack'}."[".$item->{'itemcallnumber'}."]" unless defined $status;
}else{
$status="On Loan" if ($item->{'onloan'}>0);
   $status = $item->{'branchname'}."[".$item->{'shelves'}."]" unless defined $status;
}
 $counts{$status}++;
$counts{'total'}++;
push @items,$item;

	}
		
		my $norequests = 1;
		my $noitems    = 1;
		if (@items) {
			$noitems = 0;
			foreach my $itm (@items) {
				$norequests = 0 unless $itm->{'itemnotforloan'};
			}
		}
		$oldbiblio->{'noitems'} = $noitems;
		$oldbiblio->{'norequests'} = $norequests;
		$oldbiblio->{'even'} = $even = not $even;
		$oldbiblio->{'itemcount'} = $counts{'total'};	
		my $totalitemcounts = 0;
		foreach my $key (keys %counts){
			if ($key ne 'total'){	
				$totalitemcounts+= $counts{$key};
				$oldbiblio->{'locationhash'}->{$key}=$counts{$key};
			}
		}
		
		my ($locationtext, $locationtextonly, $notavailabletext) = ('','','');
		foreach (sort keys %{$oldbiblio->{'locationhash'}}) {
			if ($_ eq 'notavailable') {
				$notavailabletext="Not available";
				my $c=$oldbiblio->{'locationhash'}->{$_};
				$oldbiblio->{'not-available-p'}=$c;
			} else {
				$locationtext.="$_";
				my $c=$oldbiblio->{'locationhash'}->{$_};
				if ($_ eq 'Item Lost') {
					$oldbiblio->{'lost-p'} = $c;
				} elsif ($_ eq 'Withdrawn') {
					$oldbiblio->{'withdrawn-p'} = $c;
				} elsif ($_ eq 'On Loan') {
					$oldbiblio->{'on-loan-p'} = $c;
				} else {
					$locationtextonly.= $_;
					$locationtextonly.= " ($c)<br> " if $totalitemcounts > 1;
				}
				if ($totalitemcounts>1) {
					$locationtext.=" ($c)<br> ";
				}
			}
		}
		if ($notavailabletext) {
			$locationtext.= $notavailabletext;
		} else {
			$locationtext=~s/, $//;
		}
		$oldbiblio->{'location'} = $locationtext;
		$oldbiblio->{'location-only'} = $locationtextonly;
		$oldbiblio->{'use-location-flags-p'} = 1;
			push @results, $oldbiblio;

		}
		$i++;
	}

	my $count = $i;
	unless ($search->{'avoidquerylog'}) { 
		add_query_line($type, $search, $count);}
	return($count,@results);
}

sub catalogsearch4 {
	my ($search,$num,$offset) = @_;
	my ($count,@results);

	if ($search->{'itemnumber'} ne '' || $search->{'isbn'} ne ''|| $search->{'biblionumber'} ne ''|| $search->{'authnumber'} ne ''){
		($count,@results) = CatSearch4('precise',$search,$num,$offset);
	} elsif ($search->{'cql'} ne ''){
		if ($search->{'rpn'} ne '') {
				warn "RPN ON";
		                ($count,@results) = CatSearch4('rpn',$search,$num,$offset);
		} else {
			warn "RPN".$search->{'rpn'};
		($count,@results) = CatSearch4('cql',$search,$num,$offset);
		}
	} elsif ($search->{'keyword'} ne ''){
		($count,@results) = CatSearch4('keyword',$search,$num,$offset);
	} elsif ($search->{'recently_items'} ne '') {
		($count,@results) = CatSearch4('recently_items',$search,$num,$offset);
	} else {
		($count,@results) = CatSearch4('loose',$search,$num,$offset);
	}
	return ($count,@results);
}

sub CatSearch4  {

	my ($type,$search,$num,$offset)=@_;
	my $dbh = C4::Context->dbh;
	my $query = '';			#to make the query statement
	my $count_query = '';	#to count total results
	my @params = ();		#to collect the params
	my @results;			#to retrieve the results
	my $attr;
	my $attr2;
	my $attr3;
	my $numresults;
	my $marcdata;
	my $toggle;
	my $even=1;
	my $cql;
	my $rpn;
	my $cql_query;
	# 1) do a search by barcode or isbn
	if ($type eq 'cql') {
		$cql=1;
		$cql_query = $search->{'cql'};
		while( my ($k, $v) = each %$search ) {
		        warn "key: $k, value: $v.\n";
			    }
		warn "QUERY:".$query;
	}
	if ($type eq 'rpn') {
		$rpn=1;
		$cql=1;
		$cql_query = $search->{'cql'}; #but it's really a rpn query FIXME
	}
	if ($type eq 'precise') {

		if ($search->{'itemnumber'} ne '') {
			
			$query = " \@attr 1=1028 ". $search->{'itemnumber'};
			
			
		}elsif ($search->{'isbn'} ne ''){
			$query = " \@attr 1=7 \@attr 4=1  \@attr 5=1 "."\"".$search->{'isbn'}."\"";
			
		}elsif ($search->{'biblionumber'} ne ''){
			$query = " \@attr 1=1007  ".$search->{'biblionumber'};
						
		}elsif ($search->{'authnumber'} ne ''){
				my $n=0;
				my @ids=split / /,$search->{'authnumber'} ;
				foreach my  $id (@ids){
				$query .= "  \@attr GILS 1=2057  ".$id;
				$n++;
				}
			if ($n>1){
			 $query= "\@or ".$query;
			}
	
		}
		#add branch condition
		if ($search->{'branch'} ne '') {
		$query= "\@and ".$query;
			$query .= " \@attr 1=1033 \"".$search->{'branch'}."\"";
		
		}
	# 2) do a search by keyword
	}elsif ($type eq 'keyword') {
		 $search->{'keyword'}=~ s/(\\|\|)//g;;
		
		#parse the keywords
		my $keyword;

		if ($search->{'ttype'} eq 'exact') {
			 $attr="\@attr 4=1  \@attr 5=1 \@attr 2=102 ";
		} else {
			 $attr=" \@attr 4=6  \@attr 5=103 \@attr 2=102 ";
		}	 
		

		#Builds the query
		$query = " \@attr 1=1016 ".$attr."\"".$search->{'keyword'}."\"";

		
		#search by itemtypes 
		if ($search->{'class'} ne '') {
			$query= "\@and ".$query;
			$query .= " \@attr 1=1031  \"".$search->{'class'}."\"";
			push @params, $search->{'class'};
		}
		#search by callnumber 
		if ($search->{'callno'} ne '') {
			$query= "\@and ".$query;
			$query .= " \@attr 1=20 \@attr 4=1  \@attr 5=1 \"".$search->{'callno'}."\"";
			
		}
		#search by branch 
		if ($search->{'branch'} ne '') {
			$query= "\@and ".$query;
			$query .= " \@attr 1=1033 \"".$search->{'branch'}."\"";

		}
		if ($search->{'stack'} ne '') {
			$query= "\@and ".$query;
			$query .= " \@attr 1=1019 \"".$search->{'stack'}."\"";
			push @params, $search->{'stack'};
		}
		if ($search->{'date_from'} ne '') {
		$query= "\@and ".$query;
	        $query .= " \@attr 1=30 \@attr 2=4 \@attr 4=4 ".$search->{'date_from'};
			push @params, $search->{'date_from'};
		}
    		if ($search->{'date_to'} ne '') {
    			     $query= "\@and ".$query;
	        $query .= " \@attr 1=30 \@attr 2=2 \@attr 4=4 ".$search->{'date_to'};
				push @params, $search->{'date_to'};
			
			}		
		
# 3) search the items acquired recently (in the last $search->{'range'} days)
	} elsif ($type eq 'recently_items') {
		my $keys;
		if ($search->{'range'}) {
			$keys = $search->{'range'}*(-1);
		} else {
			$keys = -30;
		}
	my @datearr = localtime();
	my $dateduef = (1900+$datearr[5])."-".sprintf ("%0.2d", ($datearr[4]+1))."-".$datearr[3];
	

	my ($year, $month, $day) = split /-/, $dateduef;
	($year, $month, $day) = &Date::Calc::Add_Delta_Days($year, $month, $day, ($keys - 1));
	$dateduef = "$year-$month-$day";
		 $query .= " \@attr 1=32 \@attr 2=4 \@attr 4=5 ".$dateduef; 
		#search by class
		push @params, $keys;
		if ($search->{'class'} ne '') {
		$query= "\@and ".$query;
			$query .= " \@attr 1=1031 \"".$search->{'class'}."\"";
			
		}
		

	

	# 4) do a loose search
	} else {
			
			my ($condition1, $condition2, $condition3) = ('','','');
			my $count_params = 0;
			
			if ($search->{'ttype1'} eq 'exact') {
			$attr="\@attr 4=1   ";
				if ($search->{'atype1'} eq 'start'){
				$attr.=" \@attr 3=1 \@attr 6=3 \@attr 5=1 \@attr 2=102 ";
				}else{
				$attr.=" \@attr 5=1 \@attr 3=3 \@attr 6=1 \@attr 2=102 ";
				}	
			} else {
			 $attr=" \@attr 4=6  \@attr 5=103 ";
			}	
				
			#search_field 1	
			$search->{'field_value1'}=~ s/(\.|\?|\;|\=|\/|\\|\||\:|\!|,|\-|\"|\(|\)|\[|\]|\{|\}|\/)//g;
			if ($search->{'field_name1'} eq 'all') { 
				$condition1.= " \@attr 1=1016 ".$attr." \"".$search->{'field_value1'}."\" ";
				
			} elsif ($search->{'field_name1'} eq 'author') {
				$condition1.=" \@attr 1=1003 ".$attr." \"".$search->{'field_value1'}."\" ";
				
			} elsif ($search->{'field_name1'} eq 'title') {
				$condition1.= " \@attr 1=4 ".$attr." \"".$search->{'field_value1'}."\" ";
				
			} elsif ($search->{'field_name1'} eq 'subject') {
				$condition1.=" \@attr 1=21 ".$attr." \"".$search->{'field_value1'}."\" ";
			} elsif ($search->{'field_name1'} eq 'series') {
			                                $condition1.=" \@attr 1=5 ".$attr." \"".$search->{'field_value1'}."\" ";
			
			} elsif ($search->{'field_name1'} eq 'publisher') {
				$condition1.= " \@attr 1=1018 ".$attr." \"".$search->{'field_value1'}."\" ";	
			} elsif ($search->{'field_name1'} eq 'callno') {
				$condition1.= " \@attr 1=20 \@attr 3=2 ".$attr." \"".$search->{'field_value1'}."\" ";	
			}		
			$query = $condition1;
			#search_field 2
			if ($search->{'field_value2'}) {
			$search->{'field_value2'}=~ s/(\.|\?|\;|\=|\/|\\|\||\:|\!|,|\-|\"|\(|\)|\[|\]|\{|\}|\/)//g;
			if ($search->{'ttype2'} eq 'exact') {

				$attr2="\@attr 4=1   ";
				if ($search->{'atype1'} eq 'start'){
				$attr.=" \@attr 3=1 \@attr 6=3 \@attr 5=1 \@attr 2=102 ";
				}else{
				$attr.=" \@attr 5=1 \@attr 3=3 \@attr 6=1 \@attr 2=102 ";
				}
			} else {
				 $attr2=" \@attr 4=6  \@attr 5=103 ";
			}
			
				if ($search->{'field_name2'} eq 'all') {
					if ($search->{'op1'} eq 'and') {
						$query = " \@and ".$query;
						$condition2.= " \@attr 1=1016 ".$attr2." \"".$search->{'field_value2'}."\" ";
					
					} elsif ($search->{'op1'} eq 'or')  {
						$query = " \@or ".$query;
						$condition2.= " \@attr 1=1016 ".$attr2." \"".$search->{'field_value2'}."\" ";
					} else {
						$query = " \@not ".$query;
						$condition2.= " \@attr 1=1016 ".$attr2." \"".$search->{'field_value2'}."\" ";
					
					}
				} elsif ($search->{'field_name2'} eq 'author') {
					if ($search->{'op1'} eq 'and') {
						$query = " \@and ".$query;
						$condition2.= " \@attr 1=1003 ".$attr2." \"".$search->{'field_value2'}."\" ";
					
					} elsif ($search->{'op1'} eq 'or'){
						$query = " \@or ".$query;
						$condition2.= " \@attr 1=1003 ".$attr2." \"".$search->{'field_value2'}."\" ";
					} else {
						$query = " \@not ".$query;
						$condition2.= " \@attr 1=1003 ".$attr2." \"".$search->{'field_value2'}."\" ";
					
					}
					
				} elsif ($search->{'field_name2'} eq 'title') {
					if ($search->{'op1'} eq 'and') {
						$query = " \@and ".$query;
						$condition2.= " \@attr 1=4 ".$attr2." \"".$search->{'field_value2'}."\" ";
					
					} elsif ($search->{'op1'} eq 'or'){
						$query = " \@or ".$query;
						$condition2.= " \@attr 1=4 ".$attr2." \"".$search->{'field_value2'}."\" ";
					} else {
						$query = " \@not ".$query;
						$condition2.= " \@attr 1=4 ".$attr2." \"".$search->{'field_value2'}."\" ";
					}
					
				} elsif ($search->{'field_name2'} eq 'subject') {
					if ($search->{'op1'} eq 'and') {
						$query = " \@and ".$query;
						$condition2.= " \@attr 1=21 ".$attr2." \"".$search->{'field_value2'}."\" ";
					
					} elsif ($search->{'op1'} eq 'or') {
						$query = " \@or ".$query;
						$condition2.= " \@attr 1=21 ".$attr2." \"".$search->{'field_value2'}."\" ";
					} else {
						$query = " \@not ".$query;
						$condition2.= " \@attr 1=21 ".$attr2." \"".$search->{'field_value2'}."\" ";
					}
				} elsif ($search->{'field_name2'} eq 'series') {
                                        if ($search->{'op1'} eq 'and') {
                                                $query = " \@and ".$query;
                                                $condition2.= " \@attr 1=5 ".$attr2." \"".$search->{'field_value2'}."\" ";

                                        } elsif ($search->{'op1'} eq 'or') {
                                                $query = " \@or ".$query;
                                                $condition2.= " \@attr 1=5 ".$attr2." \"".$search->{'field_value2'}."\" ";
                                        } else {
                                                $query = " \@not ".$query;
                                                $condition2.= " \@attr 1=5 ".$attr2." \"".$search->{'field_value2'}."\" ";
                                        }
				} elsif ($search->{'field_name2'} eq 'callno') {
					if ($search->{'op1'} eq 'and') {
						$query = " \@and ".$query;
						$condition2.= " \@attr 1=20 \@attr 3=2 ".$attr2." \"".$search->{'field_value2'}."\" ";
					
					} elsif ($search->{'op1'} eq 'or'){
						$query = " \@or ".$query;
						$condition2.= " \@attr 1=20 \@attr 3=2 ".$attr2." \"".$search->{'field_value2'}."\" ";
					} else {
						$query = " \@not ".$query;
						$condition2.= " \@attr 1=20 \@attr 3=2 ".$attr2." \"".$search->{'field_value2'}."\" ";
					}
				} elsif ($search->{'field_name2'} eq 'publisher') {
				$query = " \@and ".$query;
				$condition2.= " \@attr 1=1018 ".$attr2." \"".$search->{'field_value2'}."\" ";
				} elsif ($search->{'field_name2'} eq 'publicationyear') {
				$query = " \@and ".$query;
				$condition2.= " \@attr 1=30 ".$search->{'field_value2'};
				} 
					$query .=$condition2;
				

			}

			#search_field 3
			if ($search->{'field_value3'}) {
			$search->{'field_value3'}=~ s/(\.|\?|\;|\=|\/|\\|\||\:|\!|,|\-|\"|\(|\)|\[|\]|\{|\}|\/)//g;
			if ($search->{'ttype3'} eq 'exact') {
			$attr3="\@attr 4=1   ";
				if ($search->{'atype1'} eq 'start'){
				$attr.=" \@attr 3=1 \@attr 6=3 \@attr 5=1 \@attr 2=102 ";
				}else{
				$attr.=" \@attr 5=1 \@attr 3=3 \@attr 6=1 \@attr 2=102 ";
				}
			} else {
			$attr3=" \@attr 4=6  \@attr 5=103 ";
			}
			
				if ($search->{'field_name3'} eq 'all') {
					if ($search->{'op2'} eq 'and') {
						$query = " \@and ".$query;
						$condition3.= " \@attr 1=1016 ".$attr3." \"".$search->{'field_value3'}."\" ";
					
					} elsif ($search->{'op2'} eq 'or') {
						$query = " \@or ".$query;
						$condition3.= " \@attr 1=1016 ".$attr3." \"".$search->{'field_value3'}."\" ";
					} else {
						$query = " \@not ".$query;
						$condition3.= " \@attr 1=1016 ".$attr3." \"".$search->{'field_value3'}."\" ";
					}
				} elsif ($search->{'field_name3'} eq 'author') {
					if ($search->{'op2'} eq 'and') {
						$query = " \@and ".$query;
						$condition3.= " \@attr 1=1003 ".$attr3." \"".$search->{'field_value3'}."\" ";
					
					} elsif ($search->{'op2'} eq 'or') {
						$query = " \@or ".$query;
						$condition3.= " \@attr 1=1003 ".$attr3." \"".$search->{'field_value3'}."\" ";
					} else {
						$query = " \@not ".$query;
						$condition3.= " \@attr 1=1003 ".$attr3." \"".$search->{'field_value3'}."\" ";
					}
					
				} elsif ($search->{'field_name3'} eq 'title') {
					if ($search->{'op2'} eq 'and') {
						$query = " \@and ".$query;
						$condition3.= " \@attr 1=4 ".$attr3." \"".$search->{'field_value3'}."\" ";
					
					} elsif ($search->{'op2'} eq 'or') {
						$query = " \@or ".$query;
						$condition3.= " \@attr 1=4 ".$attr3." \"".$search->{'field_value3'}."\" ";
					} else {
						$query = " \@not ".$query;
						$condition3.= " \@attr 1=4 ".$attr3." \"".$search->{'field_value3'}."\" ";
					}
					
				} elsif ($search->{'field_name3'} eq 'subject') {
					if ($search->{'op2'} eq 'and') {
						$query = " \@and ".$query;
						$condition3.= " \@attr 1=21 ".$attr3." \"".$search->{'field_value3'}."\" ";
					
					} elsif ($search->{'op2'} eq 'or') {
						$query = " \@or ".$query;
						$condition3.= " \@attr 1=21 ".$attr3." \"".$search->{'field_value3'}."\" ";
					} else {
						$query = " \@not ".$query;
						$condition3.= " \@attr 1=21 ".$attr3." \"".$search->{'field_value3'}."\" ";
					}
				} elsif ($search->{'field_name3'} eq 'series') {
                                        if ($search->{'op2'} eq 'and') {
                                                $query = " \@and ".$query;
                                                $condition3.= " \@attr 1=5 ".$attr3." \"".$search->{'field_value3'}."\" ";

                                        } elsif ($search->{'op2'} eq 'or') {
                                                $query = " \@or ".$query;
                                                $condition3.= " \@attr 1=5 ".$attr3." \"".$search->{'field_value3'}."\" ";
                                        } else {
                                                $query = " \@not ".$query;
                                                $condition3.= " \@attr 1=5 ".$attr3." \"".$search->{'field_value3'}."\" ";
                                        }
				} elsif ($search->{'field_name3'} eq 'callno') {
					if ($search->{'op2'} eq 'and') {
						$query = " \@and ".$query;
						$condition3.= " \@attr 1=20 \@attr 3=2 ".$attr3." \"".$search->{'field_value3'}."\" ";
					
					} elsif ($search->{'op2'} eq 'or') {
						$query = " \@or ".$query;
						$condition3.= " \@attr 1=20 \@attr 3=2 ".$attr3." \"".$search->{'field_value3'}."\" ";
					
					} else {
						$query = " \@not ".$query;
						$condition3.= " \@attr 1=20  \@attr 3=2 ".$attr3." \"".$search->{'field_value3'}."\" ";
					}
				
				
				} elsif ($search->{'field_name3'} eq 'publisher') {
				$query = " \@and ".$query;
				$condition3.= " \@attr 1=1018 ".$attr3." \"".$search->{'field_value3'}."\" ";
				} elsif ($search->{'field_name2'} eq 'publicationyear') {
				$query = " \@and ".$query;
				$condition3.= " \@attr 1=30 ".$search->{'field_value3'};
				}
					$query .=$condition3;
				

			}

			
			
			#search by class 
		if ($search->{'class'} ne '') {
			$query= "\@and ".$query;
			$query .= " \@attr 1=1031 \"".$search->{'class'}."\"";
			push @params, $search->{'class'};
		}
		#search by branch 
		if ($search->{'branch'} ne '') {
		$query= "\@and ".$query;
			$query .= " \@attr 1=1033 \"".$search->{'branch'}."\"";
#			
		}
		if ($search->{'stack'} ne '') {
			$query= "\@and ".$query;
			$query .= " \@attr 1=1019 \"".$search->{'stack'}."\"";
			
		}
		if ($search->{'date_from'} ne '') {
		$query= "\@and ".$query;
	        $query .= " \@attr 1=30 \@attr 2=4 \@attr 4=4 ".$search->{'date_from'};	
		}
    		if ($search->{'date_to'} ne '') {
    			     $query= "\@and ".$query;
	        $query .= " \@attr 1=30 \@attr 2=2 \@attr 4=4 ".$search->{'date_to'};			
			
			}

	}
	
	if ($cql) {
		warn "STILL CQL";
		$count_query = $cql_query;
		$query=1;
	} else {
		$count_query = $query;	
	}
	warn "QUERY_AFTER".$count_query;
	if ($search->{'order'}) {
		$query.=" ".$search->{'order'};
		$query=" \@or \@or ".$query;
	}
#warn $query;
	#execute the query and returns just the results between $num and $num + $offset
	my $limit = $num + $offset;
	my $startfrom = $offset;
return unless $query; ##Somebody hit the search button with no query. Prevent a system crash
my $oConnection=C4::Context->Zconn("biblioserver");
if ($oConnection eq "error"){
  return("error",undef);
 }
#$oConnection->option(preferredRecordSyntax => "XML");
my $oResult;
my $newq;
if ($cql) {
	warn "CQLISH:".$cql_query;
	if ($rpn) {
		$newq= new ZOOM::Query::PQF($cql_query);
	} else {
		$newq = new ZOOM::Query::CQL($cql_query,$oConnection);
	}
} else {
	$newq= new ZOOM::Query::PQF($query);
}
#my $order=$search->{'order'};
#if ($order){
#$newq->sortby("$order");
#}
eval {
$oResult= $oConnection->search($newq);
};
if($@){
   return("error",undef);
 }



 $numresults=$oResult->size() if  ($oResult);

    my $i = 0;

	#proccess just the results to show
	if ($numresults>0)  {
#Build brancnames hash
#find branchname
#get branch information.....
my %branches;
		my $bsth=$dbh->prepare("SELECT branchcode,branchname FROM branches");
		$bsth->execute();
		while (my $bdata=$bsth->fetchrow_hashref){
			$branches{$bdata->{'branchcode'}}= $bdata->{'branchname'};

		}

#Building shelving hash
my %shelves;
#find shelvingname
my $stackstatus = $dbh->prepare('select authorised_value from marc_subfield_structure where kohafield="items.stack"');
		$stackstatus->execute;
		
		my ($authorised_valuecode) = $stackstatus->fetchrow;
		if ($authorised_valuecode) {
			$stackstatus = $dbh->prepare("select lib,authorised_value from authorised_values where category=? ");
			$stackstatus->execute($authorised_valuecode);
			
			while (my $lib = $stackstatus->fetchrow_hashref){
			$shelves{$lib->{'authorised_value'}} = $lib->{'lib'};
			}
		}

#search item field code
        my $sth =
          $dbh->prepare(
"select tagfield from marc_subfield_structure where kohafield like 'items.itemnumber'"
        );
 $sth->execute;
 my ($itemtag) = $sth->fetchrow;
## find column names of items related to MARC
my $sth2=$dbh->prepare("SHOW COLUMNS from items");
	$sth2->execute;
my %subfieldstosearch;
while ((my $column)=$sth2->fetchrow){
my ($tagfield,$tagsubfield) = &MARCfind_marc_from_kohafield($dbh,"items.".$column,"");
$subfieldstosearch{$column}=$tagsubfield;
}

		for ($i=$startfrom; $i<(($startfrom+$num<=$numresults) ? ($startfrom+$num):$numresults) ; $i++){
	
			my $rec=$oResult->record($i);

		$marcdata = $rec->raw();
		my $marcrecord;					
	$marcrecord = MARC::File::USMARC::decode($marcdata);
#	$marcrecord=MARC::Record->new_from_xml( $marcdata,'UTF-8' );
#	$marcrecord->encoding( 'UTF-8' );
	my $oldbiblio = MARCmarc2koha($dbh,$marcrecord,'');
			
	&add_html_bold_fields($type,$oldbiblio,$search);	
	if ($i % 2) {
		$toggle="#ffffcc";
	} else {
		$toggle="white";
	}
	$oldbiblio->{'toggle'}=$toggle;

       
       
 my @fields = $marcrecord->field($itemtag);
my @items;
 my $item;
my %counts;
$counts{'total'}=0;

#	
##Loop for each item field
     foreach my $field (@fields) {
       foreach my $code ( keys %subfieldstosearch ) {

$item->{$code}=$field->subfield($subfieldstosearch{$code});
}

my $status;

$item->{'branchname'}=$branches{$item->{'holdingbranch'}};
$item->{'shelves'}=$shelves{$item->{stack}};
$status="Lost" if ($item->{'itemlost'}>0);
$status="Withdrawn" if ($item->{'wthdrawn'}>0);
if ($search->{'from'} eq "intranet"){
$search->{'avoidquerylog'}=1;
$status="Due:".format_date($item->{'onloan'}) if ($item->{'onloan'}>0);
 $status = $item->{'holdingbranch'}."-".$item->{'stack'}."[".$item->{'itemcallnumber'}."]" unless defined $status;
}else{
$status="On Loan" if ($item->{'onloan'}>0);
   $status = $item->{'branchname'}."[".$item->{'shelves'}."]" unless defined $status;
}
 $counts{$status}++;
$counts{'total'}++;
push @items,$item;
#$oldbiblio->{'itemcount'}++;
	}
		
		my $norequests = 1;
		my $noitems    = 1;
		if (@items) {
			$noitems = 0;
			foreach my $itm (@items) {
				$norequests = 0 unless $itm->{'itemnotforloan'};
			}
		}
		$oldbiblio->{'noitems'} = $noitems;
		$oldbiblio->{'norequests'} = $norequests;
		$oldbiblio->{'even'} = $even = not $even;
		$oldbiblio->{'itemcount'} = $counts{'total'};
		
		my $totalitemcounts = 0;
		foreach my $key (keys %counts){
			if ($key ne 'total'){	
				$totalitemcounts+= $counts{$key};
				$oldbiblio->{'locationhash'}->{$key}=$counts{$key};
			}
		}
		
		my ($locationtext, $locationtextonly, $notavailabletext) = ('','','');
		foreach (sort keys %{$oldbiblio->{'locationhash'}}) {
			if ($_ eq 'notavailable') {
				$notavailabletext="Not available";
				my $c=$oldbiblio->{'locationhash'}->{$_};
				$oldbiblio->{'not-available-p'}=$c;
			} else {
				$locationtext.="$_";
				my $c=$oldbiblio->{'locationhash'}->{$_};
				if ($_ eq 'Item Lost') {
					$oldbiblio->{'lost-p'} = $c;
				} elsif ($_ eq 'Withdrawn') {
					$oldbiblio->{'withdrawn-p'} = $c;
				} elsif ($_ eq 'On Loan') {
					$oldbiblio->{'on-loan-p'} = $c;
				} else {
					$locationtextonly.= $_;
					$locationtextonly.= " ($c)<br> " if $totalitemcounts > 1;
				}
				if ($totalitemcounts>1) {
					$locationtext.=" ($c)<br> ";
				}
			}
		}
		if ($notavailabletext) {
			$locationtext.= $notavailabletext;
		} else {
			$locationtext=~s/, $//;
		}
		$oldbiblio->{'location'} = $locationtext;
		$oldbiblio->{'location-only'} = $locationtextonly;
		$oldbiblio->{'use-location-flags-p'} = 1;

	push (@results, $oldbiblio);

		}
#		$i++;
	}
#$oConnection->destroy();
	my $count = $numresults;

	unless ($search->{'avoidquerylog'}) { 
		add_query_line($type, $search, $count);}
	return($count,@results);
}


sub FindDuplicate {
	my ($record)=@_;
my $dbh=C4::Context->dbh;
	my $result = MARCmarc2koha($dbh,$record,'');
	my $sth;
	my $query;
	my $search;
	my  $type;
	my ($biblionumber,$bibid,$title);
	# search duplicate on ISBN, easy and fast..
$search->{'avoidquerylog'}=1;
	if ($result->{isbn}) {
	$type="precise";
###Temporary fix for ISBN
my $isbn=$result->{isbn};
$isbn=~ s/(\.|\?|\;|\=|\/|\\|\||\:|\!|\'|,|\-|\"|\(|\)|\[|\]|\{|\}|\/)//g;
		$search->{'isbn'}=$isbn;
			}else{
$result->{title}=~s /\\//g;
$result->{title}=~s /\"//g;
	$type="loose";
	$search->{'field_name1'}="title";
	$search->{'field_value1'}=$result->{title};
	$search->{'ttype1'}="exact";
	$search->{'atype1'}="start";
	}
	my ($total,@result)=CatSearch4($type,$search,1,0);
		return $result[0]->{'biblionumber'}, $result[0]->{'biblionumber'},$result[0]->{'title'} if ($total);

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

sub KeywordSearch2 {
  my ($env,$type,$search,$num,$offset)=@_;
  my $dbh = C4::Context->dbh;
  $search->{'keyword'}=~ s/ +$//;
  my @key=split(' ',$search->{'keyword'});
  my $count=@key;
  my $i=1;
  my @results;
  my $query ="Select * from biblio,bibliosubtitle,biblioitems where
  biblio.biblionumber=biblioitems.biblionumber and
  biblio.biblionumber=bibliosubtitle.biblionumber and
  (((title like ? or title like ?)";
  my @bind=("$key[0]%","% $key[0]%");
  while ($i < $count){
    $query .= " and (title like ? or title like ?)";
    push(@bind,"$key[$i]%","% $key[$i]%");
    $i++;
  }
  $query.= ") or ((subtitle like ? or subtitle like ?)";
  push(@bind,"$key[0]%","% $key[0]%");
  for ($i=1;$i<$count;$i++){
    $query.= " and (subtitle like ? or subtitle like ?)";
    push(@bind,"$key[$i]%","% $key[$i]%");
  }
  $query.= ") or ((seriestitle like ? or seriestitle like ?)";
  push(@bind,"$key[0]%","% $key[0]%");
  for ($i=1;$i<$count;$i++){
    $query.=" and (seriestitle like ? or seriestitle like ?)";
    push(@bind,"$key[$i]%","% $key[$i]%");
  }
  $query.= ") or ((biblio.notes like ? or biblio.notes like ?)";
  push(@bind,"$key[0]%","% $key[0]%");
  for ($i=1;$i<$count;$i++){
    $query.=" and (biblio.notes like ? or biblio.notes like ?)";
    push(@bind,"$key[$i]%","% $key[$i]%");
  }
  $query.= ") or ((biblioitems.notes like ? or biblioitems.notes like ?)";
  push(@bind,"$key[0]%","% $key[0]%");
  for ($i=1;$i<$count;$i++){
    $query.=" and (biblioitems.notes like ? or biblioitems.notes like ?)";
    push(@bind,"$key[$i]%","% $key[$i]%");
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
    $query.= "and ( itemtype=?";
    push(@bind,"$temp[0]");
    for (my $i=1;$i<$count;$i++){
      $query.=" or itemtype=?";
      push(@bind,"$temp[$i]");
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
  $sth->execute(@bind);
  $i=0;
  while (my $data=$sth->fetchrow_hashref){
#FIXME: rewrite to use ? before uncomment
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
  like ? group by biblionumber");
  $sth->execute("%".$search->{'keyword'}."%");
  while (my $data=$sth->fetchrow_hashref){
    $query="Select * from biblio,biblioitems where
    biblio.biblionumber=? and
    biblio.biblionumber=biblioitems.biblionumber ";
    @bind=($data->{'biblionumber'});
    if ($search->{'class'} ne ''){
      my @temp=split(/\|/,$search->{'class'});
      my $count=@temp;
      $query.= " and ( itemtype=?";
      push(@bind,$temp[0]);
      for (my $i=1;$i<$count;$i++){
        $query.=" or itemtype=?";
        push(@bind,$temp[$i]);
      }
      $query.=")";

    }
    if ($search->{'dewey'} ne ''){
      $query.= "and (dewey like ?)";
      push(@bind,"$search->{'dewey'}%");
    }
    my $sth2=$dbh->prepare($query);
    $sth2->execute(@bind);
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


sub add_query_line {

	my ($type,$search,$results)=@_;
	my $dbh = C4::Context->dbh;
	my $searchdesc = '';
	my $from;
	my $borrowernumber = $search->{'borrowernumber'};
	my $remote_IP =	$search->{'remote_IP'};
	my $remote_URL=	$search->{'remote_URL'};
	my $searchmode = '';
	my $searchlinkdesc = '';
	
	if ($search->{'from'}) {
		$from = $search->{'from'};
	} else {
		$from = 'opac'
	}

	if ($type eq 'keyword') {
		$searchdesc = $search->{'keyword'};		
		if ($search->{'ttype'} eq 'exact') {
			$searchmode = 'phrase';
		} else {
			$searchmode = 'any word';
		}
		$searchlinkdesc.= "search_type=keyword&keyword=$search->{'keyword'}&ttype=$search->{'ttype'}";

	} elsif ($type eq 'precise') {
		if ($search->{'itemnumber'}) {
			$searchdesc = "barcode = $search->{'itemnumber'}";
			$searchlinkdesc.= "search_type=precise&itemnumber=$search->{'itemnumber'}";
		} else {
			$searchdesc = "isbn = $search->{'itemnumber'}";
			$searchlinkdesc.= "search_type=precise&itemnumber=$search->{'isbn'}";
		}

	} elsif ($type eq 'recently_items') {
		$searchdesc = "$search->{'range'}";
		$searchlinkdesc.= "recently_items=1&search=$search->{'range'}";
	} else {
		$searchlinkdesc.= "search_type=loose";	
		if ( ($search->{"field_name1"}) && ($search->{"field_value1"}) ) {
			if ($search->{"ttype1"} eq 'exact') {
				$searchmode.= ' starting with ';
			} else {
				$searchmode.= ' containing ';
			}
			$searchdesc.= " | " . $search->{"field_name1"} . " = " . $search->{"field_value1"} . " | ";
			$searchlinkdesc.= "&ttype=$search->{'ttype1'}&field_name1=$search->{'field_name1'}&field_value1=$search->{'field_value1'}";	
		}

		if ( ($search->{"field_name2"}) && ($search->{"field_value2"}) ) {
			if ($search->{"ttype2"} eq 'exact') {
				$searchmode.= ' | starting with ';
			} else {
				$searchmode.= ' | containing ';
			}
			$searchdesc.= uc($search->{"op1"});
			$searchdesc.= " | " . $search->{"field_name2"} . " = " . $search->{"field_value2"} . " | ";
			$searchlinkdesc.= "&op1=$search->{'op1'}&ttype=$search->{'ttype2'}&field_name2=$search->{'field_name2'}&field_value2=$search->{'field_value2'}";
		}

		if ( ($search->{"field_name3"}) && ($search->{"field_value3"}) ) {
			if ($search->{"ttype3"} eq 'exact') {
				$searchmode.= ' | starting with ';
			} else {
				$searchmode.= ' | containing ';
			}
			$searchdesc.= uc($search->{"op2"});
			$searchdesc.= " | " . $search->{"field_name3"} . " = " . $search->{"field_value3"} . " | ";
			$searchlinkdesc.= "&op2=$search->{'op2'}&ttype=$search->{'ttype3'}&field_name3=$search->{'field_name3'}&field_value3=$search->{'field_value3'}";
		}
	}

	if ($search->{'branch'}) {
		$searchdesc.= " AND branch = $search->{'branch'}"; 
		$searchlinkdesc.= "&branch=$search->{'branch'}";
	}
	if ($search->{'class'}) {
		$searchdesc.= " AND itemtype = $search->{'class'}"; 
		$searchlinkdesc.= "&class=$search->{'class'}";
	}

#	my $sth = $dbh->prepare("INSERT INTO querys_log (searchtype, searchdesc, searchmode, borrowernumber, number_of_results, date, execute_from, remote_IP, linkdesc) VALUES (?,?,?,?,?,NOW(),?,?,?)");
#	$sth->execute($type, $searchdesc, $searchmode, $borrowernumber, $results, $from, $remote_IP, $searchlinkdesc);
#	$sth->finish;
my $sth = $dbh->prepare("INSERT INTO phrase_log(phr_phrase,phr_resultcount,phr_ip,user,actual) VALUES(?,?,?,?,?)");
	

$sth->execute($searchdesc,$results,$remote_IP,$borrowernumber,$remote_URL);
$sth->finish;

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
			}elsif ($search->{'branch'} ne ''){
				$query = "Select * from biblio,items  where biblio.biblionumber
				=items.biblionumber and holdingbranch like ?";
				@bind=("$search->{'branch'}");
			}elsif ($search->{'class'} ne ''){
				$query="select * from biblioitems,biblio where biblio.biblionumber=biblioitems.biblionumber";
				
				$query.= " where itemtype= ?";
				@bind=("$search->{'class'}");
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
			$query = "Select * from biblio,biblioitems where biblio.biblionumber
				=biblioitems.biblionumber and (isbn like ?)";
				@bind=("$search->{'isbn'}%");
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
	my $query = "SELECT *,items.notforloan as itemnotforloan FROM items, biblio, biblioitems 
					left join itemtypes on biblioitems.itemtype = itemtypes.itemtype
					WHERE items.biblionumber = ?
					AND biblioitems.biblioitemnumber = items.biblioitemnumber
					AND biblio.biblionumber = items.biblionumber";
	$query .= " order by items.dateaccessioned desc";
	my $sth=$dbh->prepare($query);
	$sth->execute($biblionumber);
	my $i=0;
	my @results;
my ($date_due, $count_reserves);
	while (my $data=$sth->fetchrow_hashref){
		my $datedue = '';
		my $isth=$dbh->prepare("Select issues.*,borrowers.cardnumber from issues,borrowers where itemnumber = ? and returndate is null and issues.borrowernumber=borrowers.borrowernumber");
		$isth->execute($data->{'itemnumber'});
		if (my $idata=$isth->fetchrow_hashref){
		$data->{borrowernumber} = $idata->{borrowernumber};
		$data->{cardnumber} = $idata->{cardnumber};
		$datedue = format_date($idata->{'date_due'});
		}
		if ($datedue eq ''){
	#	$datedue="Available";
			my ($restype,$reserves)=C4::Reserves2::CheckReserves($data->{'itemnumber'});
			if ($restype) {
#				$datedue=$restype;
				$count_reserves = $restype;
			}
		}
		$isth->finish;
	#get branch information.....
		my $bsth=$dbh->prepare("SELECT * FROM branches WHERE branchcode = ?");
		$bsth->execute($data->{'holdingbranch'});
		if (my $bdata=$bsth->fetchrow_hashref){
			$data->{'branchname'} = $bdata->{'branchname'};
		}
		my $date=format_date($data->{'datelastseen'});
		$data->{'datelastseen'}=$date;
		$data->{'datedue'}=$datedue;
		$data->{'count_reserves'} = $count_reserves;
	# get notforloan complete status if applicable
		my $sthnflstatus = $dbh->prepare('select authorised_value from marc_subfield_structure where kohafield="items.notforloan"');
		$sthnflstatus->execute;
		my ($authorised_valuecode) = $sthnflstatus->fetchrow;
		if ($authorised_valuecode) {
			$sthnflstatus = $dbh->prepare("select lib from authorised_values where category=? and authorised_value=?");
			$sthnflstatus->execute($authorised_valuecode,$data->{itemnotforloan});
			my ($lib) = $sthnflstatus->fetchrow;
			$data->{notforloan} = $lib;
		}

# my stack procedures

		my $stackstatus = $dbh->prepare('select authorised_value from marc_subfield_structure where kohafield="items.stack"');
		$stackstatus->execute;
		
		($authorised_valuecode) = $stackstatus->fetchrow;
		if ($authorised_valuecode) {
			$stackstatus = $dbh->prepare("select lib from authorised_values where category=? and authorised_value=?");
			$stackstatus->execute($authorised_valuecode,$data->{stack});
			
			my ($lib) = $stackstatus->fetchrow;
			$data->{stack} = $lib;
		}
		$results[$i]=$data;
		$i++;
	}
	$sth->finish;

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
   my $sth=$dbh->prepare("Select * from biblioitems where (biblionumber = ?)");
   $sth->execute($biblionumber);
   #debug_msg($env,"executed query");
   my $i=0;
   my @results;
   while (my $data=$sth->fetchrow_hashref) {
      print ($env,$data->{'biblioitemnumber'});
      my $dewey = $data->{'dewey'};
      $dewey =~ s/0+$//;
	my $isbn= $data->{'isbn'};
	
	
      my $line = $data->{'biblioitemnumber'}."\t".$data->{'itemtype'};
      $line .= "\t$data->{'classification'}\t$dewey";
      $line .= "\t$data->{'subclass'}\t$data->{'isbn'}";
      $line .= "\t$data->{'volume'}\t$data->{number}";
      my $isth= $dbh->prepare("select * from items where biblioitemnumber = ?");
      $isth->execute($data->{'biblioitemnumber'});
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
  my $sth=$dbh->prepare("Select * from items,biblioitems where barcode=?
  and items.biblioitemnumber=biblioitems.biblioitemnumber");
  $sth->execute($barcode);
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
	my $sth   = $dbh->prepare("Select *, biblioitems.notes AS bnotes, biblio.notes
								from biblio, biblioitems
								left join bibliosubtitle on
								biblio.biblionumber = bibliosubtitle.biblionumber
								left join itemtypes on biblioitems.itemtype=itemtypes.itemtype
								where biblio.biblionumber = ?
								and biblioitems.biblionumber = biblio.biblionumber");
	$sth->execute($bibnum);
	my $data;
	$data  = $sth->fetchrow_hashref;
	$sth->finish;
	# handle management of repeated subtitle
	$sth   = $dbh->prepare("Select * from bibliosubtitle where biblionumber = ?");
	$sth->execute($bibnum);
	my @subtitles;
	while (my $dat = $sth->fetchrow_hashref){
		my %line;
		$line{subtitle} = $dat->{subtitle};
		push @subtitles, \%line;
	} # while
	$data->{subtitles} = \@subtitles;
	$sth->finish;
	$sth   = $dbh->prepare("Select * from bibliosubject where biblionumber = ?");
	$sth->execute($bibnum);
	my @subjects;
	while (my $dat = $sth->fetchrow_hashref){
		my %line;
		$line{subject} = $dat->{'subject'};
		push @subjects, \%line;
	} # while
	$data->{subjects} = \@subjects;
	$sth->finish;
	$sth   = $dbh->prepare("Select * from additionalauthors where biblionumber = ?");
	$sth->execute($bibnum);
	while (my $dat = $sth->fetchrow_hashref){
		$data->{'additionalauthors'} .= "$dat->{'author'} - ";
	} # while
	chop $data->{'additionalauthors'};
	chop $data->{'additionalauthors'};
	chop $data->{'additionalauthors'};
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
    my $sth   = $dbh->prepare("Select *,biblioitems.notes as bnotes from biblio, biblioitems,itemtypes where biblio.biblionumber = biblioitems.biblionumber and biblioitemnumber = ? and biblioitems.itemtype = itemtypes.itemtype");
    my $data;

    $sth->execute($bibitem);

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
  my $sth=$dbh->prepare("Select * from bibliosubject where biblionumber=?");
  $sth->execute($bibnum);
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
  my $sth=$dbh->prepare("Select * from additionalauthors where biblionumber=?");
  $sth->execute($bibnum);
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
  my $sth=$dbh->prepare("Select * from bibliosubtitle where biblionumber=?");
  $sth->execute($bibnum);
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
    # FIXME - If this function die()s, the script will abort, and the
    # user won't get anything; depending on how far the script has
    # gotten, the user might get a blank page. It would be much better
    # to at least print an error message. The easiest way to do this
    # is to set $SIG{__DIE__}.
    my $sth   = $dbh->prepare("Select * from items where
items.biblioitemnumber = ?")
      || die $dbh->errstr;
    my $i     = 0;
    my @results;

    $sth->execute($bibitem)
      || die $sth->errstr;

    while (my $data = $sth->fetchrow_hashref) {
        # Find out who currently has this item.
        # FIXME - Wouldn't it be better to do this as a left join of
        # some sort? Currently, this code assumes that if
        # fetchrow_hashref() fails, then the book is on the shelf.
        # fetchrow_hashref() can fail for any number of reasons (e.g.,
        # database server crash), not just because no items match the
        # search criteria.
        my $sth2   = $dbh->prepare("select * from issues,borrowers
where itemnumber = ?
and returndate is NULL
and issues.borrowernumber = borrowers.borrowernumber");

        $sth2->execute($data->{'itemnumber'});
        if (my $data2 = $sth2->fetchrow_hashref) {
            $data->{'date_due'} = $data2->{'date_due'};
            $data->{'card'}     = $data2->{'cardnumber'};
	    $data->{'borrower'}     = $data2->{'borrowernumber'};
        } else {
            if ($data->{'wthdrawn'} eq '1') {
                $data->{'date_due'} = 'Cancelled';
            } else {
                $data->{'date_due'} = 'Available';
            } # else
        } # else

        $sth2->finish;

        # Find the last 3 people who borrowed this item.
        $sth2 = $dbh->prepare("select * from issues, borrowers
						where itemnumber = ?
									and issues.borrowernumber = borrowers.borrowernumber
									and returndate is not NULL
									order by returndate desc,timestamp desc") ;
        $sth2->execute($data->{'itemnumber'}) ;
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
  my $sth=$dbh->prepare("Select * from biblio,items,biblioitems
    where items.itemnumber = ?
    and biblio.biblionumber = items.biblionumber
    and biblioitems.biblioitemnumber = items.biblioitemnumber");
#  print $query;
  $sth->execute($itemnumber);
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  return($data);
}

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
		$query="Select * from borrowers where surname like '$searchstring%' order by $orderby";
#		@bind=("$searchstring%");
	}
	else	# advanced search looking in surname, firstname and othernames
	{
### Try to determine whether numeric like cardnumber
	if ($searchstring+1>1) {
	$query="Select * from borrowers where  cardnumber  like '$searchstring%' ";

	}else{
	
	my @words=split / /,$searchstring;
	foreach my $word(@words){
	$word="+".$word;
	
	}
	$searchstring=join " ",@words;
	
		$query="Select * from borrowers where  MATCH(surname,firstname,othernames) AGAINST('$searchstring'  in boolean mode)";

	}
		$query=$query." order by $orderby";
	}

	my $sth=$dbh->prepare($query);
#	warn "Q $orderby : $query";
	$sth->execute();
	my @results;
	my $cnt=$sth->rows;
	while (my $data=$sth->fetchrow_hashref){
	push(@results,$data);
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
  my $sth;
if ($bornum eq ''&& $cardnumber eq ''){ return undef; }
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

sub borrdata3 {
  my ($env,$bornum)=@_;
  my $dbh = C4::Context->dbh;
  my $query="Select count(*) from  reserveissue as r where r.borrowernumber='$bornum' 
     and rettime is null";
    # print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $sth=$dbh->prepare("Select count(*),timediff(now(),  duetime  ) as elapsed, hour(timediff(now(),  duetime  )) as hours, MINUTE(timediff(now(),  duetime  )) as min from 
    reserveissue as r where  r.borrowernumber='$bornum' and rettime is null and duetime< now() group by r.borrowernumber");
  $sth->execute;

  my $data2=$sth->fetchrow_hashref;
my $resfine;
my $rescharge=C4::Context->preference('resmaterialcharge');
if (!$rescharge){
$rescharge=1;
}
if ($data2->{'elapsed'}>0){
 $resfine=($data2->{'hours'}+$data2->{'min'}/60)*$rescharge;
$resfine=sprintf  ("%.1f",$resfine);
}
  $sth->finish;
  $sth=$dbh->prepare("Select sum(amountoutstanding) from accountlines where
    borrowernumber='$bornum'");
  $sth->execute;
  my $data3=$sth->fetchrow_hashref;
  $sth->finish;


return($data2->{'count(*)'},$data->{'count(*)'},$data3->{'sum(amountoutstanding)'},$resfine);
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
  biblionumber=? ";
  if ($type ne 'intra'){
    $query.=" and ((itemlost <>1 and itemlost <> 2) or itemlost is NULL) and
    (wthdrawn <> 1 or wthdrawn is NULL)";
  }
  my $sth=$dbh->prepare($query);
  #  print $query;
  $sth->execute($bibnum);
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

    my $sth2=$dbh->prepare("select * from issues,items where issues.itemnumber=
    ? and returndate is NULL
    and items.itemnumber=issues.itemnumber and ((items.itemlost <>1 and
    items.itemlost <> 2) or items.itemlost is NULL)
    and (wthdrawn <> 1 or wthdrawn is NULL)");
    $sth2->execute($data->{'itemnumber'});
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
    my $sth2=$dbh->prepare("Select * from aqorders where biblionumber=?");
    $sth2->execute($bibnum);
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
  biblionumber=? and items.holdingbranch=branches.branchcode";
  if ($type ne 'intra'){
    $query.=" and ((itemlost <>1 and itemlost <> 2) or itemlost is NULL) and
    (wthdrawn <> 1 or wthdrawn is NULL)";
  }
  my $sth=$dbh->prepare($query);
  #  print $query;
  $sth->execute($bibnum);
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
## find the shelving name from stack
my $stackstatus = $dbh->prepare('select authorised_value from marc_subfield_structure where kohafield="items.stack"');
		$stackstatus->execute;
		
		my ($authorised_valuecode) = $stackstatus->fetchrow;
		if ($authorised_valuecode) {
			$stackstatus = $dbh->prepare("select lib from authorised_values where category=? and authorised_value=?");
			$stackstatus->execute($authorised_valuecode,$data->{stack});
			
			my ($lib) = $stackstatus->fetchrow;
			$data->{stack} = $lib;
		}

	
    $status = $data->{'branchname'}."[".$data->{'stack'}."]" unless defined $status;
    $counts{$status}++;

  }
  my $sth2=$dbh->prepare("Select * from aqorders where biblionumber=? and
  datecancellationprinted is NULL and quantity > quantityreceived");
  $sth2->execute($bibnum);
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
  my $sth=$dbh->prepare("select description from itemtypes where itemtype=?");
  $sth->execute($type);
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
    my $sth   = $dbh->prepare("SELECT biblioitems.*,
                        itemtypes.*,
                        MIN(items.itemlost)        as itemlost,
                        MIN(items.dateaccessioned) as dateaccessioned
                          FROM biblioitems, itemtypes, items
                         WHERE biblioitems.biblionumber     = ?
                           AND biblioitems.itemtype         = itemtypes.itemtype
                           AND biblioitems.biblioitemnumber = items.biblioitemnumber
                      GROUP BY items.biblioitemnumber");
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
    my $sth=$dbh->prepare("SELECT barcode, itemlost, holdingbranch,onloan,itemnumber  FROM items
                           WHERE biblioitemnumber = ?
                             AND (wthdrawn <> 1 OR wthdrawn IS NULL)");
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
    my $sth   = $dbh->prepare("Select * from websites where biblionumber = ?");
    my $count = 0;
    my @results;

    $sth->execute($biblionumber);
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
    my $sth   = $dbh->prepare("Select * from biblioitems where biblionumber = ?
and itemtype = 'WEB'");
    my $count = 0;
    my @results;

    $sth->execute($biblionumber);
    while (my $data = $sth->fetchrow_hashref) {
        $data->{'url'} =~ s/^http:\/\///;
        $results[$count] = $data;
        $count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub getwebbiblioitems



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
    my ($query,@bind);
    my $sth;
    my @results;

    $query = "Select distinct biblio.*, biblioitems.classification from biblio, biblioitems where
				biblio.biblionumber = biblioitems.biblionumber";
	@bind=();
	if ($isbn) {
		$query .= " and isbn like ?";
		@bind=(uc($isbn)."%");
	}
	if ($title) {
		$query .= " and title like ?";
		@bind=($title."%");
	}
    $sth   = $dbh->prepare($query);

    $sth->execute(@bind);
    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    return($count, @results);
} # sub isbnsearch

=item getbranchname

  $branchname = &getbranchname($branchcode);

Given the branch code, the function returns the corresponding
branch name for a comprehensive information display

=cut

sub getbranchname
{
	my ($branchcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT branchname FROM branches WHERE branchcode = ?");
	$sth->execute($branchcode);
	my $branchname = $sth->fetchrow();
	$sth->finish();
	return $branchname;
} # sub getbranchname

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

sub getborrowercategoryinfo
{
	my ($catcode) = @_;
	my $dbh = C4::Context->dbh;
	my $sth = $dbh->prepare("SELECT * FROM categories WHERE categorycode = ?");
	$sth->execute($catcode);
	my $category = $sth->fetchrow_hashref;
	$sth->finish();
	return $category;
} # sub getborrowercategoryinfo

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



	my $record=MARCgetbiblio($dbh,$bibid);

	my @marcnotes;
	my $note = "";
	my $tag = "";
	my $marcnote;

	foreach my $field ($record->field('5..')) {
		my $value = $field->as_string();
		if ( $note ne "") {
			$marcnote = {marcnote => $note,};
			push @marcnotes, $marcnote;
			$note=$value;
		}
		if ($note ne $value) {
		        $note = $note." ".$value;
		}
	}

	if ($note) {
	        $marcnote = {marcnote => $note};
		push @marcnotes, $marcnote;   #load last tag into array
	}



	my $marcnotesarray=\@marcnotes;
	return $marcnotesarray;
}  # end getMARCnotes


sub getMARCsubjects {
    my ($dbh, $bibid, $marcflavour) = @_;
	my ($mintag, $maxtag);
	if ($marcflavour eq "MARC21") {
	        $mintag = "600";
		$maxtag = "699";
	} else {           # assume unimarc if not marc21
		$mintag = "600";
		$maxtag = "619";
	}
	my $record=MARCgetbiblio($dbh,$bibid);
	my @marcsubjcts;
	my $subjct = "";
	my $subfield = "";
	my $marcsubjct;

	foreach my $field ($record->field('6..')) {
		#my $value = $field->subfield('a');
		#$marcsubjct = {MARCSUBJCT => $value,};
		$marcsubjct = {MARCSUBJCT => $field->as_string(),};
		push @marcsubjcts, $marcsubjct;
		#$subjct = $value;
		
	}
	my $marcsubjctsarray=\@marcsubjcts;
	return $marcsubjctsarray;
}  #end getMARCsubjects


sub getMARCurls {
    my ($dbh, $bibid, $marcflavour) = @_;
	my ($mintag, $maxtag);
	if ($marcflavour eq "MARC21") {
	        $mintag = "856";
		$maxtag = "856";
	} else {           # assume unimarc if not marc21
		$mintag = "600";
		$maxtag = "619";
	}

my $record=MARCgetbiblio($dbh,$bibid);
	my @marcurls;
	my $url = "";
	my $subfil = "";
	my $marcurl;

	foreach my $field ($record->field('856')) {
   
 
		my $value = $field->subfield('u');
#		my $subfil = $data->[1];
		if ( $value ne $url) {
		        $marcurl = {MARCURLS => $value,};
			push @marcurls, $marcurl;
			$url = $value;
		}
	}


	my $marcurlsarray=\@marcurls;
        return $marcurlsarray;
}  #end getMARCurls


sub searchZOOM {
    my ($search_or_scan,$type,$query,$num,$startfrom,$then_sort_by,$expanded_facet) = @_;
	# establish database connections
    my $dbh = C4::Context->dbh;
    my $zconn=C4::Context->Zconn("biblioserver");
	my $branches = GetBranches();
	# make sure all is well with the connection
    if ($zconn eq "error") {
        return("error with connection",undef); #FIXME: better error handling
    }

    my $zoom_query_obj;

	# prepare the query depending on the type
    if ($type eq 'ccl') {
		#$query =~ s/(\(|\))//g;
        eval {
        	$zoom_query_obj = new ZOOM::Query::CCL2RPN($query,$zconn);
		};
		if ($@) {
            return ("error: Sorry, there was a problem with your query: $@",undef); #FIXME: better error handling
		}
    } elsif ($type eq 'cql') {
        eval {
            $zoom_query_obj = new ZOOM::Query::CQL2RPN($query,$zconn);
        };
        if ($@) {
            return ("error: Sorry, there was a problem with your query: $@",undef); #FIXME: better error handling
        }
    } else {
        eval {
            $zoom_query_obj = new ZOOM::Query::PQF($query);
        };
        if ($@) {
            return("error with search: $@",undef); #FIXME: better error handling
        }
    }

    # PERFORM THE SEARCH OR SCAN
    my $result;
    my @results;
    my $numresults;
    if ($search_or_scan =~ /scan/) {
        eval {
            $result = $zconn->scan($zoom_query_obj);
        };
        if ($@) {
            return ("error with scan: $@",undef);
        }
    } else {
        eval {
            $result = $zconn->search($zoom_query_obj);
        };
        if ($@) {
            return("error with search: $@",undef); #FIXME: better error handling
        }
    }

    #### RESORT RESULT SET
    if ($then_sort_by) {
        $result->sort("yaz", "$then_sort_by")
    }
	### New Facets Stuff
	my $facets_counter = ();
	my $facets_info = ();
	my $facets = [ {
		link_value => 'su-t',
		label_value => 'Subject - Topic',
		tags => ['650', '651',],
		subfield => 'a',
		},
		{
        link_value => 'au',
        label_value => 'Authors',
        tags => ['100','700',],
        subfield => 'a',
		},
		{
        link_value => 'se',
        label_value => 'Series',
        tags => ['440','490',],
        subfield => 'a',
        },
		{
        link_value => 'branch',
        label_value => 'Branches',
        tags => ['952',],
        subfield => 'b',
		expanded => '1',
        },
	];

    #### INITIALIZE SOME VARS USED CREATE THE FACETED RESULTS
	my @facets_loop; # stores the ref to array of hashes for template
	#### LOOP THROUGH THE RESULTS	
    $numresults = 0 | $result->size() if  ($result);
    for ( my $i=$startfrom; $i<(($startfrom+$num<=$numresults) ? ($startfrom+$num):$numresults) ; $i++){
		## This is just an index scan
        if  ($search_or_scan =~ /scan/) {
            my ($term,$occ) = $result->term($i);
            # here we create a minimal MARC record and hand it off to the
            # template just like a normal result ... perhaps not ideal, but
            # it works for now FIXME: distinguish between MARC21 and UNIMARC
            use MARC::Record;
            my $tmprecord = MARC::Record->new();
            $tmprecord->encoding('UTF-8');
            my $tmptitle = MARC::Field->new( '245',' ',' ',
                        a => $term,
                        b => $occ);
			$tmprecord->append_fields($tmptitle);
            push @results, $tmprecord->as_usmarc();
		## This is a real search
        } else {
            my $rec = $result->record($i);
            push(@results,$rec->raw()) if $rec; #FIXME: sometimes this fails
			
            ##### BUILD FACETS AND LIMITS ####
			my $facet_record = MARC::Record->new_from_usmarc($rec->raw());

			for (my $i=0;$i<=@$facets;$i++) {
					if ($facets->[$i]) {
						my @fields;
						for my $tag (@{$facets->[$i]->{'tags'}}) {	
							push @fields, $facet_record->field($tag);
						}
						for my $field (@fields) {
							my @subfields = $field->subfields();
							for my $subfield (@subfields) {
								my ($code,$data) = @$subfield;
								if ($code eq $facets->[$i]->{'subfield'}) {
									$facets_counter->{ $facets->[$i]->{'link_value'} }->{ $data }++;
								}
							}	
						}	
						$facets_info->{ $facets->[$i]->{'link_value'} }->{ 'label_value' } = $facets->[$i]->{'label_value'};
						$facets_info->{ $facets->[$i]->{'link_value'} }->{ 'expanded' } = $facets->[$i]->{'expanded'};
					}
			}

        }
    }
	# BUILD FACETS
	for my $link_value ( sort { $facets_counter->{$b} <=> $facets_counter->{$a} } keys %$facets_counter) { 
		my $expandable;
		my $number_of_facets;
		my @this_facets_array;
		for my $one_facet (sort { $facets_counter->{ $link_value }->{$b} <=> $facets_counter->{ $link_value }->{$a} } keys %{$facets_counter->{ $link_value }} ) {
			$number_of_facets++;
			if (($number_of_facets < 6) || ($expanded_facet eq $link_value) || ($facets_info->{ $link_value }->{ 'expanded'})) {

				# sanitize the link value ), ( will cause errors with CCL
				my $facet_link_value = $one_facet;
				$facet_link_value =~ s/(\(|\))/ /g;

				# fix the length that will display in the label
				my $facet_label_value = $one_facet;
				$facet_label_value = substr($one_facet,0,20)."..." unless length($facet_label_value)<=20;
				# well, if it's a branch, label by the name, not the code
				if ($link_value =~/branch/) {
					warn "branch";
					$facet_label_value = $branches->{$one_facet}->{'branchname'};
				}
				
				# but we're down with the whole label being in the link's title
				my $facet_title_value = $one_facet;

				push @this_facets_array , 
				( { facet_count => $facets_counter->{ $link_value }->{ $one_facet }, 
					facet_label_value => $facet_label_value,
					facet_title_value => $facet_title_value,
					facet_link_value => $facet_link_value,
					type_link_value => $link_value,
					},
				);
				}
		}
		unless ($facets_info->{ $link_value }->{ 'expanded'}) {
			$expandable=1 if (($number_of_facets > 6) && ($expanded_facet ne $link_value));
		}
		push @facets_loop, 
		( {	type_link_value => $link_value,
			type_id => $link_value."_id",
			type_label  => $facets_info->{ $link_value }->{ 'label_value' },
			facets => \@this_facets_array,
			expandable => $expandable,
			expand => $link_value,
			}
		); 
	}

	return(undef,$numresults,\@facets_loop,@results);
}

sub getRecords {
    my ($zoom_query_ref,$sort_by_ref,$servers_ref,$count,$offset) = @_;
    my @zoom_query = @$zoom_query_ref;
    my @servers = @$servers_ref;
    my @sort_by = @$sort_by_ref;

    # build the query string
    my $zoom_query;
    foreach my $query (@zoom_query) {
        $zoom_query.="$query " if $query;
    }

    # create the zoom connection and query object
    my $zconn;
    my @zconns;
    my @results;
    my @results_array; # stores the final array of hashes of arrays
    for (my $i = 0; $i < @servers; $i++) {
        $zconns[$i] = new ZOOM::Connection($servers[$i], 0,
                                async => 1, # asynchronous mode
                                count => 1, # piggyback retrieval count
                                preferredRecordSyntax => "usmarc");
        $zconns[$i]->option(    cclfile=> "/koha/etc/ccl.properties");
        # perform the search, create the results objects
        $results[$i] = $zconns[$i]->search(new ZOOM::Query::CCL2RPN($zoom_query,$zconns[$i]));

        # concatenate the sort_by limits and pass them to the results object
        my $sort_by;
        foreach my $sort (@sort_by) {
            $sort_by.=$sort." "; # used to be $sort,
        }
        $results[$i]->sort("yaz", $sort_by) if $sort_by;
    }
    while ((my $i = ZOOM::event(\@zconns)) != 0) {
        my $ev = $zconns[$i-1]->last_event();
        #print("<td><tr>connection ", $i-1, ": ", ZOOM::event_str($ev), "</tr></td>\n");
        if ($ev == ZOOM::Event::ZEND) {
            my $size = $results[$i-1]->size();
            if ($size) {
                my $results_hash;
                $results_hash->{'server'} = $servers[$i-1];
                $results_hash->{'hits'} = $size;
                for ( my $j=$offset; $j<(($offset+$count<=$size) ? ($offset+$count):$size) ; $j++){
                    my $records_hash;
                    my $record = $results[$i-1]->record($j)->raw();
                    warn $record;
                    my ($error,$final_record) = changeEncoding($record,'MARC','MARC21','UTF-8');
                    $records_hash->{'record'} = $final_record;
                    $results_hash->{'RECORDS'}[$j] = $records_hash;
                    my $dbh = C4::Context->dbh;
                    use MARC::Record;
                    my $record_obj = MARC::Record->new_from_usmarc($final_record);
                    my $oldbiblio = MARCmarc2koha($dbh,$record_obj,'');
                    $results_hash->{'BIBLIOS'}[$j] = $oldbiblio;

                }
                push @results_array, $results_hash;
            }
            #print "connection ", $i-1, ": $size hits";
            #print $results[$i-1]->record(0)->render() if $size > 0;
        }
    }
    return (undef, @results_array);
}


sub buildQuery {
    my ($operators,$operands,$limits,$sort_by) = @_;
    my @operators = @$operators if $operators;
    my @operands = @$operands if $operands;
    my @limits = @$limits if $limits;
    my @sort_by = @$sort_by if $sort_by;
    my $previous_operand;   # a flag used to keep track if there was a previous query
                            # if there was, we can apply the current operator
    my @ccl;

    # construct the query with operators
    for (my $i=0; $i<=@operands; $i++) {
        if ($operands[$i]) {

            # only add an operator if there is a previous operand
            if ($previous_operand) {
                if ($operators[$i]) {
                    push @ccl,( {operator => $operators[$i], operand => $operands[$i]} );
                }

                # the default operator is and
                else {
                    push @ccl,( {operator => 'and', operand => $operands[$i]} );
                }
            }
            else {
                push @ccl, ( {operand => $operands[$i]} );
                $previous_operand = 1;
            }
        }
    }

    # add limits
    foreach my $limit (@limits) {
        push @ccl, ( {limit => $limit} ) if $limit;
    }

    return (undef,@ccl);
}
sub searchResults {
    my ($searchdesc,$num,$count,@marcresults)=@_;
    use C4::Date;

    my $dbh= C4::Context->dbh;
    my $toggle;
    my $even=1;
    my @newresults;
	my @span_terms = split (/ /, $searchdesc);
    #Build brancnames hash
    #find branchname
    #get branch information.....
    my %branches;
    my $bsth=$dbh->prepare("SELECT branchcode,branchname FROM branches");
    $bsth->execute();
    while (my $bdata=$bsth->fetchrow_hashref){
        $branches{$bdata->{'branchcode'}}= $bdata->{'branchname'};
    }

    #search item field code
    my $sth = $dbh->prepare(
        "select tagfield from marc_subfield_structure where kohafield like 'items.itemnumber'"
        );
    $sth->execute;
    my ($itemtag) = $sth->fetchrow;

    ## find column names of items related to MARC
    my $sth2=$dbh->prepare("SHOW COLUMNS from items");
    $sth2->execute;
    my %subfieldstosearch;
    while ((my $column)=$sth2->fetchrow){
        my ($tagfield,$tagsubfield) = &MARCfind_marc_from_kohafield($dbh,"items.".$column,"");
        $subfieldstosearch{$column}=$tagsubfield;
    }
    if ($num>$count) {
            $num = $count;
    }
    for ( my $i=0; $i<$num ; $i++){
        my $marcrecord;
        $marcrecord = MARC::File::USMARC::decode($marcresults[$i]);
        my $oldbiblio = MARCmarc2koha($dbh,$marcrecord,'');
		# add spans to search term in results
		foreach my $term (@span_terms) {
			if (length($term) > 3) {
				$term =~ s/(.*=|\)|\))//g;
				$oldbiblio->{'title'} =~ s/$term/<span class=term>$term<\/span>/gi;
				$oldbiblio->{'subtitle'} =~ s/$term/<span class=term>$term<\/span>/gi;
				$oldbiblio->{'author'} =~ s/$term/<span class=term>$term<\/span>/gi;
				$oldbiblio->{'publishercode'} =~ s/$term/<span class=term>$term<\/span>/gi;
				$oldbiblio->{'place'} =~ s/$term/<span class=term>$term<\/span>/gi;
				$oldbiblio->{'pages'} =~ s/$term/<span class=term>$term<\/span>/gi;
				$oldbiblio->{'notes'} =~ s/$term/<span class=term>$term<\/span>/gi;
				$oldbiblio->{'size'} =~ s/$term/<span class=term>$term<\/span>/gi;
			}
		}

        if ($i % 2) {
            $toggle="#ffffcc";
        } else {
            $toggle="white";
        }
        $oldbiblio->{'toggle'}=$toggle;
        my @fields = $marcrecord->field($itemtag);
        my @items;
        my $item;
        my %counts;
        $counts{'total'}=0;

#
##Loop for each item field
        foreach my $field (@fields) {
        foreach my $code ( keys %subfieldstosearch ) {

        $item->{$code}=$field->subfield($subfieldstosearch{$code});
        }

        my $status;
        $item->{'branchname'}=$branches{$item->{'homebranch'}};
        $item->{'date_due'}=$item->{onloan};
        $status="Lost" if ($item->{itemlost});
        $status="Withdrawn" if ($item->{wthdrawn});
        $status =" On loan" if ($item->{onloan});
        #$status="Due:".format_date($item->{onloan}) if ($item->{onloan}>0 );
        # $status="On Loan" if ($item->{onloan} );
        if ($item->{'location'}){
            $status = $item->{'branchname'}."[".$item->{'location'}."]" unless defined $status;
        }else{
            $status = $item->{'branchname'} unless defined $status;
        }
        $counts{$status}++;
        $counts{'total'}++;
        push @items,$item;
    }
    my $norequests = 1;
    my $noitems    = 1;
    if (@items) {
        $noitems = 0;
        foreach my $itm (@items) {
            $norequests = 0 unless $itm->{'itemnotforloan'};
        }
    }
    $oldbiblio->{'noitems'} = $noitems;
    $oldbiblio->{'norequests'} = $norequests;
    $oldbiblio->{'even'} = $even = not $even;
    $oldbiblio->{'itemcount'} = $counts{'total'};
    my $totalitemcounts = 0;
    foreach my $key (keys %counts){
        if ($key ne 'total'){
            $totalitemcounts+= $counts{$key};
            $oldbiblio->{'locationhash'}->{$key}=$counts{$key};
        }
    }
    my ($locationtext, $locationtextonly, $notavailabletext) = ('','','');
    foreach (sort keys %{$oldbiblio->{'locationhash'}}) {
        if ($_ eq 'notavailable') {
            $notavailabletext="Not available";
            my $c=$oldbiblio->{'locationhash'}->{$_};
            $oldbiblio->{'not-available-p'}=$c;
        } else {
            $locationtext.="$_";
            my $c=$oldbiblio->{'locationhash'}->{$_};
            if ($_ eq 'Item Lost') {
                $oldbiblio->{'lost-p'} = $c;
            } elsif ($_ eq 'Withdrawn') {
                $oldbiblio->{'withdrawn-p'} = $c;
            } elsif ($_ eq 'On Loan') {
                $oldbiblio->{'on-loan-p'} = $c;
            } else {
                $locationtextonly.= $_;
                $locationtextonly.= " ($c)<br/> " if $totalitemcounts > 1;
            }
            if ($totalitemcounts>1) {
                $locationtext.=" ($c)<br/> ";
            }
        }
    }
    if ($notavailabletext) {
        $locationtext.= $notavailabletext;
    } else {
        $locationtext=~s/, $//;
    }
    $oldbiblio->{'location'} = $locationtext;
    $oldbiblio->{'location-only'} = $locationtextonly;
    $oldbiblio->{'use-location-flags-p'} = 1;
    push (@newresults, $oldbiblio);

    }
    return @newresults;
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>

=cut
