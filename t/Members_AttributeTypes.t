#!/usr/bin/perl
#
# Tests 'fetch', 'fake db data', and 'checks for existant attributes'

use strict;
use warnings;
use Test::MockModule;
use Test::More tests => 9;

BEGIN {
    use_ok('C4::Members::AttributeTypes');
}

my $module = new Test::MockModule('C4::Context');
$module->mock(
    '_new_dbh',
    sub {
        my $dbh = DBI->connect( 'DBI:Mock:', '', '' )
          || die "Cannot create handle: $DBI::errstr\n";
        return $dbh;
    }
);
my $members_attributetypes = [
    [
        'code',             'description',
        'repeatable',       'unique_id',
        'opac_display',     'password_allowed',
        'staff_searchable', 'authorised_value_category',
        'display_checkout', 'catagory_code',
        'class'
    ],
    [ 'one', 'ISBN', '1', '1', '1', '1', '1', 'red',  '1', 'orange', 'green' ],
    [ 'two', 'ISSN', '0', '0', '0', '0', '0', 'blue', '0', 'yellow', 'silver' ]
];

my $dbh = C4::Context->dbh();

$dbh->{mock_add_resultset} = $members_attributetypes;

my @members_attributetypes = C4::Members::AttributeTypes::GetAttributeTypes(undef, 1);

is( $members_attributetypes[0]->{'code'}, 'one', 'First code value is one' );

is( $members_attributetypes[1]->{'code'}, 'two', 'Second code value is two' );

is( $members_attributetypes[0]->{'class'},
    'green', 'First class value is green' );

is( $members_attributetypes[1]->{'class'},
    'silver', 'Second class value is silver' );

$dbh->{mock_add_resultset} = $members_attributetypes;

ok( C4::Members::AttributeTypes::AttributeTypeExists('one'),
    'checking an attribute type exists' );

ok(
    !C4::Members::AttributeTypes::AttributeTypeExists('three'),
    "checking a attribute that isn't in the code doesn't exist"
);

$dbh->{mock_add_resultset} = $members_attributetypes;

ok( C4::Members::AttributeTypes->fetch('ISBN'), "testing fetch feature" );

ok( !C4::Members::AttributeTypes->fetch('FAKE'),
    "testing fetch feature doesn't work if value not in database" );
