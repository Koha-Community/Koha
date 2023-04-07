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

use Test::More tests => 1;
use Test::Exception;
use Test::Warn;

use Koha::Preservation::Processings;
use Koha::Database;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'attributes' => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $processing = $builder->build_object( { class => 'Koha::Preservation::Processings' } );

    my $attributes = [
        { name => 'color', type => 'authorised_value', option_source => 'COLORS' },
        { name => 'title', type => 'db_column',        option_source => '245$a' },
        {
            name => 'height',
            type => 'free_text'
        },
    ];
    $processing->attributes($attributes);
    my $fetched_attributes = $processing->attributes;
    is( ref($fetched_attributes),   'Koha::Preservation::Processing::Attributes' );
    is( $fetched_attributes->count, 3 );
    $processing->attributes( [] );
    is( ref($fetched_attributes),   'Koha::Preservation::Processing::Attributes' );
    is( $fetched_attributes->count, 0 );

    $schema->storage->txn_rollback;
};
