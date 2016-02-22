# Copyright 2016 KohaSuomi
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

use Modern::Perl;
use Test::More;
use MARC::Record;
use MARC::File::XML;
use Text::Diff;


use C4::Matcher;

use t::lib::TestObjects::BiblioFactory;
use t::lib::TestObjects::MatcherFactory;

my $testContext = {};

my $mergeMatcher = t::lib::TestObjects::MatcherFactory->createTestGroup(
                    {
                        code => 'MERGE_MATCHER',
                        description => 'I merge records before MARC modification templates',
                        threshold => 1000,
                        matchpoints => [
                           {
                              index       => '',
                              score       => 0,
                              components => [{
                                   tag         => '084',
                                   subfields   => '',
                                   offset      => 0,
                                   length      => 0,
                                   norms       => ['preserve'],
                              }]
                           },
                           {
                              index       => '',
                              score       => 0,
                              components => [{
                                   tag         => '245',
                                   subfields   => '',
                                   offset      => 0,
                                   length      => 0,
                                   norms       => ['preserve'],
                              }]
                           },
                           {
                              index       => '',
                              score       => 0,
                              components => [{
                                   tag         => '942',
                                   subfields   => '',
                                   offset      => 0,
                                   length      => 0,
                                   norms       => ['preserve'],
                              }]
                           },
                        ],
                        required_checks => [
                            {
                                source => [{
                                    tag         => '049',
                                    subfields   => 'c',
                                    offset      => 0,
                                    length      => 0,
                                    norms       => ['copy'],
                                }],
                                target => [{
                                    tag         => '521',
                                    subfields   => 'a',
                                    offset      => 0,
                                    length      => 0,
                                    norms       => ['paste'],
                                }],
                            },
                            {
                                source => [{
                                    tag         => '100',
                                    subfields   => 'a',
                                    offset      => 0,
                                    length      => 0,
                                    norms       => ['move'],
                                }],
                                target => [{
                                    tag         => '110',
                                    subfields   => 'a',
                                    offset      => 0,
                                    length      => 0,
                                    norms       => ['paste'],
                                }],
                            },
                            {
                                source => [{
                                    tag         => '100',
                                    subfields   => 'c',
                                    offset      => 0,
                                    length      => 0,
                                    norms       => ['move'],
                                }],
                                target => [{
                                    tag         => '100',
                                    subfields   => 'a',
                                    offset      => 0,
                                    length      => 0,
                                    norms       => ['paste'],
                                }],
                            },
                        ],
                    }
                , undef, $testContext);

my $record = <<RECORD;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">300841</controlfield>
  <controlfield tag="003">VAARA</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">0233982213</subfield>
    <subfield code="q">NID.</subfield>
    <subfield code="z">extra field here</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">85.25</subfield>
    <subfield code="2">ykl</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">THE WISHING TREE /</subfield>
    <subfield code="c">USHA BAHL.</subfield>
  </datafield>
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="c">BK</subfield>
    <subfield code="1">1996-05-01 00:00:00</subfield>
    <subfield code="a">this field is preserved</subfield>
  </datafield>
</record>
RECORD
my $localRecord = t::lib::TestObjects::BiblioFactory->createTestGroup({record => $record}, undef, $testContext);

$record = <<RECORD;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">300841</controlfield>
  <controlfield tag="003">KYYTI</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">0233982214</subfield>
    <subfield code="q">NID.</subfield>
  </datafield>
  <datafield tag="041" ind1="0" ind2=" ">
    <subfield code="a">eng</subfield>
    <subfield code="b">vie</subfield>
  </datafield>
  <datafield tag="049" ind1=" " ind2=" ">
    <subfield code="c">this is copied to 521a</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">08.55</subfield>
    <subfield code="b">extra subfields added, even if old ones are preserved</subfield>
  </datafield>
  <datafield tag="100" ind1=" " ind2=" ">
    <subfield code="a">this is moved to 110a</subfield>
    <subfield code="c">this is moved to 100a</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">original title is preserved/</subfield>
  </datafield>
</record>
RECORD
my $remoteRecord = t::lib::TestObjects::BiblioFactory->createTestGroup({record => $record}, undef, $testContext);

$record = <<RECORD;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">300841</controlfield>
  <controlfield tag="003">KYYTI</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">0233982214</subfield>
    <subfield code="q">NID.</subfield>
  </datafield>
  <datafield tag="041" ind1="0" ind2=" ">
    <subfield code="a">eng</subfield>
    <subfield code="b">vie</subfield>
  </datafield>
  <datafield tag="049" ind1=" " ind2=" ">
    <subfield code="c">this is copied to 521a</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">85.25</subfield>
    <subfield code="2">ykl</subfield>
    <subfield code="b">extra subfields added, even if old ones are preserved</subfield>
  </datafield>
  <datafield tag="100" ind1=" " ind2=" ">
    <subfield code="a">this is moved to 100a</subfield>
  </datafield>
  <datafield tag="110" ind1=" " ind2=" ">
    <subfield code="a">this is moved to 110a</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">THE WISHING TREE /</subfield>
    <subfield code="c">USHA BAHL.</subfield>
  </datafield>
  <datafield tag="521" ind1=" " ind2=" ">
    <subfield code="a">this is copied to 521a</subfield>
  </datafield>
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="c">BK</subfield>
    <subfield code="1">1996-05-01 00:00:00</subfield>
    <subfield code="a">this field is preserved</subfield>
  </datafield>
</record>
RECORD
my $expectedRecord = t::lib::TestObjects::BiblioFactory->createTestGroup({record => $record}, undef, $testContext);

my $mergedRecord = $remoteRecord->clone();
$mergeMatcher->overlayRecord($localRecord, $mergedRecord);

my $mergedXML = $mergedRecord->as_xml_record('MARC21');
my $expectedXML = $expectedRecord->as_xml_record('MARC21');
my $diff = Text::Diff::diff(\$mergedXML, \$expectedXML);


is($mergedRecord->field('001')->data(),
   '300841',
   '001 overlaid');
is($mergedRecord->field('003')->data(),
   'KYYTI',
   '003 overlaid');
is($mergedRecord->subfield('020', 'a'),
   '0233982214',
   '020 overlaid');
is($mergedRecord->subfield('041', 'a'),
   'eng',
   '041 eng added');
is($mergedRecord->subfield('041', 'b'),
   'vie',
   '041 vie added');
is($mergedRecord->subfield('049', 'c'),
   'this is copied to 521a',
   '049c copied so it still exists');
is($mergedRecord->subfield('084', 'a'),
   '85.25',
   '084 preserved');
is($mergedRecord->subfield('084', 'b'),
   'extra subfields added, even if old ones are preserved',
   '084 preserved from extra columns');
is($mergedRecord->subfield('100', 'a'),
   'this is moved to 100a',
   '100c moved to 100a');
is($mergedRecord->subfield('110', 'a'),
   'this is moved to 110a',
   '100a moved to 110a');
is($mergedRecord->subfield('245', 'a'),
   'THE WISHING TREE /',
   '245a preserved');
is($mergedRecord->subfield('521', 'a'),
   'this is copied to 521a',
   '049c copied to 521a');
is($mergedRecord->subfield('942', 'a'),
   'this field is preserved',
   '942 preserved');

t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);

done_testing();