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

use Test::More tests => 7;
use t::lib::Mocks;
use t::lib::TestBuilder;

use Koha::Patron::Categories;
use Koha::Checkouts;
use Koha::Patrons;
use Koha::Database;
use Koha::Template::Plugin::Categories;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $nb_categories = Koha::Patron::Categories->count;

# Create sample categories
my $category_1 = $builder->build_object( { class => 'Koha::Patron::Categories', value => { description => 'ZZZZZZ' } } );
my @categories = Koha::Template::Plugin::Categories->new->all->as_list;
is( scalar(@categories), 1 + $nb_categories, '->all returns all defined categories' );

my $category_2 = $builder->build_object( { class => 'Koha::Patron::Categories', value => { description => 'AAAAAA' } } );
@categories = Koha::Template::Plugin::Categories->new->all->as_list;
is( scalar(@categories), 2 + $nb_categories, '->all returns all defined categories' );

my $category_1_pos = 0;
my $category_2_pos = 0;
for ( my $i = 0 ; $i < scalar(@categories) ; $i++ ) {
    my $idescription = $categories[$i]->description // '';
    if ( $idescription eq $category_1->description ) {
        $category_1_pos = $i;
    }
    if ( $idescription eq $category_2->description ) {
        $category_2_pos = $i;
    }
}
ok( $category_1_pos > $category_2_pos, 'Categories are sorted by description' );

is( Koha::Template::Plugin::Categories->GetName(
        $category_1->categorycode
    ),
    $category_1->description,
    '->GetName returns the right description'
);

my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );
$category_1->library_limits( [ $library_1->branchcode ] );
$category_2->library_limits( [ $library_2->branchcode ] );
t::lib::Mocks::mock_userenv( { branchcode => $library_1->branchcode } );
my $limited = Koha::Template::Plugin::Categories->limited;
is( $limited->search( { 'me.categorycode' => $category_1->categorycode } )->count,
    1, 'Category 1 is available from library 1' );
is( $limited->search( { 'me.categorycode' => $category_2->categorycode } )->count,
    0, 'Category 2 is not available from library 1' );

$schema->storage->txn_rollback;

subtest 'can_any_reset_password() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    # Make sure all existing categories have reset_password set to 0
    Koha::Patron::Categories->search->update({ reset_password => 0 });

    ok( !Koha::Template::Plugin::Categories->new->can_any_reset_password, 'No category is allowed to reset password' );

    t::lib::Mocks::mock_preference( 'OpacResetPassword', 0 );

    my $category = $builder->build_object({ class => 'Koha::Patron::Categories', value => { reset_password => 1 } });

    ok( Koha::Template::Plugin::Categories->new->can_any_reset_password, 'There\'s at least a category that is allowed to reset password' );

    $category->reset_password( undef )->store;

    ok( !Koha::Template::Plugin::Categories->new->can_any_reset_password, 'No category is allowed to reset password' );

    $schema->storage->txn_rollback;
};
