package C4::Biblio; #assumes C4/Biblio.pm

# $Id$

#-----------------
# General requirements
use strict;

require Exporter;

# Other Koha modules
use C4::Database;

#-----------------

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(
	&newbiblio &newbiblioitem &newsubject &newsubtitle 
	&modbiblio &newitems &modbibitem
	&modsubtitle &modsubject &modaddauthor &moditem &countitems 
	&delitem &delbibitem &delbiblio 
	&checkitems &modnote &getitemtypes &getbiblio
	&findall &needsmod &updatecost 
	&getbiblioitem &getitemsbybiblioitem &isbnsearch &keywordsearch
	&websitesearch &addwebsite &updatewebsite &deletewebsite
	&newcompletebiblioitem 
	&getoraddbiblio 
);
%EXPORT_TAGS = ( );     # eg: TAG => [ qw!name1 name2! ],

# your exported package globals go here,
# as well as any optionally exported functions

@EXPORT_OK   = qw($Var1 %Hashit);


# non-exported package globals go here
use vars qw(@more $stuff);

# initalize package globals, first exported ones

my $Var1   = '';
my %Hashit = ();


# then the others (which are still accessible as $Some::Module::stuff)
my $stuff  = '';
my @more   = ();

# all file-scoped lexicals must be created before
# the functions below that use them.

# file-private lexicals go here
my $priv_var    = '';
my %secret_hash = ();

# here's a file-private function as a closure,
# callable as &$priv_func;  it cannot be prototyped.
my $priv_func = sub {
  # stuff goes here.
  };
  
# make all your functions, whether exported or not;
#------------------------------------------------

# Create a new biblio entry
sub newbiblio {
  my ($biblio) = @_;	# input is ref to hash of fields
  my ($bibnum,$error);		# return resulting biblio number

  $error="";

  my $dbh    = &C4Connect;

  # Get next biblionumber in sequence
  my $query  = "Select max(biblionumber) from biblio";
  my $sth    = $dbh->prepare($query);
  $sth->execute;
  my $data   = $sth->fetchrow_arrayref;
  $bibnum = $$data[0] + 1;

  my $serial;		# is this item part of a series?

  if ($biblio->{'seriestitle'}) { $serial = 1 } else { $serial = 0 };

  $sth->finish;
  $query = "insert into biblio set
	biblionumber  = ?,
	title         = ?,
	author        = ?,
	copyrightdate = ?,
	serial        = ?,
	seriestitle   = ?,
	notes         = ?   ";

#  print $query;
  $sth = $dbh->prepare($query);
  if (  $sth->execute(
    $bibnum,
    $biblio->{'title'},
    $biblio->{'author'},
    $biblio->{'copyright'},
    $serial,
    $biblio->{'seriestitle'} ,
    $biblio->{'notes'}	   
  )  ) {
	$error='';
  } else {
	$error=$sth->errstr;
  	$bibnum = ""; 
  } # if exec error

  $sth->finish;
  $dbh->disconnect;

  return($bibnum,$error);
}

sub modbiblio {
  my ($bibnum,$title,$author,$copyright,$seriestitle,$serial,$unititle,$notes)=@_;
  my $dbh=C4Connect;
  my $query = "Update biblio set
title         = '$title',
author        = '$author',
copyrightdate = '$copyright',
seriestitle   = '$seriestitle',
serial        = '$serial',
unititle      = '$unititle',
notes         = '$notes'
where biblionumber = $bibnum";
  my $sth=$dbh->prepare($query);

  $sth->execute;

  $sth->finish;
  $dbh->disconnect;
    return($bibnum);
}

sub modsubtitle {
  my ($bibnum,$subtitle)=@_;
  my $dbh=C4Connect;
  my $query="update bibliosubtitle set subtitle='$subtitle' where biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub modaddauthor {
  my ($bibnum,$author)=@_;
  my $dbh=C4Connect;
  my $query="Delete from additionalauthors where biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);

  $sth->execute;
  $sth->finish;

  if ($author ne ''){
        $query = "Insert into additionalauthors set
author       = '$author',
biblionumber = '$bibnum'";
    $sth=$dbh->prepare($query);

    $sth->execute;

    $sth->finish;
    } # if

  $dbh->disconnect;
} # sub modaddauthor


