#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 16;
use Test::MockModule;
use Test::Warn;
use MARC::Field;
use MARC::Record;
use JSON qw( from_json );

use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::ActionLogs;
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

subtest 'Authority action logs include MARC-in-JSON diff' => sub {
    plan tests => 25;

    $schema->storage->txn_begin;

    t::lib::Mocks::mock_preference( 'AuthoritiesLog', 1 );

    my $auth_type = 'GEOGR_NAME';

    # --- ADD ---
    my $add_record = MARC::Record->new;
    $add_record->add_fields(
        [ '151', ' ', ' ', a => 'France' ],
        [ '670', ' ', ' ', a => 'Source note' ],
    );
    my $auth_id = AddAuthority( $add_record, undef, $auth_type );

    my $add_log = Koha::ActionLogs->search( { object => $auth_id, module => 'AUTHORITIES', action => 'ADD' } )->next;
    ok( defined $add_log,       'ADD action logged' );
    ok( defined $add_log->diff, 'ADD: diff column populated' );
    is(
        $add_log->info, 'authority',
        'ADD: info column is the bare "authority" prefix (no JSON payload)'
    );

    my $add_diff  = from_json( $add_log->diff );
    my $add_added = $add_diff->{D}{_marc}{A};
    ok( defined $add_added,                  'ADD diff contains _marc key' );
    ok( exists $add_added->{leader},         '_marc has leader' );
    ok( ref $add_added->{fields} eq 'ARRAY', '_marc.fields is an array (MiJ shape)' );

    my ($f151) = grep { exists $_->{'151'} } @{ $add_added->{fields} };
    ok( defined $f151, '151 field present in _marc.fields' );
    is( $f151->{'151'}{subfields}[0]{a}, 'France', '151 $a correct' );

    ok( !exists $add_diff->{D}{heading},   'MARC-derived heading column absent from diff' );
    ok( !exists $add_diff->{D}{authtrees}, 'MARC-derived authtrees column absent from diff' );

    # --- MODIFY ---
    # Indicators below are bare ASCII strings (not utf8-flagged), as a CGI
    # form would supply them. The stored MARC, once re-read via
    # MARC::Record->new_from_xml, comes back utf8-flagged. Without the
    # symmetric-reload in ModAuthority, Struct::Diff would emit phantom
    # entries for every unchanged indicator.
    my $mod_record = MARC::Record->new;
    $mod_record->add_fields(
        [ '151', ' ', ' ', a => 'France (updated)' ],
        [ '670', ' ', ' ', a => 'Source note' ],
    );
    ModAuthority( $auth_id, $mod_record, $auth_type, { skip_merge => 1 } );

    my $mod_log = Koha::ActionLogs->search( { object => $auth_id, module => 'AUTHORITIES', action => 'MODIFY' } )->next;
    ok( defined $mod_log,       'MODIFY action logged' );
    ok( defined $mod_log->diff, 'MODIFY: diff column populated' );
    like(
        $mod_log->info, qr/^authority \{/,
        'MODIFY: info column carries the pre-change JSON payload'
    );

    my $mod_diff = from_json( $mod_log->diff );
    ok( exists $mod_diff->{D}{_marc},      'MODIFY diff contains _marc key' );
    ok( !exists $mod_diff->{D}{heading},   'MARC-derived heading column absent from MODIFY diff' );
    ok( !exists $mod_diff->{D}{authtrees}, 'MARC-derived authtrees column absent from MODIFY diff' );
    like( $mod_log->diff, qr/France/,           'MODIFY: diff captures before value' );
    like( $mod_log->diff, qr/France.*updated/s, 'MODIFY: diff captures after value' );

    my @changed_tags;
    for my $field_entry ( @{ $mod_diff->{D}{_marc}{D}{fields}{D} || [] } ) {
        next unless ref $field_entry->{D} eq 'HASH';
        push @changed_tags, keys %{ $field_entry->{D} };
    }

    # 005 (timestamp) updates on every save and is expected; 151 is the
    # field we actually edited. Anything else is a phantom (typically
    # ind1/ind2 utf8-flag mismatches on untouched fields).
    my @phantom_tags = grep { $_ ne '005' && $_ ne '151' } @changed_tags;
    is_deeply(
        [ sort @phantom_tags ], [],
        'MODIFY: untouched fields produce no phantom diff entries'
    );
    unlike(
        $mod_log->diff, qr/Source note/,
        'MODIFY: untouched 670 field absent from diff'
    );

    # --- DELETE ---
    DelAuthority( { authid => $auth_id, skip_merge => 1 } );

    my $del_log = Koha::ActionLogs->search( { object => $auth_id, module => 'AUTHORITIES', action => 'DELETE' } )->next;
    ok( defined $del_log,       'DELETE action logged' );
    ok( defined $del_log->diff, 'DELETE: diff column populated' );
    like(
        $del_log->info, qr/^authority \{/,
        'DELETE: info column carries the final-state JSON payload'
    );

    my $del_diff    = from_json( $del_log->diff );
    my $del_removed = $del_diff->{D}{_marc}{R};
    ok( defined $del_removed,                  'DELETE diff contains _marc key' );
    ok( ref $del_removed->{fields} eq 'ARRAY', '_marc.fields is an array in DELETE diff' );

    $schema->storage->txn_rollback;
};

subtest 'BuildSummary/_marc21_sort_hierarchy_alpha' => sub {
    plan tests => 2;

    my @fields;
    push @fields, MARC::Field->new( '550', '', '', a => 'zzz', w => 'h' );
    push @fields, MARC::Field->new( '550', '', '', a => 'yyy', w => 'g' );
    push @fields, MARC::Field->new( '550', '', '', a => 'xxx', w => 'x' );
    push @fields, MARC::Field->new( '550', '', '', a => 'www', w => '' );
    push @fields, MARC::Field->new( '550', '', '', a => 'vvv', w => 'g' );
    push @fields, MARC::Field->new( '550', '', '', a => 'uuu', w => 'h' );

    my @sorted_sub_a = map { $_->subfield('a') } C4::AuthoritiesMarc::_marc21_sort_hierarchy_alpha(@fields);
    is_deeply( \@sorted_sub_a, [ 'vvv', 'yyy', 'www', 'xxx', 'uuu', 'zzz' ], 'Sorted as expected' );

    # MARC21 $w has up to 4 positions; only position 0 encodes the hierarchy.
    # Values like 'gnna' or 'hnnn' must still classify as broader/narrower.
    my @multi_pos_fields;
    push @multi_pos_fields, MARC::Field->new( '550', '', '', a => 'zzz', w => 'hnnn' );
    push @multi_pos_fields, MARC::Field->new( '550', '', '', a => 'yyy', w => 'gnna' );
    push @multi_pos_fields, MARC::Field->new( '550', '', '', a => 'xxx', w => 'nnnn' );
    push @multi_pos_fields, MARC::Field->new( '550', '', '', a => 'www', w => '' );
    push @multi_pos_fields, MARC::Field->new( '550', '', '', a => 'vvv', w => 'g   ' );
    push @multi_pos_fields, MARC::Field->new( '550', '', '', a => 'uuu', w => 'h   ' );

    my @sorted_multi_pos =
        map { $_->subfield('a') } C4::AuthoritiesMarc::_marc21_sort_hierarchy_alpha(@multi_pos_fields);
    is_deeply(
        \@sorted_multi_pos,
        [ 'vvv', 'yyy', 'www', 'xxx', 'uuu', 'zzz' ],
        'Multi-position $w classified by position 0 only'
    );
};
