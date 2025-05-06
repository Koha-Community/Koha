#!/usr/bin/perl

# Copyright 2019 Koha Development team
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

use Test::NoWarnings;
use Test::More tests => 2;
use Test::Exception;
use Test::Warn;

use Koha::Database;
use Koha::Patrons;
use Koha::Patron::Relationships;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $dbh     = $schema->storage->dbh;
my $builder = t::lib::TestBuilder->new;

subtest 'store() tests' => sub {

    plan tests => 14;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'borrowerRelationship', 'father1|father2' );

    my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );

    my $relationship_1 = Koha::Patron::Relationship->new(
        {
            guarantor_id => $patron_2->borrowernumber,
            guarantee_id => $patron_1->borrowernumber
        }
    );

    throws_ok { $relationship_1->store; }
    'Koha::Exceptions::Patron::Relationship::InvalidRelationship',
        'Exception is thrown as no relationship passed';

    is( "$@", "No relationship passed.", 'Exception stringified correctly' );

    is(
        Koha::Patron::Relationships->search( { guarantee_id => $patron_1->borrowernumber } )->count,
        0,
        'No guarantors added'
    );

    my $relationship = 'father';

    throws_ok { $relationship_1->relationship($relationship)->store; }
    'Koha::Exceptions::Patron::Relationship::InvalidRelationship',
        'Exception is thrown as a wrong relationship was passed';

    is( "$@", "Invalid relationship passed, '$relationship' is not defined.", 'Exception stringified correctly' );

    is(
        Koha::Patron::Relationships->search( { guarantee_id => $patron_1->borrowernumber } )->count,
        0,
        'No guarantors added'
    );

    $relationship = '';

    throws_ok { $relationship_1->relationship($relationship)->store; }
    'Koha::Exceptions::Patron::Relationship::InvalidRelationship',
        'Exception is thrown as a wrong relationship was passed';

    is( "$@", "Invalid relationship passed, '$relationship' is not defined.", 'Exception stringified correctly' );

    is(
        Koha::Patron::Relationships->search( { guarantee_id => $patron_1->borrowernumber } )->count,
        0,
        'No guarantors added when empty relationship passed and not defined'
    );

    $relationship = 'father1';

    $relationship_1->relationship($relationship)->store;

    is(
        Koha::Patron::Relationships->search( { guarantee_id => $patron_1->borrowernumber } )->count,
        1,
        'Guarantor added'
    );

    my $relationship_2 = Koha::Patron::Relationship->new(
        {
            guarantor_id => $patron_2->borrowernumber,
            guarantee_id => $patron_1->borrowernumber,
            relationship => 'father2'
        }
    );

    warning_like(
        sub {
            throws_ok { $relationship_2->store; }
            'Koha::Exceptions::Patron::Relationship::DuplicateRelationship',
                'Exception is thrown for duplicated relationship';
        },
        qr{Duplicate entry.* for key '(borrower_relationships\.)?guarantor_guarantee_idx'}
    );

    is(
        "$@",
        "There already exists a relationship for the same guarantor ("
            . $patron_2->borrowernumber
            . ") and guarantee ("
            . $patron_1->borrowernumber
            . ") combination",
        'Exception stringified correctly'
    );

    t::lib::Mocks::mock_preference( 'borrowerRelationship', '' );

    my $relationship_3 = Koha::Patron::Relationship->new(
        {
            guarantor_id => $patron_1->borrowernumber,
            guarantee_id => $patron_2->borrowernumber,
            relationship => ''
        }
    )->store();

    is( $relationship_3->relationship, '', 'Empty relationship allowed' );

    $schema->storage->txn_rollback;
};
