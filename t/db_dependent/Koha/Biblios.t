#!/usr/bin/perl

# Copyright 2016 Koha Development team
#
# This file is part of Koha
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

use Test::More tests => 5;
use Test::Exception;

use C4::Biblio;
use C4::Items;
use C4::Reserves;

use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Biblios;
use Koha::Patrons;
use Koha::Subscriptions;
use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $patron = $builder->build( { source => 'Borrower' } );
$patron = Koha::Patrons->find( $patron->{borrowernumber} );

my $biblio = Koha::Biblio->new()->store();

my $biblioitem = $schema->resultset('Biblioitem')->new(
    {
        biblionumber => $biblio->id
    }
)->insert();

subtest 'store' => sub {
    plan tests => 1;
    is(
        Koha::Biblios->find( $biblio->biblionumber )->datecreated,
        output_pref(
            { dt => dt_from_string, dateformat => 'iso', dateonly => 1 }
        ),
        "datecreated must be set to today if not passed to the constructor"
    );
};

subtest 'holds + current_holds' => sub {
    plan tests => 5;
    C4::Reserves::AddReserve( $patron->branchcode, $patron->borrowernumber, $biblio->biblionumber );
    my $holds = $biblio->holds;
    is( ref($holds), 'Koha::Holds', '->holds should return a Koha::Holds object' );
    is( $holds->count, 1, '->holds should only return 1 hold' );
    is( $holds->next->borrowernumber, $patron->borrowernumber, '->holds should return the correct hold' );
    $holds->delete;

    # Add a hold in the future
    C4::Reserves::AddReserve( $patron->branchcode, $patron->borrowernumber, $biblio->biblionumber, undef, undef, dt_from_string->add( days => 2 ) );
    $holds = $biblio->holds;
    is( $holds->count, 1, '->holds should return future holds' );
    $holds = $biblio->current_holds;
    is( $holds->count, 0, '->current_holds should not return future holds' );
    $holds->delete;

};

subtest 'subscriptions' => sub {
    plan tests => 2;
    $builder->build(
        { source => 'Subscription', value => { biblionumber => $biblio->id } }
    );
    $builder->build(
        { source => 'Subscription', value => { biblionumber => $biblio->id } }
    );
    my $biblio        = Koha::Biblios->find( $biblio->id );
    my $subscriptions = $biblio->subscriptions;
    is( ref($subscriptions), 'Koha::Subscriptions',
        'Koha::Biblio->subscriptions should return a Koha::Subscriptions object'
    );
    is( $subscriptions->count, 2, 'Koha::Biblio->subscriptions should return the correct number of subscriptions');
};

subtest 'waiting_or_in_transit' => sub {
    plan tests => 4;
    my $biblio = $builder->build( { source => 'Biblio' } );
    my $item = $builder->build({
        source => 'Item',
        value => {
            biblionumber => $biblio->{biblionumber}
        }
    });
    my $reserve = $builder->build({
        source => 'Reserve',
        value => {
            biblionumber => $biblio->{biblionumber},
            found => undef
        }
    });

    $reserve = Koha::Holds->find($reserve->{reserve_id});
    $biblio = Koha::Biblios->find($biblio->{biblionumber});

    is($biblio->has_items_waiting_or_intransit, 0, 'Item is neither waiting nor in transit');

    $reserve->found('W')->store;
    is($biblio->has_items_waiting_or_intransit, 1, 'Item is waiting');

    $reserve->found('T')->store;
    is($biblio->has_items_waiting_or_intransit, 1, 'Item is in transit');

    my $transfer = $builder->build({
        source => 'Branchtransfer',
        value => {
            itemnumber => $item->{itemnumber},
            datearrived => undef
        }
    });
    my $t = Koha::Database->new()->schema()->resultset( 'Branchtransfer' )->find($transfer->{branchtransfer_id});
    $reserve->found(undef)->store;
    is($biblio->has_items_waiting_or_intransit, 1, 'Item has transfer');
};

subtest 'can_be_transferred' => sub {
    plan tests => 11;

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');

    my $library1 = $builder->build( { source => 'Branch' } )->{branchcode};
    my $library2 = $builder->build( { source => 'Branch' } )->{branchcode};
    my $library3 = $builder->build( { source => 'Branch' } )->{branchcode};
    my ($bibnum, $title, $bibitemnum) = create_helper_biblio('ONLY1');
    my ($item_bibnum, $item_bibitemnum, $itemnumber)
        = AddItem({ homebranch => $library1, holdingbranch => $library1 }, $bibnum);
    my $item  = Koha::Items->find($itemnumber);
    my $biblio = Koha::Biblios->find($bibnum);

    is(Koha::Item::Transfer::Limits->search({
        fromBranch => $library1,
        toBranch => $library2,
    })->count, 0, 'There are no transfer limits between libraries.');
    ok($biblio->can_be_transferred({ to => $library2 }),
        'Some items of this biblio can be transferred between libraries.');

    my $limit = Koha::Item::Transfer::Limit->new({
        fromBranch => $library1,
        toBranch => $library2,
        itemtype => $item->effective_itemtype,
    })->store;
    is(Koha::Item::Transfer::Limits->search({
        fromBranch => $library1,
        toBranch => $library2,
    })->count, 1, 'Given we have added a transfer limit that applies for all '
        .'of this biblio\s items,');
    is($biblio->can_be_transferred({ to => $library2 }), 0,
        'None of the items of biblio can no longer be transferred between '
        .'libraries.');
    is($biblio->can_be_transferred({ to => $library2, from => $library1 }), 0,
         'We get the same result also if we pass the from-library parameter.');
    $item->holdingbranch($library2)->store;
    is($biblio->can_be_transferred({ to => $library2 }), 1, 'Given one of the '
         .'items is already located at to-library, then the transfer is possible.');
    $item->holdingbranch($library1)->store;
    my ($item_bibnum2, $item_bibitemnum2, $itemnumber2)
        = AddItem({ homebranch => $library1, holdingbranch => $library3 }, $bibnum);
    my $item2  = Koha::Items->find($itemnumber2);
    is($biblio->can_be_transferred({ to => $library2 }), 1, 'Given we added '
        .'another item that should have no transfer limits applying on, then '
        .'the transfer is possible.');
    $item2->holdingbranch($library1)->store;
    is($biblio->can_be_transferred({ to => $library2 }), 0, 'Given all of items'
        .' of the biblio are from same, transfer limited library, then transfer'
        .' is not possible.');
    throws_ok { $biblio->can_be_transferred({ to => undef }); }
              'Koha::Exceptions::Library::NotFound',
              'Exception thrown when no library given.';
    throws_ok { $biblio->can_be_transferred({ to => 'heaven' }); }
              'Koha::Exceptions::Library::NotFound',
              'Exception thrown when invalid library is given.';
    throws_ok { $biblio->can_be_transferred({ to => $library2, from => 'hell' }); }
              'Koha::Exceptions::Library::NotFound',
              'Exception thrown when invalid library is given.';
};

$schema->storage->txn_rollback;

# Helper method to set up a Biblio.
sub create_helper_biblio {
    my $itemtype = shift;
    my ($bibnum, $title, $bibitemnum);
    my $bib = MARC::Record->new();
    $title = 'Silence in the library';
    $bib->append_fields(
        MARC::Field->new('100', ' ', ' ', a => 'Moffat, Steven'),
        MARC::Field->new('245', ' ', ' ', a => $title),
        MARC::Field->new('942', ' ', ' ', c => $itemtype),
    );
    return ($bibnum, $title, $bibitemnum) = AddBiblio($bib, '');
}
