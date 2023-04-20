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

use Test::More tests => 6;

use Test::Exception;
use Test::MockModule;

use MARC::Field;

use C4::Items;
use C4::Biblio qw( AddBiblio ModBiblio );
use C4::Reserves qw( AddReserve );

use Koha::DateUtils qw( dt_from_string output_pref );
use Koha::Biblios;
use Koha::Patrons;
use Koha::Subscriptions;
use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $dbh     = C4::Context->dbh;

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
    C4::Reserves::AddReserve(
        {
            branchcode     => $patron->branchcode,
            borrowernumber => $patron->borrowernumber,
            biblionumber   => $biblio->biblionumber,
        }
    );
    my $holds = $biblio->holds;
    is( ref($holds), 'Koha::Holds', '->holds should return a Koha::Holds object' );
    is( $holds->count, 1, '->holds should only return 1 hold' );
    is( $holds->next->borrowernumber, $patron->borrowernumber, '->holds should return the correct hold' );
    $holds->delete;

    # Add a hold in the future
    C4::Reserves::AddReserve(
        {
            branchcode       => $patron->branchcode,
            borrowernumber   => $patron->borrowernumber,
            biblionumber     => $biblio->biblionumber,
            reservation_date => dt_from_string->add( days => 2 ),
        }
    );
    $holds = $biblio->holds;
    is( $holds->count, 1, '->holds should return future holds' );
    $holds = $biblio->current_holds;
    is( $holds->count, 0, '->current_holds should not return future holds' );
    $holds->delete;

};

subtest 'waiting_or_in_transit' => sub {
    plan tests => 4;
    my $item = $builder->build_sample_item;
    my $reserve = $builder->build({
        source => 'Reserve',
        value => {
            biblionumber => $item->biblionumber,
            found => undef
        }
    });

    $reserve = Koha::Holds->find($reserve->{reserve_id});
    $biblio = $item->biblio;

    is($biblio->has_items_waiting_or_intransit, 0, 'Item is neither waiting nor in transit');

    $reserve->found('W')->store;
    is($biblio->has_items_waiting_or_intransit, 1, 'Item is waiting');

    $reserve->found('T')->store;
    is($biblio->has_items_waiting_or_intransit, 1, 'Item is in transit');

    my $transfer = $builder->build({
        source => 'Branchtransfer',
        value => {
            itemnumber => $item->itemnumber,
            datearrived => undef,
            datecancelled => undef,
        }
    });
    my $t = Koha::Database->new()->schema()->resultset( 'Branchtransfer' )->find($transfer->{branchtransfer_id});
    $reserve->found(undef)->store;
    is($biblio->has_items_waiting_or_intransit, 1, 'Item has transfer');
};

subtest 'can_be_transferred' => sub {
    plan tests => 8;

    t::lib::Mocks::mock_preference('UseBranchTransferLimits', 1);
    t::lib::Mocks::mock_preference('BranchTransferLimitsType', 'itemtype');

    my $library1 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library2 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $library3 = $builder->build_object( { class => 'Koha::Libraries' } );
    my $biblio = $builder->build_sample_biblio({ itemtype => 'ONLY1' });
    my $item = $builder->build_sample_item(
        {
            biblionumber => $biblio->biblionumber,
            library      => $library1->branchcode
        }
    );

    is(Koha::Item::Transfer::Limits->search({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
    })->count, 0, 'There are no transfer limits between libraries.');
    ok($biblio->can_be_transferred({ to => $library2 }),
        'Some items of this biblio can be transferred between libraries.');

    my $limit = Koha::Item::Transfer::Limit->new({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
        itemtype => $item->effective_itemtype,
    })->store;
    is(Koha::Item::Transfer::Limits->search({
        fromBranch => $library1->branchcode,
        toBranch => $library2->branchcode,
    })->count, 1, 'Given we have added a transfer limit that applies for all '
        .'of this biblio\s items,');
    is($biblio->can_be_transferred({ to => $library2 }), 0,
        'None of the items of biblio can no longer be transferred between '
        .'libraries.');
    is($biblio->can_be_transferred({ to => $library2, from => $library1 }), 0,
         'We get the same result also if we pass the from-library parameter.');
    $item->holdingbranch($library2->branchcode)->store;
    is($biblio->can_be_transferred({ to => $library2 }), 1, 'Given one of the '
         .'items is already located at to-library, then the transfer is possible.');
    $item->holdingbranch($library1->branchcode)->store;

    my $item2 = $builder->build_sample_item(
        {
            biblionumber  => $biblio->biblionumber,
            homebranch    => $library1->branchcode,
            holdingbranch => $library3->branchcode,
        }
    );
    is($biblio->can_be_transferred({ to => $library2 }), 1, 'Given we added '
        .'another item that should have no transfer limits applying on, then '
        .'the transfer is possible.');
    $item2->holdingbranch($library1->branchcode)->store;
    is($biblio->can_be_transferred({ to => $library2 }), 0, 'Given all of items'
        .' of the biblio are from same, transfer limited library, then transfer'
        .' is not possible.');
};

