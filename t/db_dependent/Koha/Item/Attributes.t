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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::NoWarnings;
use Test::More tests => 11;
use utf8;

use Koha::Database;
use Koha::Caches;

use C4::Biblio;
use Koha::Item::Attributes;
use Koha::MarcSubfieldStructures;

use t::lib::TestBuilder;

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $builder = t::lib::TestBuilder->new;
my $biblio  = $builder->build_sample_biblio( { frameworkcode => '' } );
my $item    = $builder->build_sample_item( { biblionumber => $biblio->biblionumber } );

my $cache = Koha::Caches->get_instance;
$cache->clear_from_cache("MarcStructure-0-");
$cache->clear_from_cache("MarcStructure-1-");
$cache->clear_from_cache("MarcSubfieldStructure-");

# 952 $x $é $y are not linked with a kohafield
# $952$x $é repeatable
# $952$y is not repeatable
setup_mss();

$item->more_subfields_xml(undef)->store;    # Shouldn't be needed, but we want to make sure
my $attributes = $item->additional_attributes;
is( ref($attributes),        'Koha::Item::Attributes' );
is( $attributes->to_marcxml, undef );
is_deeply( $attributes->to_hashref, {} );

my $some_marc_xml = q{<?xml version="1.0" encoding="UTF-8"?>
<collection
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
  xmlns="http://www.loc.gov/MARC21/slim">

<record>
  <leader>         a              </leader>
  <datafield tag="999" ind1=" " ind2=" ">
    <subfield code="x">value for x 1</subfield>
    <subfield code="x">value for x 2</subfield>
    <subfield code="y">value for y</subfield>
    <subfield code="é">value for é 1</subfield>
    <subfield code="é">value for é 2</subfield>
    <subfield code="z">value for z 1 | value for z 2</subfield>
  </datafield>
</record>

</collection>};

$item->more_subfields_xml($some_marc_xml)->store;

$attributes = $item->additional_attributes;
is( ref($attributes),   'Koha::Item::Attributes' );
is( $attributes->{'x'}, "value for x 1 | value for x 2" );
is( $attributes->{'y'}, "value for y" );
is( $attributes->{'é'}, "value for é 1 | value for é 2" );
is( $attributes->{'z'}, "value for z 1 | value for z 2" );

is( $attributes->to_marcxml, $some_marc_xml );
is_deeply(
    $attributes->to_hashref,
    {
        'x' => "value for x 1 | value for x 2",
        'y' => "value for y",
        'é' => "value for é 1 | value for é 2",
        'z' => "value for z 1 | value for z 2",
    }
);

Koha::Caches->get_instance->clear_from_cache("MarcStructure-1-");

sub setup_mss {

    my ( $itemtag, $itemsubfield ) = C4::Biblio::GetMarcFromKohaField("items.itemnumber");

    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield      => $itemtag,
            tagsubfield   => 'é',
        }
    )->delete;    # In case it exist already

    Koha::MarcSubfieldStructure->new(
        {
            frameworkcode => '',
            tagfield      => $itemtag,
            tagsubfield   => 'é',
            kohafield     => undef,
            repeatable    => 1,
            tab           => 10,
        }
    )->store;

    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield      => $itemtag,
            tagsubfield   => [ 'x', 'y' ]
        }
    )->update( { kohafield => undef } );

    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield      => $itemtag,
            tagsubfield   => [ 'x', 'é' ],
        }
    )->update( { repeatable => 1 } );

    Koha::MarcSubfieldStructures->search(
        {
            frameworkcode => '',
            tagfield      => $itemtag,
            tagsubfield   => ['y'],
        }
    )->update( { repeatable => 0 } );

    my $i = 0;
    for my $sf (qw( x y é z )) {
        Koha::MarcSubfieldStructures->search( { frameworkcode => '', tagfield => $itemtag, tagsubfield => $sf } )
            ->update( { display_order => $i++ } );
    }

}
