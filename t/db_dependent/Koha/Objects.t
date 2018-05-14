#!/usr/bin/perl

# Copyright 2015 Koha Development team
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

use Test::More tests => 14;
use Test::Exception;
use Test::Warn;

use Koha::Authority::Types;
use Koha::Cities;
use Koha::IssuingRules;
use Koha::Patron::Category;
use Koha::Patron::Categories;
use Koha::Patrons;
use Koha::Database;

use t::lib::TestBuilder;

use Try::Tiny;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

is( ref(Koha::Authority::Types->find('')), 'Koha::Authority::Type', 'Koha::Objects->find should work if the primary key is an empty string' );

my @columns = Koha::Patrons->columns;
my $borrowernumber_exists = grep { /^borrowernumber$/ } @columns;
is( $borrowernumber_exists, 1, 'Koha::Objects->columns should return the table columns' );

subtest 'find' => sub {
    plan tests => 4;
    my $patron = $builder->build({source => 'Borrower'});
    my $patron_object = Koha::Patrons->find( $patron->{borrowernumber} );
    is( $patron_object->borrowernumber, $patron->{borrowernumber}, '->find should return the correct object' );

    eval { my @patrons = Koha::Patrons->find( $patron->{borrowernumber} ); };
    like( $@, qr|^Cannot use "->find" in list context|, "->find should not be called in list context to avoid side-effects" );

    # Test sending undef to find; should not generate a warning
    warning_is { $patron = Koha::Patrons->find( undef ); }
        "", "Sending undef does not trigger a DBIx warning";
    warning_is { $patron = Koha::Patrons->find( undef, undef ); }
        "", "Sending two undefs does not trigger a DBIx warning too";
};

subtest 'update' => sub {
    plan tests => 2;

    $builder->build( { source => 'City', value => { city_country => 'UK' } } );
    $builder->build( { source => 'City', value => { city_country => 'UK' } } );
    $builder->build( { source => 'City', value => { city_country => 'UK' } } );
    $builder->build( { source => 'City', value => { city_country => 'France' } } );
    $builder->build( { source => 'City', value => { city_country => 'France' } } );
    $builder->build( { source => 'City', value => { city_country => 'Germany' } } );
    Koha::Cities->search( { city_country => 'UK' } )->update( { city_country => 'EU' } );
    is( Koha::Cities->search( { city_country => 'EU' } )->count, 3, 'Koha::Objects->update should have updated the 3 rows' );
    is( Koha::Cities->search( { city_country => 'UK' } )->count, 0, 'Koha::Objects->update should have updated the 3 rows' );
};

subtest 'reset' => sub {
    plan tests => 3;

    my $patrons = Koha::Patrons->search;
    my $first_borrowernumber = $patrons->next->borrowernumber;
    my $second_borrowernumber = $patrons->next->borrowernumber;
    is( ref( $patrons->reset ), 'Koha::Patrons', 'Koha::Objects->reset should allow chaining' );
    is( ref( $patrons->reset->next ), 'Koha::Patron', 'Koha::Objects->reset should allow chaining' );
    is( $patrons->reset->next->borrowernumber, $first_borrowernumber, 'Koha::Objects->reset should work as expected');
};

subtest 'delete' => sub {
    plan tests => 2;

    my $patron_1 = $builder->build({source => 'Borrower'});
    my $patron_2 = $builder->build({source => 'Borrower'});
    is( Koha::Patrons->search({ -or => { borrowernumber => [ $patron_1->{borrowernumber}, $patron_2->{borrowernumber}]}})->delete, 2, '');
    is( Koha::Patrons->search({ -or => { borrowernumber => [ $patron_1->{borrowernumber}, $patron_2->{borrowernumber}]}})->count, 0, '');
};

