package C4::Acquisitions; #assumes C4/Acquisitions.pm

use strict;
require Exporter;
use C4::Database;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 0.01;

@ISA = qw(Exporter);
@EXPORT = qw(&getorders &bookseller &breakdown &basket &newbasket &bookfunds
&ordersearch &newbiblio &newbiblioitem &newsubject &newsubtitle &neworder
 &newordernum &modbiblio &modorder &getsingleorder &invoice &receiveorder
 &bookfundbreakdown &curconvert &updatesup &insertsup &makeitems &modbibitem
&getcurrencies &modsubtitle &modsubject &modaddauthor &moditem &countitems 
&findall &needsmod &delitem &delbibitem &delbiblio &delorder &branches
&getallorders &getrecorders &updatecurrencies &getorder &getcurrency &updaterecorder
&updatecost &checkitems &modnote &getitemtypes &getbiblio);

sub getorders {
  my ($supplierid)=@_;
  my $dbh=C4Connect;
  my $query = "Select count(*),authorisedby,entrydate,basketno from aqorders where 
  booksellerid='$supplierid' and (quantity > quantityreceived or
  quantityreceived is NULL)
  and (datecancellationprinted is NULL or datecancellationprinted = '0000-00-00')";
  $query.=" group by basketno order by entrydate desc";
  #print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return ($i,\@results);
}

sub itemcount{
  my ($biblio)=@_;
  my $dbh=C4Connect;
  my $query="Select count(*) from items where biblionumber=$biblio";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data->{'count(*)'});
}

sub getorder{
  my ($bi,$bib)=@_;
  my $dbh=C4Connect;
  my $query="Select ordernumber from aqorders where biblionumber=$bib and
  biblioitemnumber='$bi'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $ordnum=$sth->fetchrow_hashref;
  $sth->finish;
  my $order=getsingleorder($ordnum->{'ordernumber'});
  $dbh->disconnect;
#  print $query;
  return ($order,$ordnum->{'ordernumber'});
}

sub getsingleorder {
  my ($ordnum)=@_;
  my $dbh=C4Connect;
  my $query="Select * from biblio,biblioitems,aqorders,aqorderbreakdown 
  where aqorders.ordernumber='$ordnum' 
  and biblio.biblionumber=aqorders.biblionumber and
  biblioitems.biblioitemnumber=aqorders.biblioitemnumber and
  aqorders.ordernumber=aqorderbreakdown.ordernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
}

