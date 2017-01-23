#!/usr/bin/perl
# OUTI Billing Version 170201 - Written by Pasi Korkalo
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

use Koha::Billing::configReader;
use Koha::Billing::genericFunctions;
use Koha::Billing::databaseFunctions;

use Koha::Billing::Output::ProE;
use Koha::Billing::Output::plaintext;
use Koha::Billing::Output::lastu;

use Koha::Billing::SSN::getSSN;
use Koha::Billing::SSN::directDB;
use Koha::Billing::SSN::findSSN;

binmode STDOUT, ":utf8";

print "Outi Billing Copyright (C)2016 Koha-Suomi Oy\n\nThis program comes with ABSOLUTELY NO WARRANTY!\nThis is free software, and you are welcome to redistribute it\nunder certain conditions;\n\nsee GNU GPL for details: https://www.gnu.org/copyleft/gpl.html\n\n";

my ($overdue, $branchcategory)=@ARGV;
# Should do this better, but this will work for now
die "Required parameter missing, you need overdue and billing group, for example \'$0 60 OULULA\'" unless defined $overdue and defined $branchcategory;

logger "Getting items";
my @billable=getbillableitems($overdue, $branchcategory);
logger @billable . " items will be billed";

logger "Finding borrowers and guarantors";
our %bills;
our %guarantee;

foreach my $item (@billable) {
  # We'll need to query the patron information here because we don't really know
  # if we should bill the patron or the guarantor before the query
  my ( $borrowernumber,
       $borrowercategory,
       $guarantorid,
       @discard ) = getborrowerdata('itemnumber', $item);

  # There really shouldn't be patrons with guarantorid 0 in the database, but
  # for some reason there are, we'll just skip them
  if (defined $guarantorid and $guarantorid != 0) {
    $guarantee{$item}=$borrowernumber;
    ($borrowernumber, $borrowercategory, @discard) = getborrowerdata('borrowernumber', $guarantorid);
  }

  if (! defined $borrowernumber) {
    logger "No borrower for item $item (possibly deleted?), skipping";
    next;
  }

  # If the borrower to be billed is in ignorable category, don't bill the items
  # Otherwise push items in a hash to collect all the billable items
  next unless billable_borrowercategory($borrowercategory);
  push @{$bills{"$borrowernumber"}}, $item;
}

# Format and write, we choose output filter based on the setting in the config file
logger "Creating invoices";
{
  no strict 'refs';
  my $output=output($branchcategory);
  &$output($branchcategory);
}

logger "Done";