sub modsubject {
  my ($bibnum,$force,@subject)=@_;
  my $dbh=C4Connect;
  my $count=@subject;
  my $error;
  for (my $i=0;$i<$count;$i++){
    $subject[$i]=~ s/^ //g;
    $subject[$i]=~ s/ $//g;
    my $query = "select * from catalogueentry
where entrytype = 's'
and catalogueentry = '$subject[$i]'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
      
    if (my $data = $sth->fetchrow_hashref) {
    } else {
      if ($force eq $subject[$i]){

         #subject not in aut, chosen to force anway
	 #so insert into cataloguentry so its in auth file
	 $query = "Insert into catalogueentry
(entrytype,catalogueentry)
	 values ('s','$subject[$i]')";
	 my $sth2=$dbh->prepare($query);

	 $sth2->execute;
	 $sth2->finish;

      } else {      

        $error="$subject[$i]\n does not exist in the subject authority file";
        $query = "Select * from catalogueentry
where entrytype = 's'
and (catalogueentry like '$subject[$i] %'
or catalogueentry like '% $subject[$i] %'
or catalogueentry like '% $subject[$i]')";
        my $sth2=$dbh->prepare($query);

        $sth2->execute;
        while (my $data=$sth2->fetchrow_hashref){
          $error=$error."<br>$data->{'catalogueentry'}";
        } # while
        $sth2->finish;
      } # else
    } # else
    $sth->finish;
  } # else

  if ($error eq ''){  
    my $query="Delete from bibliosubject where biblionumber=$bibnum";
    my $sth=$dbh->prepare($query);

    $sth->execute;
    $sth->finish;

    for (my $i=0;$i<$count;$i++){
      $sth = $dbh->prepare("Insert into bibliosubject
values ('$subject[$i]', $bibnum)");

      $sth->execute;
      $sth->finish;
    } # for
  } # if

  $dbh->disconnect;
  return($error);
} # sub modsubject

sub modbibitem {
  my ($bibitemnum,$itemtype,$isbn,$publishercode,$publicationdate,$classification,$dewey,$subclass,$illus,$pages,$volumeddesc,$notes,$size,$place)=@_;
  my $dbh=C4Connect;
  my $query="update biblioitems set itemtype='$itemtype',
  isbn='$isbn',publishercode='$publishercode',publicationyear='$publicationdate',
  classification='$classification',dewey='$dewey',subclass='$subclass',illus='$illus',
  pages='$pages',volumeddesc='$volumeddesc',notes='$notes',size='$size',place='$place'
  where
  biblioitemnumber=$bibitemnum";
  my $sth=$dbh->prepare($query);
#    print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub modnote {
  my ($bibitemnum,$note)=@_;
  my $dbh=C4Connect;
  my $query="update biblioitems set notes='$note' where
  biblioitemnumber='$bibitemnum'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub newbiblioitem {
  my ($biblioitem) = @_;
  my $dbh   = C4Connect;
  my $data;
  my $bibitemnum;
  my $error;
  
  # Get next unused number
  my $query = "Select max(biblioitemnumber) from biblioitems";
  my $sth   = $dbh->prepare($query);
  $sth->execute;
  $data       = $sth->fetchrow_arrayref;
  $bibitemnum = $$data[0] + 1;
  $sth->finish;

  $query = "insert into biblioitems set
	biblioitemnumber = ?,
	biblionumber 	 = ?,
	volume		 = ?,
	number		 = ?,
	classification   = ?,
	itemtype         = ?,
	url              = ?,
	isbn		 = ?,
	issn		 = ?,
	lccn		 = ?,
	dewey		 = ?,
	subclass	 = ?,
	publicationyear	 = ?,
	publishercode	 = ?,
	volumedate	 = ?,
	volumeddesc	 = ?,
	illus		 = ?,
	pages		 = ?,
	notes		 = ?,
	size		 = ?,
	marc		 = ?,
	place		 = ?   ";

  $sth = $dbh->prepare($query);
  $sth->execute(
	$bibitemnum,
	$biblioitem->{'biblionumber'},
	$biblioitem->{'volume'},
	$biblioitem->{'number'},
	$biblioitem->{'classification'},
	$biblioitem->{'itemtype'},
	$biblioitem->{'url'},
	$biblioitem->{'isbn'},
	$biblioitem->{'issn'},
	$biblioitem->{'lccn'},
	$biblioitem->{'dewey'},
	$biblioitem->{'subclass'},
	$biblioitem->{'publicationyear'},
	$biblioitem->{'publishercode'},
	$biblioitem->{'volumedate'},
	$biblioitem->{'volumeddesc'},
	$biblioitem->{'illus'},
	$biblioitem->{'pages'},
	$biblioitem->{'notes'},
	$biblioitem->{'size'},
	$biblioitem->{'marc'},
	$biblioitem->{'place'},
  ) or $error=$sth->errstr;

  $sth->finish;
  $dbh->disconnect;
  return($bibitemnum);
} # sub newbiblioitem

sub newsubject {
  my ($bibnum)=@_;
  my $dbh=C4Connect;
  my $query="insert into bibliosubject (biblionumber) values
  ($bibnum)";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub newsubtitle {
  my ($bibnum, $subtitle) = @_;
  my $dbh   = C4Connect;
  $subtitle = $dbh->quote($subtitle);
  my $query = "insert into bibliosubtitle set
biblionumber = $bibnum,
subtitle = $subtitle";
  my $sth   = $dbh->prepare($query);

  $sth->execute;

  $sth->finish;
  $dbh->disconnect;
}

sub newitems {
  my ($item, @barcodes) = @_;
  my $dbh=C4Connect;
  my $query = "Select max(itemnumber) from items";
  my $sth   = $dbh->prepare($query);
  my $data;
  my $itemnumber;
  my $error;

  $sth->execute;
  $data       = $sth->fetchrow_hashref;
  $itemnumber = $data->{'max(itemnumber)'} + 1;
  $sth->finish;
  

  foreach my $barcode (@barcodes) {
    $barcode = uc($barcode);
    $query   = "Insert into items set
itemnumber           = ?,
biblionumber         = ?,
biblioitemnumber     = ?,
barcode              = ?,
booksellerid         = ?,
dateaccessioned      = NOW(),
homebranch           = ?,
holdingbranch        = ?,
price                = ?,
replacementprice     = ?,
replacementpricedate = NOW(),
itemnotes            = ?";

    if ($item->{'loan'}) {
      $query .= ",
notforloan           = $item->{'loan'}";
    } # if

    $sth = $dbh->prepare($query);
    $sth->execute(
    	$itemnumber,
	$item->{'biblionumber'},
	$item->{'biblioitemnumber'},
	$barcode,
	$item->{'booksellerid'},
	$item->{'homebranch'},
	$item->{'homebranch'},
	$item->{'price'},
	$item->{'replacementprice'},
	$item->{'itemnotes'}
    );

    $error=$sth->errstr;

    $sth->finish;
    $itemnumber++;
  } # for

  $dbh->disconnect;
  return($error);
}

sub checkitems{
  my ($count,@barcodes)=@_;
  my $dbh=C4Connect;
  my $error;
  for (my $i=0;$i<$count;$i++){
    $barcodes[$i]=uc $barcodes[$i];
    my $query="Select * from items where barcode='$barcodes[$i]'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    if (my $data=$sth->fetchrow_hashref){
      $error.=" Duplicate Barcode: $barcodes[$i]";
    }
    $sth->finish;
  }
  $dbh->disconnect;
  return($error);
}

sub moditem {
  my ($loan,$itemnum,$bibitemnum,$barcode,$notes,$homebranch,$lost,$wthdrawn,$replacement)=@_;
  my $dbh=C4Connect;
  my $query="update items set biblioitemnumber=$bibitemnum,
  barcode='$barcode',itemnotes='$notes'
  where itemnumber=$itemnum";
  if ($barcode eq ''){
    $query="update items set biblioitemnumber=$bibitemnum,notforloan=$loan where itemnumber=$itemnum";
  }
  if ($lost ne ''){
    $query="update items set biblioitemnumber=$bibitemnum,
      barcode='$barcode',itemnotes='$notes',homebranch='$homebranch',
      itemlost='$lost',wthdrawn='$wthdrawn' where itemnumber=$itemnum";
  }
  if ($replacement ne ''){
    $query=~ s/ where/,replacementprice='$replacement' where/;
  }

  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub updatecost{
  my($price,$rrp,$itemnum)=@_;
  my $dbh=C4Connect;
  my $query="update items set price='$price',replacementprice='$rrp'
  where itemnumber=$itemnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}
sub countitems{
  my ($bibitemnum)=@_;
  my $dbh=C4Connect;
  my $query="Select count(*) from items where biblioitemnumber='$bibitemnum'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data->{'count(*)'});
}

sub findall {
  my ($biblionumber)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblioitems,items,itemtypes where 
  biblioitems.biblionumber=$biblionumber 
  and biblioitems.biblioitemnumber=items.biblioitemnumber and
  itemtypes.itemtype=biblioitems.itemtype
  order by items.biblioitemnumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return(@results);
}

sub needsmod{
  my ($bibitemnum,$itemtype)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblioitems where biblioitemnumber=$bibitemnum
  and itemtype='$itemtype'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $result=0;
  if (my $data=$sth->fetchrow_hashref){
    $result=1;
  }
  $sth->finish;
  $dbh->disconnect;
  return($result);
}

sub delitem{
  my ($itemnum)=@_;
  my $dbh=C4Connect;
  my $query="select * from items where itemnumber=$itemnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @data=$sth->fetchrow_array;
  $sth->finish;
  $query="Insert into deleteditems values (";
  foreach my $temp (@data){
    $query=$query."'$temp',";
  }
  $query=~ s/\,$/\)/;
#  print $query;
  $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $query = "Delete from items where itemnumber=$itemnum";
  $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub delbibitem{
  my ($itemnum)=@_;
  my $dbh=C4Connect;
  my $query="select * from biblioitems where biblioitemnumber=$itemnum";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  if (my @data=$sth->fetchrow_array){
    $sth->finish;
    $query="Insert into deletedbiblioitems values (";
    foreach my $temp (@data){
      $temp=~ s/\'/\\\'/g;
      $query=$query."'$temp',";
    }
    $query=~ s/\,$/\)/;
#   print $query;
    $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
    $query = "Delete from biblioitems where biblioitemnumber=$itemnum";
    $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
  }
  $sth->finish;
  $dbh->disconnect;
}

sub delbiblio{
  my ($biblio)=@_;
  my $dbh=C4Connect;
  my $query="select * from biblio where biblionumber=$biblio";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  if (my @data=$sth->fetchrow_array){
    $sth->finish;
    $query="Insert into deletedbiblio values (";
    foreach my $temp (@data){
      $temp=~ s/\'/\\\'/g;
      $query=$query."'$temp',";
    }
    $query=~ s/\,$/\)/;
#   print $query;
    $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
    $query = "Delete from biblio where biblionumber=$biblio";
    $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
  }

  $sth->finish;
  $dbh->disconnect;
}

