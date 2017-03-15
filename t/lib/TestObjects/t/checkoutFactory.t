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
use DateTime;

use t::lib::TestObjects::ItemFactory;
use Koha::Items;
use t::lib::TestObjects::BiblioFactory;
use Koha::Biblios;
use t::lib::TestObjects::CheckoutFactory;
use Koha::Checkouts;

my $subtestContext = {};
##Create and Delete using dependencies in the $testContext instantiated in previous subtests.
my $biblios = t::lib::TestObjects::BiblioFactory->createTestGroup([
                    {'biblio.title' => 'I wish I met your mother',
                     'biblio.author'   => 'Pertti Kurikka',
                     'biblio.copyrightdate' => '1960',
                     'biblioitems.isbn'     => '9519671580',
                     'biblioitems.itemtype' => 'BK',
                    },
                ], 'biblioitems.isbn', $subtestContext);
my $items = t::lib::TestObjects::ItemFactory->createTestGroup([
                    {biblionumber => $biblios->{9519671580}->{biblionumber},
                     barcode => '167Nabe0001',
                     homebranch   => 'CPL',
                     holdingbranch => 'CPL',
                     price     => '0.50',
                     replacementprice => '0.50',
                     itype => 'BK',
                     biblioisbn => '9519671580',
                     itemcallnumber => 'PK 84.2',
                    },
                    {biblionumber => $biblios->{9519671580}->{biblionumber},
                     barcode => '167Nabe0002',
                     homebranch   => 'CPL',
                     holdingbranch => 'FFL',
                     price     => '3.50',
                     replacementprice => '3.50',
                     itype => 'BK',
                     biblioisbn => '9519671580',
                     itemcallnumber => 'JK 84.2',
                    },
                ], 'barcode', $subtestContext);
my $objects = t::lib::TestObjects::CheckoutFactory->createTestGroup([
                {
                    cardnumber        => '11A001',
                    barcode           => '167Nabe0001',
                    daysOverdue       => 7,
                    daysAgoCheckedout => 28,
                },
                {
                    cardnumber        => '11A002',
                    barcode           => '167Nabe0002',
                    daysOverdue       => -7,
                    daysAgoCheckedout => 14,
                    checkoutBranchRule => 'holdingbranch',
                },
                ], undef, $subtestContext);

is($objects->{'11A001-167Nabe0001'}->branchcode,
   'CPL',
   "Checkout '11A001-167Nabe0001' checked out from the default context branch 'CPL'.");
is($objects->{'11A002-167Nabe0002'}->branchcode,
   'FFL',
   "Checkout '11A002-167Nabe0002' checked out from the holdingbranch 'FFL'.");
is(Koha::DateUtils::dt_from_string($objects->{'11A001-167Nabe0001'}->issuedate)->day(),
   DateTime->now(time_zone => C4::Context->tz())->subtract(days => '28')->day()
   , "Checkout '11A001-167Nabe0001', adjusted issuedates match.");
is(Koha::DateUtils::dt_from_string($objects->{'11A002-167Nabe0002'}->date_due)->day(),
   DateTime->now(time_zone => C4::Context->tz())->subtract(days => '-7')->day()
   , "Checkout '11A002-167Nabe0002', adjusted date_dues match.");

t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
my $object1 = Koha::Checkouts->find({borrowernumber => $objects->{'11A001-167Nabe0001'}->borrowernumber,
                                     itemnumber => $objects->{'11A001-167Nabe0001'}->itemnumber});
ok (not($object1), "Checkout '11A001-167Nabe0001' deleted");
my $object2 = Koha::Checkouts->find({borrowernumber => $objects->{'11A002-167Nabe0002'}->borrowernumber,
                                     itemnumber => $objects->{'11A002-167Nabe0002'}->itemnumber});
ok (not($object2), "Checkout '11A002-167Nabe0002' deleted");

done_testing();
