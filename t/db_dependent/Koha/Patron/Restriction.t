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
# along with Koha; if not, see <http://www.gnu.org/licenses>

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 4;
use Test::Exception;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;

my $builder = t::lib::TestBuilder->new;

use_ok('Koha::Patron::Restriction');
use_ok('Koha::Patron::Restrictions');

subtest 'is_expired' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $debarment   = $builder->build( { source => 'BorrowerDebarment' } );
    my $restriction = Koha::Patron::Restrictions->find( $debarment->{borrower_debarment_id} );

    $restriction->expiration(undef)->store->discard_changes;
    is( $restriction->is_expired, 0, 'Restriction should not be considered expired if dateexpiry is not set' );

    $restriction->expiration( dt_from_string->add( days => 1 ) )->store->discard_changes;
    is( $restriction->is_expired, 0, 'Restriction should not be considered expired if dateexpiry is tomorrow' );

    $restriction->expiration(dt_from_string)->store->discard_changes;
    is( $restriction->is_expired, 1, 'Restriction should be considered expired if dateexpiry is today' );

    $restriction->expiration( dt_from_string->add( days => -1 ) )->store->discard_changes;
    is( $restriction->is_expired, 1, 'Restriction should be considered expired if dateexpiry is yesterday' );

    $schema->storage->txn_rollback;
};

1;
