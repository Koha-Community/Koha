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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 2;

use t::lib::TestBuilder;

use File::Basename qw( dirname );

use Koha::Database;
use Koha::BiblioFrameworks;
use Koha::MarcSubfieldStructures;
use C4::ImportExportFramework qw( ImportFramework ExportFramework );
use Koha::Authority::Types;
use Koha::Authority::Subfields;

my $schema  = Koha::Database->new->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'ImportFramework() tests' => sub {

    plan tests => 6;

    subtest 'CSV tests for biblio frameworks' => sub {
        plan tests => 15;

        run_biblio_tests('csv');

        run_csv_no_quoted();
    };

    subtest 'ODS tests for biblio frameworks' => sub {
        plan tests => 15;

        run_biblio_tests('ods');

        run_ods_new();
    };

    subtest 'XML tests for biblio frameworks' => sub {
        plan tests => 9;

        run_biblio_tests('xml');
    };

    subtest 'CSV tests for auth frameworks' => sub {
        plan tests => 9;

        run_auth_tests('csv');
    };

    subtest 'ODS tests for auth frameworks' => sub {
        plan tests => 9;

        run_auth_tests('ods');
    };

    subtest 'XML tests for auth frameworks' => sub {
        plan tests => 9;

        run_auth_tests('xml');
    };

};

sub run_biblio_tests {

    my ($format) = @_;
    my $type = "biblio";

    $schema->storage->txn_begin;

    my $data_filepath = dirname(__FILE__) . "/data/frameworks/biblio_framework.$format";
    my $fw_1          = $builder->build_object( { class => 'Koha::BiblioFrameworks' } );

    my $result = C4::ImportExportFramework::ImportFramework( $data_filepath, $fw_1->id, 0, $type );
    is( $result, 0, 'Import successful, no tags removed' );

    my $nb_tags = $schema->resultset('MarcTagStructure')->search( { frameworkcode => $fw_1->id } )->count;
    is( $nb_tags, 4, "4 tags should have been imported" );

    my $nb_subfields = Koha::MarcSubfieldStructures->search( { frameworkcode => $fw_1->id } )->count;
    is( $nb_subfields, 12, "12 subfields should have been imported" );

    # bad file tests
    my $fw_2 = $builder->build_object( { class => 'Koha::BiblioFrameworks' } );
    $result = C4::ImportExportFramework::ImportFramework( '', $fw_2->id, 0, $type );

    is( $result, -1, 'Bad file makes it return -1' );

    $nb_tags = $schema->resultset('MarcTagStructure')->search( { frameworkcode => $fw_2->id } )->count;
    is( $nb_tags, 0, "0 tags should have been imported" );

    $nb_subfields = Koha::MarcSubfieldStructures->search( { frameworkcode => $fw_2->id } )->count;
    is( $nb_subfields, 0, "0 subfields should have been imported" );

    # framework overwrite
    $data_filepath = dirname(__FILE__) . "/data/frameworks/biblio_framework_smaller.$format";

    $result = C4::ImportExportFramework::ImportFramework( $data_filepath, $fw_1->id, 0, $type );
    is( $result, 5, 'Smaller fw import successful, 4 tags removed' );

    $nb_tags = $schema->resultset('MarcTagStructure')->search( { frameworkcode => $fw_1->id } )->count;
    is( $nb_tags, 3, "3 tags should have been imported" );

    $nb_subfields = Koha::MarcSubfieldStructures->search( { frameworkcode => $fw_1->id } )->count;
    is( $nb_subfields, 8, "8 subfields should have been imported" );

    $schema->storage->txn_rollback;
}

sub run_csv_no_quoted {

    $schema->storage->txn_begin;

    my $data_filepath = dirname(__FILE__) . "/data/frameworks/biblio_framework_no_quoted.csv";
    my $fw_1          = $builder->build_object( { class => 'Koha::BiblioFrameworks' } );

    my $result = C4::ImportExportFramework::ImportFramework( $data_filepath, $fw_1->id );
    is( $result, 0, 'Import successful, no tags removed' );

    my $nb_tags = $schema->resultset('MarcTagStructure')->search( { frameworkcode => $fw_1->id } )->count;
    is( $nb_tags, 4, "4 tags should have been imported" );

    my $nb_subfields = Koha::MarcSubfieldStructures->search( { frameworkcode => $fw_1->id } )->count;
    is( $nb_subfields, 12, "12 subfields should have been imported" );

    # bad file tests
    my $fw_2 = $builder->build_object( { class => 'Koha::BiblioFrameworks' } );
    $result = C4::ImportExportFramework::ImportFramework( '', $fw_2->id );

    is( $result, -1, 'Bad file makes it return -1' );

    $nb_tags = $schema->resultset('MarcTagStructure')->search( { frameworkcode => $fw_2->id } )->count;
    is( $nb_tags, 0, "0 tags should have been imported" );

    $nb_subfields = Koha::MarcSubfieldStructures->search( { frameworkcode => $fw_2->id } )->count;
    is( $nb_subfields, 0, "0 subfields should have been imported" );

    $schema->storage->txn_rollback;
}

