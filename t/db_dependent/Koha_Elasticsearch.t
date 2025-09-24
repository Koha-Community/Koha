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
# along with Koha; if not, see <https://www.gnu.org/licenses>

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;
use Test::MockModule;

use t::lib::Mocks;
use t::lib::TestBuilder;
use MARC::Record;

use Koha::SearchFields;
use Koha::SearchEngine::Elasticsearch;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'get_facet_fields() tests' => sub {

    plan tests => 13;

    $schema->storage->txn_begin;

    Koha::SearchFields->search()->delete;

    $builder->build(
        {
            source => 'SearchField',
            value  => {
                name        => 'author',
                label       => 'author',
                type        => 'string',
                facet_order => undef
            }
        }
    );
    $builder->build(
        {
            source => 'SearchField',
            value  => {
                name        => 'holdingbranch',
                label       => 'holdingbranch',
                type        => 'string',
                facet_order => 1
            }
        }
    );
    $builder->build(
        {
            source => 'SearchField',
            value  => {
                name        => 'homebranch',
                label       => 'homebranch',
                type        => 'string',
                facet_order => 2
            }
        }
    );
    $builder->build(
        {
            source => 'SearchField',
            value  => {
                name        => 'itype',
                label       => 'itype',
                type        => 'string',
                facet_order => 3
            }
        }
    );
    $builder->build(
        {
            source => 'SearchField',
            value  => {
                name        => 'title-series',
                label       => 'titles-series',
                type        => 'string',
                facet_order => 4
            }
        }
    );
    $builder->build(
        {
            source => 'SearchField',
            value  => {
                name        => 'su-geo',
                label       => 'su-geo',
                type        => 'string',
                facet_order => 5
            }
        }
    );
    $builder->build(
        {
            source => 'SearchField',
            value  => {
                name        => 'subject',
                label       => 'subject',
                type        => 'string',
                facet_order => 6
            }
        }
    );
    $builder->build(
        {
            source => 'SearchField',
            value  => {
                name        => 'not_facetable_field',
                label       => 'not_facetable_field',
                type        => 'string',
                facet_order => undef
            }
        }
    );

    my @faceted_fields = Koha::SearchEngine::Elasticsearch->get_facet_fields();
    is( scalar(@faceted_fields), 6 );

    is( $faceted_fields[0]->name,        'holdingbranch' );
    is( $faceted_fields[0]->facet_order, 1 );
    is( $faceted_fields[1]->name,        'homebranch' );
    is( $faceted_fields[1]->facet_order, 2 );
    is( $faceted_fields[2]->name,        'itype' );
    is( $faceted_fields[2]->facet_order, 3 );
    is( $faceted_fields[3]->name,        'title-series' );
    is( $faceted_fields[3]->facet_order, 4 );
    is( $faceted_fields[4]->name,        'su-geo' );
    is( $faceted_fields[4]->facet_order, 5 );
    is( $faceted_fields[5]->name,        'subject' );
    is( $faceted_fields[5]->facet_order, 6 );

    $schema->storage->txn_rollback;
};
