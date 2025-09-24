#!/usr/bin/perl

# Copyright 2024 Koha Development team
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;
use C4::Context;

use Koha::Database;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

subtest 'extended_attributes patrons join searches() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;

    my $patron1 = $builder->build( { source => 'Borrower' } )->{borrowernumber};
    my $patron2 = $builder->build( { source => 'Borrower' } )->{borrowernumber};

    my $attribute_type_1 = $builder->build(
        {
            source => 'BorrowerAttributeType',
            value  => { repeatable => 1, is_date => 0, code => 'CODE_1' },
        }
    );
    my $attribute_type_2 = $builder->build(
        {
            source => 'BorrowerAttributeType',
            value  => { repeatable => 1, is_date => 0, code => 'CODE_2' }
        }
    );

    my $attr1 = Koha::Patron::Attribute->new(
        {
            borrowernumber => $patron1,
            code           => $attribute_type_1->{code},
            attribute      => 'Bar'
        }
    )->store;
    my $attr2 = Koha::Patron::Attribute->new(
        {
            borrowernumber => $patron1,
            code           => $attribute_type_2->{code},
            attribute      => 'Foo'
        }
    )->store;

    my $patrons_search = Koha::Patrons->search(
        [
            '-and' => [
                {
                    'extended_attributes.attribute' => { 'like' => '%Bar%' },
                    'extended_attributes.code'      => $attr1->code
                },
                {
                    'extended_attributes.attribute' => { 'like' => '%Foo%' },
                    'extended_attributes.code'      => $attr2->code
                }
            ],
        ],
        { 'prefetch' => ['extended_attributes'] }
    );

    is( $patrons_search->count, 1, "Patrons extended_attribute 'AND' query works." );

    my $patrons_search2 = Koha::Patrons->search(
        [
            '-and' => [
                {
                    'extended_attributes.attribute' => { 'like' => '%Bar%' },
                    'extended_attributes.code'      => $attr1->code
                },
                {
                    'extended_attributes.attribute' => { 'like' => '%Bar%' },
                    'extended_attributes.code'      => $attr2->code
                }
            ],
        ],
        { 'prefetch' => ['extended_attributes'] }
    );

    is( $patrons_search2->count, 0, "Second patrons extended_attribute 'AND' query works." );

    my $patrons_search3 = Koha::Patrons->search(
        [
            [
                {
                    'extended_attributes.attribute' => { 'like' => '%Bar%' },
                    'extended_attributes.code'      => $attr1->code
                }
            ],
            [
                {
                    'extended_attributes.attribute' => { 'like' => '%Foo%' },
                    'extended_attributes.code'      => $attr2->code
                }
            ],
            [
                {
                    'extended_attributes.attribute' => { 'like' => '%Foo%' },
                    'extended_attributes.code'      => $attr1->code
                }
            ],
        ],
        { 'prefetch' => ['extended_attributes'] }
    );

    is( $patrons_search3->count, 1, "Patrons extended_attribute 'OR' search works" );

    $schema->storage->txn_rollback;
};

subtest 'extended_attributes ill requests join searches() tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $builder = t::lib::TestBuilder->new;

    # ILL::Requests
    my $illrequest1 = $builder->build( { source => 'Illrequest' } )->{illrequest_id};
    my $illrequest2 = $builder->build( { source => 'Illrequest' } )->{illrequest_id};

    my $illrequest_attribute1 = 'author';

    my $ill_attr1 = Koha::ILL::Request::Attribute->new(
        {
            illrequest_id => $illrequest1,
            type          => 'author',
            value         => 'Pedro'
        }
    )->store;
    my $ill_attr2 = Koha::ILL::Request::Attribute->new(
        {
            illrequest_id => $illrequest2,
            type          => 'author',
            value         => 'Pedro'
        }
    )->store;

    my $ill_requests = Koha::ILL::Requests->search(
        [
            [
                {
                    'extended_attributes.value' => { 'like' => '%Pedro%' },
                    'extended_attributes.type'  => $illrequest_attribute1
                }
            ],
            [
                {
                    'extended_attributes.value' => { 'like' => '%field2 value%' },
                    'extended_attributes.type'  => $illrequest_attribute1
                }
            ],
        ],
        { 'prefetch' => ['extended_attributes'] }
    );

    is( $ill_requests->count, 2, "ILL requests extended_attribute search works" );

    $schema->storage->txn_rollback;

};