sub getitemtypes {
  my $dbh   = C4Connect;
  my $query = "select * from itemtypes";
  my $sth   = $dbh->prepare($query);
    # || die "Cannot prepare $query" . $dbh->errstr;
  my $count = 0;
  my @results;
  
  $sth->execute;
    # || die "Cannot execute $query\n" . $sth->errstr;
  while (my $data = $sth->fetchrow_hashref) {
    $results[$count] = $data;
    $count++;
  } # while
  
  $sth->finish;
  $dbh->disconnect;
  return($count, @results);
} # sub getitemtypes


sub getbiblio {
    my ($biblionumber) = @_;
    my $dbh   = C4Connect;
    my $query = "Select * from biblio where biblionumber = $biblionumber";
    my $sth   = $dbh->prepare($query);
      # || die "Cannot prepare $query\n" . $dbh->errstr;
    my $count = 0;
    my @results;
    
    $sth->execute;
      # || die "Cannot execute $query\n" . $sth->errstr;
    while (my $data = $sth->fetchrow_hashref) {
      $results[$count] = $data;
      $count++;
    } # while
    
    $sth->finish;
    $dbh->disconnect;
    return($count, @results);
} # sub getbiblio


sub getbiblioitem {
    my ($biblioitemnum) = @_;
    my $dbh   = C4Connect;
    my $query = "Select * from biblioitems where
biblioitemnumber = $biblioitemnum";
    my $sth   = $dbh->prepare($query);
    my $count = 0;
    my @results;

    $sth->execute;

    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    $dbh->disconnect;
    return($count, @results);
} # sub getbiblioitem


