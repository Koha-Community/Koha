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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 25;
use Test::Exception;
use Test::MockModule;
use Test::Warn;

use C4::Context;

use Koha::Authority::Types;
use Koha::Cities;
use Koha::Biblios;
use Koha::Items;
use Koha::Patron::Category;
use Koha::Patron::Categories;
use Koha::Patrons;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use t::lib::TestBuilder;
use t::lib::Mocks;

use Try::Tiny;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

is(
    ref( Koha::Authority::Types->find('') ), 'Koha::Authority::Type',
    'Koha::Objects->find should work if the primary key is an empty string'
);

my @columns               = Koha::Patrons->columns;
my $borrowernumber_exists = grep { /^borrowernumber$/ } @columns;
is( $borrowernumber_exists, 1, 'Koha::Objects->columns should return the table columns' );

subtest 'find' => sub {
    plan tests => 6;
    my $patron        = $builder->build( { source => 'Borrower' } );
    my $patron_object = Koha::Patrons->find( $patron->{borrowernumber} );
    is( $patron_object->borrowernumber, $patron->{borrowernumber}, '->find should return the correct object' );

    my @patrons = Koha::Patrons->find( $patron->{borrowernumber} );
    is( scalar @patrons, 1, '->find in list context returns a value' );
    is(
        $patrons[0]->borrowernumber, $patron->{borrowernumber},
        '->find in list context returns the same value as in scalar context'
    );

    my $patrons = {
        foo => Koha::Patrons->find('foo'),
        bar => 'baz',
    };
    is( $patrons->{foo}, undef, '->find in list context returns undef when no record is found' );

    # Test sending undef to find; should not generate a warning
    warning_is { $patron = Koha::Patrons->find(undef); }
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
    is(
        Koha::Cities->search( { city_country => 'EU' } )->count, 3,
        'Koha::Objects->update should have updated the 3 rows'
    );
    is(
        Koha::Cities->search( { city_country => 'UK' } )->count, 0,
        'Koha::Objects->update should have updated the 3 rows'
    );
};

subtest 'reset' => sub {
    plan tests => 3;

    my $patrons               = Koha::Patrons->search;
    my $first_borrowernumber  = $patrons->next->borrowernumber;
    my $second_borrowernumber = $patrons->next->borrowernumber;
    is( ref( $patrons->reset ),                'Koha::Patrons',       'Koha::Objects->reset should allow chaining' );
    is( ref( $patrons->reset->next ),          'Koha::Patron',        'Koha::Objects->reset should allow chaining' );
    is( $patrons->reset->next->borrowernumber, $first_borrowernumber, 'Koha::Objects->reset should work as expected' );
};

subtest 'delete' => sub {
    plan tests => 2;

    my $patron_1 = $builder->build( { source => 'Borrower' } );
    my $patron_2 = $builder->build( { source => 'Borrower' } );
    is(
        Koha::Patrons->search(
            { -or => { borrowernumber => [ $patron_1->{borrowernumber}, $patron_2->{borrowernumber} ] } }
        )->delete,
        2,
        ''
    );
    is(
        Koha::Patrons->search(
            { -or => { borrowernumber => [ $patron_1->{borrowernumber}, $patron_2->{borrowernumber} ] } }
        )->count,
        0,
        ''
    );
};

subtest 'new' => sub {
    plan tests => 2;
    my $a_cat_code      = 'A_CAT_CODE';
    my $patron_category = Koha::Patron::Category->new( { categorycode => $a_cat_code } )->store;
    is(
        Koha::Patron::Categories->find($a_cat_code)->category_type, 'A',
        'Koha::Object->new should set the default value'
    );
    Koha::Patron::Categories->find($a_cat_code)->delete;
    $patron_category = Koha::Patron::Category->new( { categorycode => $a_cat_code, category_type => undef } )->store;
    is(
        Koha::Patron::Categories->find($a_cat_code)->category_type, 'A',
        'Koha::Object->new should set the default value even if the argument exists but is not defined'
    );
    Koha::Patron::Categories->find($a_cat_code)->delete;
};

subtest 'find' => sub {
    plan tests => 5;

    # check find on a single PK
    my $patron = $builder->build( { source => 'Borrower' } );
    is(
        Koha::Patrons->find( $patron->{borrowernumber} )->surname,
        $patron->{surname}, "Checking an arbitrary patron column after find"
    );

    # check find with unique column
    my $obj = Koha::Patrons->find( $patron->{cardnumber}, { key => 'cardnumber' } );
    is(
        $obj->borrowernumber, $patron->{borrowernumber},
        'Find with unique column and key specified'
    );

    # check find with an additional where clause in the attrs hash
    # we do not expect to find something now
    is(
        Koha::Patrons->find(
            $patron->{borrowernumber},
            { where => { surname => { '!=', $patron->{surname} } } },
        ),
        undef,
        'Additional where clause in find call'
    );

    is( Koha::Patrons->find(), undef, 'Find returns undef if no params passed' );

    # Test that find passes $result in object_class call
    my $module = Test::MockModule->new('Koha::Patrons');
    $module->mock(
        'object_class',
        sub {
            my ( $self, $params ) = @_;
            warn "Found " . ref $params;
            return $module->original("object_class")->( $self, $params );
        }
    );
    warning_is { $obj = Koha::Patrons->find( $patron->{borrowernumber} ); }
    'Found Koha::Schema::Result::Borrower', "Koha::Objects->find passed DBIx::Class::Result to \$self->object_class";
    $module->unmock('object_class');
};

subtest 'search_related' => sub {

    plan tests => 3;

    my $builder   = t::lib::TestBuilder->new;
    my $patron_1  = $builder->build( { source => 'Borrower' } );
    my $patron_2  = $builder->build( { source => 'Borrower' } );
    my $libraries = Koha::Patrons->search(
        { -or => { borrowernumber => [ $patron_1->{borrowernumber}, $patron_2->{borrowernumber} ] } } )
        ->search_related('branchcode');
    is(
        ref($libraries), 'Koha::Libraries',
        'Koha::Objects->search_related should return an instantiated Koha::Objects-based object'
    );
    is(
        $libraries->count, 2,
        'Koha::Objects->search_related should work as expected'
    );
    ok(
        eq_array(
            [ $libraries->get_column('branchcode') ],
            [ $patron_1->{branchcode}, $patron_2->{branchcode} ]
        ),
        'Koha::Objects->search_related should work as expected'
    );
};

