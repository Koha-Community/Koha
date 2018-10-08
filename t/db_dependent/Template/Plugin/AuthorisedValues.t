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
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Test::More tests => 2;

use C4::Context;
use Koha::Caches;
use Koha::Database;
use Koha::MarcSubfieldStructures;
use Koha::Template::Plugin::AuthorisedValues;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->schema;
my $builder = t::lib::TestBuilder->new;

subtest 'GetByCode' => sub {
    plan tests => 4;

    $schema->storage->txn_begin;

    my $avc =
      $builder->build_object( { class => 'Koha::AuthorisedValueCategories' } );
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
    my $description =
      Koha::Template::Plugin::AuthorisedValues->GetByCode( $avc->category_name,
        $av_1->authorised_value );
    is( $description, $av_1->lib, 'GetByCode should return the correct dsecription' );
    my $opac_description =
      Koha::Template::Plugin::AuthorisedValues->GetByCode( $avc->category_name,
        $av_1->authorised_value, 'opac' );
    is( $opac_description, $av_1->opac_description, 'GetByCode should return the correct opac_description' );
    $av_1->lib_opac(undef)->store;
    $opac_description =
      Koha::Template::Plugin::AuthorisedValues->GetByCode( $avc->category_name,
        $av_1->authorised_value, 'opac' );
    is( $opac_description, $av_1->lib, 'GetByCode should return the staff description if the lib_opac is not filled' );

    $description =
      Koha::Template::Plugin::AuthorisedValues->GetByCode( $avc->category_name,
        'does_not_exist' );
    is( $description, 'does_not_exist', 'GetByCode should return the code passed if the AV does not exist' );

    $schema->storage->txn_rollback;
};

subtest 'GetDescriptionByKohaField' => sub {

    plan tests => 7;

    $schema->storage->txn_begin;

    my $avc = $builder->build_object( { class => 'Koha::AuthorisedValueCategories' } );

    # Create a framework mapping
    Koha::MarcSubfieldStructure->new(
        {   tagfield         => '988',
            tagsubfield      => 'a',
            liblibrarian     => 'Dummy field',
            libopac          => 'Dummy field',
            repeatable       => 0,
            mandatory        => 0,
            kohafield        => 'dummy.field',
            tab              => '9',
            authorised_value => $avc->category_name,
            authtypecode     => q{},
            value_builder    => q{},
            isurl            => 0,
            hidden           => 0,
            frameworkcode    => q{},
            seealso          => q{},
            link             => q{},
            defaultvalue     => undef
        }
    )->store;

    # Make sure we are not catch by cache
    Koha::Caches->get_instance->flush_all;
    my $av_1 = $builder->build_object(
        {   class => 'Koha::AuthorisedValues',
            value => { category => $avc->category_name, lib_opac => 'lib_opac', lib => 'lib' }
        }
    );
    my $av_2 = $builder->build_object(
        {   class => 'Koha::AuthorisedValues',
            value => { category => $avc->category_name, lib_opac => undef, lib => 'lib' }
        }
    );
    my $av_3 = $builder->build_object(
        {   class => 'Koha::AuthorisedValues',
            value => { category => $avc->category_name, lib_opac => undef, lib => undef }
        }
    );
    my $non_existent_av = $av_3->authorised_value;
    $av_3->delete;

    my $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { opac => 1, kohafield => 'dummy.field', authorised_value => $av_1->authorised_value } );
    is( $av, 'lib_opac', 'We requested OPAC description.' );
    $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { opac => 1, kohafield => 'dummy.field', authorised_value => $av_2->authorised_value } );
    is( $av, 'lib', 'We requested OPAC description, return a regular description.' );
    $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { opac => 1, kohafield => 'dummy.field', authorised_value => $av_3->authorised_value } );
    is( $av, $av_3->authorised_value, 'We requested OPAC or regular description, return the authorised_value.' );
    $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { opac => 1, kohafield => 'dummy.field', authorised_value => $non_existent_av } );
    is( $av, $av_3->authorised_value, 'We requested a non existing authorised_value for the OPAC, return the authorised_value.' );
    $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { kohafield => 'dummy.field', authorised_value => $av_1->authorised_value } );
    is( $av, 'lib', 'We requested a regular description.' );
    $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { kohafield => 'dummy.field', authorised_value => $av_3->authorised_value } );
    is( $av, $av_3->authorised_value, 'We requested a regular description, return the authorised_value.' );
    $av = Koha::Template::Plugin::AuthorisedValues->GetDescriptionByKohaField(
        { kohafield => 'dummy.field', authorised_value => $non_existent_av } );
    is( $av, $av_3->authorised_value, 'We requested a non existing authorised_value, return the authorised_value.' );

    $schema->storage->txn_rollback;
};