subtest 'custom_cover_image_url' => sub {
    plan tests => 6;

    t::lib::Mocks::mock_preference( 'CustomCoverImagesURL', 'https://my_url/{isbn}_{issn}.png' );

    my $isbn       = '0553573403 | 9780553573404 (pbk.).png';
    my $issn       = 'my_issn';
    my $cf_value   = 'from_control_field';
    my $marc_record = MARC::Record->new;
    my ( $biblionumber, undef ) = C4::Biblio::AddBiblio($marc_record, '');

    my $biblio = Koha::Biblios->find( $biblionumber );
    my $biblioitem = $biblio->biblioitem->set(
        { isbn => $isbn, issn => $issn });
    is( $biblio->custom_cover_image_url, "https://my_url/${isbn}_${issn}.png" );

    my $marc_024a = '710347104926';
    $marc_record->append_fields( MARC::Field->new( '024', '', '', a => $marc_024a ) );
    C4::Biblio::ModBiblio( $marc_record, $biblio->biblionumber );

    t::lib::Mocks::mock_preference( 'CustomCoverImagesURL', 'https://my_url/{024$a}.png' );
    is( $biblio->custom_cover_image_url, "https://my_url/$marc_024a.png" );

    t::lib::Mocks::mock_preference( 'CustomCoverImagesURL', 'https://my_url/{normalized_isbn}.png' );
    my $normalized_isbn = C4::Koha::GetNormalizedISBN($isbn);
    is( $biblio->custom_cover_image_url, "https://my_url/$normalized_isbn.png" );

    $biblio->biblioitem->isbn('')->store;
    is( $biblio->custom_cover_image_url, undef, "Don't generate the url if the biblio does not have the value needed to generate it" );

    t::lib::Mocks::mock_preference( 'CustomCoverImagesURL', 'https://my_url/{001}.png' );
    is( $biblio->custom_cover_image_url, undef, 'Record does not have 001' );
    $marc_record->append_fields(MARC::Field->new('001', $cf_value));
    C4::Biblio::ModBiblio( $marc_record, $biblio->biblionumber );
    $biblio = Koha::Biblios->find( $biblionumber );
    is( $biblio->get_from_storage->custom_cover_image_url, "https://my_url/$cf_value.png", 'URL generated using 001' );
};

$schema->storage->txn_rollback;

subtest 'pickup_locations() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    # Build 8 libraries
    my $l_1 = $builder->build_object({ class => 'Koha::Libraries', value => { pickup_location => 1 } });
    my $l_2 = $builder->build_object({ class => 'Koha::Libraries', value => { pickup_location => 1 } });
    my $l_3 = $builder->build_object({ class => 'Koha::Libraries', value => { pickup_location => 1 } });
    my $l_4 = $builder->build_object({ class => 'Koha::Libraries', value => { pickup_location => 1 } });
    my $l_5 = $builder->build_object({ class => 'Koha::Libraries', value => { pickup_location => 1 } });
    my $l_6 = $builder->build_object({ class => 'Koha::Libraries', value => { pickup_location => 1 } });
    my $l_7 = $builder->build_object({ class => 'Koha::Libraries', value => { pickup_location => 1 } });
    my $l_8 = $builder->build_object({ class => 'Koha::Libraries', value => { pickup_location => 1 } });

    # Mock Koha::Item->pickup_locations so we have control on the output
    # The $switch variable controls the output.
    my $switch  = 0;
    my $queries = [
        { branchcode => [ $l_1->branchcode, $l_2->branchcode ] },
        { branchcode => [ $l_3->branchcode, $l_4->branchcode ] },
        { branchcode => [ $l_5->branchcode, $l_6->branchcode ] },
        { branchcode => [ $l_7->branchcode, $l_8->branchcode ] }
    ];

    my $mock_item = Test::MockModule->new('Koha::Item');
    $mock_item->mock(
        'pickup_locations',
        sub {
            my $query = $queries->[$switch];
            $switch++;
            return Koha::Libraries->search($query);
        }
    );

    # Two biblios
    my $biblio_1 = $builder->build_sample_biblio;
    my $biblio_2 = $builder->build_sample_biblio;

    # Two items each
    my $item_1_1 = $builder->build_sample_item({ biblionumber => $biblio_1->biblionumber });
    my $item_1_2 = $builder->build_sample_item({ biblionumber => $biblio_1->biblionumber });
    my $item_2_1 = $builder->build_sample_item({ biblionumber => $biblio_2->biblionumber });
    my $item_2_2 = $builder->build_sample_item({ biblionumber => $biblio_2->biblionumber });

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });

    my $biblios = Koha::Biblios->search(
        {
            biblionumber => [ $biblio_1->biblionumber, $biblio_2->biblionumber ]
        }
    );

    throws_ok
      { $biblios->pickup_locations }
      'Koha::Exceptions::MissingParameter',
      'Exception thrown on missing parameter';

    is( $@->parameter, 'patron', 'Exception param correctly set' );

    my $library_ids = [
        Koha::Libraries->search(
            {
                branchcode => [
                    $l_1->branchcode, $l_2->branchcode, $l_3->branchcode,
                    $l_4->branchcode, $l_5->branchcode, $l_6->branchcode,
                    $l_7->branchcode, $l_8->branchcode
                ]
            },
            { order_by => ['branchname'] }
        )->_resultset->get_column('branchcode')->all
    ];

    my $pickup_locations_ids = [
        $biblios->pickup_locations({ patron => $patron })->_resultset->get_column('branchcode')->all
    ];

    is_deeply(
        $library_ids,
        $pickup_locations_ids,
        'The addition of all biblios+items pickup locations is returned'
    );

    $schema->storage->txn_rollback;
};
