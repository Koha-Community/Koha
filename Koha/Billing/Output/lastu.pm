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
use C4::Context;
use Template;

our %bills;
our %guarantee;

sub lastu {
  my $branchcategory=shift;
  my ($sec, $min, $hour, $dom, $month, $year)=getdate;
  my $isodate=$year . '-' . $month . '-' . $dom;

  my $targetdir=targetdir($branchcategory) . '/' . $isodate;
  my $template=template($branchcategory);
  my %template_options = ( ABSOLUTE => 1, ENCODING => encoding($branchcategory) );

  if ( ! -d $targetdir ) {
    mkdir $targetdir;
  }

  foreach my $borrower (keys %bills) {
    my $totalprice=0;
    my $invoicenumber=getinvoicenumber;
    my @lines;

    my ( $borrowernumber,
         $borrowercategory,
         $guarantorid,
         $relationship,
         $cardnumber,
         $firstname,
         $surname,
         $address,
         $city,
         $zipcode
       ) = getborrowerdata('borrowernumber', $borrower);

    $cardnumber='' unless defined $cardnumber;

    # Borrower information
    my %vars=(invoicedate => $dom . '.' . $month . '.' . $year,
                 borrower => {   surname => $surname,
                               firstname => $firstname,
                                 address => $address,
                                 zipcode => $zipcode,
                                    city => $city });

    # Insert billable items
    for (0 .. $#{$bills{$borrower}}) {
      my $itemnumber=$bills{$borrower}[$_];

      # Get item data
      my ( $barcode,
           $price,
           $itype,
           $holdingbranch,
           $author,
           $title ) = getitemdata($itemnumber);

      $price='0.00' if ! defined $price;

      # Resolve real itemtype and branch
      my $itemtype=resolveitemtype($itype);
      my $branch=resolvebranchcode($holdingbranch);
      chomp ($itemtype, $branch);

      # When was the item due
      my ($year, $month, $day)=getdue($itemnumber);
      my $due=$day . '.' . $month . '.' . $year;

      # Get guarantee information and block patron
      my (@guaranteedata, $guaranteeline);
      if ( defined $guarantee{$itemnumber} ) {
        @guaranteedata=getborrowerdata('borrowernumber', $guarantee{$itemnumber});
        $guaranteeline=$guaranteedata[6] . ' ' . $guaranteedata[5] . ' (' . $guaranteedata[4] . ')';
        debar $branchcategory, $guarantee{$itemnumber}, $invoicenumber, $isodate;
      } else {
        debar $branchcategory, $borrowernumber, $invoicenumber, $isodate;
      }

      push @lines, {    barcode => $barcode,
                       itemtype => $itemtype,
                       date_due => $due,
                     branchname => $branch,
                         author => $author,
                          title => $title,
                          price => $price,
                      guarantee => $guaranteeline };

      # Calculate the total sum to be billed
      $totalprice=$totalprice + $price;

      # Update the billed status (if defined to be updated)
      updatenotforloan($itemnumber);
    }

    $vars{'billableitems'}=[@lines];

    # Set due date for the invoice
    my ($year, $month, $dom)=invoicedue($branchcategory);
    $vars{'invoicedue'}=$dom . '.' . $month . '.' . $year;

    # Add summary lines and such
    $vars{'total'}=sprintf '%.2f', $totalprice;
    $vars{'invoicenumber'}=$invoicenumber;
    $vars{'referencenumber'}=refnumber($branchcategory);

    # Push it throught template to make HTML-file
    my $ttl=Template->new(\%template_options);
    $ttl->process($template, \%vars, $targetdir . '/' . $invoicenumber . '.html', {binmode => ':utf8'}) or die $ttl->error;

  }

  return 1;
}

1;
