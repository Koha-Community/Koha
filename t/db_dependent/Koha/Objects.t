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

use Test::More tests => 20;
use Test::Exception;
use Test::Warn;

use Koha::Authority::Types;
use Koha::Cities;
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
    plan tests => 6;
    my $patron = $builder->build({source => 'Borrower'});
    my $patron_object = Koha::Patrons->find( $patron->{borrowernumber} );
    is( $patron_object->borrowernumber, $patron->{borrowernumber}, '->find should return the correct object' );

    my @patrons = Koha::Patrons->find( $patron->{borrowernumber} );
    is(scalar @patrons, 1, '->find in list context returns a value');
    is($patrons[0]->borrowernumber, $patron->{borrowernumber}, '->find in list context returns the same value as in scalar context');

    my $patrons = {
        foo => Koha::Patrons->find('foo'),
        bar => 'baz',
    };
    is ($patrons->{foo}, undef, '->find in list context returns undef when no record is found');

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
    plan tests => 4;

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

subtest '->search() tests' => sub {

    plan tests => 12;

    $schema->storage->txn_begin;

    my $count = Koha::Patrons->search->count;

    # Create 10 patrons
    foreach (1..10) {
        $builder->build_object({ class => 'Koha::Patrons' });
    }

    my $patrons = Koha::Patrons->search();
    is( ref($patrons), 'Koha::Patrons', 'search in scalar context returns the Koha::Object-based type' );
    my @patrons = Koha::Patrons->search();
    is( scalar @patrons, $count + 10, 'search in list context returns a list of objects' );
    my $i = 0;
    foreach (1..10) {
        is( ref($patrons[$i]), 'Koha::Patron', 'Objects in the list have the singular type' );
        $i++;
    }

    $schema->storage->txn_rollback;
};

subtest "to_api() tests" => sub {

    plan tests => 18;

    $schema->storage->txn_begin;

    my $city_1 = $builder->build_object( { class => 'Koha::Cities' } );
    my $city_2 = $builder->build_object( { class => 'Koha::Cities' } );

    my $cities = Koha::Cities->search(
        {
            cityid => [ $city_1->cityid, $city_2->cityid ]
        },
        { -orderby => { -desc => 'cityid' } }
    );

    is( $cities->count, 2, 'Count is correct' );
    my $cities_api = $cities->to_api;
    is( ref( $cities_api ), 'ARRAY', 'to_api returns an array' );
    is_deeply( $cities_api->[0], $city_1->to_api, 'to_api returns the individual objects with ->to_api' );
    is_deeply( $cities_api->[1], $city_2->to_api, 'to_api returns the individual objects with ->to_api' );

    my $biblio_1 = $builder->build_sample_biblio();
    my $item_1   = $builder->build_sample_item({ biblionumber => $biblio_1->biblionumber });
    my $hold_1   = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { itemnumber => $item_1->itemnumber }
        }
    );

    my $biblio_2 = $builder->build_sample_biblio();
    my $item_2   = $builder->build_sample_item({ biblionumber => $biblio_2->biblionumber });
    my $hold_2   = $builder->build_object(
        {
            class => 'Koha::Holds',
            value => { itemnumber => $item_2->itemnumber }
        }
    );

    my $embed = { 'items' => {} };

    my $i = 0;
    my @items = ( $item_1, $item_2 );
    my @holds = ( $hold_1, $hold_2 );

    my $biblios_api = Koha::Biblios->search(
        {
            biblionumber => [ $biblio_1->biblionumber, $biblio_2->biblionumber ]
        }
    )->to_api( { embed => $embed } );

    foreach my $biblio_api ( @{ $biblios_api } ) {
        ok(exists $biblio_api->{items}, 'Items where embedded in biblio results');
        is($biblio_api->{items}->[0]->{item_id}, $items[$i]->itemnumber, 'Item matches');
        ok(!exists $biblio_api->{items}->[0]->{holds}, 'No holds info should be embedded yet');

        $i++;
    }

    # One more level
    $embed = {
        'items' => {
            children => { 'holds' => {} }
        }
    };

    $i = 0;

    $biblios_api = Koha::Biblios->search(
        {
            biblionumber => [ $biblio_1->biblionumber, $biblio_2->biblionumber ]
        }
    )->to_api( { embed => $embed } );

    foreach my $biblio_api ( @{ $biblios_api } ) {

        ok(exists $biblio_api->{items}, 'Items where embedded in biblio results');
        is($biblio_api->{items}->[0]->{item_id}, $items[$i]->itemnumber, 'Item still matches');
        ok(exists $biblio_api->{items}->[0]->{holds}, 'Holds info should be embedded');
        is($biblio_api->{items}->[0]->{holds}->[0]->{hold_id}, $holds[$i]->reserve_id, 'Hold matches');

        $i++;
    }

    $schema->storage->txn_rollback;
};