subtest 'new' => sub {
    plan tests => 2;
    my $a_cat_code = 'A_CAT_CODE';
    my $patron_category = Koha::Patron::Category->new( { categorycode => $a_cat_code } )->store;
    is( Koha::Patron::Categories->find($a_cat_code)->category_type, 'A', 'Koha::Object->new should set the default value' );
    Koha::Patron::Categories->find($a_cat_code)->delete;
    $patron_category = Koha::Patron::Category->new( { categorycode => $a_cat_code, category_type => undef } )->store;
    is( Koha::Patron::Categories->find($a_cat_code)->category_type, 'A', 'Koha::Object->new should set the default value even if the argument exists but is not defined' );
    Koha::Patron::Categories->find($a_cat_code)->delete;
};

subtest 'find' => sub {
    plan tests => 5;

    # check find on a single PK
    my $patron = $builder->build({ source => 'Borrower' });
    is( Koha::Patrons->find($patron->{borrowernumber})->surname,
        $patron->{surname}, "Checking an arbitrary patron column after find"
    );
    # check find with unique column
    my $obj = Koha::Patrons->find($patron->{cardnumber}, { key => 'cardnumber' });
    is( $obj->borrowernumber, $patron->{borrowernumber},
        'Find with unique column and key specified' );
    # check find with an additional where clause in the attrs hash
    # we do not expect to find something now
    is( Koha::Patrons->find(
        $patron->{borrowernumber},
        { where => { surname => { '!=', $patron->{surname} }}},
    ), undef, 'Additional where clause in find call' );

    # check find with a composite FK
    my $rule = $builder->build({ source => 'Issuingrule' });
    my @pk = ( $rule->{branchcode}, $rule->{categorycode}, $rule->{itemtype} );
    is( ref(Koha::IssuingRules->find(@pk)), "Koha::IssuingRule",
        'Find returned a Koha object for composite primary key' );

    is( Koha::Patrons->find(), undef, 'Find returns undef if no params passed' );
};

subtest 'search_related' => sub {
    plan tests => 8;
    my $builder   = t::lib::TestBuilder->new;
    my $patron_1  = $builder->build( { source => 'Borrower' } );
    my $patron_2  = $builder->build( { source => 'Borrower' } );
    my $libraries = Koha::Patrons->search( { -or => { borrowernumber => [ $patron_1->{borrowernumber}, $patron_2->{borrowernumber} ] } } )->search_related('branchcode');
    is( ref( $libraries ), 'Koha::Libraries', 'Koha::Objects->search_related should return an instanciated Koha::Objects-based object' );
    is( $libraries->count,            2,                       'Koha::Objects->search_related should work as expected' );
    is( $libraries->next->branchcode, $patron_1->{branchcode}, 'Koha::Objects->search_related should work as expected' );
    is( $libraries->next->branchcode, $patron_2->{branchcode}, 'Koha::Objects->search_related should work as expected' );

    my @libraries = Koha::Patrons->search( { -or => { borrowernumber => [ $patron_1->{borrowernumber}, $patron_2->{borrowernumber} ] } } )->search_related('branchcode');
    is( ref( $libraries[0] ),      'Koha::Library',         'Koha::Objects->search_related should return a list of Koha::Object-based objects' );
    is( scalar(@libraries),        2,                       'Koha::Objects->search_related should work as expected' );
    is( $libraries[0]->branchcode, $patron_1->{branchcode}, 'Koha::Objects->search_related should work as expected' );
    is( $libraries[1]->branchcode, $patron_2->{branchcode}, 'Koha::Objects->search_related should work as expected' );
};

subtest 'single' => sub {
    plan tests => 2;
    my $builder   = t::lib::TestBuilder->new;
    my $patron_1  = $builder->build( { source => 'Borrower' } );
    my $patron_2  = $builder->build( { source => 'Borrower' } );
    my $patron = Koha::Patrons->search({}, { rows => 1 })->single;
    is(ref($patron), 'Koha::Patron', 'Koha::Objects->single returns a single Koha::Patron object.');
    warning_like { Koha::Patrons->search->single } qr/SQL that returns multiple rows/,
    "Warning is presented if single is used for a result with multiple rows.";
};

