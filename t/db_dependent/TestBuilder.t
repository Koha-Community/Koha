#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2014 - Biblibre SARL
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

use utf8;

use Test::More tests => 16;
use Test::Warn;
use Try::Tiny;
use File::Basename qw(dirname);

use Koha::Database;
use Koha::Patrons;

BEGIN {
    use_ok('t::lib::TestBuilder');
}

our $schema = Koha::Database->new->schema;
our $builder;

subtest 'Start with some trivial tests' => sub {
    plan tests => 7;

    $schema->storage->txn_begin;

    $builder = t::lib::TestBuilder->new;
    isnt( $builder, undef, 'We got a builder' );

    my $data;
    warning_like { $data = $builder->build; } qr/.+/, 'Catch a warning';
    is( $data, undef, 'build without arguments returns undef' );
    is( ref( $builder->schema ), 'Koha::Schema', 'check schema' );
    is( ref( $builder->can('delete') ), 'CODE', 'found delete method' );

    # invalid argument
    warning_like { $builder->build({
            source => 'Borrower',
            value  => { surname => { invalid_hash => 1 } },
        }) } qr/^Hash not allowed for surname/,
        'Build should not accept a hash for this column';

    # return undef if a record exists
    my $branchcode = $builder->build({ source => 'Branch' })->{branchcode};
    my $param = { source => 'Branch', value => { branchcode => $branchcode } };
    warning_like { $builder->build( $param ) }
        qr/Violation of unique constraint/,
        'Catch warn on adding existing record';

    $schema->storage->txn_rollback;
};


subtest 'Build all sources' => sub {
    plan tests => 1;

    $schema->storage->txn_begin;

    my @sources = $builder->schema->sources;
    my @source_in_failure;
    for my $source ( @sources ) {
        my $res;
        # Skip the source if it is a view
        next if $schema->source($source)->isa('DBIx::Class::ResultSource::View');
        eval { $res = $builder->build( { source => $source } ); };
        push @source_in_failure, $source if $@ || !defined( $res );
    }
    is( @source_in_failure, 0,
        'TestBuilder should be able to create an object for every source' );
    if ( @source_in_failure ) {
        diag( "The following sources have not been generated correctly: " .
        join ', ', @source_in_failure );
    }

    $schema->storage->txn_rollback;
};


subtest 'Test length of some generated fields' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    # Test the length of a returned character field
    my $bookseller = $builder->build({ source  => 'Aqbookseller' });
    my $max = $schema->source('Aqbookseller')->column_info('phone')->{size};
    is( length( $bookseller->{phone} ) > 0, 1,
        'The length for a generated string (phone) should not be zero' );
    is( length( $bookseller->{phone} ) <= $max, 1,
        'Check maximum length for a generated string (phone)' );

    my $item = $builder->build({ source => 'Item' });
    is( $item->{replacementprice}, sprintf("%.2f", $item->{replacementprice}), "The number of decimals for floats should not be more than 2" );

    $schema->storage->txn_rollback;
};


subtest 'Test FKs in overduerules_transport_type' => sub {
    plan tests => 5;

    $schema->storage->txn_begin;

    my $my_overduerules_transport_type = {
        message_transport_type => {
            message_transport_type => 'my msg_t_t',
        },
        overduerules_id => {
            branchcode   => 'codeB',
            categorycode => 'codeC',
        },
    };

    my $overduerules_transport_type = $builder->build({
        source => 'OverduerulesTransportType',
        value  => $my_overduerules_transport_type,
    });
    is(
        $overduerules_transport_type->{message_transport_type},
        $my_overduerules_transport_type->{message_transport_type}->{message_transport_type},
        'build stores the message_transport_type correctly'
    );
    is(
        $schema->resultset('Overduerule')->find( $overduerules_transport_type->{overduerules_id} )->branchcode,
        $my_overduerules_transport_type->{overduerules_id}->{branchcode},
        'build stores the branchcode correctly'
    );
    is(
        $schema->resultset('Overduerule')->find( $overduerules_transport_type->{overduerules_id} )->categorycode,
        $my_overduerules_transport_type->{overduerules_id}->{categorycode},
        'build stores the categorycode correctly'
    );
    is(
        $schema->resultset('MessageTransportType')->find( $overduerules_transport_type->{message_transport_type} )->message_transport_type,
        $overduerules_transport_type->{message_transport_type},
        'build stores the foreign key message_transport_type correctly'
    );
    isnt(
        $schema->resultset('Overduerule')->find( $my_overduerules_transport_type->{overduerules_id} )->letter2,
        undef,
        'build generates values if they are not given'
    );

    $schema->storage->txn_rollback;
};