subtest "TO_JSON() tests" => sub {

    plan tests => 4;

    $schema->storage->txn_begin;

    my $city_1 = $builder->build_object( { class => 'Koha::Cities' } );
    my $city_2 = $builder->build_object( { class => 'Koha::Cities' } );

    my $cities = Koha::Cities->search(
        {
            cityid => [ $city_1->cityid, $city_2->cityid ]
        },
        { -orderby => { -desc => 'cityid' } }
    );

    is( $cities->count, 2, 'Count is correct' );
    my $cities_json = $cities->TO_JSON;
    is( ref($cities_json), 'ARRAY', 'to_api returns an array' );
    is_deeply( $cities_json->[0], $city_1->TO_JSON, 'TO_JSON returns the individual objects with ->TO_JSON' );
    is_deeply( $cities_json->[1], $city_2->TO_JSON,'TO_JSON returns the individual objects with ->TO_JSON' );

    $schema->storage->txn_rollback;
};

# Koha::Object[s] must behave the same as DBIx::Class
subtest 'Return same values as DBIx::Class' => sub {
    plan tests => 1;

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
                ok( ref($r_us) && ref($r_them),
                    'Successful delete should return the object ' );
                ok( !defined $e_us && !defined $e_them,
                    'Successful delete should not raise an exception' );
                is( ref($r_us), 'Koha::City', 'Successful delete should return our Koha::Obect based object' );

                # CASE 2 - Delete an object that is not in storage
                try { $r_us   = $r_us->delete;   } catch { $e_us   = $_ };
                try { $r_them = $r_them->delete; } catch { $e_them = $_ };
                ok(
                    defined $e_us && defined $e_them,
                    'Delete an object that is not in storage should raise an exception'
                );
                is( ref($e_us), 'DBIx::Class::Exception' )
                  ; # FIXME This needs adjustement, we want to throw a Koha::Exception

            };

            subtest 'Koha::Objects->delete' => sub {

                plan tests => 4;

                my ( $r_us, $e_us, $r_them, $e_them );

                # CASE 1 - Delete existing objects
                my $city_1 = $builder->build_object({ class => 'Koha::Cities' });
                my $city_2 = $builder->build_object({ class => 'Koha::Cities' });
                my $city_3 = $builder->build_object({ class => 'Koha::Cities' });
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

                $city_1 = $builder->build_object({ class => 'Koha::Cities' });
                $city_2 = $builder->build_object({ class => 'Koha::Cities' });
                $city_3 = $builder->build_object({ class => 'Koha::Cities' });
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
                ok (!defined($e_us) && !defined($e_them));

                # CASE 2 - One of the object is not in storage
                $city_1 = $builder->build_object({ class => 'Koha::Cities' });
                $city_2 = $builder->build_object({ class => 'Koha::Cities' });
                $city_3 = $builder->build_object({ class => 'Koha::Cities' });
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

                $city_2->delete; # We delete one of the object
                try { $r_us = $cities->delete; } catch { $e_us = $_ };

                $city_1 = $builder->build_object({ class => 'Koha::Cities' });
                $city_2 = $builder->build_object({ class => 'Koha::Cities' });
                $city_3 = $builder->build_object({ class => 'Koha::Cities' });
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

                $city_2->delete; # We delete one of the object
                try { $r_them = $cities->delete; } catch { $e_them = $_ };

                ok( $r_us == 2 && $r_them == 2 );
                ok (!defined($e_us) && !defined($e_them));
            };
        };

        subtest 'Overwritten Koha::Objects->delete - Koha::Patrons' => sub {

            plan tests => 2;

            subtest 'Koha::Object->delete' => sub {

                plan tests => 7;

                my ( $r_us, $e_us, $r_them, $e_them );

                # CASE 1 - Delete an existing patron
                my $patron = $builder->build_object({ class => 'Koha::Patrons' });
                my $patron_data = $patron->unblessed;
                $patron->delete;

                $patron = Koha::Patron->new( $patron_data )->store;
                try {$r_us = $patron->delete;} catch { $e_us = $_ };
                $patron = $schema->resultset('Borrower')->new( $patron_data )->update_or_insert;
                try {$r_them = $patron->delete;} catch { $e_them = $_ };
                ok( ref($r_us) && ref($r_them),
                    'Successful delete should return the patron object' );
                ok( !defined $e_us && !defined $e_them,
                    'Successful delete should not raise an exception' );
                is( ref($r_us), 'Koha::Patron',
                    'Successful delete should return our Koha::Obect based object' );

                # CASE 2 - Delete a patron that is not in storage
                try { $r_us   = $r_us->delete;   } catch { $e_us   = $_ };
                try { $r_them = $r_them->delete; } catch { $e_them = $_ };
                ok(
                    defined $e_us && defined $e_them,
                    'Delete a patron that is not in storage should raise an exception'
                );
                is( ref($e_us), 'DBIx::Class::Exception' )
                  ; # FIXME This needs adjustement, we want to throw a Koha::Exception

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
                  ; # FIXME This needs adjustement, we want to throw a Koha::Exception
            };

            subtest 'Koha::Objects->delete' => sub {

                plan tests => 9;

                my ( $r_us, $e_us, $r_them, $e_them );

                # CASE 1 - Delete existing objects
                my $patron_1 = $builder->build_object({ class => 'Koha::Patrons' });
                my $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });
                my $patron_3 = $builder->build_object({ class => 'Koha::Patrons' });
                my $patrons = Koha::Patrons->search(
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

                $patron_1 = $builder->build_object({ class => 'Koha::Patrons' });
                $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });
                $patron_3 = $builder->build_object({ class => 'Koha::Patrons' });
                $patrons = $schema->resultset('Borrower')->search(
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
                ok (!defined($e_us) && !defined($e_them), '->delete should not raise exception if everything went well');

                # CASE 2 - One of the patrons is not in storage
                undef $_ for $r_us, $e_us, $r_them, $e_them;
                $patron_1 = $builder->build_object({ class => 'Koha::Patrons' });
                $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });
                $patron_3 = $builder->build_object({ class => 'Koha::Patrons' });
                $patrons = Koha::Patrons->search(
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

                $patron_2->delete; # We delete one of the patron
                try { $r_us = $patrons->delete; } catch { $e_us = $_ };

                $patron_1 = $builder->build_object({ class => 'Koha::Patrons' });
                $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });
                $patron_3 = $builder->build_object({ class => 'Koha::Patrons' });
                $patrons = $schema->resultset('Borrower')->search(
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

                $patron_2->delete; # We delete one of the patron
                try { $r_them = $patrons->delete; } catch { $e_them = $_ };

                ok( $r_us == 2 && $r_them == 2, 'Delete patrons with one that was not in storage should delete the patrons' );
                ok (!defined($e_us) && !defined($e_them), 'no exception should be raised if at least one patron was not in storage');

                # CASE 3 - Delete a set of patrons with one that that cannot be deleted (as a checkout)
                undef $_ for $r_us, $e_us, $r_them, $e_them;
                $patron_1 = $builder->build_object({ class => 'Koha::Patrons' });
                $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });
                $patron_3 = $builder->build_object({ class => 'Koha::Patrons' });
                $patrons = Koha::Patrons->search(
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

                warning_like {
                    try { $r_us = $patrons->delete; } catch { $e_us = $_ };
                }
                qr{DBD::mysql::st execute failed: Cannot delete or update a parent row: a foreign key constraint fails},
                  "Foreign key constraint DBI error should be logged";
                my $not_deleted_us = $patron_1->in_storage + $patron_2->in_storage + $patron_3->in_storage;

                $patron_1 = $builder->build_object({ class => 'Koha::Patrons' });
                $patron_2 = $builder->build_object({ class => 'Koha::Patrons' });
                $patron_3 = $builder->build_object({ class => 'Koha::Patrons' });
                $patrons = $schema->resultset('Borrower')->search(
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

                warning_like {
                    try { $r_them = $patrons->delete; } catch { $e_them = $_ };
                }
                qr{DBD::mysql::st execute failed: Cannot delete or update a parent row: a foreign key constraint fails},
                  "Foreign key constraint DBI error should be logged";

                my $not_deleted_them = $patron_1->in_storage + $patron_2->in_storage + $patron_3->in_storage;
                ok(
                    defined $e_us && defined $e_them,
                    'Delete patrons with one that cannot be deleted should raise an exception'
                );
                is( ref($e_us), 'DBIx::Class::Exception' )
                  ; # FIXME This needs adjustement, we want to throw a Koha::Exception

                ok($not_deleted_us == 3 && $not_deleted_them == 3, 'If one patron cannot be deleted, none should have been deleted');
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