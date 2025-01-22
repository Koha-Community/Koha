#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 14;
use Test::MockModule;
use Test::Warn;
use MARC::Field;
use MARC::Record;

use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::Database;
use Koha::Authority::Types;

BEGIN {
    use_ok(
        'C4::AuthoritiesMarc',
        qw( GetHeaderAuthority AddAuthority AddAuthorityTrees GetAuthority BuildAuthHierarchies GenerateHierarchy BuildSummary DelAuthority CompareFieldWithAuthority ModAuthority merge )
    );
}

# We are now going to be testing the authorities hierarchy code, and
# therefore need to pretend that we have consistent data in our database
my $module = Test::MockModule->new('C4::AuthoritiesMarc');
$module->mock(
    'GetHeaderAuthority',
    sub {
        return { 'authtrees' => '' };
    }
);
$module->mock(
    'AddAuthorityTrees',
    sub {
        return;
    }
);
$module->mock(
    'GetAuthority',
    sub {
        my ($authid) = @_;
        my $record = MARC::Record->new();
        if ( $authid eq '1' ) {
            $record->add_fields(
                [ '001', '1' ],
                [ '151', ' ', ' ', a => 'United States' ]
            );
        } elsif ( $authid eq '2' ) {
            $record->add_fields(
                [ '001', '2' ],
                [ '151', ' ', ' ', a => 'New York (State)' ],
                [ '551', ' ', ' ', a => 'United States', w => 'g',                   9 => '1' ],
                [ '751', ' ', ' ', a => 'United States', w => 'g',                   9 => '1' ],
                [ '781', ' ', ' ', a => 'New York',      x => 'General subdivision', 9 => '1' ]
            );
        } elsif ( $authid eq '3' ) {
            $record->add_fields(
                [ '001', '3' ],
                [ '151', ' ', ' ', a => 'New York (City)' ],
                [ '551', ' ', ' ', a => 'New York (State)', w => 'g', 9 => '2' ]
            );
        } elsif ( $authid eq '4' ) {
            $record->add_fields(
                [ '001', '4' ],
                [ '151', ' ', ' ', a => 'New York (City)' ],
                [ '551', ' ', ' ', a => 'New York (State)', w => 'g' ]
            );
        } elsif ( $authid eq '5' ) {
            $record->add_fields(
                [ '001', '5' ],
                [ '100', ' ', ' ', a => 'Lastname, Firstname', b => 'b', c => 'c', i => 'i' ]
            );
        } else {
            undef $record;
        }
        return $record;
    }
);

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh     = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );

# Authority type GEOGR_NAME is hardcoded here
if ( !Koha::Authority::Types->find('GEOGR_NAME') ) {
    $builder->build( { source => 'AuthType', value => { authtypecode => 'GEOGR_NAME' } } );
}

is( BuildAuthHierarchies( 3, 1 ), '1,2,3', "Built linked authtrees hierarchy string" );

my $expectedhierarchy = [
    [
        {
            'authid'   => '1',
            'value'    => 'United States',
            'class'    => 'child0',
            'children' => [
                {
                    'authid'   => '2',
                    'value'    => 'New York (State)',
                    'class'    => 'child1',
                    'children' => [
                        {
                            'authid'        => '3',
                            'current_value' => 1,
                            'value'         => 'New York (City)',
                            'class'         => 'child2',
                            'children'      => [],
                            'parents'       => [
                                {
                                    'authid' => '2',
                                    'value'  => 'New York (State)'
                                }
                            ]
                        }
                    ],
                    'parents' => [
                        {
                            'authid' => '1',
                            'value'  => 'United States'
                        }
                    ]
                }
            ],
            'parents' => []
        }
    ]
];

is_deeply( GenerateHierarchy(3), $expectedhierarchy, "Generated hierarchy data structure for linked hierarchy" );

is( BuildAuthHierarchies( 4, 1 ), '4', "Built unlinked authtrees hierarchy string" );
$expectedhierarchy = [
    [
        {
            'authid'        => '4',
            'current_value' => 1,
            'value'         => 'New York (City)',
            'class'         => 'child0',
            'children'      => [],
            'parents'       => []
        }
    ]
];
is_deeply( GenerateHierarchy(4), $expectedhierarchy, "Generated hierarchy data structure for unlinked hierarchy" );