subtest 'Tests with composite FK in userpermission' => sub {
    plan tests => 9;

    $schema->storage->txn_begin;

    my $my_user_permission = default_userpermission();
    my $user_permission = $builder->build({
        source => 'UserPermission',
        value  => $my_user_permission,
    });

    # Checks on top level of userpermission
    isnt(
        $user_permission->{borrowernumber},
        undef,
        'build generates a borrowernumber correctly'
    );
    is(
        $user_permission->{code},
        $my_user_permission->{code}->{code},
        'build stores code correctly'
    );

    # Checks one level deeper userpermission -> borrower
    my $patron = $schema->resultset('Borrower')->find({ borrowernumber => $user_permission->{borrowernumber} });
    is(
        $patron->surname,
        $my_user_permission->{borrowernumber}->{surname},
        'build stores surname correctly'
    );
    isnt(
        $patron->cardnumber,
        undef,
        'build generated cardnumber'
    );

    # Checks two levels deeper userpermission -> borrower -> branch
    my $branch = $schema->resultset('Branch')->find({ branchcode => $patron->branchcode->branchcode });
    is(
        $branch->branchname,
        $my_user_permission->{borrowernumber}->{branchcode}->{branchname},
        'build stores branchname correctly'
    );
    isnt(
        $branch->branchaddress1,
        undef,
        'build generated branch address'
    );

    # Checks with composite FK: userpermission -> permission
    my $perm = $schema->resultset('Permission')->find({ module_bit => $user_permission->{module_bit}, code => $my_user_permission->{code}->{code} });
    isnt( $perm, undef, 'build generated record for composite FK' );
    is(
        $perm->code,
        $my_user_permission->{code}->{code},
        'build stored code correctly'
    );
    is(
        $perm->description,
        $my_user_permission->{code}->{description},
        'build stored description correctly'
    );

    $schema->storage->txn_rollback;
};

sub default_userpermission {
    return {
        borrowernumber => {
            surname => 'my surname',
            address => 'my adress',
            city    => 'my city',
            branchcode => {
                branchname => 'my branchname',
            },
            categorycode => {
                hidelostitems   => 0,
                category_type   => 'A',
                default_privacy => 'default',
            },
            privacy => 1,
        },
        module_bit => {
            module_bit => {
                flag        => 'my flag',
            },
        },
        code => {
            code        => 'my code',
            description => 'my desc',
        },
    };
}


subtest 'Test build with NULL values' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    # PK should not be null
    my $params = { source => 'Branch', value => { branchcode => undef }};
    warning_like { $builder->build( $params ) }
        qr/Null value for branchcode/,
        'Catch warn on adding branch with a null branchcode';
    # Nullable column
    my $info = $schema->source( 'Item' )->column_info( 'barcode' );
    $params = { source => 'Item', value  => { barcode => undef }};
    my $item = $builder->build( $params );
    is( $info->{is_nullable} && $item && !defined( $item->{barcode} ), 1,
        'Barcode can be NULL' );
    # Nullable FK
    $params = { source => 'Reserve', value  => { itemnumber => undef }};
    my $reserve = $builder->build( $params );
    $info = $schema->source( 'Reserve' )->column_info( 'itemnumber' );
    is( $reserve && $info->{is_nullable} && $info->{is_foreign_key} &&
        !defined( $reserve->{itemnumber} ), 1, 'Nullable FK' );

    $schema->storage->txn_rollback;
};


subtest 'Tests for delete method' => sub {
    plan tests => 11;

    $schema->storage->txn_begin;

    # Test delete with single and multiple records
    my $basket1 = $builder->build({ source => 'Aqbasket' });
    my $basket2 = $builder->build({ source => 'Aqbasket' });
    my $basket3 = $builder->build({ source => 'Aqbasket' });
    my ( $id1, $id2 ) = ( $basket1->{basketno}, $basket2->{basketno} );
    $builder->delete({ source => 'Aqbasket', records => $basket1 });
    isnt( exists $basket1->{basketno}, 1, 'Delete cleared PK hash value' );

    is( $builder->schema->resultset('Aqbasket')->search({ basketno => $id1 })->count, 0, 'Basket1 is no longer found' );
    is( $builder->schema->resultset('Aqbasket')->search({ basketno => $id2 })->count, 1, 'Basket2 is still found' );
    is( $builder->delete({ source => 'Aqbasket', records => [ $basket2, $basket3 ] }), 2, "Returned two delete attempts" );
    is( $builder->schema->resultset('Aqbasket')->search({ basketno => $id2 })->count, 0, 'Basket2 is no longer found' );


    # Test delete in table without primary key (..)
    is( $schema->source('AccountCreditTypesBranch')->primary_columns, 0,
        'Table without primary key detected' );
    my $cnt1 = $schema->resultset('AccountCreditTypesBranch')->count;
    # Insert a new record in AccountCreditTypesBranch with that biblionumber
    my $rec = $builder->build({ source => 'AccountCreditTypesBranch' });
    my $cnt2 = $schema->resultset('AccountCreditTypesBranch')->count;
    is( defined($rec) && $cnt2 == $cnt1 + 1 , 1, 'Created a record' );
    is( $builder->delete({ source => 'AccountCreditTypesBranch', records => $rec }),
        undef, 'delete returns undef' );
    is( $schema->resultset('AccountCreditTypesBranch')->count, $cnt2,
        "Method did not delete record in table without PK" );

    # Test delete with NULL values
    my $val = { branchcode => undef };
    is( $builder->delete({ source => 'Branch', records => $val }), 0,
        'delete returns zero for an undef search with one key' );
    $val = { module_bit => 1, #catalogue
             code       => undef };
    is( $builder->delete({ source => 'Permission', records => $val }), 0,
        'delete returns zero for an undef search with a composite PK' );

    $schema->storage->txn_rollback;
};

