#!/usr/bin/perl

use C4::Database;
use CGI;
use strict;
use C4::Acquisitions;
use C4::Output;

my $input= new CGI;
#print $input->header;
#print $input->dump;


#my $title=checkinp($input->param('Title'));
#my $author=checkinp($input->param('Author'));
my $bibnum=checkinp($input->param('bibnum'));
my $itemnum=checkinp($input->param('itemnumber'));
my $copyright=checkinp($input->param('Copyright'));
my $seriestitle=checkinp($input->param('Series'));
my $serial=checkinp($input->param('Serial'));
my $unititle=checkinp($input->param('Unititle'));
my $notes=checkinp($input->param('ItemNotes'));

#need to do barcode check
my $barcode=$input->param('Barcode');
#modbiblio($bibnum,$title,$author,$copyright,$seriestitle,$serial,$unititle,$notes);

my $bibitemnum=checkinp($input->param('bibitemnum'));
#my $olditemtype
my $itemtype=checkinp($input->param('Item'));
my $isbn=checkinp($input->param('ISBN'));
my $publishercode=checkinp($input->param('Publisher'));
my $publicationdate=checkinp($input->param('Publication'));
my $class=checkinp($input->param('Class'));
my $homebranch=checkinp($input->param('Home'));
my $lost=$input->param('Lost');
my $wthdrawn=$input->param('withdrawn');
my $classification;
my $dewey;
my $subclass;
if ($itemtype ne 'NF'){
  $classification=$class;
}
if ($class =~/[0-9]+/){
#   print $class;
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
#   print $classification,$dewey,$subclass;
}else{
  $dewey='';
}
my $illus=checkinp($input->param('Illustrations'));
my $pages=checkinp($input->param('Pages'));
my $volumeddesc=checkinp($input->param('Volume'));

#have to check how many items are attached to this bibitem, if one, just change it,
#if more than one, we must create a new one.
#my $number=countitems($bibitemnum);
#if ($number > 1){
#   print $number;
  #check if bibitemneeds modifying
#  my $needsmod=needsmod($bibitemnum,$itemtype);
#  if ($needsmod != 1){
#    $bibitemnum=newbiblioitem($bibnum,$itemtype,$volumeddesc,$classification);
#  }
#} 
#modbibitem($bibitemnum,$itemtype,$isbn,$publishercode,$publicationdate,$classification,$dewey,$subclass,$illus,$pages,$volumeddesc);
moditem('loan',$itemnum,$bibitemnum,$barcode,$notes,$homebranch,$lost,$wthdrawn);

print $input->redirect("moredetail.pl?type=intra&bib=$bibnum&bi=$bibitemnum");
#print $bibitemnum;

sub checkinp{
  my ($inp)=@_;
  $inp=~ s/\'/\\\'/g;
  $inp=~ s/\"/\\\"/g;
  return($inp);
}