subtest 'last' => sub {
    plan tests => 3;
    my $builder = t::lib::TestBuilder->new;
    my $patron_1  = $builder->build( { source => 'Borrower' } );
    my $patron_2  = $builder->build( { source => 'Borrower' } );
    my $last_patron = Koha::Patrons->search->last;
    is( $last_patron->borrowernumber, $patron_2->{borrowernumber}, '->last should return the last inserted patron' );
    $last_patron = Koha::Patrons->search({ borrowernumber => $patron_1->{borrowernumber} })->last;
    is( $last_patron->borrowernumber, $patron_1->{borrowernumber}, '->last should work even if there is only 1 result' );
    $last_patron = Koha::Patrons->search({ surname => 'should_not_exist' })->last;
    is( $last_patron, undef, '->last should return undef if search does not return any results' );
};

subtest 'get_column' => sub {
    plan tests => 1;
    my @cities = Koha::Cities->search;
    my @city_names = map { $_->city_name } @cities;
    is_deeply( [ Koha::Cities->search->get_column('city_name') ], \@city_names, 'Koha::Objects->get_column should be allowed' );
};

subtest 'Exceptions' => sub {
    plan tests => 7;

    my $patron_borrowernumber = $builder->build({ source => 'Borrower' })->{ borrowernumber };
    my $patron = Koha::Patrons->find( $patron_borrowernumber );

    # Koha::Object
    try {
        $patron->blah('blah');
    } catch {
        ok( $_->isa('Koha::Exceptions::Object::MethodNotCoveredByTests'),
            'Calling a non-covered method should raise a Koha::Exceptions::Object::MethodNotCoveredByTests exception' );
        is( $_->message, 'The method Koha::Patron->blah is not covered by tests!', 'The message raised should contain the package and the method' );
    };

    try {
        $patron->set({ blah => 'blah' });
    } catch {
        ok( $_->isa('Koha::Exceptions::Object::PropertyNotFound'),
            'Setting a non-existent property should raise a Koha::Exceptions::Object::PropertyNotFound exception' );
    };

    # Koha::Objects
    try {
        Koha::Patrons->search->not_covered_yet;
    } catch {
        ok( $_->isa('Koha::Exceptions::Object::MethodNotCoveredByTests'),
            'Calling a non-covered method should raise a Koha::Exceptions::Object::MethodNotCoveredByTests exception' );
        is( $_->message, 'The method Koha::Patrons->not_covered_yet is not covered by tests!', 'The message raised should contain the package and the method' );
    };

    try {
        Koha::Patrons->not_covered_yet;
    } catch {
        ok( $_->isa('Koha::Exceptions::Object::MethodNotCoveredByTests'),
            'Calling a non-covered method should raise a Koha::Exceptions::Object::MethodNotCoveredByTests exception' );
        is( $_->message, 'The method Koha::Patrons->not_covered_yet is not covered by tests!', 'The message raised should contain the package and the method' );
    };
};

$schema->storage->txn_rollback;

subtest '->is_paged and ->pager tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    # Delete existing patrons
    Koha::Checkouts->delete;
    Koha::Patrons->delete;
    # Create 10 patrons
    foreach (1..10) {
        $builder->build_object({ class => 'Koha::Patrons' });
    }

    # Non-paginated search
    my $patrons = Koha::Patrons->search();
    is( $patrons->count, 10, 'Search returns all patrons' );
    ok( !$patrons->is_paged, 'Search is not paged' );

    # Paginated search
    $patrons = Koha::Patrons->search( undef, { 'page' => 1, 'rows' => 3 } );
    is( $patrons->count, 3, 'Search returns only one page, 3 patrons' );
    ok( $patrons->is_paged, 'Search is paged' );
    my $pager = $patrons->pager;
    is( ref($patrons->pager), 'DBIx::Class::ResultSet::Pager',
       'Koha::Objects->pager returns a valid DBIx::Class object' );

    $schema->storage->txn_rollback;
};
