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

our %bills;
our %guarantee;

sub plaintext {
  my $branchcategory=shift;
  my @writefile;
  my $totalprice=0;

  push @writefile, $branchcategory;

  foreach my $borrower (keys %bills) {

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

    # We need SSN
    my $ssn=getssn($borrowernumber);

    # Borrower information
    push @writefile, $firstname . ' ' . $surname . '\n';
    push @writefile, $address . '\n';
    push @writefile, $zipcode . ' ' . $city . '\n';
    push @writefile, $ssn . '\n';

    # Starting texts
    push @writefile, "PALAUTTAMATON AINEISTO:\n";

    # Insert billable items
    for ( 0 .. $#{$bills{$borrower}}) {
      my $itemnumber=$bills{$borrower}[$_];

      # Get item data
      my ( $barcode,
           $price,
           $itype,
           $holdingbranch,
           $author,
           $title ) = getitemdata($itemnumber);

      # Resolve real itemtype and branch
      my $itemtype=resolveitemtype($itype);
      my $branch=resolvebranchcode($holdingbranch);

      # When was the item due
      my ($year, $month, $day)=getdue($itemnumber);
      my $due=$day . '.' . $month . '.' . $year;

      $author=$author . ' ' unless $author eq '';
      my $itemline=$barcode . ': ' . $itemtype . ', ' . $due . ', ' . $branch . ', ' . $author . $title . ', ' . $price;

      # Calculate total price for the billl
      $totalprice=$totalprice + $price;

      # First line of text
      push @writefile, substr($itemline, 0, 62) . '\n';

      # Second line of text if the itemline was over 62 character (additional lines after the second one
      # will just be skipped, two lines is enough ;P)
      push @writefile, substr($itemline, 62, 124) . '\n' if length($itemline) > 62;

      # Add guarantee if not the same as borrower
      if (defined $guarantee{$itemnumber}) {
        push @writefile, 'LAINAAJA: ' . substr($guarantee{$itemnumber}, 0, 62) . '\n';
      }

      # Update the billed status (if defined to be updated)
      updatenotforloan($itemnumber);
    }

    # Make reference number
    my $reference=refnumber($branchcategory, refno_increment($branchcategory));
    push @writefile, 'VIITENUMERO: ' . $reference . '\n';

    # Finally...
    push @writefile, 'KORVAUSSUMMA YHTEENSÄ: ' . $totalprice . '€\n';
    push @writefile, 'LASKUA EI TARVITSE MAKSAA, JOS AINEISTO PALAUTETAAN.\n';
    push @writefile, 'Veroton vahingonkorvaus.\n';
  }

  writefile(@writefile);
  return 1;
}
1;
