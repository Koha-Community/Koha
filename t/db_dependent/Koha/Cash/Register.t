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

use Test::More tests => 1;

use C4::Context;

use Koha::Library;
use Koha::Libraries;
use Koha::Database;

use t::lib::TestBuilder;

my $builder = t::lib::TestBuilder->new;
my $schema  = Koha::Database->new->schema;

subtest 'library' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    my $library = $builder->build_object( { class => 'Koha::Libraries' } );
    my $register = $builder->build_object(
        {
            class => 'Koha::Cash::Registers',
            value => { branch => $library->branchcode },
        }
    );

    is( ref( $register->library ),
        'Koha::Library',
        'Koha::Cash::Register->library should return a Koha::Library' );

    is( $register->library->id,
        $library->id,
        'Koha::Cash::Register->library returns the correct Koha::Library' );

    $schema->storage->txn_rollback;
};
