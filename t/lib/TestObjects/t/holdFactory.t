#!/usr/bin/perl

# Copyright KohaSuomi 2016
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

use Modern::Perl;
use Test::More;

use C4::Reserves;
use t::lib::TestObjects::HoldFactory;

my $subtestContext = {};
##Create and Delete using dependencies in the $testContext instantiated in previous subtests.
my $hold = t::lib::TestObjects::HoldFactory->createTestGroup(
                    {cardnumber        => '1A01',
                     isbn              => '971',
                     barcode           => '1N01',
                     branchcode        => 'CPL',
                     waitingdate       => '2015-01-15',
                    },
                    ['cardnumber','isbn','barcode'], $subtestContext);

is($hold->{branchcode},
   'CPL',
   "Hold '1A01-971-1N01' pickup location is 'CPL'.");
is($hold->{waitingdate},
   '2015-01-15',
   "Hold '1A01-971-1N01' waiting date is '2015-01-15'.");

#using the default test hold identifier reservenotes to distinguish hard-to-identify holds.
my $holds2 = t::lib::TestObjects::HoldFactory->createTestGroup([
                    {cardnumber        => '1A01',
                     isbn              => '971',
                     barcode           => '1N02',
                     branchcode        => 'CPL',
                     reservenotes      => 'nice hold',
                    },
                    {cardnumber        => '1A01',
                     barcode           => '1N03',
                     isbn              => '971',
                     branchcode        => 'CPL',
                     reservenotes      => 'better hold',
                    },
                ], undef, $subtestContext);

is($holds2->{'nice hold'}->{branchcode},
    'CPL',
    "Hold 'nice hold' pickup location is 'CPL'.");
is($holds2->{'nice hold'}->{borrower}->cardnumber,
    '1A01',
    "Hold 'nice hold' cardnumber is '1A01'.");
is($holds2->{'better hold'}->{isbn},
    '971',
    "Hold 'better hold' isbn '971'.");

t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);

my $holds_deleted = C4::Reserves::GetReservesFromBiblionumber({biblionumber => $hold->{biblio}->{biblionumber}});
ok (not(@$holds_deleted), "Holds deleted");

done_testing();