sub getitemsbybiblioitem {
    my ($biblioitemnum) = @_;
    my $dbh   = C4Connect;
    my $query = "Select * from items, biblio where
biblio.biblionumber = items.biblionumber and biblioitemnumber
= $biblioitemnum";
    my $sth   = $dbh->prepare($query);
      # || die "Cannot prepare $query\n" . $dbh->errstr;
    my $count = 0;
    my @results;
    
    $sth->execute;
      # || die "Cannot execute $query\n" . $sth->errstr;
    while (my $data = $sth->fetchrow_hashref) {
      $results[$count] = $data;
      $count++;
    } # while
    
    $sth->finish;
    $dbh->disconnect;
    return($count, @results);
} # sub getitemsbybiblioitem


sub isbnsearch {
    my ($isbn) = @_;
    my $dbh   = C4Connect;
    my $count = 0;
    my $query;
    my $sth;
    my @results;
    
    $isbn  = $dbh->quote($isbn);
    $query = "Select * from biblioitems where isbn = $isbn";
    $sth   = $dbh->prepare($query);
    
    $sth->execute;
    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    $dbh->disconnect;
    return($count, @results);
} # sub isbnsearch


sub keywordsearch {
  my ($keywordlist) = @_;
  my $dbh   = C4Connect;
  my $query = "Select * from biblio where";
  my $count = 0;
  my $sth;
  my @results;
  my @keywords = split(/ +/, $keywordlist);
  my $keyword = shift(@keywords);

  $keyword =~ s/%/\\%/g;
  $keyword =~ s/_/\\_/;
  $keyword = "%" . $keyword . "%";
  $keyword = $dbh->quote($keyword);
  $query  .= " (author like $keyword) or
(title like $keyword) or (unititle like $keyword) or
(notes like $keyword) or (seriestitle like $keyword) or
(abstract like $keyword)";

  foreach $keyword (@keywords) {
    $keyword =~ s/%/\\%/;
    $keyword =~ s/_/\\_/;
    $keyword = "%" . $keyword . "%";
    $keyword = $dbh->quote($keyword);
    $query  .= " or (author like $keyword) or
(title like $keyword) or (unititle like $keyword) or 
(notes like $keyword) or (seriestitle like $keyword) or
(abstract like $keyword)";
  } # foreach
  
  $sth = $dbh->prepare($query);
  $sth->execute;
  
  while (my $data = $sth->fetchrow_hashref) {
    $results[$count] = $data;
    $count++;
  } # while
  
  $sth->finish;
  $dbh->disconnect;
  return($count, @results);
} # sub keywordsearch