subtest 'single' => sub {
    plan tests => 3;
    my $builder  = t::lib::TestBuilder->new;
    my $patron_1 = $builder->build( { source => 'Borrower' } );
    my $patron_2 = $builder->build( { source => 'Borrower' } );
    my $patron   = Koha::Patrons->search( {}, { rows => 1 } )->single;
    is( ref($patron), 'Koha::Patron', 'Koha::Objects->single returns a single Koha::Patron object.' );
    warning_like { Koha::Patrons->search->single } qr/SQL that returns multiple rows/,
        "Warning is presented if single is used for a result with multiple rows.";

    # Test that single passes $result in object_class call
    my $module = Test::MockModule->new('Koha::Patrons');
    $module->mock(
        'object_class',
        sub {
            my ( $self, $params ) = @_;
            warn "Found " . ref $params;
            return $module->original("object_class")->( $self, $params );
        }
    );
    warning_is { $patron = Koha::Patrons->search( {}, { rows => 1 } )->single; }
    'Found Koha::Schema::Result::Borrower',
        "Koha::Objects->single passed DBIx::Class::Result into \$self->object_class";

    $module->unmock('object_class');
};

subtest 'next' => sub {
    plan tests => 1;

    my $builder  = t::lib::TestBuilder->new;
    my $patron_1 = $builder->build( { source => 'Borrower' } );
    my $patron_2 = $builder->build( { source => 'Borrower' } );

    # Test that single passes $result in object_class call
    my $module = Test::MockModule->new('Koha::Patrons');
    $module->mock(
        'object_class',
        sub {
            my ( $self, $params ) = @_;
            warn "Found " . ref $params;
            return $module->original("object_class")->( $self, $params );
        }
    );
    warning_is { my $next_patron = Koha::Patrons->search->next; }
    'Found Koha::Schema::Result::Borrower', "Koha::Objects->next passed DBIx::Class::Result into \$self->object_class";

    $module->unmock('object_class');
};

subtest 'last' => sub {
    plan tests => 4;
    my $builder     = t::lib::TestBuilder->new;
    my $patron_1    = $builder->build( { source => 'Borrower' } );
    my $patron_2    = $builder->build( { source => 'Borrower' } );
    my $last_patron = Koha::Patrons->search->last;
    is( $last_patron->borrowernumber, $patron_2->{borrowernumber}, '->last should return the last inserted patron' );
    $last_patron = Koha::Patrons->search( { borrowernumber => $patron_1->{borrowernumber} } )->last;
    is(
        $last_patron->borrowernumber, $patron_1->{borrowernumber},
        '->last should work even if there is only 1 result'
    );
    $last_patron = Koha::Patrons->search( { surname => 'should_not_exist' } )->last;
    is( $last_patron, undef, '->last should return undef if search does not return any results' );

    # Test that single passes $result in object_class call
    my $module = Test::MockModule->new('Koha::Patrons');
    $module->mock(
        'object_class',
        sub {
            my ( $self, $params ) = @_;
            warn "Found " . ref $params;
            return $module->original("object_class")->( $self, $params );
        }
    );
    warning_is { $last_patron = Koha::Patrons->search->last; }
    'Found Koha::Schema::Result::Borrower', "Koha::Objects->last passed DBIx::Class::Result into \$self->object_class";

    $module->unmock('object_class');
};

subtest 'get_column' => sub {
    plan tests => 1;
    my @cities     = Koha::Cities->search->as_list;
    my @city_names = map { $_->city_name } @cities;
    is_deeply(
        [ Koha::Cities->search->get_column('city_name') ], \@city_names,
        'Koha::Objects->get_column should be allowed'
    );
};

subtest 'Exceptions' => sub {
    plan tests => 7;

    my $patron_borrowernumber = $builder->build( { source => 'Borrower' } )->{borrowernumber};
    my $patron                = Koha::Patrons->find($patron_borrowernumber);

    # Koha::Object
    try {
        $patron->blah('blah');
    } catch {
        ok(
            $_->isa('Koha::Exceptions::Object::MethodNotCoveredByTests'),
            'Calling a non-covered method should raise a Koha::Exceptions::Object::MethodNotCoveredByTests exception'
        );
        is(
            $_->message, 'The method Koha::Patron->blah is not covered by tests!',
            'The message raised should contain the package and the method'
        );
    };

    try {
        $patron->set( { blah => 'blah' } );
    } catch {
        ok(
            $_->isa('Koha::Exceptions::Object::PropertyNotFound'),
            'Setting a non-existent property should raise a Koha::Exceptions::Object::PropertyNotFound exception'
        );
    };

    # Koha::Objects
    try {
        Koha::Patrons->search->not_covered_yet;
    } catch {
        ok(
            $_->isa('Koha::Exceptions::Object::MethodNotCoveredByTests'),
            'Calling a non-covered method should raise a Koha::Exceptions::Object::MethodNotCoveredByTests exception'
        );
        is(
            $_->message, 'The method Koha::Patrons->not_covered_yet is not covered by tests!',
            'The message raised should contain the package and the method'
        );
    };

    try {
        Koha::Patrons->not_covered_yet;
    } catch {
        ok(
            $_->isa('Koha::Exceptions::Object::MethodNotCoveredByTests'),
            'Calling a non-covered method should raise a Koha::Exceptions::Object::MethodNotCoveredByTests exception'
        );
        is(
            $_->message, 'The method Koha::Patrons->not_covered_yet is not covered by tests!',
            'The message raised should contain the package and the method'
        );
    };
};

$schema->storage->txn_rollback;

