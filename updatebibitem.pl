#!/usr/bin/perl

use C4::Database;
use CGI;
use strict;
use C4::Acquisitions;
use C4::Output;
use C4::Search;

my $input= new CGI;

my $bibitemnum      = checkinp($input->param('bibitemnum'));
my $bibnum          = checkinp($input->param('bibnum'));
my $itemtype        = checkinp($input->param('Item'));
my $url             = checkinp($input->param('url'));
my $isbn            = checkinp($input->param('ISBN'));
my $publishercode   = checkinp($input->param('Publisher'));
my $publicationdate = checkinp($input->param('Publication'));
my $class           = checkinp($input->param('Class'));
my $illus           = checkinp($input->param('Illustrations'));
my $pages           = checkinp($input->param('Pages'));
my $volumeddesc     = checkinp($input->param('Volume'));
my $notes           = checkinp($input->param('Notes'));
my $size            = checkinp($input->param('Size'));
my $place           = checkinp($input->param('Place'));
my $classification;
my $dewey;
my $subclass;

if ($itemtype ne 'NF') {
  $classification=$class;
} # if

if ($class =~/[0-9]+/) {
   $dewey= $class;
   $dewey=~ s/[a-z]+//gi;
   my @temp;
   if ($class =~ /\./) {
     @temp=split(/[0-9]+\.[0-9]+/,$class);
   } else {
     @temp=split(/[0-9]+/,$class);
   } # else
   $classification=$temp[0];
   $subclass=$temp[1];

} else {
  $dewey='';
  $subclass='';
} # else

my (@items) = &itemissues($bibitemnum);
my $count   = @items;
my @barcodes;

my $existing=$input->param('existing');
if ($existing eq 'YES'){
#  print "yes";
  my $group=$input->param('existinggroup');
  #go thru items assing selected ones to group
  for (my $i=0;$i<$count;$i++){
    my $temp="check_group_".$items[$i]->{'barcode'};
    my $barcode=$input->param($temp);
    if ($barcode ne ''){
      moditem($items[$i]->{'notforloan'},$items[$i]->{'itemnumber'},$group);
#      print "modify $items[$i]->{'itemnumber'} $group";
    }
  }
  $bibitemnum=$group;
} else {
    my $flag;
    my $flag2;
    for (my $i=0;$i<$count;$i++){
      my $temp="check_group_".$items[$i]->{'barcode'};
      $barcodes[$i]=$input->param($temp);
      if ($barcodes[$i] eq ''){
        $flag="notall";
      } else {
        $flag2="leastone";
      }
   }
   my $loan;
   if ($flag eq 'notall' && $flag2 eq 'leastone'){
      $bibitemnum = &newbiblioitem({
	  biblionumber    => $bibnum,
	  itemtype        => $itemtype?$itemtype:"",
	  url             => $url?$url:"",
	  isbn            => $isbn?$isbn:"",
	  publishercode   => $publishercode?$publishercode:"",
	  publicationyear => $publicationdate?$publicationdate:"",
	  volumeddesc     => $volumeddesc?$volumeddesc:"",
	  classification  => $classification?$classification:"",
	  dewey           => $dewey?$dewey:"",
	  subclass        => $subclass?$subclass:"",
	  illus           => $illus?$illus:"",
	  pages           => $pages?$pages:"",
	  notes           => $notes?$notes:"",
	  size            => $size?$size:"",
	  place           => $place?$place:"" });
      if ($itemtype =~ /REF/){
        $loan=1;
      } else {
        $loan=0;
      }
      for (my $i=0;$i<$count;$i++){
        if ($barcodes[$i] ne ''){
	  moditem($loan,$items[$i]->{'itemnumber'},$bibitemnum);
	}
      }
      
   } elsif ($flag2 eq 'leastone') {
      &modbibitem({
	  biblioitemnumber => $bibitemnum,
	  itemtype         => $itemtype?$itemtype:"",
	  url              => $url?$url:"",
	  isbn             => $isbn?$isbn:"",
	  publishercode    => $publishercode?$publishercode:"",
	  publicationyear  => $publicationdate?$publicationdate:"",
	  classification   => $classification?$classification:"",
	  dewey            => $dewey?$dewey:"",
	  subclass         => $subclass?$subclass:"",
	  illus            => $illus?$illus:"",
	  pages            => $pages?$pages:"",
	  volumeddesc      => $volumeddesc?$volumeddesc:"",
	  notes            => $notes?$notes:"",
	  size             => $size?$size:"",
	  place            => $place?$place:"" });
      if ($itemtype =~ /REF/){
        $loan=1;
      } else {
        $loan=0;
      }
	for (my $i=0;$i<$count;$i++){                                             
	  if ($barcodes[$i] ne ''){                                               
	    moditem($loan,$items[$i]->{'itemnumber'},$bibitemnum);                
	  }                                                                       
	}
      
   } else {
     &modbibitem({
         biblioitemnumber => $bibitemnum,
	 itemtype         => $itemtype?$itemtype:"",
	 url              => $url?$url:"",
	 isbn             => $isbn?$isbn:"",
	 publishercode    => $publishercode?$publishercode:"",
         publicationyear  => $publicationdate?$publicationdate:"",
         classification   => $classification?$classification:"",
         dewey            => $dewey?$dewey:"",
         subclass         => $subclass?$subclass:"",
         illus            => $illus?$illus:"",
         pages            => $pages?$pages:"",
         volumeddesc      => $volumeddesc?$volumeddesc:"",
         notes            => $notes?$notes:"",
         size             => $size?$size:"",
         place            => $place?$place:"" });
   } # else
}
print $input->redirect("moredetail.pl?type=intra&bib=$bibnum&bi=$bibitemnum");


sub checkinp{
  my ($inp)=@_;
  $inp=~ s/\'/\\\'/g;
  $inp=~ s/\"/\\\"/g;
  return($inp);
}
