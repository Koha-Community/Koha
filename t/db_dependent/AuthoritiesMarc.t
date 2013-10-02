#!/usr/bin/perl
#
# This Koha test module is a stub!  
# Add more tests here!!!

use strict;
use warnings;

use Test::More tests => 8;
use Test::MockModule;
use Test::Warn;
use MARC::Record;
use t::lib::Mocks;

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

my $dbh = C4::Context->dbh;
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

t::lib::Mocks::mock_preference('marcflavour', 'MARC21');

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

# set up auth_types for next tests
$dbh->do('DELETE FROM auth_types');
$dbh->do(q{
    INSERT INTO auth_types (authtypecode, authtypetext, auth_tag_to_report, summary)
    VALUES ('GEOGR_NAME', 'Geographic Name', '151', 'Geographic Name')
});

t::lib::Mocks::mock_preference('marcflavour', 'MARC21');
my $expected_marc21_summary = {
    'authorized' => [
                      {
                        'field' => '151',
                        'heading' => 'New York (State)',
                        'hemain' => 'New York (State)'
                      }
                    ],
    'authtypecode' => 'GEOGR_NAME',
    'mainentry' => 'New York (State)',
    'mainmainentry' => 'New York (State)',
    'notes' => [],
    'otherscript' => [],
    'seealso' => [
                   {
                     'authid' => '1',
                     'field' => '551',
                     'heading' => 'United States',
                     'hemain' => 'United States',
                     'search' => 'United States',
                     'type' => 'broader'
                   }
                 ],
    'seefrom' => [],
    'label' => 'Geographic Name',
    'type' => 'Geographic Name'
};
is_deeply(
    BuildSummary(C4::AuthoritiesMarc::GetAuthority(2), 2, 'GEOGR_NAME'),
    $expected_marc21_summary,
    'test BuildSummary for MARC21'
);

my $marc21_subdiv = MARC::Record->new();
$marc21_subdiv->add_fields(
    [ '181', ' ', ' ', x => 'Political aspects' ]
);
warning_is { BuildSummary($marc21_subdiv, 99999, 'GEN_SUBDIV') } [],
    'BuildSummary does not generate warning if main heading subfield not present';

t::lib::Mocks::mock_preference('marcflavour', 'UNIMARC');
$dbh->do(q{
    INSERT INTO auth_types (authtypecode, authtypetext, auth_tag_to_report, summary)
    VALUES ('NP', 'Auteur', '200', '[200a][, 200b][ 200d][ ; 200c][ (200f)]')
});

my $unimarc_name_auth = MARC::Record->new();
$unimarc_name_auth->add_fields(
    ['100', ' ', ' ',  a => '20121025              frey50       '],
    ['200', ' ', ' ',  a => 'Fossey', b => 'Brigitte' ],
    ['152', ' ', ' ',  a => 'NP'],
);
my $expected_unimarc_name_summary = {
    'authorized' => [
                      {
                        'field' => '200',
                        'heading' => 'Fossey Brigitte',
                        'hemain' => 'Fossey'
                      }
                    ],
    'authtypecode' => 'NP',
    'mainentry' => 'Fossey Brigitte',
    'mainmainentry' => 'Fossey',
    'notes' => [],
    'otherscript' => [],
    'seealso' => [],
    'seefrom' => [],
    'summary' => 'Fossey, Brigitte',
    'type' => 'Auteur'
};

is_deeply(
    BuildSummary($unimarc_name_auth, 99999, 'NP'),
    $expected_unimarc_name_summary,
    'test BuildSummary for UNIMARC'
);

$dbh->rollback;
