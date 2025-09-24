#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2024 Koha Development Team
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
use Test::More tests => 5;
use Test::NoWarnings;

use Test::MockModule;
use File::Temp qw/tempdir/;
use File::Path qw/make_path/;
use File::Spec;

use t::lib::Mocks;
use t::lib::TestBuilder;

BEGIN { use_ok('Koha::Installer') }

my $schema = Koha::Database->new->schema;

subtest 'needs_update' => sub {
    plan tests => 5;

    my $dbh = $schema->storage->dbh;

    # Back up the original row where variable = 'Version'
    # Note: We can't do the usual transaction wrapping here for rollback due to not sharing a db handle
    my $sth = $dbh->prepare("SELECT * FROM systempreferences WHERE variable = 'Version'");
    $sth->execute();
    my $original_row = $sth->fetchrow_hashref();

    # Tests
    my $mock_koha      = Test::MockModule->new('Koha');
    my $mock_installer = Test::MockModule->new('Koha::Installer');

    $dbh->do("UPDATE systempreferences SET value = '20.0501000' WHERE variable = 'Version'");
    $mock_koha->mock( 'version', sub { '20.05.01.000' } );
    $mock_installer->mock( 'get_atomic_updates', sub { return [] } );

    my $result = Koha::Installer::needs_update();
    is( $result, 0, 'No update needed when DB version matches code version and no atomic updates' );

    # Test 2: DB version does not match code version, no atomic updates
    $dbh->do("UPDATE systempreferences SET value = '19.1102999' WHERE variable = 'Version'");
    $mock_koha->mock( 'version', sub { '20.05.01.000' } );

    $result = Koha::Installer::needs_update();
    is( $result, 1, 'Update needed when DB version does not match code version' );

    # Test 3: DB version matches code version, atomic updates present
    $dbh->do("UPDATE systempreferences SET value = '20.0501000' WHERE variable = 'Version'");
    $mock_installer->mock( 'get_atomic_updates', sub { return ['update_001.perl'] } );

    $result = Koha::Installer::needs_update();
    is( $result, 1, 'Update needed when atomic updates are present, even if versions match' );

    # Test 4: DB version does not match code version, atomic updates present
    $dbh->do("UPDATE systempreferences SET value = '18.0001000' WHERE variable = 'Version'");
    $mock_installer->mock( 'get_atomic_updates', sub { return ['update_001.perl'] } );

    $result = Koha::Installer::needs_update();
    is( $result, 1, 'Update needed when DB version does not match code version and atomic updates are present' );

    # Test 5: Edge case where DB version is undefined (should default to update needed)
    $dbh->do("DELETE FROM systempreferences WHERE variable = 'Version'");
    $mock_installer->mock( 'get_atomic_updates', sub { return [] } );

    $result = Koha::Installer::needs_update();
    is( $result, 1, 'Update needed when DB version is undefined' );

    # Restore the original row
    if ($original_row) {
        $dbh->do(
            "INSERT INTO systempreferences (variable, value, options, explanation, type) VALUES (?, ?, ?, ?, ?)",
            undef,
            $original_row->{variable},
            $original_row->{value},
            $original_row->{options},
            $original_row->{explanation},
            $original_row->{type}
        );
    } else {
        $dbh->do("DELETE FROM systempreferences WHERE variable = 'Version'");
    }
};

subtest 'TransformToNum' => sub {
    plan tests => 3;

    my %test_cases = (
        '20.05.01.000' => '20.0501000',
        '21.06.00.003' => '21.0600003',
        '22.11.01.123' => '22.1101123',
    );

    foreach my $input_version ( keys %test_cases ) {
        my $expected_output = $test_cases{$input_version};
        my $actual_output   = Koha::Installer::TransformToNum($input_version);

        is( $actual_output, $expected_output, "TransformToNum('$input_version') = '$expected_output'" );
    }

};

subtest 'get_atomic_updates method' => sub {
    plan tests => 1;

    # Create a temporary directory with some files
    my $temp_dir   = tempdir( CLEANUP => 1 );
    my $update_dir = File::Spec->catdir( $temp_dir, 'installer', 'data', 'mysql', 'atomicupdate' );
    make_path($update_dir) or die "Failed to create directory $update_dir: $!";

    my @test_files = (
        'update_001.perl',
        'update_002.pl',
        'update_003.sql',    # Should be ignored
        'skeleton.perl',     # Should be ignored
        'update_004.perl',
        'skeleton.pl',       # Should be ignored
        'README.txt',        # Should be ignored
    );

    foreach my $file (@test_files) {
        open my $fh, '>', File::Spec->catfile( $update_dir, $file ) or die $!;
        close $fh;
    }

    my $mock_koha_config = Test::MockModule->new('Koha::Config');
    $mock_koha_config->mock( 'guess_koha_conf', sub { '/fake/koha.conf' } );
    $mock_koha_config->mock(
        'get_instance',
        sub {
            return { config => { intranetdir => $temp_dir } };
        }
    );

    # Run the method under test
    my $result = Koha::Installer::get_atomic_updates();

    # Expected output (sorted)
    my @expected_files = sort ( 'update_001.perl', 'update_002.pl', 'update_004.perl' );

    is_deeply( $result, \@expected_files, 'get_atomic_updates returns correct files' );
};
