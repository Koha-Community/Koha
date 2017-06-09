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

use Test::More tests => 4;
use t::lib::TestBuilder;

use Koha::Patron::Categories;
use Koha::Checkouts;
use Koha::Patrons;
use Koha::Database;
use Koha::Template::Plugin::Categories;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

# Delete all categories
Koha::Checkouts->search->delete;
Koha::Patrons->search->delete;
Koha::Patron::Categories->search->delete;

my $builder = t::lib::TestBuilder->new;

is( Koha::Template::Plugin::Categories->new->all->count,
    0, '->all returns 0 results if no categories defined' );

# Create sample categories
my $category_1 = $builder->build( { source => 'Category' } );
my @categories = Koha::Template::Plugin::Categories->new->all;
is( scalar(@categories), 1, '->all returns all defined categories' );

my $category_2 = $builder->build( { source => 'Category' } );
@categories = Koha::Template::Plugin::Categories->new->all;
is( scalar(@categories), 2, '->all returns all defined categories' );

is( Koha::Template::Plugin::Categories->GetName(
        $category_1->{categorycode}
    ),
    $category_1->{description},
    '->GetName returns the right description'
);

$schema->storage->txn_rollback;

