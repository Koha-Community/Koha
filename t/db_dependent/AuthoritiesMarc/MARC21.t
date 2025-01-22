#!/usr/bin/perl
#

use strict;
use warnings;

use Test::MockModule;
use Test::NoWarnings;
use Test::More tests => 3;
use MARC::Field;
use MARC::Record;

use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN {
    use_ok('C4::AuthoritiesMarc::MARC21');
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;
my $dbh     = C4::Context->dbh;
my $builder = t::lib::TestBuilder->new;

t::lib::Mocks::mock_preference( 'marcflavour', 'MARC21' );

subtest 'CompareFieldWithAuthority tests' => sub {
    plan tests => 3;

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
                    [ '551', ' ', ' ', a => 'United States', w => 'g', 9 => '1' ]
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

    $dbh->do('DELETE FROM auth_types');
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