sub websitesearch {
    my ($keywordlist) = @_;
    my $dbh   = C4Connect;
    my $query = "Select distinct biblio.* from biblio, biblioitems where
biblio.biblionumber = biblioitems.biblionumber and (";
    my $count = 0;
    my $sth;
    my @results;
    my @keywords = split(/ +/, $keywordlist);
    my $keyword = shift(@keywords);

    $keyword =~ s/%/\\%/g;
    $keyword =~ s/_/\\_/;
    $keyword = "%" . $keyword . "%";
    $keyword = $dbh->quote($keyword);
    $query  .= " (url like $keyword)";

    foreach $keyword (@keywords) {
        $keyword =~ s/%/\\%/;
	$keyword =~ s/_/\\_/;
	$keyword = "%" . $keyword . "%";
        $keyword = $dbh->quote($keyword);
	$query  .= " or (url like $keyword)";
    } # foreach

    $query .= ")";
    $sth    = $dbh->prepare($query);
    $sth->execute;

    while (my $data = $sth->fetchrow_hashref) {
        $results[$count] = $data;
	$count++;
    } # while

    $sth->finish;
    $dbh->disconnect;
    return($count, @results);
} # sub websitesearch


sub addwebsite {
    my ($website) = @_;
    my $dbh = C4Connect;
    my $query;
    
    $website->{'biblionumber'} = $dbh->quote($website->{'biblionumber'});
    $website->{'title'}        = $dbh->quote($website->{'title'});
    $website->{'description'}  = $dbh->quote($website->{'description'});
    $website->{'url'}          = $dbh->quote($website->{'url'});
    
    $query = "Insert into websites set
biblionumber = $website->{'biblionumber'},
title        = $website->{'title'},
description  = $website->{'description'},
url          = $website->{'url'}";
    
    $dbh->do($query);
    
    $dbh->disconnect;
} # sub website


sub updatewebsite {
    my ($website) = @_;
    my $dbh = C4Connect;
    my $query;
    
    $website->{'title'}      = $dbh->quote($website->{'title'});
    $website->{'description'} = $dbh->quote($website->{'description'});
    $website->{'url'}        = $dbh->quote($website->{'url'});
    
    $query = "Update websites set
title       = $website->{'title'},
description = $website->{'description'},
url         = $website->{'url'}
where websitenumber = $website->{'websitenumber'}";

    $dbh->do($query);
    
    $dbh->disconnect;
} # sub updatewebsite


sub deletewebsite {
    my ($websitenumber) = @_;
    my $dbh = C4Connect;
    my $query = "Delete from websites where websitenumber = $websitenumber";
    
    $dbh->do($query);
    
    $dbh->disconnect;
} # sub deletewebsite




#------------------------------------------------

# Add a biblioitem and related data to Koha database
sub newcompletebiblioitem {
	use strict;

	my ( 
	  $dbh,			# DBI handle
	  $biblio,		# hash ref to biblio record
	  $biblioitem,		# hash ref to biblioitem record
	  $subjects,		# list ref of subjects
	  $addlauthors,		# list ref of additional authors
	)=@_ ;

	my ( $biblionumber, $biblioitemnumber, $error);		# return values

	my $debug=0;
	my $sth;
	my $subjectheading;
	my $additionalauthor;

	#--------
    	requireDBI($dbh,"newcompletebiblioitem");

	print "<PRE>Trying to add biblio item Title=$biblio->{title} " .
		"ISBN=$biblioitem->{isbn} </PRE>\n" if $debug;

	# Make sure master biblio entry exists
	($biblionumber,$error)=getoraddbiblio($dbh, $biblio);

        if ( ! $error ) { 

	  $biblioitem->{biblionumber}=$biblionumber;

	  # Add biblioitem
	  $biblioitemnumber=newbiblioitem($biblioitem);

	  # Add subjects
	  $sth=$dbh->prepare("insert into bibliosubject 
		(biblionumber,subject)
		values (?, ? )" );
	  foreach $subjectheading (@{$subjects} ) {
	      $sth->execute($biblionumber, $subjectheading) 
			or $error.=$sth->errstr ;
	
	  } # foreach subject

	  # Add additional authors
	  $sth=$dbh->prepare("insert into additionalauthors 
		(biblionumber,author)
		values (?, ? )");
	  foreach $additionalauthor (@{$addlauthors} ) {
	    $sth->execute($biblionumber, $additionalauthor) 
			or $error.=$sth->errstr ;
	  } # foreach author

	} else {
	  # couldn't get biblio
	  $biblionumber='';
	  $biblioitemnumber='';

	} # if no biblio error

	return ( $biblionumber, $biblioitemnumber, $error);

} # sub newcompletebiblioitem

#---------------------------------------
# Find a biblio entry, or create a new one if it doesn't exist.
#  If a "subtitle" entry is in hash, add it to subtitle table
sub getoraddbiblio {
	# input params
	my (
	  $dbh,		# db handle
	  $biblio,	# hash ref to fields
	)=@_;

	# return
	my $biblionumber;

	my $debug=0;
	my $sth;
	my $error;
	
	#-----
    	requireDBI($dbh,"getoraddbiblio");

	print "<PRE>Looking for biblio </PRE>\n" if $debug;
	$sth=$dbh->prepare("select biblionumber 
		from biblio 
		where title=? and author=? 
		  and copyrightdate=? and seriestitle=?");
	$sth->execute(
		$biblio->{title}, $biblio->{author}, 
		$biblio->{copyright}, $biblio->{seriestitle} );
	if ($sth->rows) {
	    ($biblionumber) = $sth->fetchrow;
	    print "<PRE>Biblio exists with number $biblionumber</PRE>\n" if $debug;
	} else {
	    # Doesn't exist.  Add new one.
	    print "<PRE>Adding biblio</PRE>\n" if $debug;
	    ($biblionumber,$error)=&newbiblio($biblio);
	    if ( $biblionumber ) {
	      print "<PRE>Added with biblio number=$biblionumber</PRE>\n" if $debug;
	      if ( $biblio->{subtitle} ) {
	    	&newsubtitle($biblionumber,$biblio->{subtitle} );
	      } # if subtitle
	    } else {
		print "<PRE>Couldn't add biblio: $error</PRE>\n" if $debug;
	    } # if added
	}

	return $biblionumber,$error;

} # sub getoraddbiblio

END { }       # module clean-up code here (global destructor)

#---------------------------------------
# $Log$
# Revision 1.1.2.4  2002/06/26 22:13:49  tonnesen
# Fix to allow non-numeric barcodes.
#
# Revision 1.1.2.3  2002/06/26 07:24:12  amillar
# New subs to streamline biblio additions: addcompletebiblioitem and getoraddbiblio
#
