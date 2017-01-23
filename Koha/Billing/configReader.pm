#!/bin/perl
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
use XML::Simple;

# Get the config
my $configfile=$ENV{'KOHA_CONF'};
   $configfile=~s/koha-conf.xml$/outibilling.xml/;

our $xml=new XML::Simple;
our $config=$xml->XMLin($configfile);

sub billable_borrowercategory {
  # Return true if borrowercategory is billable, false otherwise
  my $category=shift;
  my $ignorecategories=$config->{'ignore_borrowercategories'}->{'category'};
  return 0 if grep /$category/, @$ignorecategories;
  return 1;
}

sub nonbillable {
  # Return notforloan value for non-billable items
  return $config->{'notforloan'}->{'nonbillable'};
}

sub billed {
  # Return notforloan value for billed items
  return $config->{'notforloan'}->{'billed'};
}

sub updateitem {
  # Should we update the notforloan status of billed items
  return 1 if $config->{'notforloan'}->{'updateitem'} eq 'yes';
  return 0;
}

sub targetdir {
  # Return target directory for the files
  my $branchcategory=shift;
  return $config->{'branchcategories'}->{$branchcategory}->{'targetdir'};
}

sub template {
  # Return the name and location of the template for the branchcategory
  my $branchcategory=shift;
  return $config->{'branchcategories'}->{$branchcategory}->{'template'};
}

sub encoding {
  # Return the set character encoding for the bills
  my $branchcategory=shift;
  return $config->{'branchcategories'}->{$branchcategory}->{'encoding'};
}

sub output {
  # Return the preferred output format for the branchcategory
  my $branchcategory=shift;
  return $config->{'branchcategories'}->{$branchcategory}->{'output'};
}

sub getssndbconfig {
  # Return an array with direct database connection configuration
  my @ssndb;
  push @ssndb, C4::Context->config('ssnProvider')->{'directDB'}->{'host'};
  push @ssndb, C4::Context->config('ssnProvider')->{'directDB'}->{'port'};
  push @ssndb, C4::Context->config('ssnProvider')->{'directDB'}->{'user'};
  push @ssndb, C4::Context->config('ssnProvider')->{'directDB'}->{'password'};
  return @ssndb;
}

sub getfindssnconfig {
  # Return findssn service details in an array
  my @findssn;
  push @findssn, C4::Context->config('ssnProvider')->{'url'};
  push @findssn, C4::Context->config('ssnProvider')->{'findSSN'}->{'user'};
  push @findssn, C4::Context->config('ssnProvider')->{'findSSN'}->{'password'};
  return @findssn;
}

sub ssninterface {
  return C4::Context->config('ssnProvider')->{'interface'};
}

sub getrefno_increment {
  # Get increment value for reference numbers
  my $branchcategory=shift;
  return $config->{'branchcategories'}->{$branchcategory}->{'refno_increment'};
}

sub getinvoicedue {
  # Get due date for created invoices
  my $branchcategory=shift;
  return $config->{'branchcategories'}->{$branchcategory}->{'invoicedue'};
}

sub getdebarborrower {
  my $branchcategory=shift;
  return $config->{'branchcategories'}->{$branchcategory}->{'debarborrower'};
}

1;
