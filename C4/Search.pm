package C4::Search;

# Copyright 2000-2002 Katipo Communications
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
use C4::Reserves2;
use C4::Biblio;
use Date::Calc;
use Encode;
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

  my ($count, @results) = catalogsearch4($env, $type, $search, $num, $offset);

=head1 DESCRIPTION

This module provides the searching facilities for the Koha catalog and
ZEBRA databases.



=head1 FUNCTIONS

=over 2

=cut

@ISA = qw(Exporter);
@EXPORT = qw(
 &barcodes   &ItemInfo &itemcount
 &getcoverPhoto &add_query_line
 &FindDuplicate   &ZEBRAsearch_kohafields &sqlsearch &cataloguing_search
&getMARCnotes &getMARCsubjects &getMARCurls &parsefields);
# make all your functions, whether exported or not;

=item
ZEBRAsearchkohafields is the underlying API for searching zebra for KOHA internal use
its kept similar to earlier version Koha Marc searches. instead of passing marc tags to the routine
you pass named kohafields
So you give an array of @kohafieldnames,@values, what relation they have @relations (equal, truncation etc) @and_or and
you receive an array of XML records.
The routine also has a flag $fordisplay and if it is set to 1 it will return the @results as an array of Perl hashes so that your previous
search results templates do actually work.
However more advanced search frontends will be available and this routine can serve as the connecting API for circulation and serials management
See sub FindDuplicates for an example;
=cut




sub ZEBRAsearch_kohafields{
my ($kohafield,$value, $relation,$sort, $and_or, $fordisplay,$reorder,$startfrom,$number_of_results,$searchfrom)=@_;
return (0,undef) unless (@$value[0]);
my $server="biblioserver";
my @results;
my $attr;
my $query;


my $i;
	for ( $i=0; $i<=$#{$value}; $i++){
	last if (@$value[$i] eq "");

	my $keyattr=MARCfind_attr_from_kohafield(@$kohafield[$i]) if (@$kohafield[$i]);
	if (!$keyattr){$keyattr=" \@attr 1=any";}
	@$value[$i]=~ s/(\.|\?|\;|\=|\/|\\|\||\:|\*|\!|\,|\(|\)|\[|\]|\{|\}|\/)/ /g;
	$query.=@$relation[$i]." ".$keyattr." \"".@$value[$i]."\" " if @$value[$i];
	}
	for (my $z= 0;$z<=$#{$and_or};$z++){
	$query=@$and_or[$z]." ".$query if (@$value[$z+1] ne "");
	}


#warn $query;
my @oConnection;
($oConnection[0])=C4::Context->Zconn($server);



if ($reorder){
my (@sortpart)=split /,/,$reorder;
	if (@sortpart<2){
	push @sortpart,1; ##
	}
my ($sortattr)=MARCfind_attr_from_kohafield($sortpart[0]);
my @sortfield=split /@/,$sortattr; ## incase our $sortattr contains type modifiers
	$query.=" \@attr 7=".$sortpart[1]." \@".$sortfield[1]." 0";## 
	$query= "\@or ".$query;
}elsif ($sort){
my (@sortpart)=split /,/,$sort;
	if (@sortpart<2){
	push @sortpart,1; ## Ascending by default
	}
my ($sortattr)=MARCfind_attr_from_kohafield($sortpart[0]);
 my @sortfield=split /@/,$sortattr; ## incase our $sortattr contains type modifiers
	$query.=" \@attr 7=".$sortpart[1]." \@".$sortfield[1]." 0";## fix to accept secondary sort as well
	$query= "\@or ".$query;
}else{
 unless($query=~/4=109/){ ###ranked sort not valid for numeric fields
##Use Ranked sort
$query="\@attr 2=102 ".$query;
}
}
#warn $query;
my $oResult;

my $tried=0;

my $numresults;

retry:
$oResult= $oConnection[0]->search_pqf($query);
my $i;
my $event;
   while (($i = ZOOM::event(\@oConnection)) != 0) {
	$event = $oConnection[$i-1]->last_event();
	last if $event == ZOOM::Event::ZEND;
   }# while
	
	 my($error, $errmsg, $addinfo, $diagset) = $oConnection[0]->error_x();
	if ($error==10007 && $tried<3) {## timeout --another 30 looonng seconds for this update
		$tried=$tried+1;
		goto "retry";
	}elsif ($error==2 && $tried<2) {## timeout --temporary zebra error !whatever that means
		$tried=$tried+1;
		goto "retry";
	}elsif ($error){
		warn "Error-$server    /errcode:, $error, /MSG:,$errmsg,$addinfo \n";	
		$oResult->destroy();
		$oConnection[0]->destroy();
		return (undef,undef);
	}
my $dbh=C4::Context->dbh;
 $numresults=$oResult->size() ;

   if ($numresults>0){
	my $ri=0;
	my $z=0;

	$ri=$startfrom if $startfrom;
		for ( $ri; $ri<$numresults ; $ri++){
		my $xmlrecord=$oResult->record($ri)->raw();
		$xmlrecord=Encode::decode("utf8",$xmlrecord);
			 $xmlrecord=XML_xml2hash($xmlrecord);
			$z++;
			push @results,$xmlrecord;
			last if ($number_of_results &&  $z>=$number_of_results);
			
	
		}## for #numresults	
			if ($fordisplay){
			my (@parsed)=parsefields($dbh,$searchfrom,@results);
			return ($numresults,@parsed)  ;
			}
    }# if numresults

$oResult->destroy();
$oConnection[0]->destroy();
return ($numresults,@results)  ;
#return (0,undef);
}

