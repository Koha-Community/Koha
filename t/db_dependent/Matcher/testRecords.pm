package t::db_dependent::Matcher::testRecords;
#
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

use t::lib::TestObjects::BiblioFactory;

=head IN THIS FILE

Here we create some fully catalogued records to play with

We create three duplicate records and one not duplicate record.
=cut

sub create {
my ($testContext) = @_;
my ($record, @records);

#This record has primary language of 'fin'
$record = <<RECORD;
<record>
  <leader>00597nga a22001817i 4500</leader>
  <controlfield tag="001">duplicate</controlfield>
  <controlfield tag="003">VAARA</controlfield>
  <controlfield tag="005">overwrittenByKoha</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">isbn1</subfield>
  </datafield>
  <datafield tag="245" ind1="0" ind2="0">
    <subfield code="a">Old school song.</subfield>
  </datafield>
  <datafield tag="773" ind1="0" ind2=" ">
    <subfield code="w">4127234</subfield>
  </datafield>
</record>
RECORD
push(@records, {record => $record});

$record = <<RECORD;
<record>
  <leader>00597nga a22001817i 4500</leader>
  <controlfield tag="001">duplicate</controlfield>
  <controlfield tag="003">VAARA</controlfield>
  <controlfield tag="005">overwrittenByKoha</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">isbn2</subfield>
  </datafield>
  <datafield tag="100" ind1=" " ind2=" ">
    <subfield code="a">Author</subfield>
  </datafield>
  <datafield tag="245" ind1="0" ind2="0">
    <subfield code="a">Old school song</subfield>
  </datafield>
  <datafield tag="773" ind1="0" ind2=" ">
    <subfield code="w">4127234</subfield>
  </datafield>
</record>
RECORD
push(@records, {record => $record});

$record = <<RECORD;
<record>
  <leader>00597nga a22001817i 4500</leader>
  <controlfield tag="001">duplicate</controlfield>
  <controlfield tag="003">VAARA</controlfield>
  <controlfield tag="005">overwrittenByKoha</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">isbn3</subfield>
  </datafield>
  <datafield tag="100" ind1=" " ind2=" ">
    <subfield code="a">Author. Mies</subfield>
  </datafield>
  <datafield tag="245" ind1="0" ind2="0">
    <subfield code="a">Old school song :</subfield>
  </datafield>
  <datafield tag="773" ind1="0" ind2=" ">
    <subfield code="w">4127234</subfield>
  </datafield>
</record>
RECORD
push(@records, {record => $record});

$record = <<RECORD;
<record>
  <leader>00597nga a22001817i 4500</leader>
  <controlfield tag="001">not-duplicate</controlfield>
  <controlfield tag="003">KYYTI</controlfield>
  <controlfield tag="005">overwrittenByKoha</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">isbn4</subfield>
  </datafield>
  <datafield tag="100" ind1=" " ind2=" ">
    <subfield code="a">Author</subfield>
  </datafield>
  <datafield tag="245" ind1="0" ind2="0">
    <subfield code="a">Old skoolz</subfield>
  </datafield>
</record>
RECORD
push(@records, {record => $record});

return t::lib::TestObjects::BiblioFactory->createTestGroup(\@records, undef, $testContext);

} #EO prepareContext()

1;
