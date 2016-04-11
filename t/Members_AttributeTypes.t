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

use Test::MockModule;
use Test::More;

use Module::Load::Conditional qw/check_install/;

BEGIN {
    if ( check_install( module => 'Test::DBIx::Class' ) ) {
        plan tests => 10;
    } else {
        plan skip_all => "Need Test::DBIx::Class"
    }
}

use_ok('C4::Members::AttributeTypes');

use Test::DBIx::Class {
    schema_class => 'Koha::Schema',
    connect_info => ['dbi:SQLite:dbname=:memory:','',''],
    connect_opts => { name_sep => '.', quote_char => '`', },
    fixture_class => '::Populate',
}, 'BorrowerAttributeType', 'Category' ;

fixtures_ok [
    Category => [
        ['categorycode'],
        ['orange'], ['yellow'],
    ],
    BorrowerAttributeType => [
    [
        'code',             'description',
        'repeatable',       'unique_id',
        'opac_display',
        'staff_searchable', 'authorised_value_category',
        'display_checkout', 'category_code',
        'class'
    ],
    [ 'one', 'ISBN', '1', '1', '1', '1', 'red',  '1', 'orange', 'green' ],
    [ 'two', 'ISSN', '0', '0', '0', '0', 'blue', '0', 'yellow', 'silver' ]

    ],
], 'add fixtures';

my $db = Test::MockModule->new('Koha::Database');
$db->mock( _new_schema => sub { return Schema(); } );

my @members_attributetypes = C4::Members::AttributeTypes::GetAttributeTypes(undef, 1);

is( $members_attributetypes[0]->{'code'}, 'one', 'First code value is one' );

is( $members_attributetypes[1]->{'code'}, 'two', 'Second code value is two' );

is( $members_attributetypes[0]->{'class'},
    'green', 'First class value is green' );

is( $members_attributetypes[1]->{'class'},
    'silver', 'Second class value is silver' );

ok( C4::Members::AttributeTypes::AttributeTypeExists('one'),
    'checking an attribute type exists' );

ok(
    !C4::Members::AttributeTypes::AttributeTypeExists('three'),
    "checking a attribute that isn't in the code doesn't exist"
);

ok( C4::Members::AttributeTypes->fetch('one'), "testing fetch feature" );

ok( !C4::Members::AttributeTypes->fetch('FAKE'),
    "testing fetch feature doesn't work if value not in database" );
