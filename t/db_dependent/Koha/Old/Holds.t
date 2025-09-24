#!/usr/bin/perl

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Exception;

use Koha::Database;
use Koha::DateUtils qw(dt_from_string);
use Koha::Old::Holds;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'anonymize() tests' => sub {

    plan tests => 10;

    $schema->storage->txn_begin;

    my $patron           = $builder->build_object( { class => 'Koha::Patrons' } );
    my $anonymous_patron = $builder->build_object( { class => 'Koha::Patrons' } );

    is( $patron->old_holds->count, 0, 'Patron has no old holds' );

    t::lib::Mocks::mock_preference( 'AnonymousPatron', undef );

    throws_ok { $patron->old_holds->anonymize; }
    'Koha::Exceptions::SysPref::NotSet',
        'Exception thrown because AnonymousPatron not set';

    is( $@->syspref, 'AnonymousPatron', 'syspref parameter is correctly passed' );

    t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous_patron->id );

    is( $patron->old_holds->anonymize + 0, 0, 'Anonymizing an empty resultset returns 0' );

    my $hold_1 = $builder->build_object(
        {
            class => 'Koha::Old::Holds',
            value => { borrowernumber => $patron->id, timestamp => dt_from_string() }
        }
    );
    my $hold_2 = $builder->build_object(
        {
            class => 'Koha::Old::Holds',
            value => {
                borrowernumber => $patron->id,
                timestamp      => dt_from_string()->subtract( days => 1 )
            }
        }
    );
    my $hold_3 = $builder->build_object(
        {
            class => 'Koha::Old::Holds',
            value => {
                borrowernumber => $patron->id,
                timestamp      => dt_from_string()->subtract( days => 2 )
            }
        }
    );
    my $hold_4 = $builder->build_object(
        {
            class => 'Koha::Old::Holds',
            value => {
                borrowernumber => $patron->id,
                timestamp      => dt_from_string()->subtract( days => 3 )
            }
        }
    );

    is( $patron->old_holds->count, 4, 'Patron has 4 completed holds' );

    # filter them so only the older two are part of the resultset
    my $holds = $patron->old_holds->search( { timestamp => { '<=' => dt_from_string()->subtract( days => 2 ) } } );

    # Anonymize them

    t::lib::Mocks::mock_preference( 'AnonymousPatron', undef );
    throws_ok { $holds->anonymize; }
    'Koha::Exceptions::SysPref::NotSet',
        'Exception thrown because AnonymousPatron not set';

    is( $@->syspref,               'AnonymousPatron', 'syspref parameter is correctly passed' );
    is( $patron->old_holds->count, 4,                 'Patron has 4 completed holds' );

    t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous_patron->id );

    my $anonymized_count = $holds->anonymize();
    is( $anonymized_count, 2, 'update() tells 2 rows were updated' );

    is( $patron->old_holds->count, 2, 'Patron has 2 completed holds' );

    $schema->storage->txn_rollback;
};

subtest 'filter_by_anonymizable() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    # patron_1 => keep records forever
    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons', value => { privacy => 0 } } );

    # patron_2 => never keep records
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons', value => { privacy => 1 } } );

    is( $patron_1->old_holds->count, 0, 'patron_1 has no old holds' );
    is( $patron_2->old_holds->count, 0, 'patron_2 has no old holds' );

    my $hold_1 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $patron_1->id,
            }
        }
    )->_move_to_old;
    my $hold_2 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $patron_2->id,
            }
        }
    )->_move_to_old;
    my $hold_3 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $patron_1->id,
            }
        }
    )->_move_to_old;
    my $hold_4 = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => {
                borrowernumber => $patron_2->id,
            }
        }
    )->_move_to_old;

    $hold_1 = Koha::Old::Holds->find( $hold_1->id )->set( { timestamp => dt_from_string() } )->store;
    $hold_2 =
        Koha::Old::Holds->find( $hold_2->id )->set( { timestamp => dt_from_string()->subtract( days => 1 ) } )->store;
    $hold_3 =
        Koha::Old::Holds->find( $hold_3->id )->set( { timestamp => dt_from_string()->subtract( days => 2 ) } )->store;
    $hold_4 =
        Koha::Old::Holds->find( $hold_4->id )->set( { timestamp => dt_from_string()->subtract( days => 3 ) } )->store;

    is( $patron_1->old_holds->count, 2, 'patron_1 has 2 completed holds' );
    is( $patron_2->old_holds->count, 2, 'patron_2 has 2 completed holds' );

    # filter them so only the older two are part of the resultset
    my $holds = Koha::Old::Holds->search( { 'me.borrowernumber' => [ $patron_1->id, $patron_2->id ] } );
    is( $holds->count, 4, 'Total of 4 holds returned correctly' );
    my $rs = $holds->filter_by_anonymizable;
    is( $rs->count, 2, 'Only 2 can be anonymized' );

    $rs = $holds->filter_by_anonymizable->filter_by_last_update( { days => 1 } );

    is( $rs->count, 1, 'Only 1 can be anonymized with date filter applied' );

    $schema->storage->txn_rollback;
};