subtest '->is_paged and ->pager tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    # Count existing patrons
    my $nb_patrons = Koha::Patrons->search()->count;

    # Create 10 more patrons
    foreach ( 1 .. 10 ) {
        $builder->build_object( { class => 'Koha::Patrons' } );
    }

    # Non-paginated search
    my $patrons = Koha::Patrons->search();
    is( $patrons->count, $nb_patrons + 10, 'Search returns all patrons' );
    ok( !$patrons->is_paged, 'Search is not paged' );

    # Paginated search
    $patrons = Koha::Patrons->search( undef, { 'page' => 1, 'rows' => 3 } );
    is( $patrons->count, 3, 'Search returns only one page, 3 patrons' );
    ok( $patrons->is_paged, 'Search is paged' );
    my $pager = $patrons->pager;
    is(
        ref( $patrons->pager ), 'DBIx::Class::ResultSet::Pager',
        'Koha::Objects->pager returns a valid DBIx::Class object'
    );

    $schema->storage->txn_rollback;
};

subtest "to_api() tests" => sub {

    plan tests => 19;

    $schema->storage->txn_begin;

    my $city_1 = $builder->build_object( { class => 'Koha::Cities' } );
    my $city_2 = $builder->build_object( { class => 'Koha::Cities' } );

    my $cities = Koha::Cities->search(
        { cityid   => [ $city_1->cityid, $city_2->cityid ] },
        { -orderby => { -desc => 'cityid' } }
    );

    is( $cities->count, 2, 'Count is correct' );
    my $cities_api = $cities->to_api;
    is( ref($cities_api), 'ARRAY', 'to_api returns an array' );
    is_deeply( $cities_api->[0], $city_1->to_api, 'to_api returns the individual objects with ->to_api' );
    is_deeply( $cities_api->[1], $city_2->to_api, 'to_api returns the individual objects with ->to_api' );

    my $biblio_1 = $builder->build_sample_biblio();
    my $item_1   = $builder->build_sample_item( { biblionumber => $biblio_1->biblionumber } );
    my $hold_1   = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { itemnumber => $item_1->itemnumber }
        }
    );

    my $biblio_2 = $builder->build_sample_biblio();
    my $item_2   = $builder->build_sample_item( { biblionumber => $biblio_2->biblionumber } );
    my $hold_2   = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { itemnumber => $item_2->itemnumber }
        }
    );

    my $embed = { 'items' => {} };

    my $i     = 0;
    my @items = ( $item_1, $item_2 );
    my @holds = ( $hold_1, $hold_2 );

    my $biblios_api = Koha::Biblios->search( { biblionumber => [ $biblio_1->biblionumber, $biblio_2->biblionumber ] } )
        ->to_api( { embed => $embed } );

    foreach my $biblio_api ( @{$biblios_api} ) {
        ok( exists $biblio_api->{items}, 'Items where embedded in biblio results' );
        is( $biblio_api->{items}->[0]->{item_id}, $items[$i]->itemnumber, 'Item matches' );
        ok( !exists $biblio_api->{items}->[0]->{holds}, 'No holds info should be embedded yet' );

        $i++;
    }

    # One more level
    $embed = { 'items' => { children => { 'holds' => {} } } };

    $i = 0;

    $biblios_api = Koha::Biblios->search( { biblionumber => [ $biblio_1->biblionumber, $biblio_2->biblionumber ] } )
        ->to_api( { embed => $embed } );

    foreach my $biblio_api ( @{$biblios_api} ) {

        ok( exists $biblio_api->{items}, 'Items where embedded in biblio results' );
        is( $biblio_api->{items}->[0]->{item_id}, $items[$i]->itemnumber, 'Item still matches' );
        ok( exists $biblio_api->{items}->[0]->{holds}, 'Holds info should be embedded' );
        is( $biblio_api->{items}->[0]->{holds}->[0]->{hold_id}, $holds[$i]->reserve_id, 'Hold matches' );

        $i++;
    }

    subtest 'unprivileged request tests' => sub {

        my @all_attrs    = Koha::Libraries->columns();
        my $public_attrs = { map { $_ => 1 } @{ Koha::Library->public_read_list() } };
        my $mapping      = Koha::Library->to_api_mapping;

        # Create sample libraries
        my $library_1 = $builder->build_object( { class => 'Koha::Libraries' } );
        my $library_2 = $builder->build_object( { class => 'Koha::Libraries' } );
        my $libraries = Koha::Libraries->search(
            { branchcode => { '-in' => [ $library_1->branchcode, $library_2->branchcode ] } } );

        plan tests => scalar @all_attrs * 2 * $libraries->count;

        my $libraries_unprivileged_representation = $libraries->to_api( { public => 1 } );
        my $libraries_privileged_representation   = $libraries->to_api();

        for ( my $i = 0 ; $i < $libraries->count ; $i++ ) {
            my $privileged_representation   = $libraries_privileged_representation->[$i];
            my $unprivileged_representation = $libraries_unprivileged_representation->[$i];
            foreach my $attr (@all_attrs) {
                my $mapped = exists $mapping->{$attr} ? $mapping->{$attr} : $attr;
                if ( defined($mapped) ) {
                    ok(
                        exists $privileged_representation->{$mapped},
                        "Attribute '$attr' is present when privileged"
                    );
                    if ( exists $public_attrs->{$attr} ) {
                        ok(
                            exists $unprivileged_representation->{$mapped},
                            "Attribute '$attr' is present when public"
                        );
                    } else {
                        ok(
                            !exists $unprivileged_representation->{$mapped},
                            "Attribute '$attr' is not present when public"
                        );
                    }
                } else {
                    ok(
                        !exists $privileged_representation->{$attr},
                        "Unmapped attribute '$attr' is not present when privileged"
                    );
                    ok(
                        !exists $unprivileged_representation->{$attr},
                        "Unmapped attribute '$attr' is not present when public"
                    );
                }
            }
        }
    };

    $schema->storage->txn_rollback;
};