# set up auth_types for next tests
$dbh->do('DELETE FROM auth_types');
$dbh->do(
    q{
    INSERT INTO auth_types (authtypecode, authtypetext, auth_tag_to_report, summary)
    VALUES ('GEOGR_NAME', 'Geographic Name', '151', 'Geographic Name')
}
);

t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );
my $expected_marc21_summary = {
    'authorized' => [
        {
            'field'   => '151',
            'heading' => 'New York (State)',
            'hemain'  => 'New York (State)'
        }
    ],
    'authtypecode'  => 'GEOGR_NAME',
    'mainentry'     => 'New York (State)',
    'mainmainentry' => 'New York (State)',
    'notes'         => [],
    'otherscript'   => [],
    'seealso'       => [
        {
            'authid'  => '1',
            'field'   => '551',
            'heading' => 'United States',
            'hemain'  => 'United States',
            'search'  => 'United States',
            'type'    => 'broader'
        }
    ],
    'equalterm' => [
        {
            'field'   => '751',
            'hemain'  => 'United States',
            'heading' => 'United States'
        },
        {
            'hemain'  => undef,
            'field'   => '781',
            'heading' => 'General subdivision'
        }
    ],
    'seefrom' => [],
    'label'   => 'Geographic Name',
    'type'    => 'Geographic Name',
};

is_deeply(
    BuildSummary( C4::AuthoritiesMarc::GetAuthority(2), 2, 'GEOGR_NAME' ),
    $expected_marc21_summary,
    'test BuildSummary for MARC21'
);

my $marc21_subdiv = MARC::Record->new();
$marc21_subdiv->add_fields( [ '181', ' ', ' ', x => 'Political aspects' ] );
warning_is { BuildSummary( $marc21_subdiv, 99999, 'GEN_SUBDIV' ) } [],
    'BuildSummary does not generate warning if main heading subfield not present';

t::lib::Mocks::mock_preference( 'marcflavour', 'UNIMARC' );
$dbh->do(
    q{
    INSERT INTO auth_types (authtypecode, authtypetext, auth_tag_to_report, summary)
    VALUES ('NP', 'Auteur', '200', '[200a][, 200b][ 200d][ ; 200c][ (200f)]')
}
);
$dbh->do(
    q{
    INSERT INTO marc_subfield_structure (frameworkcode,authtypecode,tagfield)
    VALUES ('','NP','200')
}
);

my $unimarc_name_auth = MARC::Record->new();
$unimarc_name_auth->add_fields(
    [ '100', ' ', ' ', a => '20121025              frey50       ' ],
    [ '200', ' ', ' ', a => 'Fossey', b => 'Brigitte' ],
    [ '152', ' ', ' ', a => 'NP' ],
);
my $expected_unimarc_name_summary = {
    'authorized' => [
        {
            'field'   => '200',
            'heading' => 'Fossey Brigitte',
            'hemain'  => 'Fossey'
        }
    ],
    'authtypecode'  => 'NP',
    'mainentry'     => 'Fossey Brigitte',
    'mainmainentry' => 'Fossey',
    'notes'         => [],
    'otherscript'   => [],
    'seealso'       => [],
    'seefrom'       => [],
    'summary'       => 'Fossey, Brigitte',
    'type'          => 'Auteur',
    'equalterm'     => []
};

is_deeply(
    BuildSummary( $unimarc_name_auth, 99999, 'NP' ),
    $expected_unimarc_name_summary,
    'test BuildSummary for UNIMARC'
);

subtest 'AddAuthority should respect AUTO_INCREMENT (BZ 18104)' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );
    my $record = MARC::Record->new();
    my $field  = MARC::Field->new( '151', ' ', ' ', a => 'Amsterdam (Netherlands)', 'x' => 'Economic conditions' );
    $record->append_fields($field);
    my $id1 = AddAuthority( $record, undef, 'GEOGR_NAME' );
    DelAuthority( { authid => $id1 } );
    $record = MARC::Record->new();
    $record->append_fields($field);
    my $id2 = AddAuthority( $record, undef, 'GEOGR_NAME' );
    isnt( $id1, $id2, 'Do not return the same id again' );
    t::lib::Mocks::mock_preference( 'marcflavour', 'UNIMARC' );
    $record = MARC::Record->new();
    $field  = MARC::Field->new( '200', ' ', ' ', a => 'Fossey', 'b' => 'Brigitte' );
    $record->append_fields($field);
    my $id3 = AddAuthority( $record, undef, 'NP' );
    ok( $id3 > 0, 'Tested AddAuthority with UNIMARC' );
    is( $record->field('001')->data, $id3, 'Check updated 001' );
};

