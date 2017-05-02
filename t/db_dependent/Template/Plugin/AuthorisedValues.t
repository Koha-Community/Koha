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

use Test::More tests => 1;

use C4::Context;
use Koha::Database;
use Koha::Template::Plugin::AuthorisedValues;

use t::lib::TestBuilder;
use t::lib::Mocks;

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

subtest 'GetByCode' => sub {
    plan tests => 4;
    my $avc =
      $builder->build( { source => 'AuthorisedValueCategory' } );
    my $av_1 = $builder->build(
        {
            source => 'AuthorisedValue',
            value => { category => $avc->{category_name} }
        }
    );
    my $av_2 = $builder->build(
        {
            class => 'AuthorisedValue',
            value => { category => $avc->{category_name} }
        }
    );
    my $av_3 = $builder->build(
        {
            class => 'AuthorisedValue',
            value => { category => $avc->{category_name}, lib_opc => undef }
        }
    );
    my $description =
      Koha::Template::Plugin::AuthorisedValues->GetByCode( $avc->{category_name},
        $av_1->{authorised_value} );
    is( $description, $av_1->{lib}, 'GetByCode should return the correct dsecription' );
    my $opac_description =
      Koha::Template::Plugin::AuthorisedValues->GetByCode( $avc->{category_name},
        $av_1->{authorised_value}, 'opac' );
    is( $opac_description, $av_1->{lib_opac}, 'GetByCode should return the correct opac_description' );
    $opac_description =
      Koha::Template::Plugin::AuthorisedValues->GetByCode( $avc->{category_name},
        $av_3->{authorised_value}, 'opac' );
    is( $opac_description, $av_3->{lib}, 'GetByCode should return the staff description if the lib_opac is not filled' );

    $description =
      Koha::Template::Plugin::AuthorisedValues->GetByCode( $avc->{category_name},
        'does_not_exist' );
    is( $description, 'does_not_exist', 'GetByCode should return the code passed if the AV does not exist' );
};
