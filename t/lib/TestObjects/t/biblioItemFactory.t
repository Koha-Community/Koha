#!/usr/bin/perl

# Copyright KohaSuomi 2016
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

use Modern::Perl;
use Test::More;

use t::lib::TestObjects::ItemFactory;
use Koha::Items;
use t::lib::TestObjects::BiblioFactory;
use Koha::Biblios;
use C4::Biblio;

my $marcxml = <<RECORD;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">300841</controlfield>
  <controlfield tag="003">KYYTI</controlfield>
  <controlfield tag="005">20150216235917.0</controlfield>
  <controlfield tag="008">       1988    xxk|||||||||| ||||1|eng|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">0233982213</subfield>
    <subfield code="q">NID.</subfield>
  </datafield>
  <datafield tag="041" ind1="0" ind2=" ">
    <subfield code="a">eng</subfield>
    <subfield code="a">vie</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">85.25</subfield>
    <subfield code="2">ykl</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">THE WISHING TREE /</subfield>
    <subfield code="c">USHA BAHL.</subfield>
  </datafield>
  <datafield tag="260" ind1=" " ind2=" ">
    <subfield code="c">1990</subfield>
  </datafield>
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="c">BK</subfield>
    <subfield code="1">1996-05-01 00:00:00</subfield>
  </datafield>
</record>
RECORD

my $subtestContext = {};
subtest "Create biblios from db columns", \&createBibliosFromDBColumns;
sub createBibliosFromDBColumns {
    ##Create and Delete. Add one
    my $biblios = t::lib::TestObjects::BiblioFactory->createTestGroup([
                        {'biblio.title' => 'I wish I met your mother',
                         'biblio.author'   => 'Pertti Kurikka',
                         'biblio.copyrightdate' => '1960',
                         'biblioitems.isbn'     => '9519671580',
                         'biblioitems.itemtype' => 'BK',
                        },
                    ], 'biblioitems.isbn', $subtestContext);
    my $objects = t::lib::TestObjects::ItemFactory->createTestGroup([
                        {biblionumber => $biblios->{9519671580}->{biblionumber},
                         barcode => '167Nabe0001',
                         homebranch   => 'CPL',
                         holdingbranch => 'CPL',
                         price     => '0.50',
                         replacementprice => '0.50',
                         itype => 'BK',
                         biblioisbn => '9519671580',
                         itemcallnumber => 'PK 84.2',
                        },
                    ], 'barcode', $subtestContext);

    is($objects->{'167Nabe0001'}->barcode, '167Nabe0001', "Item '167Nabe0001'.");
    ##Add one more to test incrementing the subtestContext.
    $objects = t::lib::TestObjects::ItemFactory->createTestGroup([
                        {biblionumber => $biblios->{9519671580}->{biblionumber},
                         barcode => '167Nabe0002',
                         homebranch   => 'CPL',
                         holdingbranch => 'FFL',
                         price     => '3.50',
                         replacementprice => '3.50',
                         itype => 'BK',
                         biblioisbn => '9519671580',
                         itemcallnumber => 'JK 84.2',
                        },
                    ], 'barcode', $subtestContext);

    is($subtestContext->{item}->{'167Nabe0001'}->barcode, '167Nabe0001', "Item '167Nabe0001' from \$subtestContext.");
    is($objects->{'167Nabe0002'}->holdingbranch,           'FFL',         "Item '167Nabe0002'.");
    is(ref($biblios->{9519671580}), 'MARC::Record', "Biblio 'I wish I met your mother'.");

    ##Delete objects
    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
    my $object1 = Koha::Items->find({barcode => '167Nabe0001'});
    ok (not($object1), "Item '167Nabe0001' deleted");
    my $object2 = Koha::Items->find({barcode => '167Nabe0002'});
    ok (not($object2), "Item '167Nabe0002' deleted");
    my $object3 = Koha::Biblios->find({title => 'I wish I met your mother', author => "Pertti Kurikka"});
    ok (not($object2), "Biblio 'I wish I met your mother' deleted");
}


subtest "Create biblios from MARCXML", \&createBibliosFromMARCXML;
sub createBibliosFromMARCXML {
    my ($record, $biblio);

    ##Create from a HASH with a reference to MARCXML
    $record = t::lib::TestObjects::BiblioFactory->createTestGroup(
                                    {record => $marcxml}, 'biblioitems.isbn', $subtestContext);

    $biblio = C4::Biblio::GetBiblioData($record->{biblionumber});
    is($biblio->{title},
       'THE WISHING TREE /',
       'Title ok');
    is($biblio->{copyrightdate},
       '1990',
       'Copyrightdate ok');

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);

    $biblio = C4::Biblio::GetBiblioData($record->{biblionumber});
    ok(not($biblio),
       'Biblio deleted');


    ##Create from a MARCXML scalar
    $record = t::lib::TestObjects::BiblioFactory->createTestGroup(
                                    $marcxml, 'biblioitems.isbn', $subtestContext);

    $biblio = C4::Biblio::GetBiblioData($record->{biblionumber});
    is($biblio->{title},
       'THE WISHING TREE /',
       'Title ok');
    is($biblio->{copyrightdate},
       '1990',
       'Copyrightdate ok');

    t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);

    $biblio = C4::Biblio::GetBiblioData($record->{biblionumber});
    ok(not($biblio),
       'Biblio deleted');
}

done_testing();