subtest "TO_JSON() tests" => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $city_1 = $builder->build_object( { class => 'Koha::Cities' } );
    my $city_2 = $builder->build_object( { class => 'Koha::Cities' } );

    my $cities = Koha::Cities->search(
        { cityid   => [ $city_1->cityid, $city_2->cityid ] },
        { -orderby => { -desc => 'cityid' } }
    );

    is( $cities->count, 2, 'Count is correct' );
    my $cities_json = $cities->TO_JSON;
    is( ref($cities_json), 'ARRAY', 'to_api returns an array' );
    is_deeply( $cities_json->[0], $city_1->TO_JSON, 'TO_JSON returns the individual objects with ->TO_JSON' );
    is_deeply( $cities_json->[1], $city_2->TO_JSON, 'TO_JSON returns the individual objects with ->TO_JSON' );

    $schema->storage->txn_rollback;
};

# Koha::Object[s] must behave the same as DBIx::Class
subtest 'Return same values as DBIx::Class' => sub {
    plan tests => 2;

    subtest 'Delete' => sub {
        plan tests => 2;

        $schema->storage->txn_begin;

        subtest 'Simple Koha::Objects - Koha::Cities' => sub {
            plan tests => 2;

            subtest 'Koha::Object->delete' => sub {

                plan tests => 5;

                my ( $r_us, $e_us, $r_them, $e_them );

                # CASE 1 - Delete an existing object
                my $c = Koha::City->new( { city_name => 'city4test' } )->store;
                try { $r_us = $c->delete; } catch { $e_us = $_ };
                $c = $schema->resultset('City')->new( { city_name => 'city4test_2' } )->update_or_insert;
                try { $r_them = $c->delete; } catch { $e_them = $_ };
                ok(
                    ref($r_us) && ref($r_them),
                    'Successful delete should return the object '
                );
                ok(
                    !defined $e_us && !defined $e_them,
                    'Successful delete should not raise an exception'
                );
                is( ref($r_us), 'Koha::City', 'Successful delete should return our Koha::Object based object' );

                # CASE 2 - Delete an object that is not in storage
                try { $r_us   = $r_us->delete; } catch   { $e_us   = $_ };
                try { $r_them = $r_them->delete; } catch { $e_them = $_ };
                ok(
                    defined $e_us && defined $e_them,
                    'Delete an object that is not in storage should raise an exception'
                );
                is( ref($e_us), 'DBIx::Class::Exception' )
                    ;    # FIXME This needs adjustment, we want to throw a Koha::Exception

            };

            subtest 'Koha::Objects->delete' => sub {

                plan tests => 4;

                my ( $r_us, $e_us, $r_them, $e_them );

                # CASE 1 - Delete existing objects
                my $city_1 = $builder->build_object( { class => 'Koha::Cities' } );
                my $city_2 = $builder->build_object( { class => 'Koha::Cities' } );
                my $city_3 = $builder->build_object( { class => 'Koha::Cities' } );
                my $cities = Koha::Cities->search(
                    {
                        cityid => {
                            -in => [
                                $city_1->cityid,
                                $city_2->cityid,
                                $city_3->cityid,
                            ]
                        }
                    }
                );

                try { $r_us = $cities->delete; } catch { $e_us = $_ };

                $city_1 = $builder->build_object( { class => 'Koha::Cities' } );
                $city_2 = $builder->build_object( { class => 'Koha::Cities' } );
                $city_3 = $builder->build_object( { class => 'Koha::Cities' } );
                $cities = $schema->resultset('City')->search(
                    {
                        cityid => {
                            -in => [
                                $city_1->cityid,
                                $city_2->cityid,
                                $city_3->cityid,
                            ]
                        }
                    }
                );

                try { $r_them = $cities->delete; } catch { $e_them = $_ };

                ok( $r_us == 3 && $r_them == 3 );
                ok( !defined($e_us) && !defined($e_them) );

                # CASE 2 - One of the object is not in storage
                $city_1 = $builder->build_object( { class => 'Koha::Cities' } );
                $city_2 = $builder->build_object( { class => 'Koha::Cities' } );
                $city_3 = $builder->build_object( { class => 'Koha::Cities' } );
                $cities = Koha::Cities->search(
                    {
                        cityid => {
                            -in => [
                                $city_1->cityid,
                                $city_2->cityid,
                                $city_3->cityid,
                            ]
                        }
                    }
                );

                $city_2->delete;    # We delete one of the object
                try { $r_us = $cities->delete; } catch { $e_us = $_ };

                $city_1 = $builder->build_object( { class => 'Koha::Cities' } );
                $city_2 = $builder->build_object( { class => 'Koha::Cities' } );
                $city_3 = $builder->build_object( { class => 'Koha::Cities' } );
                $cities = $schema->resultset('City')->search(
                    {
                        cityid => {
                            -in => [
                                $city_1->cityid,
                                $city_2->cityid,
                                $city_3->cityid,
                            ]
                        }
                    }
                );

                $city_2->delete;    # We delete one of the object
                try { $r_them = $cities->delete; } catch { $e_them = $_ };

                ok( $r_us == 2 && $r_them == 2 );
                ok( !defined($e_us) && !defined($e_them) );
            };
        };

        subtest 'Overwritten Koha::Objects->delete - Koha::Patrons' => sub {

            plan tests => 2;

            subtest 'Koha::Object->delete' => sub {

                plan tests => 7;

                my ( $r_us, $e_us, $r_them, $e_them );

                # CASE 1 - Delete an existing patron
                my $patron      = $builder->build_object( { class => 'Koha::Patrons' } );
                my $patron_data = $patron->unblessed;
                $patron->delete;

                $patron = Koha::Patron->new($patron_data)->store;
                try { $r_us = $patron->delete; } catch { $e_us = $_ };
                $patron = $schema->resultset('Borrower')->new($patron_data)->update_or_insert;
                try { $r_them = $patron->delete; } catch { $e_them = $_ };
                ok(
                    ref($r_us) && ref($r_them),
                    'Successful delete should return the patron object'
                );
                ok(
                    !defined $e_us && !defined $e_them,
                    'Successful delete should not raise an exception'
                );
                is(
                    ref($r_us), 'Koha::Patron',
                    'Successful delete should return our Koha::Object based object'
                );

                # CASE 2 - Delete a patron that is not in storage
                try { $r_us   = $r_us->delete; } catch   { $e_us   = $_ };
                try { $r_them = $r_them->delete; } catch { $e_them = $_ };
                ok(
                    defined $e_us && defined $e_them,
                    'Delete a patron that is not in storage should raise an exception'
                );
                is( ref($e_us), 'DBIx::Class::Exception' )
                    ;    # FIXME This needs adjustment, we want to throw a Koha::Exception

                # CASE 3 - Delete a patron that cannot be deleted (as a checkout)
                $patron = Koha::Patron->new($patron_data)->store;
                $builder->build_object(
                    {
                        class => 'Koha::Checkouts',
                        value => { borrowernumber => $patron->borrowernumber }
                    }
                );
                try { $r_us = $r_us->delete; } catch { $e_us = $_ };
                $patron = $schema->resultset('Borrower')->find( $patron->borrowernumber );
                try { $r_them = $r_them->delete; } catch { $e_them = $_ };
                ok(
                    defined $e_us && defined $e_them,
                    'Delete a patron that cannot be deleted should raise an exception'
                );
                is( ref($e_us), 'DBIx::Class::Exception' )
                    ;    # FIXME This needs adjustment, we want to throw a Koha::Exception
            };

            subtest 'Koha::Objects->delete' => sub {

                plan tests => 7;

                my ( $r_us, $e_us, $r_them, $e_them );

                # CASE 1 - Delete existing objects
                my $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
                my $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
                my $patron_3 = $builder->build_object( { class => 'Koha::Patrons' } );
                my $patrons  = Koha::Patrons->search(
                    {
                        borrowernumber => {
                            -in => [
                                $patron_1->borrowernumber,
                                $patron_2->borrowernumber,
                                $patron_3->borrowernumber
                            ]
                        }
                    }
                );

                try { $r_us = $patrons->delete; } catch { $e_us = $_ };

                $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_3 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patrons  = $schema->resultset('Borrower')->search(
                    {
                        borrowernumber => {
                            -in => [
                                $patron_1->borrowernumber,
                                $patron_2->borrowernumber,
                                $patron_3->borrowernumber
                            ]
                        }
                    }
                );

                try { $r_them = $patrons->delete; } catch { $e_them = $_ };

                ok( $r_us == 3 && $r_them == 3, '->delete should return the number of deleted patrons' );
                ok(
                    !defined($e_us) && !defined($e_them),
                    '->delete should not raise exception if everything went well'
                );

                # CASE 2 - One of the patrons is not in storage
                undef $_ for $r_us, $e_us, $r_them, $e_them;
                $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_3 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patrons  = Koha::Patrons->search(
                    {
                        borrowernumber => {
                            -in => [
                                $patron_1->borrowernumber,
                                $patron_2->borrowernumber,
                                $patron_3->borrowernumber
                            ]
                        }
                    }
                );

                $patron_2->delete;    # We delete one of the patron
                try { $r_us = $patrons->delete; } catch { $e_us = $_ };

                $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_3 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patrons  = $schema->resultset('Borrower')->search(
                    {
                        borrowernumber => {
                            -in => [
                                $patron_1->borrowernumber,
                                $patron_2->borrowernumber,
                                $patron_3->borrowernumber
                            ]
                        }
                    }
                );

                $patron_2->delete;    # We delete one of the patron
                try { $r_them = $patrons->delete; } catch { $e_them = $_ };

                ok(
                    $r_us == 2 && $r_them == 2,
                    'Delete patrons with one that was not in storage should delete the patrons'
                );
                ok(
                    !defined($e_us) && !defined($e_them),
                    'no exception should be raised if at least one patron was not in storage'
                );

                # CASE 3 - Delete a set of patrons with one that that cannot be deleted (as a checkout)
                undef $_ for $r_us, $e_us, $r_them, $e_them;
                $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_3 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patrons  = Koha::Patrons->search(
                    {
                        borrowernumber => {
                            -in => [
                                $patron_1->borrowernumber,
                                $patron_2->borrowernumber,
                                $patron_3->borrowernumber
                            ]
                        }
                    }
                );

                # Adding a checkout to patron_2
                $builder->build_object(
                    {
                        class => 'Koha::Checkouts',
                        value => { borrowernumber => $patron_2->borrowernumber }
                    }
                );

                try { $r_us = $patrons->delete; } catch { $e_us = $_ };
                my $not_deleted_us = $patron_1->in_storage + $patron_2->in_storage + $patron_3->in_storage;

                $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_3 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patrons  = $schema->resultset('Borrower')->search(
                    {
                        borrowernumber => {
                            -in => [
                                $patron_1->borrowernumber,
                                $patron_2->borrowernumber,
                                $patron_3->borrowernumber
                            ]
                        }
                    }
                );

                # Adding a checkout to patron_2
                $builder->build_object(
                    {
                        class => 'Koha::Checkouts',
                        value => { borrowernumber => $patron_2->borrowernumber }
                    }
                );

                try { $r_them = $patrons->delete; } catch { $e_them = $_ };

                my $not_deleted_them = $patron_1->in_storage + $patron_2->in_storage + $patron_3->in_storage;
                ok(
                    defined $e_us && defined $e_them,
                    'Delete patrons with one that cannot be deleted should raise an exception'
                );
                is( ref($e_us), 'Koha::Exceptions::Object::FKConstraintDeletion' );

                ok(
                    $not_deleted_us == 3 && $not_deleted_them == 3,
                    'If one patron cannot be deleted, none should have been deleted'
                );
            };
        };

        $schema->storage->txn_rollback;

    };

    subtest 'Update (set/store)' => sub {
        plan tests => 2;

        $schema->storage->txn_begin;

        subtest 'Simple Koha::Objects - Koha::Cities' => sub {
            plan tests => 2;

            subtest 'Koha::Object->update' => sub {

                plan tests => 5;

                my ( $r_us, $e_us, $r_them, $e_them );

                # CASE 1 - Update an existing object
                my $c_us = Koha::City->new( { city_name => 'city4test' } )->store;
                try { $r_us = $c_us->update( { city_country => 'country4test' } ); } catch { $e_us = $_ };
                my $c_them = $schema->resultset('City')->new( { city_name => 'city4test_2' } )->update_or_insert;
                try { $r_them = $c_them->update( { city_country => 'country4test_2' } ); } catch { $e_them = $_ };
                ok(
                    ref($r_us) && ref($r_them),
                    'Successful update should return the object '
                );
                ok(
                    !defined $e_us && !defined $e_them,
                    'Successful update should not raise an exception'
                );
                is( ref($r_us), 'Koha::City', 'Successful update should return our Koha::Object based object' );

                # CASE 2 - Update an object that is not in storage
                $c_us->delete;
                $c_them->delete;
                try { $r_us   = $c_us->update( { city_country => 'another_country' } ); } catch   { $e_us   = $_ };
                try { $r_them = $c_them->update( { city_country => 'another_country' } ); } catch { $e_them = $_ };
                ok(
                    defined $e_us && defined $e_them,
                    'Update an object that is not in storage should raise an exception'
                );
                is( ref($e_us), 'Koha::Exceptions::Object::NotInStorage' );
            };

            subtest 'Koha::Objects->update' => sub {

                plan tests => 6;

                my ( $r_us, $e_us, $r_them, $e_them );

                # CASE 1 - update existing objects
                my $city_1 = $builder->build_object( { class => 'Koha::Cities' } );
                my $city_2 = $builder->build_object( { class => 'Koha::Cities' } );
                my $city_3 = $builder->build_object( { class => 'Koha::Cities' } );
                my $cities = Koha::Cities->search(
                    {
                        cityid => {
                            -in => [
                                $city_1->cityid,
                                $city_2->cityid,
                                $city_3->cityid,
                            ]
                        }
                    }
                );

                try { $r_us = $cities->update( { city_country => 'country4test' } ); } catch { $e_us = $_ };

                $city_1 = $builder->build_object( { class => 'Koha::Cities' } );
                $city_2 = $builder->build_object( { class => 'Koha::Cities' } );
                $city_3 = $builder->build_object( { class => 'Koha::Cities' } );
                $cities = $schema->resultset('City')->search(
                    {
                        cityid => {
                            -in => [
                                $city_1->cityid,
                                $city_2->cityid,
                                $city_3->cityid,
                            ]
                        }
                    }
                );

                try { $r_them = $cities->update( { city_country => 'country4test' } ); } catch { $e_them = $_ };

                ok( $r_us == 3 && $r_them == 3, '->update should return the number of updated cities' );
                ok( !defined($e_us) && !defined($e_them) );

                # CASE 2 - One of the object is not in storage
                $city_1 = $builder->build_object( { class => 'Koha::Cities' } );
                $city_2 = $builder->build_object( { class => 'Koha::Cities' } );
                $city_3 = $builder->build_object( { class => 'Koha::Cities' } );
                $cities = Koha::Cities->search(
                    {
                        cityid => {
                            -in => [
                                $city_1->cityid,
                                $city_2->cityid,
                                $city_3->cityid,
                            ]
                        }
                    }
                );

                $city_2->delete;    # We delete one of the object
                try { $r_us = $cities->update( { city_country => 'country4test' } ); } catch { $e_us = $_ };

                $city_1 = $builder->build_object( { class => 'Koha::Cities' } );
                $city_2 = $builder->build_object( { class => 'Koha::Cities' } );
                $city_3 = $builder->build_object( { class => 'Koha::Cities' } );
                $cities = $schema->resultset('City')->search(
                    {
                        cityid => {
                            -in => [
                                $city_1->cityid,
                                $city_2->cityid,
                                $city_3->cityid,
                            ]
                        }
                    }
                );

                $city_2->delete;    # We delete one of the object
                try { $r_them = $cities->update( { city_country => 'country4test' } ); } catch { $e_them = $_ };

                ok( $r_us == 2 && $r_them == 2, '->update should return the number of updated cities' );
                ok( !defined($e_us) && !defined($e_them) );

                throws_ok { Koha::Cities->update( { city_country => 'Castalia' } ); }
                'Koha::Exceptions::Object::NotInstantiated',
                    'Exception thrown if not instantiated class';

                is(
                    "$@", 'Tried to access the \'update\' method, but Koha::Cities is not instantiated',
                    'Exception stringified correctly'
                );

            };
        };

        subtest 'Overwritten Koha::Objects->store|update - Koha::Patrons' => sub {

            plan tests => 2;

            subtest 'Koha::Object->update' => sub {

                plan tests => 5;

                my ( $r_us, $e_us, $r_them, $e_them );

                # CASE 1 - Update an existing patron
                my $patron_us = $builder->build_object( { class => 'Koha::Patrons' } );
                try { $r_us = $patron_us->update( { city => 'a_city' } ); } catch { $e_us = $_ };

                my $patron_data = $builder->build_object( { class => 'Koha::Patrons' } )->delete->unblessed;
                my $patron_them = $schema->resultset('Borrower')->new($patron_data)->update_or_insert;
                try { $r_them = $patron_them->update( { city => 'a_city' } ); } catch { $e_them = $_ };
                ok(
                    ref($r_us) && ref($r_them),
                    'Successful update should return the patron object'
                );
                ok(
                    !defined $e_us && !defined $e_them,
                    'Successful update should not raise an exception'
                );
                is(
                    ref($r_us), 'Koha::Patron',
                    'Successful update should return our Koha::Object based object'
                );

                # CASE 2 - Update a patron that is not in storage
                $patron_us->delete;
                $patron_them->delete;
                try { $r_us   = $patron_us->update( { city => 'another_city' } ); } catch   { $e_us   = $_ };
                try { $r_them = $patron_them->update( { city => 'another_city' } ); } catch { $e_them = $_ };
                ok(
                    defined $e_us && defined $e_them,
                    'Update a patron that is not in storage should raise an exception'
                );
                is( ref($e_us), 'Koha::Exceptions::Object::NotInStorage' );

            };

            subtest 'Koha::Objects->Update ' => sub {

                plan tests => 6;

                my ( $r_us, $e_us, $r_them, $e_them );

                # CASE 1 - Update existing objects
                my $patron_1   = $builder->build_object( { class => 'Koha::Patrons' } );
                my $patron_2   = $builder->build_object( { class => 'Koha::Patrons' } );
                my $patron_3   = $builder->build_object( { class => 'Koha::Patrons' } );
                my $patrons_us = Koha::Patrons->search(
                    {
                        borrowernumber => {
                            -in => [
                                $patron_1->borrowernumber,
                                $patron_2->borrowernumber,
                                $patron_3->borrowernumber
                            ]
                        }
                    }
                );

                try { $r_us = $patrons_us->update( { city => 'a_city' } ); } catch { $e_us = $_ };

                $patron_1 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_2 = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_3 = $builder->build_object( { class => 'Koha::Patrons' } );
                my $patrons_them = $schema->resultset('Borrower')->search(
                    {
                        borrowernumber => {
                            -in => [
                                $patron_1->borrowernumber,
                                $patron_2->borrowernumber,
                                $patron_3->borrowernumber
                            ]
                        }
                    }
                );

                try { $r_them = $patrons_them->update( { city => 'a_city' } ); } catch { $e_them = $_ };

                ok( $r_us == 3 && $r_them == 3, '->update should return the number of update patrons' );
                ok(
                    !defined($e_us) && !defined($e_them),
                    '->update should not raise exception if everything went well'
                );

                # CASE 2 - One of the patrons is not in storage
                undef $_ for $r_us, $e_us, $r_them, $e_them;
                $patron_1   = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_2   = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_3   = $builder->build_object( { class => 'Koha::Patrons' } );
                $patrons_us = Koha::Patrons->search(
                    {
                        borrowernumber => {
                            -in => [
                                $patron_1->borrowernumber,
                                $patron_2->borrowernumber,
                                $patron_3->borrowernumber
                            ]
                        }
                    }
                );

                $patron_2->delete;    # We delete one of the patron
                try { $r_us = $patrons_us->update( { city => 'another_city' } ); } catch { $e_us = $_ };

                $patron_1     = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_2     = $builder->build_object( { class => 'Koha::Patrons' } );
                $patron_3     = $builder->build_object( { class => 'Koha::Patrons' } );
                $patrons_them = $schema->resultset('Borrower')->search(
                    {
                        borrowernumber => {
                            -in => [
                                $patron_1->borrowernumber,
                                $patron_2->borrowernumber,
                                $patron_3->borrowernumber
                            ]
                        }
                    }
                );

                $patron_2->delete;    # We delete one of the patron
                try { $r_them = $patrons_them->update( { city => 'another_city' } ); } catch { $e_them = $_ };

                ok(
                    $r_us == 2 && $r_them == 2,
                    'Update patrons with one that was not in storage should update the patrons'
                );
                ok(
                    !defined($e_us) && !defined($e_them),
                    'no exception should be raised if at least one patron was not in storage'
                );

                # Testing no_triggers
                t::lib::Mocks::mock_preference( 'uppercasesurnames', 1 );
                $patrons_us = Koha::Patrons->search(
                    {
                        borrowernumber => {
                            -in => [
                                $patron_1->borrowernumber,
                                $patron_2->borrowernumber,
                                $patron_3->borrowernumber
                            ]
                        }
                    }
                );
                $patrons_us->update( { surname => 'foo' } ); # Koha::Patron->store is supposed to uppercase the surnames
                is( $patrons_us->search( { surname => 'FOO' } )->count, 2, 'Koha::Patron->store is hit' );

                $patrons_us->update( { surname => 'foo' }, { no_triggers => 1 } )
                    ;    # The surnames won't be uppercase as we won't hit Koha::Patron->store
                is( $patrons_us->search( { surname => 'foo' } )->count, 2, 'Koha::Patron->store is not hit' );

            };

        };

        $schema->storage->txn_rollback;

    };

};

