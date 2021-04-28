#!/usr/bin/perl

# Copyright 2020 Koha Development team
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

use Test::More tests => 3;

use Test::Exception;
use Test::MockModule;

use t::lib::TestBuilder;

use Koha::Libraries;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'patron() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $patron = $builder->build_object({ class => 'Koha::Patrons' });
    my $hold   = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $patron->borrowernumber
            }
        }
    );

    my $hold_patron = $hold->patron;
    is( ref($hold_patron), 'Koha::Patron', 'Right type' );
    is( $hold_patron->id, $patron->id, 'Right object' );

    $schema->storage->txn_rollback;
};

subtest 'set_pickup_location() tests' => sub {

    plan tests => 11;

    $schema->storage->txn_begin;

    my $mock_biblio = Test::MockModule->new('Koha::Biblio');
    my $mock_item   = Test::MockModule->new('Koha::Item');

    my $library_1 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_2 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_3 = $builder->build_object({ class => 'Koha::Libraries' });

    # let's control what Koha::Biblio->pickup_locations returns, for testing
    $mock_biblio->mock( 'pickup_locations', sub {
        return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
    });
    # let's mock what Koha::Item->pickup_locations returns, for testing
    $mock_item->mock( 'pickup_locations', sub {
        return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
    });

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    # Test biblio-level holds
    my $biblio_hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                biblionumber => $biblio->biblionumber,
                branchcode   => $library_3->branchcode,
                itemnumber   => undef,
            }
        }
    );

    throws_ok
        { $biblio_hold->set_pickup_location({ library_id => $library_1->branchcode }); }
        'Koha::Exceptions::Hold::InvalidPickupLocation',
        'Exception thrown on invalid pickup location';

    $biblio_hold->discard_changes;
    is( $biblio_hold->branchcode, $library_3->branchcode, 'branchcode remains untouched' );

    my $ret = $biblio_hold->set_pickup_location({ library_id => $library_2->id });
    is( ref($ret), 'Koha::Hold', 'self is returned' );

    $biblio_hold->discard_changes;
    is( $biblio_hold->branchcode, $library_2->id, 'Pickup location changed correctly' );

    # Test item-level holds
    my $item_hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                biblionumber => $biblio->biblionumber,
                branchcode   => $library_3->branchcode,
                itemnumber   => $item->itemnumber,
            }
        }
    );

    throws_ok
        { $item_hold->set_pickup_location({ library_id => $library_1->branchcode }); }
        'Koha::Exceptions::Hold::InvalidPickupLocation',
        'Exception thrown on invalid pickup location';

    $item_hold->discard_changes;
    is( $item_hold->branchcode, $library_3->branchcode, 'branchcode remains untouched' );

    $item_hold->set_pickup_location({ library_id => $library_1->branchcode, override => 1 });
    $item_hold->discard_changes;
    is( $item_hold->branchcode, $library_1->branchcode, 'branchcode changed because of \'override\'' );

    $ret = $item_hold->set_pickup_location({ library_id => $library_2->id });
    is( ref($ret), 'Koha::Hold', 'self is returned' );

    $item_hold->discard_changes;
    is( $item_hold->branchcode, $library_2->id, 'Pickup location changed correctly' );

    throws_ok
        { $item_hold->set_pickup_location({ library_id => undef }); }
        'Koha::Exceptions::MissingParameter',
        'Exception thrown if missing parameter';

    is( "$@", 'The library_id parameter is mandatory', 'Exception message is clear' );

    $schema->storage->txn_rollback;
};

subtest 'is_pickup_location_valid() tests' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $mock_biblio = Test::MockModule->new('Koha::Biblio');
    my $mock_item   = Test::MockModule->new('Koha::Item');

    my $library_1 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_2 = $builder->build_object({ class => 'Koha::Libraries' });
    my $library_3 = $builder->build_object({ class => 'Koha::Libraries' });

    # let's control what Koha::Biblio->pickup_locations returns, for testing
    $mock_biblio->mock( 'pickup_locations', sub {
        return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
    });
    # let's mock what Koha::Item->pickup_locations returns, for testing
    $mock_item->mock( 'pickup_locations', sub {
        return Koha::Libraries->search( { branchcode => [ $library_2->branchcode, $library_3->branchcode ] } );
    });

    my $biblio = $builder->build_sample_biblio;
    my $item   = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });

    # Test biblio-level holds
    my $biblio_hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                biblionumber => $biblio->biblionumber,
                branchcode   => $library_3->branchcode,
                itemnumber   => undef,
            }
        }
    );

    ok( !$biblio_hold->is_pickup_location_valid({ library_id => $library_1->branchcode }), 'Pickup location invalid');
    ok( $biblio_hold->is_pickup_location_valid({ library_id => $library_2->id }), 'Pickup location valid');

    # Test item-level holds
    my $item_hold = $builder->build_object(
        {
            class => "Koha::Holds",
            value => {
                biblionumber => $biblio->biblionumber,
                branchcode   => $library_3->branchcode,
                itemnumber   => $item->itemnumber,
            }
        }
    );

    ok( !$item_hold->is_pickup_location_valid({ library_id => $library_1->branchcode }), 'Pickup location invalid');
    ok( $item_hold->is_pickup_location_valid({ library_id => $library_2->id }), 'Pickup location valid' );

    $schema->storage->txn_rollback;
};