subtest 'Auto-increment values tests' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    # Pick a table with AI PK
    my $source  = 'Biblio'; # table
    my $column  = 'biblionumber'; # ai column

    my $col_info = $schema->source( $source )->column_info( $column );
    is( $col_info->{is_auto_increment}, 1, "biblio.biblionumber is detected as autoincrement");

    # Create a biblio
    my $biblio_1 = $builder->build({ source => $source });
    # Get the AI value
    my $ai_value = $biblio_1->{ biblionumber };
    # Create a biblio
    my $biblio_2 = $builder->build({ source => $source });
    # Get the next AI value
    my $next_ai_value = $biblio_2->{ biblionumber };
    is( $ai_value + 1, $next_ai_value, "AI values are consecutive");

    # respect autoincr column
    warning_like { $builder->build({
            source => $source,
            value  => { biblionumber => 123 },
        }) } qr/^Value not allowed for auto_incr/,
        'Build should not overwrite an auto_incr column';

    $schema->storage->txn_rollback;
};

subtest 'Date handling' => sub {
    plan tests => 2;

    $schema->storage->txn_begin;

    $builder = t::lib::TestBuilder->new;

    my $patron = $builder->build( { source => 'Borrower' } );
    is( length( $patron->{updated_on} ),  19, 'A timestamp column value should be YYYY-MM-DD HH:MM:SS' );
    is( length( $patron->{dateofbirth} ), 10, 'A date column value should be YYYY-MM-DD' );

    $schema->storage->txn_rollback;
};

subtest 'Default values' => sub {
    plan tests => 3;

    $schema->storage->txn_begin;

    $builder = t::lib::TestBuilder->new;
    my $item = $builder->build( { source => 'Item' } );
    is( $item->{more_subfields_xml}, undef, 'This xml field should be undef' );
    $item = $builder->build( { source => 'Item', value => { more_subfields_xml => 'some xml' } } );
    is( $item->{more_subfields_xml}, 'some xml', 'Default should not overwrite assigned value' );

    subtest 'generated dynamically (coderef)' => sub {
        plan tests => 2;
        my $patron = $builder->build_object({ class => 'Koha::Patrons' });
        like( $patron->category->category_type, qr{^(A|C|S|I|P|)$}, );

        my $patron_category_X = $builder->build_object({ class => 'Koha::Patron::Categories', value => { category_type => 'X' } });
        $patron = $builder->build_object({ class => 'Koha::Patrons', value => {categorycode => $patron_category_X->categorycode} });
        is( $patron->category->category_type, 'X', );
    };

    $schema->storage->txn_rollback;
};