subtest "attributes_from_api() tests" => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $cities_rs = Koha::Cities->new;
    my $city      = Koha::City->new;

    my $api_attributes = {
        name        => 'Cordoba',
        postal_code => 5000
    };

    is_deeply(
        $cities_rs->attributes_from_api($api_attributes),
        $city->attributes_from_api($api_attributes)
    );

    $schema->storage->txn_rollback;

};

subtest "filter_by_last_update" => sub {

    $schema->storage->txn_begin;

    my $now = dt_from_string->truncate( to => 'day' );
    my @borrowernumbers;

    # Building 6 patrons that have been created today, yesterday, ... 1 per day
    for my $i ( 0 .. 5 ) {
        push @borrowernumbers,
            $builder->build_object(
            {
                class => 'Koha::Patrons',
                value => { updated_on => $now->clone->subtract( days => $i ) }
            }
            )->borrowernumber;
    }

    my $patrons = Koha::Patrons->search( { borrowernumber => { -in => \@borrowernumbers } } );

    try {
        $patrons->filter_by_last_update( { timestamp_column_name => 'updated_on' } )->count;
    } catch {
        ok(
            $_->isa('Koha::Exceptions::MissingParameter'),
            'Should raise an exception if no parameter given'
        );
    };

    my $filtered_patrons = $patrons->filter_by_last_update( { timestamp_column_name => 'updated_on', days => 2 } );
    is( ref($filtered_patrons), 'Koha::Patrons', 'filter_by_last_update must return a Koha::Objects-based object' );

    my $count = $patrons->filter_by_last_update( { timestamp_column_name => 'updated_on', days => 2 } )->count;
    is( $count, 3, '3 patrons have been updated before the last 2 days (exclusive)' );

    $count = $patrons->filter_by_last_update( { timestamp_column_name => 'updated_on', min_days => 2 } )->count;
    is( $count, 4, '4 patrons have been updated before the last 2 days (inclusive)' );

    $count = $patrons->filter_by_last_update( { timestamp_column_name => 'updated_on', days => 1 } )->count;
    is( $count, 4, '4 patrons have been updated before yesterday (exclusive)' );

    $count = $patrons->filter_by_last_update( { timestamp_column_name => 'updated_on', min_days => 1 } )->count;
    is( $count, 5, '5 patrons have been updated before yesterday (inclusive)' );

    $count = $patrons->filter_by_last_update( { timestamp_column_name => 'updated_on', days => 0 } )->count;
    is( $count, 5, '5 patrons have been updated before today (exclusive)' );

    $count = $patrons->filter_by_last_update( { timestamp_column_name => 'updated_on', min_days => 0 } )->count;
    is( $count, 6, '6 patrons have been updated before today (inclusive)' );

    $count = $patrons->filter_by_last_update( { timestamp_column_name => 'updated_on', from => $now } )->count;
    is( $count, 1, '1 patron has been updated "from today" (inclusive)' );

    $count = $patrons->filter_by_last_update( { timestamp_column_name => 'updated_on', to => $now } )->count;
    is( $count, 6, '6 patrons have been updated "to today" (inclusive)' );

    $count = $patrons->filter_by_last_update(
        {
            timestamp_column_name => 'updated_on',
            from                  => $now->clone->subtract( days => 4 ),
            to                    => $now->clone->subtract( days => 2 )
        }
    )->count;
    is( $count, 3, '3 patrons have been updated between D-4 and D-2' );

    throws_ok {
        $count =
            $patrons->filter_by_last_update( { timestamp_column_name => 'updated_on', from => '1970-12-31' } )->count;
    }
    'Koha::Exceptions::WrongParameter', 'from parameter must be a DateTime object';
    throws_ok {
        $count =
            $patrons->filter_by_last_update( { timestamp_column_name => 'updated_on', to => '1970-12-31' } )->count;
    }
    'Koha::Exceptions::WrongParameter', 'to parameter must be a DateTime object';

    subtest 'Parameters older_than, younger_than' => sub {
        my $now = dt_from_string();
        my $rs  = Koha::Patrons->search( { borrowernumber => { -in => \@borrowernumbers } } );
        $rs->update( { updated_on => $now->clone->subtract( hours => 24 ) } );
        is(
            $rs->filter_by_last_update( { timestamp_column_name => 'updated_on', from => $now } )->count, 0,
            'All updated yesterday'
        );
        is(
            $rs->filter_by_last_update(
                {
                    timestamp_column_name => 'updated_on',
                    from                  => $now->clone->subtract( days => 1 )->truncate( to => 'day' )
                }
            )->count,
            6,
            'Yesterday, truncated from is inclusive'
        );
        is(
            $rs->filter_by_last_update(
                { timestamp_column_name => 'updated_on', from => $now->clone->subtract( minutes => 24 * 60 - 1 ), }
            )->count,
            0,
            'Yesterday + 1m, not truncated, no results'
        );
        is(
            $rs->filter_by_last_update(
                { timestamp_column_name => 'updated_on', from => $now->clone->subtract( hours => 24 ), }
            )->count,
            6,
            'Yesterday, not truncated, results'
        );
    };

    $schema->storage->txn_rollback;
};

