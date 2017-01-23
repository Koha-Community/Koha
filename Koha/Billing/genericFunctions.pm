#!/usr/bin/perl
# Outi Billing Version 170201 - Written by Pasi Korkalo
# Copyright (C)2016-2017 Koha-Suomi Oy
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

use utf8;
use strict;
use warnings;
use DateTime;

sub getdate {
  my ($sec, $min, $hour, $dom, $month, $year, @discard)=localtime;
  undef @discard;
  $year+=1900;
  $month+=1;
  $sec=sprintf("%02d", $sec);
  $min=sprintf("%02d", $min);
  $hour=sprintf("%02d", $hour);
  $dom=sprintf("%02d", $dom);
  $month=sprintf("%02d", $month);
  return $sec, $min, $hour, $dom, $month, $year;
}

sub logger {
  my ($sec, $min, $hour, $dom, $month, $year)=getdate();
  print $year . '-' . $month . '-' . $dom . ' ' . $hour . ':' . $min . ':' . $sec . ' ';
  print @_;
  print "\n";
}

sub filename {
  my $branchcategory=shift;
  my $output=output($branchcategory);
  my ($sec, $min, $hour, $dom, $month, $year)=getdate();
  return 'KIKOHA' . $output . $branchcategory . $year . $month . $dom . $hour . $min . $sec . '.dat';
}

sub writefile {
  my $branchcategory=shift;
  my $encoding=encoding($branchcategory);
  my $targetdir=targetdir($branchcategory);
  my $filename=filename($branchcategory);

  # Write it (will probably spit out some encoding warnings)
  open OUTFILE, ">:encoding($encoding)", $targetdir . '/' . $filename or die "Can't open ". $targetdir . "/test-filedata.dat for writing.";
  foreach (@_) {
    print OUTFILE $_;
  }
  close OUTFILE;

  # "Fix" (or rather "neutralise") encoding errors
  if ( $encoding ne 'UTF-8' ) {
    open INFILE, "<:encoding($encoding)", $targetdir . '/' . $filename or die "Can't open ". $targetdir . "/test-filedata.dat for reading.";
    my @FILE=<INFILE>;
    close INFILE;

    open OUTFILE, ">:encoding($encoding)", $targetdir . '/' . $filename or die "Can't open ". $targetdir . "/test-filedata.dat for writing.";
    foreach (@FILE) {
      my $outline=$_;
      $outline=~s/\\x\{....\}/?/g;
      print OUTFILE $outline;
    }
    close OUTFILE;
  }
}

sub refchecksum {
  # Calculate checksum for reference number
  my $ref=reverse(shift);
  my $checkSum=0;
  my @weights=(7,3,1);
  my $i=0;

  for my $refNumber (split //, $ref) {
      $i=0 if $i==@weights;
      $checkSum=$checkSum+($refNumber*$weights[$i]);
      $i++;
  }

  my $nextTen=$checkSum+9;
  $nextTen=$nextTen-($nextTen%10);
  return $nextTen-$checkSum;
}

sub refnumber {
  # Get the next available reference number for the branchgroup from
  # the sequences-table and concatenate the checksum
  my $branchcategory=shift;
  my $refno=getrefsequence($branchcategory, getrefno_increment($branchcategory));
  return $refno . refchecksum($refno);
}

sub invoicedue {
  # Return due date for created invoice
  my $due=getinvoicedue(shift);
  my $currentdate=DateTime->now();
  my $duedate=$currentdate->add(days => $due);
  return split('-', $duedate->ymd('-'), 3);
}

1;