=item add_bold_fields
After a search the searched keyword is <b>boldened</b> in the displayed search results if it exists in the title or author
It is now depreceated 
=cut
sub add_html_bold_fields {
	my ($type, $data, $search) = @_;
	foreach my $key ('title', 'author') {
		my $new_key; 
		
			$new_key = 'bold_' . $key;
			$data->{$new_key} = $data->{$key};
		
	
		my $key1;
		
			$key1 = $key;
		

		my @keys;
		my $i = 1;
		if ($type eq 'keyword') {
		my $newkey=$search->{'keyword'};
		$newkey=~s /\++//g;
		@keys = split " ", $newkey;
		} 
		my $count = @keys;
		for ($i = 0; $i < $count ; $i++) {
			
				if (($data->{$new_key} =~ /($keys[$i])/i) && (lc($keys[$i]) ne 'b') ) {
					my $word = $1;
					$data->{$new_key} =~ s/$word/<b>$word<\/b>/;
				}
			
		}
	}


}
 sub sqlsearch{
## This searches the SQL database only for biblionumber,itemnumber,barcode
### Not very useful on production but as a debug tool useful during system maturing for ZEBRA operations

my ($dbh,$search)=@_;
my $sth;
if ($search->{'barcode'} ne '') {
	$sth=$dbh->prepare("SELECT biblionumber from items  where  barcode=?");
	$sth->execute($search->{'barcode'});
}elsif ($search->{'itemnumber'} ne '') {
	$sth=$dbh->prepare("SELECT biblionumber from items  where itemnumber=?");
	$sth->execute($search->{'itemnumber'});
}elsif ($search->{'biblionumber'} ne '') {
	$sth=$dbh->prepare("SELECT biblionumber from biblio where biblionumber=?");
	$sth->execute($search->{'biblionumber'});
}else{
return (undef,undef);
}

 my $result=$sth->fetchrow_hashref;
return (1,$result) if $result;
}

