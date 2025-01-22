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
use Test::More tests => 4;

use Koha::Database;
use Koha::Old::Patrons;
use Koha::Old::Biblios;
use Koha::Old::Checkouts;
use Koha::Old::Items;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'Koha::Old::Patrons' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $patron           = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_unblessed = $patron->unblessed;
    $patron->move_to_deleted;
    $patron->delete;
    my $deleted_patron = Koha::Old::Patrons->search( { borrowernumber => $patron->borrowernumber } )->next->unblessed;
    delete $deleted_patron->{updated_on};
    delete $patron_unblessed->{updated_on};
    is_deeply( $deleted_patron, $patron_unblessed );

    $schema->storage->txn_rollback;
};

subtest 'Koha::Old::Biblios and Koha::Old::Items' => sub {

    # Cannot be tested in a meaningful way so far
    ok(1);
};

subtest 'Koha::Old::Checkout->library() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $library  = $builder->build_object( { class => 'Koha::Libraries' } );
    my $checkout = $builder->build_object(
        {
            class => 'Koha::Old::Checkouts',
            value => { branchcode => $library->branchcode }
        }
    );

    is( ref( $checkout->library ),      'Koha::Library',      'Object type is correct' );
    is( $checkout->library->branchcode, $library->branchcode, 'Right library linked' );

    $library->delete;
    $checkout->discard_changes;

    is( $checkout->library, undef, 'If the library has been deleted, undef is returned' );

    $schema->storage->txn_rollback;
};
