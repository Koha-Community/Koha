#!/usr/bin/perl

# Copyright 2022 Koha Development team
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
use utf8;

use Koha::Database;

use t::lib::TestBuilder;

use Test::NoWarnings;
use Test::More tests => 3;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

use_ok("Koha::Item::Templates");

subtest 'get_available' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    Koha::Item::Templates->search->delete;

    my $library  = $builder->build( { source => 'Branch' } );
    my $category = $builder->build( { source => 'Category' } );
    my $patron_1 = Koha::Patron->new(
        {
            branchcode   => $library->{branchcode},
            categorycode => $category->{categorycode},
            surname      => 'surname for patron1',
            firstname    => 'firstname for patron1',
        }
    )->store;
    my $patron_2 = Koha::Patron->new(
        {
            branchcode   => $library->{branchcode},
            categorycode => $category->{categorycode},
            surname      => 'surname for patron2',
            firstname    => 'firstname for patron2',
        }
    )->store;

    my $owner_template = Koha::Item::Template->new(
        {
            patron_id => $patron_1->id,
            name      => 'My template',
            contents  => { location => 'test' },
            is_shared => 0,
        }
    )->store();

    my $shared_template = Koha::Item::Template->new(
        {
            patron_id => $patron_2->id,
            name      => 'My template',
            contents  => { location => 'test' },
            is_shared => 1,
        }
    )->store();

    my $unshared_template = Koha::Item::Template->new(
        {
            patron_id => $patron_2->id,
            name      => 'My template',
            contents  => { location => 'test🙂' },
            is_shared => 0,
        }
    )->store;
    $unshared_template->discard_changes;    # refresh
    is( $unshared_template->decoded_contents->{location}, 'test🙂', 'Tested encoding/decoding' );

    my $templates = Koha::Item::Templates->get_available( $patron_1->id );
    is( $templates->{owned}->count,  1, "Got back one owned template" );
    is( $templates->{shared}->count, 1, "Got back one shared templated" );

    $schema->storage->txn_rollback;
};
