#!/usr/bin/perl

# $Id$

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

use CGI;
use strict;
use C4::Biblio;
use C4::Output;
use C4::Search;

my $input= new CGI;
#print $input->header;
#print $input->Dump;

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
#   print $class;
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
#   print $classification,$dewey,$subclass;
} else {
  $dewey='';
  $subclass='';
} # else

my (@items) = &itemissues($bibitemnum);
#print @items;
my $count   = @items;
#print $count;
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
      moditem({ biblionumber => $bibnum,
		notforloan   => $items[$i]->{'notforloan'},
		itemnumber   => $items[$i]->{'itemnumber'},
		group        => $group
		    });
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
	  moditem({ biblionumber => $bibnum,
		    loan         => $loan,
		    itemnumber   => $items[$i]->{'itemnumber'},
		    bibitemnum   => $bibitemnum
		    });
	}
      }

   } elsif ($flag2 eq 'leastone') {
      &modbibitem({
	  biblioitemnumber => $bibitemnum,
	  biblionumber     => $bibnum,
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
	    moditem( {biblionumber => $bibnum,
		      loan         => $loan,
		      itemnumber   => $items[$i]->{'itemnumber'},
		      bibitemnum   => $bibitemnum
		      });
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
