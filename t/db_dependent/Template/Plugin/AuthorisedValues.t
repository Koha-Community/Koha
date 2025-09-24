#!/usr/bin/perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Test::NoWarnings;
use Test::More tests => 3;

use C4::Context;
use Koha::Caches;
use Koha::Database;
use Koha::MarcSubfieldStructures;
use Koha::Template::Plugin::AuthorisedValues;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema  = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'GetByCode' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $avc  = $builder->build_object( { class => 'Koha::AuthorisedValueCategories' } );
    my $av_1 = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => { category => $avc->category_name }
        }
    );
    my $av_2 = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => { category => $avc->category_name }
        }
    );
    my $description = Koha::Template::Plugin::AuthorisedValues->GetByCode(
        $avc->category_name,
        $av_1->authorised_value
    );
    is( $description, $av_1->lib, 'GetByCode should return the correct dsecription' );
    my $opac_description = Koha::Template::Plugin::AuthorisedValues->GetByCode(
        $avc->category_name,
        $av_1->authorised_value, 'opac'
    );
    is( $opac_description, $av_1->opac_description, 'GetByCode should return the correct opac_description' );
    $av_1->lib_opac(undef)->store;
    $opac_description = Koha::Template::Plugin::AuthorisedValues->GetByCode(
        $avc->category_name,
        $av_1->authorised_value, 'opac'
    );
    is( $opac_description, $av_1->lib, 'GetByCode should return the staff description if the lib_opac is not filled' );

    $description = Koha::Template::Plugin::AuthorisedValues->GetByCode(
        $avc->category_name,
        'does_not_exist'
    );
    is( $description, 'does_not_exist', 'GetByCode should return the code passed if the AV does not exist' );

    $schema->storage->txn_rollback;
};

subtest 'GetDescriptionByKohaField' => sub {

    plan tests => 8;

    $schema->storage->txn_begin;

    my $avc = $builder->build_object( { class => 'Koha::AuthorisedValueCategories' } );

    # Create a framework mapping
    $builder->build_object(
        {
            class => 'Koha::MarcSubfieldStructures',
            value => {

                tagfield         => '988',
                tagsubfield      => 'a',
                liblibrarian     => 'Dummy field',
                libopac          => 'Dummy field',
                kohafield        => 'dummy.field',
                authorised_value => $avc->category_name,
                frameworkcode    => q{},
            }
        }
    )->store;

    # Make sure we are not catch by cache
    Koha::Caches->get_instance->flush_all;
    my $av_1 = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => { category => $avc->category_name, lib_opac => 'lib_opac', lib => 'lib' }
        }
    )->store;
    my $av_2 = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => { category => $avc->category_name, lib_opac => undef, lib => 'lib' }
        }
    )->store;
    my $av_3 = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => { category => $avc->category_name, lib_opac => undef, lib => undef }
        }
    )->store;

    my $non_existent_av = $builder->build_object(
        {
            class => 'Koha::AuthorisedValues',
            value => { category => $avc->category_name, }
        }
    )->store->delete;

    # Opac display
    my $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { opac => 1, kohafield => 'dummy.field', authorised_value => $av_1->authorised_value } );
    is( $av, 'lib_opac', 'For OPAC: The OPAC description should be displayed if exists' );
    $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { opac => 1, kohafield => 'dummy.field', authorised_value => $av_2->authorised_value } );
    is( $av, 'lib', 'For OPAC: The staff description should be displayed if none exists for OPAC' );
    $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { opac => 1, kohafield => 'dummy.field', authorised_value => $av_3->authorised_value } );
    is(
        $av, $av_3->authorised_value,
        'For OPAC: If both OPAC and staff descriptions are missing, the code should be displayed'
    );
    $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { opac => 1, kohafield => 'dummy.field', authorised_value => $non_existent_av } );
    is(
        $av, $non_existent_av,
        'For OPAC: If both OPAC and staff descriptions are missing, the parameter should be displayed'
    );

    # Staff display
    $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { kohafield => 'dummy.field', authorised_value => $av_1->authorised_value } );
    is( $av, 'lib', 'The staff description should be displayed' );
    $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { kohafield => 'dummy.field', authorised_value => $av_3->authorised_value } );
    is( $av, $av_3->authorised_value, 'If both OPAC and staff descriptions are missing, the code should be displayed' );
    $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { kohafield => 'dummy.field', authorised_value => $non_existent_av } );
    is( $av, $non_existent_av, 'If both OPAC and staff descriptions are missing, the parameter should be displayed' );
    $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { kohafield => 'dummy.field', authorised_value => undef } );
    is(
        $av, '',
        'If both OPAC and staff descriptions are missing, and the parameter is undef, an empty string should be displayed'
    );

    $schema->storage->txn_rollback;
};