sub run_ods_new {

    my ($format) = @_;

    $schema->storage->txn_begin;

    my $data_filepath = dirname(__FILE__) . "/data/frameworks/biblio_framework_new.ods";
    my $fw_1          = $builder->build_object( { class => 'Koha::BiblioFrameworks' } );

    my $result = C4::ImportExportFramework::ImportFramework( $data_filepath, $fw_1->id );
    is( $result, 0, 'Import successful, no tags removed' );

    my $nb_tags = $schema->resultset('MarcTagStructure')->search( { frameworkcode => $fw_1->id } )->count;
    is( $nb_tags, 5, "5 tags should have been imported" );

    my $nb_subfields = Koha::MarcSubfieldStructures->search( { frameworkcode => $fw_1->id } )->count;
    is( $nb_subfields, 16, "16 subfields should have been imported" );

    # bad file tests
    my $fw_2 = $builder->build_object( { class => 'Koha::BiblioFrameworks' } );
    $result = C4::ImportExportFramework::ImportFramework( '', $fw_2->id );

    is( $result, -1, 'Bad file makes it return -1' );

    $nb_tags = $schema->resultset('MarcTagStructure')->search( { frameworkcode => $fw_2->id } )->count;
    is( $nb_tags, 0, "0 tags should have been imported" );

    $nb_subfields = Koha::MarcSubfieldStructures->search( { frameworkcode => $fw_2->id } )->count;
    is( $nb_subfields, 0, "0 subfields should have been imported" );

    $schema->storage->txn_rollback;
}

sub run_auth_tests {

    my ($format) = @_;
    my $type = "authority";

    $schema->storage->txn_begin;

    my $data_filepath = dirname(__FILE__) . "/data/frameworks/auth_type.$format";
    my $fw_1          = $builder->build_object( { class => 'Koha::Authority::Types' } );

    my $result = C4::ImportExportFramework::ImportFramework( $data_filepath, $fw_1->id, '', $type );
    is( $result, 0, 'Import successful, no tags removed' );

    my $nb_tags = $schema->resultset('AuthTagStructure')->search( { authtypecode => $fw_1->id } )->count;
    is( $nb_tags, 6, "6 tags should have been imported" );

    my $nb_subfields = Koha::Authority::Subfields->search( { authtypecode => $fw_1->id } )->count;
    is( $nb_subfields, 8, "8 subfields should have been imported" );

    # bad file tests
    my $fw_2 = $builder->build_object( { class => 'Koha::Authority::Types' } );
    $result = C4::ImportExportFramework::ImportFramework( '', $fw_2->id, '', $type );

    is( $result, -1, 'Bad file makes it return -1' );

    $nb_tags = $schema->resultset('AuthTagStructure')->search( { authtypecode => $fw_2->id } )->count;
    is( $nb_tags, 0, "0 tags should have been imported" );

    $nb_subfields = Koha::Authority::Subfields->search( { authtypecode => $fw_2->id } )->count;
    is( $nb_subfields, 0, "0 subfields should have been imported" );

    # framework overwrite
    $data_filepath = dirname(__FILE__) . "/data/frameworks/auth_type_smaller.$format";

    $result = C4::ImportExportFramework::ImportFramework( $data_filepath, $fw_1->id, '', $type );
    is( $result, 8, 'Smaller fw import successful, 6 tags removed' );

    $nb_tags = $schema->resultset('AuthTagStructure')->search( { authtypecode => $fw_1->id } )->count;
    is( $nb_tags, 3, "3 tags should have been imported" );

    $nb_subfields = Koha::Authority::Subfields->search( { authtypecode => $fw_1->id } )->count;
    is( $nb_subfields, 3, "3 subfields should have been imported" );

    $schema->storage->txn_rollback;
}