sub cataloguing_search{
## This is an SQL based search designed to be used when adding a new biblio incase library sets
## preference zebraorsql to sql when adding a new biblio
my ($search,$num,$offset) = @_;
	my ($count,@results);
my $dbh=C4::Context->dbh;
#Prepare search
my $query;
my $condition="select SQL_CALC_FOUND_ROWS marcxml from biblio where ";
if ($search->{'isbn'} ne''){
$search->{'isbn'}=$search->{'isbn'}."%";
$query=$search->{'isbn'};
$condition.= "  isbn like ?  ";
}else{
return (0,undef) unless $search->{title};
$query=$search->{'title'};
$condition.= "  MATCH (title) AGAINST(? in BOOLEAN MODE )  ";
}
my $sth=$dbh->prepare($condition);
$sth->execute($query);
 my $nbresult=$dbh->prepare("SELECT FOUND_ROWS()");
 $nbresult->execute;
 my $count=$nbresult->fetchrow;
my $limit = $num + $offset;
my $startfrom = $offset;
my $i=0;
my @results;
while (my $marc=$sth->fetchrow){
	if (($i >= $startfrom) && ($i < $limit)) {
	my $record=XML_xml2hash_onerecord($marc);
	my $data=XMLmarc2koha_onerecord($dbh,$record,"biblios");
	push @results,$data;
	}
$i++;
last if $i==$limit;
}
return ($count,@results);
}



