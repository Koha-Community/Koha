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

use Test::More tests => 2;

use Koha::Database;
use Koha::Old::Patrons;
use Koha::Old::Biblios;
use Koha::Old::Items;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;

subtest 'Koha::Old::Patrons' => sub {
    plan tests => 1;

    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    my $patron_unblessed = $patron->unblessed;
    $patron->move_to_deleted;
    $patron->delete;
    my $deleted_patron = Koha::Old::Patrons->search(
        {
            borrowernumber => $patron->borrowernumber
        }
    )->next->unblessed;
    delete $deleted_patron->{updated_on};
    delete $patron_unblessed->{updated_on};
    is_deeply( $deleted_patron, $patron_unblessed );
};

subtest 'Koha::Old::Biblios and Koha::Old::Items' => sub {
    # Cannot be tested in a meaningful way so far
    ok(1);
};
$schema->storage->txn_rollback;
