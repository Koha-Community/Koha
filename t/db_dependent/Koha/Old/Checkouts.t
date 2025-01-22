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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;
use Test::Exception;

use Koha::Database;
use Koha::DateUtils qw(dt_from_string);
use Koha::Old::Checkouts;

use t::lib::Mocks;
use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'anonymize() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    my $patron           = $builder->build_object( { class => 'Koha::Patrons' } );
    my $anonymous_patron = $builder->build_object( { class => 'Koha::Patrons' } );

    is( $patron->old_checkouts->count, 0, 'Patron has no old checkouts' );

    t::lib::Mocks::mock_preference( 'AnonymousPatron', undef );

    throws_ok { $patron->old_checkouts->anonymize; }
    'Koha::Exceptions::SysPref::NotSet',
        'Exception thrown because AnonymousPatron not set';

    is( $@->syspref, 'AnonymousPatron', 'syspref parameter is correctly passed' );

    t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous_patron->id );

    is(
        $patron->old_checkouts->anonymize + 0,
        0, 'Anonymizing an empty resultset returns 0'
    );

    my $checkout_1 = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => { borrowernumber => $patron->id, timestamp => dt_from_string() }
        }
    );
    my $checkout_2 = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => {
                borrowernumber => $patron->id,
                timestamp      => dt_from_string()->subtract( days => 1 )
            }
        }
    );
    my $checkout_3 = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => {
                borrowernumber => $patron->id,
                timestamp      => dt_from_string()->subtract( days => 2 )
            }
        }
    );
    my $checkout_4 = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => {
                borrowernumber => $patron->id,
                timestamp      => dt_from_string()->subtract( days => 3 )
            }
        }
    );
    my $renewal_1 = $builder->build_object(
        {
            class => 'Koha::Checkouts::Renewals',
            value => {
                checkout_id => undef,
                interface   => 'opac',
                renewer_id  => $patron->id
            }
        }
    );
    $renewal_1->checkout_id( $checkout_4->id )->store();
    my $renewal_2 = $builder->build_object(
        {
            class => 'Koha::Checkouts::Renewals',
            value => {
                checkout_id => undef,
                interface   => 'intranet'
            }
        }
    );
    $renewal_2->checkout_id( $checkout_4->id )->store();

    is( $patron->old_checkouts->count, 4, 'Patron has 4 completed checkouts' );
    is( $checkout_4->renewals->count,  2, 'Checkout 4 has 2 renewals' );

    # filter them so only the older two are part of the resultset
    my $checkouts = $patron->old_checkouts->filter_by_last_update( { min_days => 1 } );

    t::lib::Mocks::mock_preference( 'AnonymousPatron', undef );
    throws_ok { $checkouts->anonymize; }
    'Koha::Exceptions::SysPref::NotSet',
        'Exception thrown because AnonymousPatron not set';

    is( $@->syspref,                   'AnonymousPatron', 'syspref parameter is correctly passed' );
    is( $patron->old_checkouts->count, 4,                 'Patron has 4 completed checkouts' );

    t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous_patron->id );

    # Anonymize them
    my $anonymized_count = $checkouts->anonymize();
    is( $anonymized_count, 2, 'update() tells 2 rows were updated' );

    is( $patron->old_checkouts->count, 2, 'Patron has 2 completed checkouts' );
    is( $checkout_4->renewals->count,  2, 'Checkout 4 still has 2 renewals' );
    is(
        $checkout_4->renewals->search( { renewer_id => $anonymous_patron->id } )->count,
        1,
        'OPAC renewal was anonymized'
    );

    $schema->storage->txn_rollback;
};

subtest 'filter_by_anonymizable() tests' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $anonymous_patron = $builder->build_object( { class => 'Koha::Patrons' } );
    t::lib::Mocks::mock_preference( 'AnonymousPatron', $anonymous_patron->id );

    # patron_1 => keep records forever
    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons', value => { privacy => 0 } } );

    # patron_2 => never keep records
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons', value => { privacy => 1 } } );

    is( $patron_1->old_checkouts->count, 0, 'patron_1 has no old checkouts' );
    is( $patron_2->old_checkouts->count, 0, 'patron_2 has no old checkouts' );

    my $checkout_1 = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => {
                borrowernumber => $patron_1->id,
            }
        }
    );
    my $checkout_2 = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => {
                borrowernumber => $patron_2->id,
            }
        }
    );
    my $checkout_3 = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => {
                borrowernumber => $patron_1->id,
            }
        }
    );
    my $checkout_4 = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => {
                borrowernumber => $patron_2->id,
            }
        }
    );

    # borrowernumber == undef => never listed as anonymizable
    my $checkout_5 = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => {
                borrowernumber => undef,
            }
        }
    );

    # borrowernumber == anonymous patron => never listed as anonymizable
    my $checkout_6 = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => {
                borrowernumber => $anonymous_patron->id,
            }
        }
    );

    $checkout_2->set( { timestamp => dt_from_string()->subtract( days => 1 ) } )->store;
    $checkout_3->set( { timestamp => dt_from_string()->subtract( days => 2 ) } )->store;
    $checkout_4->set( { timestamp => dt_from_string()->subtract( days => 3 ) } )->store;

    is( $patron_1->old_checkouts->count, 2, 'patron_1 has 2 completed checkouts' );
    is( $patron_2->old_checkouts->count, 2, 'patron_2 has 2 completed checkouts' );

    # filter them so only the older two are part of the resultset
    my $checkouts = Koha::Old::Checkouts->search( { 'me.borrowernumber' => [ $patron_1->id, $patron_2->id ] } );
    is( $checkouts->count, 4, 'Total of 4 checkouts returned correctly' );
    my $rs = $checkouts->filter_by_anonymizable;
    is( $rs->count, 2, 'Only 2 can be anonymized' );

    $rs = $checkouts->filter_by_anonymizable->filter_by_last_update( { days => 1 } );

    is( $rs->count, 1, 'Only 1 can be anonymized with date filter applied' );

    $schema->storage->txn_rollback;
};
