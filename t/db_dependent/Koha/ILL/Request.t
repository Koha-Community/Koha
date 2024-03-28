#!/usr/bin/perl

# Copyright 2023 Koha Development team
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
use Test::MockModule;

use Koha::ILL::Requests;

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'patron() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    my $patron_module = Test::MockModule->new('Koha::Patron');

    my $patroncategory = $builder->build_object(
        {
            class => 'Koha::Patron::Categories',
            value => { can_place_ill_in_opac => 1, BlockExpiredPatronOpacActions => 'ill_request' }
        }
    );
    my $patron =
        $builder->build_object( { class => 'Koha::Patrons', value => { categorycode => $patroncategory->id } } );
    my $request =
        $builder->build_object( { class => 'Koha::ILL::Requests', value => { borrowernumber => $patron->id } } );

    my $req_patron = $request->patron;
    is( ref($req_patron), 'Koha::Patron' );
    is( $req_patron->id,  $patron->id );

    $request = $builder->build_object( { class => 'Koha::ILL::Requests', value => { borrowernumber => undef } } );

    is( $request->patron, undef );

    # patron is not expired, is allowed
    $patron_module->mock( 'is_expired', sub { return 0; } );
    is( $request->can_patron_place_ill_in_opac($patron), 1 );

    # patron is expired, is not allowed
    $patron_module->mock( 'is_expired', sub { return 1; } );
    is( $request->can_patron_place_ill_in_opac($patron), 0 );

    $schema->storage->txn_rollback;
};

subtest 'get_type_disclaimer_value() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $request = $builder->build_object( { class => 'Koha::ILL::Requests' } );

    is(
        $request->get_type_disclaimer_value, undef,
        'get_type_disclaimer_value() returns undef if no get_type_disclaimer_value is set'
    );

    $builder->build_object(
        {
            class => 'Koha::ILL::Request::Attributes',
            value => {
                illrequest_id => $request->illrequest_id,
                type          => 'type_disclaimer_value',
                value         => 'Yes'
            }
        }
    );

    is(
        $request->get_type_disclaimer_value, "Yes",
        'get_type_disclaimer_value() returns the value if is set'
    );

    $schema->storage->txn_rollback;
};

subtest 'get_type_disclaimer_date() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $request = $builder->build_object( { class => 'Koha::ILL::Requests' } );

    is(
        $request->get_type_disclaimer_date, undef,
        'get_type_disclaimer_date() returns undef if no get_type_disclaimer_date is set'
    );

    $builder->build_object(
        {
            class => 'Koha::ILL::Request::Attributes',
            value => {
                illrequest_id => $request->illrequest_id,
                type          => 'type_disclaimer_date',
                value         => '2023-11-27T14:27:01'
            }
        }
    );

    is(
        $request->get_type_disclaimer_date, "2023-11-27T14:27:01",
        'get_type_disclaimer_date() returns the value if is set'
    );

    $schema->storage->txn_rollback;
};
