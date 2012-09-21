#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 5;
use Test::MockModule;
use MARC::Record;

BEGIN {
        use_ok('C4::AuthoritiesMarc');
}

# We are now going to be testing the authorities hierarchy code, and
# therefore need to pretend that we have consistent data in our database
my $module = new Test::MockModule('C4::AuthoritiesMarc');
$module->mock('GetHeaderAuthority', sub {
    return {'authtrees' => ''};
});
$module->mock('AddAuthorityTrees', sub {
    return;
});
$module->mock('GetAuthority', sub {
    my ($authid) = @_;
    my $record = MARC::Record->new();
    if ($authid eq '1') {
        $record->add_fields(
            [ '001', '1' ],
            [ '151', ' ', ' ', a => 'United States' ]
            );
    } elsif ($authid eq '2') {
        $record->add_fields(
            [ '001', '2' ],
            [ '151', ' ', ' ', a => 'New York (State)' ],
            [ '551', ' ', ' ', a => 'United States', w => 'g', 9 => '1' ]
            );
    } elsif ($authid eq '3') {
        $record->add_fields(
            [ '001', '3' ],
            [ '151', ' ', ' ', a => 'New York (City)' ],
            [ '551', ' ', ' ', a => 'New York (State)', w => 'g', 9 => '2' ]
            );
    } elsif ($authid eq '4') {
        $record->add_fields(
            [ '001', '4' ],
            [ '151', ' ', ' ', a => 'New York (City)' ],
            [ '551', ' ', ' ', a => 'New York (State)', w => 'g' ]
            );
    } else {
        undef $record;
    }
    return $record;
});

is(BuildAuthHierarchies(3, 1), '1,2,3', "Built linked authtrees hierarchy string");

my $expectedhierarchy = [ [ {
        'authid' => '1',
        'value' => 'United States',
        'class' => 'child0',
        'children' => [ {
            'authid' => '2',
            'value' => 'New York (State)',
            'class' => 'child1',
            'children' => [ {
                'authid' => '3',
                'current_value' => 1,
                'value' => 'New York (City)',
                'class' => 'child2',
                'children' => [],
                'parents' => [ {
                    'authid' => '2',
                    'value' => 'New York (State)'
                } ]
            } ],
            'parents' => [ {
                'authid' => '1',
                'value' => 'United States'
            } ]
        } ],
        'parents' => []
} ] ];

is_deeply(GenerateHierarchy(3), $expectedhierarchy, "Generated hierarchy data structure for linked hierarchy");

is(BuildAuthHierarchies(4, 1), '4', "Built unlinked authtrees hierarchy string");
$expectedhierarchy = [ [ {
    'authid' => '4',
    'current_value' => 1,
    'value' => 'New York (City)',
    'class' => 'child0',
    'children' => [],
    'parents' => []
} ] ];
is_deeply(GenerateHierarchy(4), $expectedhierarchy, "Generated hierarchy data structure for unlinked hierarchy");
