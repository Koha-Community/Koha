#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 2;
use Test::Warn;
use t::lib::TestBuilder;
use t::lib::Mocks;

use Koha::ItemTypes;

BEGIN {
    use_ok('C4::XSLT');
}

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

$schema->storage->txn_begin;

subtest 'buildKohaItemsNamespace status tests' => sub {
    plan tests => 14;

    t::lib::Mocks::mock_preference('Reference_NFL_Statuses', '1|2');

    my $itype = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $itemtype = $builder->build_object({ class => 'Koha::ItemTypes' });
    my $item  = $builder->build_sample_item({ itype => $itype->itemtype });
    $item->biblioitem->itemtype($itemtype->itemtype)->store;

    my $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<status>available</status>},"Item is available when no other status applied");

    # notforloan
    {
        t::lib::Mocks::mock_preference('item-level_itypes', 0);
        $item->notforloan(0)->store;
        Koha::ItemTypes->find($item->itype)->notforloan(0)->store;
        Koha::ItemTypes->find($item->biblioitem->itemtype)->notforloan(1)->store;
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
        like($xml,qr{<status>reference</status>},"reference if positive itype notforloan value");

        t::lib::Mocks::mock_preference('item-level_itypes', 1);
        Koha::ItemTypes->find($item->itype)->notforloan(1)->store;
        Koha::ItemTypes->find($item->biblioitem->itemtype)->notforloan(0)->store;
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
        like($xml,qr{<status>reference</status>},"reference if positive itemtype notforloan value");
        Koha::ItemTypes->find($item->itype)->notforloan(0)->store;

        my $substatus = Koha::AuthorisedValues->search({ category => 'NOT_LOAN', authorised_value => -1 })->next->lib;
        $item->notforloan(-1)->store;
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
        like($xml,qr{<status>reallynotforloan</status>},"reallynotforloan if negative notforloan value");
        like($xml,qr{<substatus>$substatus</substatus>},"substatus set if negative notforloan value");

        $item->notforloan(1)->store;
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
        like($xml,qr{<status>reference</status>},"reference if positive notforloan value");

        # But now make status notforloan==1 count under Not available
        t::lib::Mocks::mock_preference('Reference_NFL_Statuses', '2');
        $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
        like($xml,qr{<status>reallynotforloan</status>},"reallynotforloan when we change Reference_NFL_Statuses");
        t::lib::Mocks::mock_preference('Reference_NFL_Statuses', '1|2');
    }

    $item->onloan('2001-01-01')->store;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<status>Checked out</status>},"Checked out status takes precedence over Not for loan");

    $item->withdrawn(1)->store;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<status>Withdrawn</status>},"Withdrawn status takes precedence over Checked out");

    $item->itemlost(1)->store;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<status>Lost</status>},"Lost status takes precedence over Withdrawn");

    $item->damaged(1)->store;
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<status>Damaged</status>},"Damaged status takes precedence over Lost");

    $builder->build({ source => "Branchtransfer", value => {
        itemnumber  => $item->itemnumber,
        datearrived => undef,
        datecancelled => undef,
        }
    });
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<status>In transit</status>},"In-transit status takes precedence over Damaged");

    my $hold = $builder->build_object({ class => 'Koha::Holds', value => {
        biblionumber => $item->biblionumber,
        itemnumber   => $item->itemnumber,
        found        => 'W',
        priority     => 0,
        }
    });
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<status>Waiting</status>},"Waiting status takes precedence over In transit");

    $builder->build({ source => "TmpHoldsqueue", value => {
        itemnumber => $item->itemnumber
        }
    });
    $xml = C4::XSLT::buildKohaItemsNamespace( $item->biblionumber,[]);
    like($xml,qr{<status>Pending hold</status>},"Pending status takes precedence over all");


};

$schema->storage->txn_rollback;