sub FindDuplicate {
	my ($xml)=@_;
my $dbh=C4::Context->dbh;
	my ($result) = XMLmarc2koha_onerecord($dbh,$xml,"biblios");
	my @kohafield;
	my @value;
	my @relation;
	my  @and_or;
	
	# search duplicate on ISBN, easy and fast..

	if ($result->{isbn}) {
	push @kohafield,"isbn";
###Temporary fix for ISBN
my $isbn=$result->{isbn};
$isbn=~ s/(\.|\?|\;|\=|\/|\\|\||\:|\!|\'|,|\-|\"|\*|\(|\)|\[|\]|\{|\}|\/)//g;
		push @value,$isbn;
			}else{
$result->{title}=~s /\\//g;
$result->{title}=~s /\"//g;
$result->{title}=~ s/(\.|\?|\;|\=|\/|\\|\||\:|\*|\!|\,|\-|\(|\)|\[|\]|\{|\}|\/)/ /g;
	
	push @kohafield,"title";
	push @value,$result->{title};
	push @relation,"\@attr 6=3 \@attr 4=1 \@attr 5=1"; ## right truncated,phrase,whole field

	}
	my ($total,@result)=ZEBRAsearch_kohafields(\@kohafield,\@value,\@relation,"",\@and_or,0,"",0,1);
if ($total){
my $title=XML_readline($result[0],"title","biblios") ;
my $biblionumber=XML_readline($result[0],"biblionumber","biblios") ;
		return $biblionumber,$title ;
}

}


sub add_query_line {

	my ($type,$search,$results)=@_;
	my $dbh = C4::Context->dbh;
	my $searchdesc = '';
	my $from;
	my $borrowernumber = $search->{'borrowernumber'};
	my $remote_IP =	$search->{'remote_IP'};
	my $remote_URL=	$search->{'remote_URL'};
	my $searchdesc = $search->{'searchdesc'};
	
my $sth = $dbh->prepare("INSERT INTO phrase_log(phr_phrase,phr_resultcount,phr_ip,user,actual) VALUES(?,?,?,?,?)");
	

$sth->execute($searchdesc,$results,$remote_IP,$borrowernumber,$remote_URL);
$sth->finish;

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
	my ($dbh,$data) = @_;
	my $i=0;
	my @results;
my ($date_due, $count_reserves);
		my $datedue = '';
		my $isth=$dbh->prepare("Select issues.*,borrowers.cardnumber from issues,borrowers where itemnumber = ? and returndate is null and issues.borrowernumber=borrowers.borrowernumber");
		$isth->execute($data->{'itemnumber'});
		if (my $idata=$isth->fetchrow_hashref){
		$data->{borrowernumber} = $idata->{borrowernumber};
		$data->{cardnumber} = $idata->{cardnumber};
		$datedue = format_date($idata->{'date_due'});
		}
		if ($datedue eq '' || $datedue eq "0000-00-00"){
		$datedue="";
			my ($restype,$reserves)=C4::Reserves2::CheckReserves($data->{'itemnumber'});
			if ($restype) {
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
		my $date=substr($data->{'datelastseen'},0,8);
		$data->{'datelastseen'}=format_date($date);
		$data->{'datedue'}=$datedue;
		$data->{'count_reserves'} = $count_reserves;
	# get notforloan complete status if applicable
		my ($tagfield,$tagsub)=MARCfind_marc_from_kohafield("notforloan","holdings");
		my $sthnflstatus = $dbh->prepare("select authorised_value from holdings_subfield_structure where tagfield='$tagfield' and tagsubfield='$tagsub'");
		$sthnflstatus->execute;
		my ($authorised_valuecode) = $sthnflstatus->fetchrow;
		if ($authorised_valuecode) {
			$sthnflstatus = $dbh->prepare("select lib from authorised_values where category=? and authorised_value=?");
			$sthnflstatus->execute($authorised_valuecode,$data->{itemnotforloan});
			my ($lib) = $sthnflstatus->fetchrow;
			$data->{notforloan} = $lib;
		}

# my shelf procedures
		my ($tagfield,$tagsubfield)=MARCfind_marc_from_kohafield("shelf","holdings");
		
		my $shelfstatus = $dbh->prepare("select authorised_value from holdings_subfield_structure where tagfield='$tagfield' and tagsubfield='$tagsubfield'");
$shelfstatus->execute;
		$authorised_valuecode = $shelfstatus->fetchrow;
		if ($authorised_valuecode) {
			$shelfstatus = $dbh->prepare("select lib from authorised_values where category=? and authorised_value=?");
			$shelfstatus->execute($authorised_valuecode,$data->{shelf});
			
			my ($lib) = $shelfstatus->fetchrow;
			$data->{shelf} = $lib;
		}
		
	

	return($data);
}





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
    my ($biblionumber)=@_;
#warn $biblionumber;
    my $dbh = C4::Context->dbh;
	my @kohafields;
	my @values;
	my @relations;
	my $sort;
	my @and_or;
	my @fields;
	push @kohafields, "biblionumber";
	push @values,$biblionumber;
	push @relations, " "," \@attr 2=1"; ## selecting wthdrawn less then 1
	push @and_or, "\@and";
		$sort="";
	my ($count,@results)=ZEBRAsearch_kohafields(\@kohafields,\@values,\@relations,$sort,\@and_or,"","");
push  @fields,"barcode","itemlost","itemnumber","date_due","wthdrawn","notforloan";
	my ($biblio,@items)=XMLmarc2koha($dbh,$results[0],"holdings", @fields); 
return(@items);
}





sub getMARCnotes {
##Requires a MARCXML as $record
        my ($dbh, $record, $marcflavour) = @_;

	my ($mintag, $maxtag);
	if ($marcflavour eq "MARC21") {
	        $mintag = "500";
		$maxtag = "599";
	} else {           # assume unimarc if not marc21
		$mintag = "300";
		$maxtag = "399";
	}
	my @marcnotes;
	foreach my $field ($mintag..$maxtag) {
	my @value=XML_readline_asarray($record,"","",$field,"");
	push @marcnotes, \@value;	
	}



	my $marcnotesarray=\@marcnotes;
	return $marcnotesarray;
}  # end getMARCnotes


sub getMARCsubjects {

    my ($dbh, $record, $marcflavour) = @_;
	my ($mintag, $maxtag);
	if ($marcflavour eq "MARC21") {
	        $mintag = "600";
		$maxtag = "699";
	} else {           # assume unimarc if not marc21
		$mintag = "600";
		$maxtag = "619";
	}
	my @marcsubjcts;
	my $subjct = "";
	my $subfield = "";
	my $marcsubjct;

	foreach my $field ($mintag..$maxtag) {
		my @value =XML_readline_asarray($record,"","",$field,"a");
			foreach my $subject (@value){
		        $marcsubjct = {MARCSUBJCT => $subject,};
			push @marcsubjcts, $marcsubjct;
			}
		
	}
	my $marcsubjctsarray=\@marcsubjcts;
        return $marcsubjctsarray;
}  #end getMARCsubjects


sub getMARCurls {
### This code is wrong only works with MARC21
    my ($dbh, $record, $marcflavour) = @_;
	my ($mintag, $maxtag);
	if ($marcflavour eq "MARC21") {
	        $mintag = "856";
		$maxtag = "856";
	} else {           # assume unimarc if not marc21
		$mintag = "600";
		$maxtag = "619";
	}

	my @marcurls;
	my $url = "";
	my $subfil = "";
	my $marcurl;
	my $value;
	foreach my $field ($mintag..$maxtag) {
		my @value =XML_readline_asarray($record,"","",$field,"a");
			foreach my $url (@value){
				if ( $value ne $url) {
		    	   	 $marcurl = {MARCURL => $url,};
				push @marcurls, $marcurl;
				 $value=$url;
				}
			}
	}


	my $marcurlsarray=\@marcurls;
        return $marcurlsarray;
}  #end getMARCurls



sub parsefields{
#pass this a  MARC record and it will parse it for display purposes
my ($dbh,$intranet,@marcrecords)=@_;
my @results;
my @items;
my $retrieve_from=C4::Context->preference('retrieve_from');
#Build brancnames hash  for displaying in OPAC - more user friendly
#find branchname
#get branch information.....
my %branches;
		my $bsth=$dbh->prepare("SELECT branchcode,branchname FROM branches");
		$bsth->execute();
		while (my $bdata=$bsth->fetchrow_hashref){
			$branches{$bdata->{'branchcode'}}= $bdata->{'branchname'};
		}

#Building shelving hash if library has shelves defined like junior section, non-fiction, audio-visual room etc
my %shelves;
#find shelvingname
my ($tagfield,$tagsubfield)=MARCfind_marc_from_kohafield("shelf","holdings");
my $shelfstatus = $dbh->prepare("select authorised_value from holdings_subfield_structure where tagfield='$tagfield' and tagsubfield='$tagsubfield'");
		$shelfstatus->execute;		
		my ($authorised_valuecode) = $shelfstatus->fetchrow;
		if ($authorised_valuecode) {
			$shelfstatus = $dbh->prepare("select lib,authorised_value from authorised_values where category=? ");
			$shelfstatus->execute($authorised_valuecode);			
			while (my $lib = $shelfstatus->fetchrow_hashref){
			$shelves{$lib->{'authorised_value'}} = $lib->{'lib'};
			}
		}
my $even=1;
foreach my $xml(@marcrecords){
#my $xml=XML_xml2hash($xmlrecord);
my @kohafields; ## just name those necessary for the result page
push @kohafields, "biblionumber","title","author","publishercode","classification","itemtype","copyrightdate", "holdingbranch","date_due","location","shelf","itemcallnumber","notforloan","itemlost","wthdrawn";
my ($oldbiblio,@itemrecords) = XMLmarc2koha($dbh,$xml,"",@kohafields);
my $bibliorecord;

my %counts;

$counts{'total'}=0;
my $noitems    = 1;
my $norequests = 1;
		##Loop for each item field
				
			foreach my $item (@itemrecords) {
 				$norequests = 0 unless $item->{'itemnotforloan'};
				$noitems = 0;
				my $status;
				#renaming some fields according to templates
				$item->{'branchname'}=$branches{$item->{'holdingbranch'}};
				$item->{'shelves'}=$shelves{$item->{'shelf'}};
				$status="Lost" if ($item->{'itemlost'}>0);
				$status="Withdrawn" if ($item->{'wthdrawn'}>0);
				if ($intranet eq "intranet"){ ## we give full itemcallnumber detail in intranet
				$status="Due:".format_date($item->{'date_due'}) if ($item->{'date_due'} gt "0000-00-00");
 				$status = $item->{'holdingbranch'}."-".$item->{'shelf'}."[".$item->{'itemcallnumber'}."]" unless defined $status;
 				}else{
				$status="On Loan" if ($item->{'date_due'} gt "0000-00-00");
				  $status = $item->{'branchname'}."[".$item->{'shelves'}."]" unless defined $status;
				}
				
				$counts{$status}++;
				$counts{'total'}++;
			}	
		$oldbiblio->{'noitems'} = $noitems;
		$oldbiblio->{'norequests'} = $norequests;
		$oldbiblio->{'even'} = $even;
		$even= not $even;
			if ($even){
			$oldbiblio->{'toggle'}="#ffffcc";
			} else {
			$oldbiblio->{'toggle'}="white";
			} ; ## some forms seems to use toggle
			
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
				if ($_ eq 'Lost') {
					$oldbiblio->{'lost-p'} = $c;
				} elsif ($_ eq 'Withdrawn') {
					$oldbiblio->{'withdrawn-p'} = $c;
				} elsif ($_  =~/\^Due:/) {

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
	push @results,$oldbiblio;
   
}## For each record received
	return(@results);
}

sub getcoverPhoto {
## return the address of a cover image if defined otherwise the amazon cover images
	my $record =shift  ;

	my $image=XML_readline_onerecord($record,"coverphoto","biblios");
	if ($image){
	return $image;
	}
# if there is no image put the amazon cover image adress

my $isbn=XML_readline_onerecord($record,"isbn","biblios");
return "http://images.amazon.com/images/P/".$isbn.".01.MZZZZZZZ.jpg";	
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



sub itemcount {
  my ($env,$bibnum,$type)=@_;
  my $dbh = C4::Context->dbh;
my @kohafield;
my @value;
my @relation;
my @and_or;
my $sort;
  my $query="Select * from items where
  biblionumber=? ";
push @kohafield,"biblionumber";
push @value,$bibnum;
 
my ($total,@result)=ZEBRAsearch_kohafields(\@kohafield,\@value, \@relation,"", \@and_or, 0);## there is only one record no need for $num or $offset
my @fields;## extract only the fields required
push @fields,"itemnumber","itemlost","wthdrawn","holdingbranch","date_due";
my ($biblio,@items)=XMLmarc2koha ($dbh,$result[0],"holdings",\@fields);
  my $count=0;
  my $lcount=0;
  my $nacount=0;
  my $fcount=0;
  my $scount=0;
  my $lostcount=0;
  my $mending=0;
  my $transit=0;
  my $ocount=0;
 foreach my $data(@items){
    if ($type ne "intra"){
  next if ($data->{itemlost} || $data->{wthdrawn});
    }  ## Probably trying to hide lost item from opac ?
    $count++;
   
## Now it seems we want to find those which are onloan 
    

    if ( $data->{date_due} gt "0000-00-00"){
       $nacount++;
	next;
    } 
### The rest of this code is hardcoded for Foxtrot Shanon etc. We urgently need a global understanding of these terms--TG
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
#  if ($count == 0){
    my $sth2=$dbh->prepare("Select * from aqorders where biblionumber=?");
    $sth2->execute($bibnum);
    if (my $data=$sth2->fetchrow_hashref){
      $ocount=$data->{'quantity'} - $data->{'quantityreceived'};
    }
#    $count+=$ocount;

  return ($count,$lcount,$nacount,$fcount,$scount,$lostcount,$mending,$transit,$ocount);
}

END { }       # module clean-up code here (global destructor)

1;
__END__

=back

=head1 AUTHOR

Koha Developement team <info@koha.org>
# New functions to comply with ZEBRA search and new KOHA 3 API added 2006 Tumer Garip tgarip@neu.edu.tr

=cut
