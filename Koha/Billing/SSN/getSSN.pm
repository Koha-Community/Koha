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

sub getssn() {
  # Return ssn using configured ssn interface. This is just to keep
  # the code in output filters cleaner (this functionality doesn't need
  # to be duplicated in each of them)
  my $ssninterface=ssninterface();
  my $ssnkey=getssnkey(shift);
  my $ssn;

  if (defined $ssnkey) {
    no strict 'refs';
    $ssn=&$ssninterface($ssnkey);
  }

  $ssn=' ' x 11 unless defined $ssn;
  return $ssn;
}

1;