subtest 'AddAuthority should create heading field with display form' => sub {
    plan tests => 2;

    t::lib::Mocks::mock_preference( 'marcflavour',    'MARC21' );
    t::lib::Mocks::mock_preference( 'AuthoritiesLog', 0 );
    my $record = MARC::Record->new();
    my $field  = MARC::Field->new( '151', ' ', ' ', a => 'White River Junction (Vt.)' );
    $record->append_fields($field);
    my $id        = AddAuthority( $record, undef, 'GEOGR_NAME' );
    my $authority = Koha::Authorities->find($id);
    is(
        $authority->heading, 'White River Junction (Vt.)',
        'Heading field is formed as expected when adding authority'
    );
    $record = MARC::Record->new();
    $field  = MARC::Field->new( '151', ' ', ' ', a => 'Lyon (France)', 'x' => 'Antiquities' );
    $record->append_fields($field);
    $id        = ModAuthority( $id, $record, 'GEOGR_NAME' );
    $authority = Koha::Authorities->find($id);
    is(
        $authority->heading, 'Lyon (France)--Antiquities',
        'Heading field is formed as expected when modding authority'
    );

};

subtest 'CompareFieldWithAuthority tests' => sub {
    plan tests => 3;

    t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );

    $builder->build( { source => 'AuthType', value => { authtypecode => 'PERSO_NAME' } } );

    my $field = MARC::Field->new( '100', 0, 0, a => 'Lastname, Firstname', b => 'b', c => 'c' );

    ok( C4::AuthoritiesMarc::CompareFieldWithAuthority( { 'field' => $field, 'authid' => 5 } ), 'Authority matches' );

    $field->add_subfields( i => 'X' );

    ok(
        C4::AuthoritiesMarc::CompareFieldWithAuthority( { 'field' => $field, 'authid' => 5 } ),
        'Compare ignores unlisted subfields'
    );

    $field->add_subfields( d => 'd' );

    ok(
        !C4::AuthoritiesMarc::CompareFieldWithAuthority( { 'field' => $field, 'authid' => 5 } ),
        'Authority does not match'
    );
};

$schema->storage->txn_rollback;

$module->unmock('GetAuthority');

subtest 'ModAuthority() tests' => sub {

    plan tests => 2;

    $schema->storage->txn_begin;

    my $auth_type = 'GEOGR_NAME';
    my $record    = MARC::Record->new;
    $record->add_fields(
        [ '001', '1' ],
        [ '151', ' ', ' ', a => 'United States' ]
    );

    my $auth_id = AddAuthority( $record, undef, $auth_type );

    my $mocked_authorities_marc = Test::MockModule->new('C4::AuthoritiesMarc');
    $mocked_authorities_marc->mock( 'merge', sub { warn 'merge called'; } );

    warning_is { ModAuthority( $auth_id, $record, $auth_type ); }
    'merge called',
        'No param, merge called';

    warning_is { ModAuthority( $auth_id, $record, $auth_type, { skip_merge => 1 } ); }
    undef,
        'skip_merge passed, merge not called';

    $schema->storage->txn_rollback;
};

subtest 'DelAuthority() tests' => sub {

    plan tests => 3;

    $schema->storage->txn_begin;

    my $auth_type = 'GEOGR_NAME';
    my $record    = MARC::Record->new;
    $record->add_fields(
        [ '001', '1' ],
        [ '151', ' ', ' ', a => 'United States' ]
    );

    my $auth_id = AddAuthority( $record, undef, $auth_type );

    my $mocked_authorities_marc = Test::MockModule->new('C4::AuthoritiesMarc');
    $mocked_authorities_marc->mock( 'merge', sub { warn 'merge called'; } );

    warning_is { DelAuthority( { authid => $auth_id } ); }
    'merge called',
        'No param, merge called';

    $auth_id = AddAuthority( $record, undef, $auth_type );

    warning_is { DelAuthority( { authid => $auth_id, skip_merge => 1 } ); }
    undef,
        'skip_merge passed, merge not called';

    # Check if last delete got moved to deletedauth_header
    isnt( Koha::Database->new->schema->resultset('DeletedauthHeader')->find($auth_id), undef, 'Moved to deleted' );

    $schema->storage->txn_rollback;
};