subtest "from_api_mapping() tests" => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $cities_rs = Koha::Cities->new;
    my $city      = Koha::City->new;

    is_deeply(
        $cities_rs->from_api_mapping,
        $city->from_api_mapping
    );

    $schema->storage->txn_rollback;
};

subtest 'prefetch_whitelist() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $biblios = Koha::Biblios->new;

    my $prefetch_whitelist = $biblios->prefetch_whitelist;

    ok(
        exists $prefetch_whitelist->{orders},
        'Relationship matching method name is listed'
    );
    is(
        $prefetch_whitelist->{orders},
        'Koha::Acquisition::Order',
        'Guessed the non-standard object class correctly'
    );

    is(
        $prefetch_whitelist->{items},
        'Koha::Item',
        'Guessed the standard object class correctly'
    );

    $schema->storage->txn_rollback;
};

subtest 'empty() tests' => sub {

    plan tests => 6;

    $schema->storage->txn_begin;

    # Add a patron, we need at least 1
    my $patron = $builder->build_object( { class => 'Koha::Patrons' } );
    ok( Koha::Patrons->count > 0, 'There is at least one Koha::Patron on the resultset' );

    my $empty = Koha::Patrons->new->empty;
    is( ref($empty),   'Koha::Patrons', '->empty returns a Koha::Patrons iterator' );
    is( $empty->count, 0,               'The empty resultset is, well, empty :-D' );

    my $new_rs = $empty->search( { borrowernumber => $patron->borrowernumber } );

    is( $new_rs->count, 0, 'Further chaining an empty resultset, returns an empty resultset' );

    throws_ok { Koha::Patrons->empty; }
    'Koha::Exceptions::Object::NotInstantiated',
        'Exception thrown if not instantiated class';

    is(
        "$@", 'Tried to access the \'empty\' method, but Koha::Patrons is not instantiated',
        'Exception stringified correctly'
    );

    $schema->storage->txn_rollback;
};

