#!/usr/bin/perl

use C4::Database;
use CGI;
use strict;
use C4::Acquisitions;
use C4::Biblio;
use C4::Output;
use C4::Circulation::Circ2;
use C4::Accounts2;
use C4::Auth;

my $env;
my $input= new CGI;

my $flagsrequired;
$flagsrequired->{editcatalogue}=1;
my ($loggedinuser, $cookie, $sessionID) = checkauth($input, 0, $flagsrequired);


my $bibnum=checkinp($input->param('bibnum'));
my $itemnum=checkinp($input->param('itemnumber'));
my $copyright=checkinp($input->param('Copyright'));
my $seriestitle=checkinp($input->param('Series'));
my $serial=checkinp($input->param('Serial'));
my $unititle=checkinp($input->param('Unititle'));
my $notes=checkinp($input->param('ItemNotes'));

#need to do barcode check
my $barcode=$input->param('Barcode');

my $bibitemnum=checkinp($input->param('bibitemnum'));
my $itemtype=checkinp($input->param('Item'));
my $isbn=checkinp($input->param('ISBN'));
my $publishercode=checkinp($input->param('Publisher'));
my $publicationdate=checkinp($input->param('Publication'));
my $class=checkinp($input->param('Class'));
my $homebranch=checkinp($input->param('Home'));
my $replacementprice=$input->param('replacementprice');
my $lost=$input->param('Lost');
my $wthdrawn=$input->param('withdrawn');
my $classification;
my $dewey;
my $subclass;
my $override=$input->param('override');
if ($itemtype ne 'NF'){
  $classification=$class;
}
if ($class =~/[0-9]+/){
   $dewey= $class;
   $dewey=~ s/[a-z]+//gi;
   my @temp;
   if ($class =~ /\./){
     @temp=split(/[0-9]+\.[0-9]+/,$class);
   } else {
     @temp=split(/[0-9]+/,$class);
   }
   $classification=$temp[0];
   $subclass=$temp[1];
}else{
  $dewey='';
}
my $illus=checkinp($input->param('Illustrations'));
my $pages=checkinp($input->param('Pages'));
my $volumeddesc=checkinp($input->param('Volume'));

if ($wthdrawn == 0 && $override ne 'yes'){
  moditem('loan',$itemnum,$bibitemnum,$barcode,$notes,$homebranch,$lost,$wthdrawn,$replacementprice);
  if ($lost ==1){
    my $dbh=C4Connect;
    my $sth=$dbh->prepare("Select * from issues where (itemnumber='$itemnum') and (returndate is null)");
    $sth->execute;
    my $data=$sth->fetchrow_hashref;
    if ($data->{'borrowernumber'} ne '') {
      #item on issue add replacement cost to borrowers record
      my $accountno=getnextacctno($env,$data->{'borrowernumber'},$dbh);
      my $item=getiteminformation($env, $itemnum);
      my $account="Insert into accountlines
      (borrowernumber,accountno,date,amount,description,accounttype,amountoutstanding,itemnumber)
      values
      ('$data->{'borrowernumber'}','$accountno',now(),'$item->{'replacementprice'}',
      'Lost Item $item->{'title'} $item->{'barcode'}','L',
      '$item->{'replacementprice'}','$itemnum')";
      my $sth2=$dbh->prepare($account);
#      print $input->header;
#      print $account;
      $sth2->execute;
      $sth2->finish;
    }
    $sth->finish;
  }
  print $input->redirect("moredetail.pl?type=intra&bib=$bibnum&bi=$bibitemnum");
} else {
  
#  print "marking cancelled";
  #need to check if it is on reserve or issued
  my $dbh=C4Connect;
  my $flag=0; 
  my ($resbor,$resrec)=C4::Circulation::Circ2::checkreserve($env,$dbh,$itemnum);
 # print $resbor;
  if ($resbor){
    print $input->header;
    print "The biblio or biblioitem this item belongs to has a reserve on it";
    $flag=1;
  }
  my $sth=$dbh->prepare("Select * from issues where (itemnumber='$itemnum') and (returndate is null)"); 
  $sth->execute;
  my $data=$sth->fetchrow_hashref;
  if ($data->{'borrowernumber'} ne '') {
    print $input->header;
    print "<p>Item is on issue";
    $flag=1;
  }
  $sth->finish;
  $dbh->disconnect;
  if ($flag == 1){
    my $url=$input->self_url;
    $url.="&override=yes";
    print "<p> <a href=$url>Cancel Anyway</a> &nbsp; or <a href=\"\">Back</a>";
  }else {
    moditem('loan',$itemnum,$bibitemnum,$barcode,$notes,$homebranch,$lost,$wthdrawn);
    print $input->redirect("moredetail.pl?type=intra&bib=$bibnum&bi=$bibitemnum");
  }
}
#print $bibitemnum;

sub checkinp{
  my ($inp)=@_;
  $inp=~ s/\'/\\\'/g;
  $inp=~ s/\"/\\\"/g;
  return($inp);
}

#sub checkissue{
  
