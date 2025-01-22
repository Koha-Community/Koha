#!/usr/bin/perl

# This file is part of Koha.
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

use Koha::Database;

use t::lib::TestBuilder;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'usage_count() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $source = $builder->build_object( { class => 'Koha::RecordSources' } );

    is( $source->usage_count, 0, q{Unused record source has a count of 0} );

    foreach ( 1 .. 3 ) {
        my $biblio = $builder->build_sample_biblio();
        $biblio->metadata->record_source_id( $source->id )->store();
    }

    is( $source->usage_count, 3, q{3 records linked, count is 3} );

    $schema->storage->txn_rollback;
};