sub invoice {
  my ($invoice)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorders,biblio,biblioitems where
  booksellerinvoicenumber='$invoice' 
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber=
  aqorders.biblioitemnumber group by aqorders.ordernumber,aqorders.biblioitemnumber";
  my $i=0;
  my @results;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub getallorders {
  #gets all orders from a certain supplier, orders them alphabetically
  my ($supid)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorders,biblio,biblioitems where booksellerid='$supid'
  and (cancelledby is NULL or cancelledby = '')
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber=                    
  aqorders.biblioitemnumber 
  group by aqorders.biblioitemnumber 
  order by
  biblio.title";
  my $i=0;
  my @results;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub getrecorders {
  #gets all orders from a certain supplier, orders them alphabetically
  my ($supid)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorders,biblio,biblioitems where booksellerid='$supid'
  and (cancelledby is NULL or cancelledby = '')
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber=                    
  aqorders.biblioitemnumber and
  aqorders.quantityreceived>0
  and aqorders.datereceived >=now()
  group by aqorders.biblioitemnumber 
  order by
  biblio.title";
  my $i=0;
  my @results;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub ordersearch {
  my ($search,$biblio,$catview)=@_;
  my $dbh=C4Connect;
  my $query="Select *,biblio.title from aqorders,biblioitems,biblio
  where aqorders.biblioitemnumber=
  biblioitems.biblioitemnumber and biblio.biblionumber=aqorders.biblionumber 
  and (datecancellationprinted is NULL or datecancellationprinted =
'000-00-00')
  and ((";
  my @data=split(' ',$search);
  my $count=@data;
  for (my $i=0;$i<$count;$i++){
    $query.= "(biblio.title like '$data[$i]%' or biblio.title like '% $data[$i]%') and ";
  }
  $query=~ s/ and $//;
  $query.=" ) or biblioitems.isbn='$search' 
  or (aqorders.ordernumber='$search' and aqorders.biblionumber='$biblio')) ";
  if ($catview ne 'yes'){
    $query.=" and (quantityreceived < quantity or quantityreceived is NULL)";
  }
  $query.=" group by aqorders.ordernumber";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  my $i=0;
  my @results;
  while (my $data=$sth->fetchrow_hashref){
     my $sth2=$dbh->prepare("Select * from biblio where
     biblionumber='$data->{'biblionumber'}'");
     $sth2->execute;
     my $data2=$sth2->fetchrow_hashref;
     $sth2->finish;
     $data->{'author'}=$data2->{'author'};
     $data->{'seriestitle'}=$data2->{'seriestitle'};
     $sth2=$dbh->prepare("Select * from aqorderbreakdown where
    ordernumber=$data->{'ordernumber'}");
    $sth2->execute;
    $data2=$sth2->fetchrow_hashref;
    $sth2->finish;
    $data->{'branchcode'}=$data2->{'branchcode'};
    $data->{'bookfundid'}=$data2->{'bookfundid'};
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}


sub bookseller {
  my ($searchstring)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqbooksellers where name like '%$searchstring%' or
  id = '$searchstring'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub breakdown {
  my ($id)=@_;
  my $dbh=C4Connect;
  my $query="Select * from aqorderbreakdown where ordernumber='$id'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@results);
}

sub basket {
  my ($basketno,$supplier)=@_;
  my $dbh=C4Connect;
  my $query="Select *,biblio.title from aqorders,biblio,biblioitems 
  where basketno='$basketno'
  and biblio.biblionumber=aqorders.biblionumber and biblioitems.biblioitemnumber
  =aqorders.biblioitemnumber 
  and (datecancellationprinted is NULL or datecancellationprinted =
  '0000-00-00')";
  if ($supplier ne ''){
    $query.=" and aqorders.booksellerid='$supplier'";
  } 
  $query.=" group by aqorders.ordernumber";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
#  print $query;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub newbasket {
  my $dbh=C4Connect;
  my $query="Select max(basketno) from aqorders";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_arrayref;
  my $basket=$$data[0];
  $basket++;
  $sth->finish;
  $dbh->disconnect;
  return($basket);
}

sub bookfunds {
  my $dbh=C4Connect;
  my $query="Select * from aqbookfund,aqbudget where aqbookfund.bookfundid
  =aqbudget.bookfundid 
  and aqbudget.startdate='2001=07-01' 
  group by aqbookfund.bookfundid order by bookfundname";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub branches {
  my $dbh=C4Connect;
  my $query="Select * from branches";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,@results);
}

sub bookfundbreakdown {
  my ($id)=@_;
  my $dbh=C4Connect;
  my $query="Select quantity,datereceived,freight,unitprice,listprice,ecost,quantityreceived,subscription
  from aqorders,aqorderbreakdown where bookfundid='$id' and 
  aqorders.ordernumber=aqorderbreakdown.ordernumber and ((budgetdate >=
  '2001-07-01' and budgetdate <'2002-07-01') or
  (datereceived >= '2001-07-01' and datereceived < '2002-07-01'))
  and (datecancellationprinted is NULL or
  datecancellationprinted='0000-00-00')";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $comtd=0;
  my $spent=0;
  while (my $data=$sth->fetchrow_hashref){
    if ($data->{'subscription'} == 1){
      $spent+=$data->{'quantity'}*$data->{'unitprice'};
    } else {
      my $leftover=$data->{'quantity'}-$data->{'quantityreceived'};
      $comtd+=($data->{'ecost'})*$leftover;
      $spent+=($data->{'unitprice'})*$data->{'quantityreceived'};
    }
  }
  $sth->finish;
  $dbh->disconnect;
  return($spent,$comtd);
}
      

sub newbiblio {
  my ($biblio) = @_;
  my $dbh    = &C4Connect;
  my $query  = "Select max(biblionumber) from biblio";
  my $sth    = $dbh->prepare($query);
  $sth->execute;
  my $data   = $sth->fetchrow_arrayref;
  my $bibnum = $$data[0] + 1;
  my $series = 0;

  $biblio->{'title'}       = $dbh->quote($biblio->{'title'});
  $biblio->{'author'}      = $dbh->quote($biblio->{'author'});
  $biblio->{'copyright'}   = $dbh->quote($biblio->{'copyright'});
  $biblio->{'seriestitle'} = $dbh->quote($biblio->{'seriestitle'});
  $biblio->{'notes'}	   = $dbh->quote($biblio->{'notes'});
  if ($biblio->{'seriestitle'}) { $series = 1 };

  $sth->finish;
  $query = "insert into biblio set
biblionumber  = $bibnum,
title         = $biblio->{'title'},
author        = $biblio->{'author'},
copyrightdate = $biblio->{'copyright'},
series        = $series;
seriestitle   = $biblio->{'seriestitle'},
notes         = $biblio->{'notes'}";

  $sth = $dbh->prepare($query);
#  print $query;
  $sth->execute;

  $sth->finish;
  $dbh->disconnect;
  return($bibnum);
}

sub modbiblio {
  my ($bibnum,$title,$author,$copyright,$seriestitle,$serial,$unititle,$notes)=@_;
  my $dbh=C4Connect;
  my $query="update biblio set title='$title',
  author='$author',copyrightdate='$copyright',
  seriestitle='$seriestitle',serial='$serial',unititle='$unititle',notes='$notes'
  where
  biblionumber=$bibnum";
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
      $query="insert into additionalauthors (author,biblionumber) values ('$author','$bibnum')";
    $sth=$dbh->prepare($query);
    $sth->execute;
    $sth->finish;
  }
  $dbh->disconnect;
} 

sub modsubject {
  my ($bibnum,$force,@subject)=@_;
  my $dbh=C4Connect;
  my $count=@subject;
  my $error;
  for (my $i=0;$i<$count;$i++){
    $subject[$i]=~ s/^ //g;
    $subject[$i]=~ s/ $//g;
    my $query="select * from catalogueentry where entrytype='s' and
    catalogueentry='$subject[$i]'";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    if (my $data=$sth->fetchrow_hashref){
      
    } else {
      if ($force eq $subject[$i]){
         #subject not in aut, chosen to force anway
	 #so insert into cataloguentry so its in auth file
	 $query="Insert into catalogueentry (entrytype,catalogueentry)
	 values ('s','$subject[$i]')";
	 my $sth2=$dbh->prepare($query);
#	 print $query;
	 $sth2->execute;
	 $sth2->finish;
      } else {      
        $error="$subject[$i]\n does not exist in the subject authority file";
        $query= "Select * from catalogueentry where
        entrytype='s' and (catalogueentry like '$subject[$i] %' or 
        catalogueentry like '% $subject[$i] %' or catalogueentry like
        '% $subject[$i]')";
        my $sth2=$dbh->prepare($query);
#        print $query;
        $sth2->execute;
        while (my $data=$sth2->fetchrow_hashref){
          $error=$error."<br>$data->{'catalogueentry'}";
        }
        $sth2->finish;
#       $error=$error."<br>$query";
     }
   }
    $sth->finish;
  }
  if ($error eq ''){  
    my $query="Delete from bibliosubject where biblionumber=$bibnum";
#  print $query;
    my $sth=$dbh->prepare($query);
#  print $query;
    $sth->execute;
    $sth->finish;
    for (my $i=0;$i<$count;$i++){
      $sth=$dbh->prepare("Insert into bibliosubject values ('$subject[$i]',$bibnum)");
#     print $subject[$i];
      $sth->execute;
      $sth->finish;
    }
  }
  $dbh->disconnect;
  return($error);
}

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
  my $query = "Select max(biblioitemnumber) from biblioitems";
  my $sth   = $dbh->prepare($query);
  my $data;
  my $bibitemnum;
  
  $biblioitem->{'volume'}          = $dbh->quote($biblioitem->{'volume'});
  $biblioitem->{'number'} 	   = $dbh->quote($biblioitem->{'number'});
  $biblioitem->{'classification'}  = $dbh->quote($biblioitem->{'classification'});
  $biblioitem->{'itemtype'}        = $dbh->quote($biblioitem->{'itemtype'});
  $biblioitem->{'isbn'}            = $dbh->quote($biblioitem->{'isbn'});
  $biblioitem->{'issn'}            = $dbh->quote($biblioitem->{'issn'});
  $biblioitem->{'dewey'}           = $dbh->quote($biblioitem->{'dewey'});
  $biblioitem->{'subclass'}        = $dbh->quote($biblioitem->{'subclass'});
  $biblioitem->{'publicationyear'} = $dbh->quote($biblioitem->{'publicationyear'});
  $biblioitem->{'publishercode'}   = $dbh->quote($biblioitem->{'publishercode'});
  $biblioitem->{'volumedate'}      = $dbh->quote($biblioitem->{'volumedate'});
  $biblioitem->{'volumeddesc'}     = $dbh->quote($biblioitem->{'volumeddesc'});  $biblioitem->{'illus'}            = $dbh->quote($biblioitem->{'illus'});
  $biblioitem->{'pages'}           = $dbh->quote($biblioitem->{'pages'});
  $biblioitem->{'notes'}           = $dbh->quote($biblioitem->{'notes'});
  $biblioitem->{'size'}            = $dbh->quote($biblioitem->{'size'});
  $biblioitem->{'place'}           = $dbh->quote($biblioitem->{'place'});
  
  $sth->execute;
  $data       = $sth->fetchrow_arrayref;
  $bibitemnum = $$data[0] + 1;

  $sth->finish;

  $query = "insert into biblioitems set
biblioitemnumber = $bibitemnum,
biblionumber 	 = $biblioitem->{'biblionumber'},
volume		 = $biblioitem->{'volume'},
number		 = $biblioitem->{'number'},
classification   = $biblioitem->{'classification'},
itemtype         = $biblioitem->{'itemtype'},
isbn		 = $biblioitem->{'isbn'},
issn		 = $biblioitem->{'issn'},
dewey		 = $biblioitem->{'dewey'},
subclass	 = $biblioitem->{'subclass'},
publicationyear	 = $biblioitem->{'publicationyear'},
publishercode	 = $biblioitem->{'publishercode'},
volumedate	 = $biblioitem->{'volumedate'},
volumeddesc	 = $biblioitem->{'volumeddesc'},
illus		 = $biblioitem->{'illus'},
pages		 = $biblioitem->{'pages'},
notes		 = $biblioitem->{'notes'},
size		 = $biblioitem->{'size'},
place		 = $biblioitem->{'place'}";

  $sth = $dbh->prepare($query);
  $sth->execute;

  $sth->finish;
  $dbh->disconnect;
  return($bibitemnum);
}

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

sub neworder {
  my ($bibnum,$title,$ordnum,$basket,$quantity,$listprice,$supplier,$who,$notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst,$budget,$cost,$sub,$invoice)=@_;
  if ($budget eq 'now'){
    $budget="now()";
  } else {
    $budget="'2001-07-01'";
  }
  if ($sub eq 'yes'){
    $sub=1;
  } else {
    $sub=0;
  }
  my $dbh=C4Connect;
  my $query="insert into aqorders (biblionumber,title,basketno,
  quantity,listprice,booksellerid,entrydate,requisitionedby,authorisedby,notes,
  biblioitemnumber,rrp,ecost,gst,budgetdate,unitprice,subscription,booksellerinvoicenumber)

  values
  ($bibnum,'$title',$basket,$quantity,$listprice,'$supplier',now(),
  '$who','$who','$notes',$bibitemnum,'$rrp','$ecost','$gst',$budget,'$cost',
  '$sub','$invoice')";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $query="select * from aqorders where
  biblionumber=$bibnum and basketno=$basket and ordernumber >=$ordnum";
  $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $ordnum=$data->{'ordernumber'};
  $query="insert into aqorderbreakdown (ordernumber,bookfundid) values
  ($ordnum,'$bookfund')";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub delorder {
  my ($bibnum,$ordnum)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set datecancellationprinted=now()
  where biblionumber='$bibnum' and
  ordernumber='$ordnum'";
  my $sth=$dbh->prepare($query);
  #print $query;
  $sth->execute;
  $sth->finish;
  my $count=itemcount($bibnum);
  if ($count == 0){
    delbiblio($bibnum);
  }
  $dbh->disconnect;
}

sub modorder {
  my ($title,$ordnum,$quantity,$listprice,$bibnum,$basketno,$supplier,$who,$notes,$bookfund,$bibitemnum,$rrp,$ecost,$gst,$budget,$cost,$invoice)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set title='$title',
  quantity='$quantity',listprice='$listprice',basketno='$basketno', 
  rrp='$rrp',ecost='$ecost',unitprice='$cost',
  booksellerinvoicenumber='$invoice'
  where
  ordernumber=$ordnum and biblionumber=$bibnum";
  my $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $query="update aqorderbreakdown set bookfundid=$bookfund where
  ordernumber=$ordnum";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
}

sub newordernum {
  my $dbh=C4Connect;
  my $query="Select max(ordernumber) from aqorders";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_arrayref;
  my $ordnum=$$data[0];
  $ordnum++;
  $sth->finish;
  $dbh->disconnect;
  return($ordnum);
}

sub receiveorder {
  my ($biblio,$ordnum,$quantrec,$user,$cost,$invoiceno,$bibitemno,$freight,$bookfund,$rrp)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set quantityreceived='$quantrec',
  datereceived=now(),booksellerinvoicenumber='$invoiceno',
  biblioitemnumber=$bibitemno,unitprice='$cost',freight='$freight',
  rrp='$rrp'
  where biblionumber=$biblio and ordernumber=$ordnum
  ";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $query="update aqorderbreakdown set bookfundid=$bookfund where
  ordernumber=$ordnum";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;  
  $dbh->disconnect;
}
sub updaterecorder{
  my($biblio,$ordnum,$user,$cost,$bookfund,$rrp)=@_;
  my $dbh=C4Connect;
  my $query="update aqorders set
  unitprice='$cost', rrp='$rrp'
  where biblionumber=$biblio and ordernumber=$ordnum
  ";
#  print $query;
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $query="update aqorderbreakdown set bookfundid=$bookfund where
  ordernumber=$ordnum";
  $sth=$dbh->prepare($query);
#  print $query;
  $sth->execute;
  $sth->finish;  
  $dbh->disconnect;
}

sub curconvert {
  my ($currency,$price)=@_;
  my $dbh=C4Connect;
  my $query="Select rate from currency where currency='$currency'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  my $cur=$data->{'rate'};
  if ($cur==0){
    $cur=1;
  }
  my $price=$price / $cur;
  return($price);
}

sub getcurrencies {
  my $dbh=C4Connect;
  my $query="Select * from currency";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  my @results;
  my $i=0;
  while (my $data=$sth->fetchrow_hashref){
    $results[$i]=$data;
    $i++;
  }
  $sth->finish;
  $dbh->disconnect;
  return($i,\@results);
} 

sub getcurrency {
  my ($cur)=@_;
  my $dbh=C4Connect;
  my $query="Select * from currency where currency='$cur'";
  my $sth=$dbh->prepare($query);
  $sth->execute;

  my $data=$sth->fetchrow_hashref;
  $sth->finish;
  $dbh->disconnect;
  return($data);
} 

sub updatecurrencies {
  my ($currency,$rate)=@_;
  my $dbh=C4Connect;
  my $query="update currency set rate=$rate where currency='$currency'";
  my $sth=$dbh->prepare($query);
  $sth->execute;
  $sth->finish;
  $dbh->disconnect;
} 

sub updatesup {
   my ($data)=@_;
   my $dbh=C4Connect;
   my $query="Update aqbooksellers set
   name='$data->{'name'}',address1='$data->{'address1'}',address2='$data->{'address2'}',
   address3='$data->{'address3'}',address4='$data->{'address4'}',postal='$data->{'postal'}',
   phone='$data->{'phone'}',fax='$data->{'fax'}',url='$data->{'url'}',
   contact='$data->{'contact'}',contpos='$data->{'contpos'}',
   contphone='$data->{'contphone'}', contfax='$data->{'contfax'}', contaltphone=
   '$data->{'contaltphone'}', contemail='$data->{'contemail'}', contnotes=
   '$data->{'contnotes'}', active=$data->{'active'},
   listprice='$data->{'listprice'}', invoiceprice='$data->{'invoiceprice'}',
   gstreg=$data->{'gstreg'}, listincgst=$data->{'listincgst'},
   invoiceincgst=$data->{'invoiceincgst'}, specialty='$data->{'specialty'}',
   discount='$data->{'discount'}',invoicedisc='$data->{'invoicedisc'}',
   nocalc='$data->{'nocalc'}'
   where id='$data->{'id'}'";
   my $sth=$dbh->prepare($query);
   $sth->execute;
   $sth->finish;
   $dbh->disconnect;
#   print $query;
}

sub insertsup {
  my ($data)=@_;
  my $dbh=C4Connect;
  my $sth=$dbh->prepare("Select max(id) from aqbooksellers");
  $sth->execute;
  my $data2=$sth->fetchrow_hashref;
  $sth->finish;
  $data2->{'max(id)'}++;
  $sth=$dbh->prepare("Insert into aqbooksellers (id) values ($data2->{'max(id)'})");
  $sth->execute;
  $sth->finish;
  $data->{'id'}=$data2->{'max(id)'};
  $dbh->disconnect;
  updatesup($data);
  return($data->{'id'});
}

sub makeitems {
  my
($count,$bibitemno,$biblio,$replacement,$price,$booksellerid,$branch,$loan,@barcodes)=@_;
  my $dbh=C4Connect;
  my $sth=$dbh->prepare("Select max(itemnumber) from items");
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  my $item=$data->{'max(itemnumber)'};
  $sth->finish;
  $item++;
  my $error;
  for (my $i=0;$i<$count;$i++){
    $barcodes[$i]=uc $barcodes[$i];
    my $query="Insert into items (biblionumber,biblioitemnumber,itemnumber,barcode,
    booksellerid,dateaccessioned,homebranch,holdingbranch,price,replacementprice,
    replacementpricedate,notforloan) values
    ($biblio,$bibitemno,$item,'$barcodes[$i]','$booksellerid',now(),'$branch',
    '$branch','$price','$replacement',now(),$loan)";
    my $sth=$dbh->prepare($query);
    $sth->execute;
    $error.=$sth->errstr;
    $sth->finish;
    $item++;
#    print $query;
  }
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
    @results[$count] = $data;
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
      # || die "Cannot prepare $query" . $dbh->errstr;
    my $count = 0;
    my @results;
    
    $sth->execute;
      # || die "Cannot execute $query" . $sth->errstr;
    while (my $data = $sth->fetchrow_hashref) {
      $results[$count] = $data;
      $count++;
    } # while
    
    $sth->finish;
    $dbh->disconnect;
    return($count, @results);
} # sub getbiblio


END { }       # module clean-up code here (global destructor)