subtest 'delete() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    # Make sure no cities
    warnings_are { Koha::Cities->delete }[],
        "No warnings, no Koha::City->delete called as it doesn't exist";

    # Mock Koha::City
    my $mocked_city = Test::MockModule->new('Koha::City');
    $mocked_city->mock(
        'delete',
        sub {
            shift->_result->delete;
            warn "delete called!";
        }
    );

    # Add two cities
    $builder->build_object( { class => 'Koha::Cities' } );
    $builder->build_object( { class => 'Koha::Cities' } );

    my $cities = Koha::Cities->search;
    $cities->next;
    warnings_are { $cities->delete }
    [ "delete called!", "delete called!" ],
        "No warnings, no Koha::City->delete called as it doesn't exist";

    my $item_id_1 = $builder->build_sample_item()->id;
    my $item_id_2 = $builder->build_sample_item()->id;

    # Mock Koha::City
    my $mocked_item = Test::MockModule->new('Koha::Item');
    $mocked_item->mock(
        'delete',
        sub {
            my ( $self, $params ) = @_;
            warn ref($self);
            warn $params->{skip_record_index};
        }
    );
    my $items = Koha::Items->search( { itemnumber => [ $item_id_1, $item_id_2 ] } );

    warning_is { $items->delete( { skip_record_index => 1 } ) }
    [ "Koha::Item", "1", "Koha::Item", "1" ],
        "No warnings, no Koha::City->delete called as it doesn't exist";

    $schema->storage->txn_rollback;
};