subtest 'build_object() tests' => sub {

    plan tests => 5;

    $schema->storage->txn_begin;

    $builder = t::lib::TestBuilder->new();

    my $branchcode = $builder->build( { source => 'Branch' } )->{branchcode};
    my $categorycode = $builder->build( { source => 'Category' } )->{categorycode};
    my $itemtype = $builder->build( { source => 'Itemtype' } )->{itemtype};

    my $issuing_rule = $builder->build_object(
        {   class => 'Koha::CirculationRules',
            value => {
                branchcode   => $branchcode,
                categorycode => $categorycode,
                itemtype     => $itemtype
            }
        }
    );

    is( ref($issuing_rule), 'Koha::CirculationRule', 'Type is correct' );
    is( $issuing_rule->categorycode,
        $categorycode, 'Category code correctly set' );
    is( $issuing_rule->itemtype, $itemtype, 'Item type correctly set' );

    subtest 'Test all classes' => sub {
        my $Koha_modules_dir = dirname(__FILE__) . '/../../Koha';
        my @koha_object_based_modules = `/bin/grep -rl -e '^sub object_class' $Koha_modules_dir`;
        my @source_in_failure;
        for my $module_filepath ( @koha_object_based_modules ) {
            chomp $module_filepath;
            next unless $module_filepath =~ m|\.pm$|;
            my $module = $module_filepath;
            $module =~ s|^.*/(Koha.*)\.pm$|$1|;
            $module =~ s|/|::|g;
            next if $module eq 'Koha::Objects';
            eval "require $module";
            my $object = $builder->build_object( { class => $module } );
            is( ref($object), $module->object_class, "Testing $module" );
            if ( ! grep {$module eq $_ } qw( Koha::Old::Patrons Koha::Statistics ) ) { # FIXME deletedborrowers and statistics do not have a PK
                eval {$object->get_from_storage};
                is( $@, '', "Module $module should have koha_object[s]_class method if needed" );
            }

            # Testing koha_object_class and koha_objects_class
            my $object_class =  Koha::Object::_get_object_class($object->_result->result_class);
            eval "require $object_class";
            is( $@, '', "Module $object_class should be defined");
            my $objects_class = Koha::Objects::_get_objects_class($object->_result->result_class);
            eval "require $objects_class";
            is( $@, '', "Module $objects_class should be defined");
        }
    };

    subtest 'test parameters' => sub {
        plan tests => 3;

        warning_is { $issuing_rule = $builder->build_object( {} ); }
        { carped => 'Missing class param' },
            'The class parameter is mandatory, raises a warning if absent';
        is( $issuing_rule, undef,
            'If the class parameter is missing, undef is returned' );

        warnings_like {
            $builder->build_object(
                { class => 'Koha::Patrons', categorycode => 'foobar' } );
        } qr{Unknown parameter\(s\): categorycode}, "Unknown parameter detected";
    };

    $schema->storage->txn_rollback;
};

subtest '->build parameter' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    # Test to make sure build() warns user of unknown parameters.
    warnings_are {
        $builder->build({
            source => 'Branch',
            value => {
                branchcode => 'BRANCH_1'
            }
        })
    } [], "No warnings on correct use";

    warnings_like {
        $builder->build({
            source     => 'Branch',
            branchcode => 'BRANCH_2' # This is wrong!
        })
    } qr/unknown param/i, "Carp unknown parameters";

    warnings_like {
        $builder->build({
            zource     => 'Branch', # Intentional spelling error
        })
    } qr/Source parameter not specified/, "Catch warning on missing source";

    warnings_like {
        $builder->build(
            { source => 'Borrower', categorycode => 'foobar' } );
    } qr{Unknown parameter\(s\): categorycode}, "Unkown parameter detected";

    $schema->storage->txn_rollback;
};

subtest 'build_sample_biblio() tests' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    warnings_are
        { $builder->build_sample_biblio({ title => 'hell❤️' }); }
        [],
        "No encoding warnings!";

    $schema->storage->txn_rollback;
};

subtest 'Existence of object is only checked using primary keys' => sub {

    plan tests => 1;

    $schema->storage->txn_begin;

    my $biblio = $builder->build_sample_biblio();
    my $item1 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    my $item2 = $builder->build_sample_item({ biblionumber => $biblio->biblionumber });
    warnings_are {
      $builder->build_object({
        class => 'Koha::Holds',
        value  => {
            biblionumber => $biblio->biblionumber
        }
      });
    } [], "No warning about query returning more than one row";

    $schema->storage->txn_rollback;
};

subtest 'Test bad columns' => sub {
    plan tests => 3;
    $schema->storage->txn_begin;

    try {
        my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { wrong => 1 } });
        ok( 0, 'Unexpected pass with wrong column' );
    }
    catch {
        like( $_, qr/^Error: value hash contains unrecognized columns: wrong/, 'Column wrong is bad' );
    };
    try {
        my $patron = $builder->build_object({ class => 'Koha::Patrons', value => { surname => 'Pass', nested => { ignored => 1 }} });
        ok( 1, 'Nested hash ignored' );
    }
    catch {
        ok( 0, 'Unexpected trouble with nested hash' );
    };
    try {
        my $patron = $builder->build_object({
            class => 'Koha::Patrons',
             value => { surname => 'WontPass', categorycode => { description => 'bla', wrong_nested => 1 }},
        });
        ok( 0, 'Unexpected pass with wrong nested column' );
    }
    catch {
        like( $_, qr/^Error: value hash contains unrecognized columns: wrong_nested/, 'Column wrong_nested is bad' );
    };

    $schema->storage->txn_rollback;
};
