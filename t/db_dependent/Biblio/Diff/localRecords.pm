package t::db_dependent::Biblio::Diff::localRecords;
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

=cut

sub create {
my ($testContext) = @_;
my ($record, @records);

$record = <<RECORD;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">300841</controlfield>
  <controlfield tag="003">KYYTI</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">9510108303</subfield>
    <subfield code="q">NID.</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">THE WISHING TREE /</subfield>
    <subfield code="c">USHA BAHL.</subfield>
  </datafield>
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="c">BK</subfield>
    <subfield code="1">1996-05-01 00:00:00</subfield>
  </datafield>
</record>
RECORD
push(@records, {record => $record});

$record = <<RECORD;
<record>
  <leader>00618cam a22002294a 4500</leader>
  <controlfield tag="001">21937</controlfield>
  <controlfield tag="003">OUTI</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">9510108304</subfield>
    <subfield code="q">NID.</subfield>
    <subfield code="c">7.74 EUR</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="0">
    <subfield code="a">TYRANNIT VOIVAT PAREMMIN :</subfield>
    <subfield code="b">RUNOJA /</subfield>
    <subfield code="c">AKI LUOSTARINEN.</subfield>
  </datafield>
  <datafield tag="245" ind1="0" ind2="0">
    <subfield code="a">TYRANNIT VOIVAT PARHAITEN :</subfield>
  </datafield>
</record>
RECORD
push(@records, {record => $record});

$record = <<RECORD;
<record>
  <leader>01096cam a22003134i 4500</leader>
  <controlfield tag="001">4312727</controlfield>
  <controlfield tag="007">ta</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">9510108305</subfield>
  </datafield>
  <datafield tag="041" ind1="0" ind2=" ">
    <subfield code="a">lat</subfield>
    <subfield code="a">swe</subfield>
    <subfield code="a">eng</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="0">
    <subfield code="a">TYRANNIT VOIVAT PAREMMIN :</subfield>
    <subfield code="b">RUNOJA /</subfield>
    <subfield code="c">AKI LUOSTARINEN.</subfield>
  </datafield>
  <datafield tag="952" ind1="1" ind2="0">
    <subfield code="a">CPL</subfield>
    <subfield code="b">CPL</subfield>
  </datafield>
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="2">ykl</subfield>
    <subfield code="c">BK</subfield>
    <subfield code="1">2016-02-15T15:03:05</subfield>
  </datafield>
</record>
RECORD
push(@records, {record => $record});

return t::lib::TestObjects::BiblioFactory->createTestGroup(\@records, undef, $testContext);
}

sub create2 {
my ($testContext) = @_;
my ($record, @records);

$record = <<RECORD;
<record
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
    xmlns="http://www.loc.gov/MARC21/slim">

  <leader>01708cam a2200553zi 4500</leader>
  <controlfield tag="001">000035144</controlfield>
  <controlfield tag="003">FI-MELINDA</controlfield>
  <controlfield tag="005">20160304181804.0</controlfield>
  <controlfield tag="008">820317s1981    fi |||||||||||||||f|fin||</controlfield>
  <datafield tag="015" ind1=" " ind2=" ">
    <subfield code="a">fx37918</subfield>
    <subfield code="2">skl</subfield>
  </datafield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">9510107417</subfield>
    <subfield code="c">43,80 mk</subfield>
    <subfield code="q">sid.</subfield>
  </datafield>
  <datafield tag="035" ind1=" " ind2=" ">
    <subfield code="a">(FI-MELINDA)000035144</subfield>
  </datafield>
  <datafield tag="035" ind1=" " ind2=" ">
    <subfield code="a">(FI-MELINDA)000035144</subfield>
  </datafield>
  <datafield tag="040" ind1=" " ind2=" ">
    <subfield code="a">FI-NL</subfield>
  </datafield>
  <datafield tag="041" ind1="1" ind2=" ">
    <subfield code="a">fin</subfield>
    <subfield code="h">eng</subfield>
  </datafield>
  <datafield tag="042" ind1=" " ind2=" ">
    <subfield code="a">finb</subfield>
  </datafield>
  <datafield tag="072" ind1=" " ind2="7">
    <subfield code="a">87</subfield>
    <subfield code="2">kkaa</subfield>
  </datafield>
  <datafield tag="080" ind1=" " ind2=" ">
    <subfield code="a">820</subfield>
    <subfield code="x">-3</subfield>
  </datafield>
  <datafield tag="082" ind1="1" ind2="4">
    <subfield code="a">84.5</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">84.2</subfield>
    <subfield code="2">ykl</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">84.2</subfield>
    <subfield code="2">ykl</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">84.5</subfield>
    <subfield code="2">ykl</subfield>
  </datafield>
  <datafield tag="100" ind1="1" ind2=" ">
    <subfield code="a">Doyle, Arthur Conan.</subfield>
  </datafield>
  <datafield tag="240" ind1="1" ind2="4">
    <subfield code="a">The hound of the Baskervilles</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="0">
    <subfield code="a">Baskervillen koira /</subfield>
    <subfield code="c">Arthur Conan Doyle.</subfield>
  </datafield>
  <datafield tag="250" ind1=" " ind2=" ">
    <subfield code="a">10. p.</subfield>
  </datafield>
  <datafield tag="260" ind1=" " ind2=" ">
    <subfield code="a">Porvoo ;</subfield>
    <subfield code="a">Hki ;</subfield>
    <subfield code="a">Juva :</subfield>
    <subfield code="b">WSOY,</subfield>
    <subfield code="c">1981</subfield>
    <subfield code="e">(Porvoo)</subfield>
  </datafield>
  <datafield tag="300" ind1=" " ind2=" ">
    <subfield code="a">159, [1] s. ;</subfield>
    <subfield code="c">21 cm.</subfield>
  </datafield>
  <datafield tag="336" ind1=" " ind2=" ">
    <subfield code="a">Teksti</subfield>
  </datafield>
  <datafield tag="337" ind1=" " ind2=" ">
    <subfield code="a">ei välittävää laitetta</subfield>
  </datafield>
  <datafield tag="490" ind1="1" ind2=" ">
    <subfield code="a">Koulun peruskirjasto;</subfield>
    <subfield code="v">22</subfield>
  </datafield>
  <datafield tag="500" ind1=" " ind2=" ">
    <subfield code="a">9. p. 1972.</subfield>
  </datafield>
  <datafield tag="500" ind1=" " ind2=" ">
    <subfield code="a">Korjattu suomennos.</subfield>
  </datafield>
  <datafield tag="500" ind1=" " ind2=" ">
    <subfield code="a">Lisäpainokset: 11. p. 1983.</subfield>
  </datafield>
  <datafield tag="500" ind1=" " ind2=" ">
    <subfield code="a">Luokkataso: yläkoulu.</subfield>
  </datafield>
  <datafield tag="500" ind1=" " ind2=" ">
    <subfield code="a">9. P. 1972. - KORJATTU SUOMENNOS</subfield>
  </datafield>
  <datafield tag="500" ind1=" " ind2=" ">
    <subfield code="a">11. P. 1983</subfield>
  </datafield>
  <datafield tag="600" ind1="1" ind2="4">
    <subfield code="a">Holmes, Sherlock,</subfield>
    <subfield code="c">fikt.</subfield>
  </datafield>
  <datafield tag="600" ind1="1" ind2="4">
    <subfield code="a">Watson, John H.,</subfield>
    <subfield code="c">fikt.</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">kaunokirjallisuus</subfield>
    <subfield code="x">suomenkielinen kirjallisuus</subfield>
    <subfield code="2">ysa</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">kriminalfiktion</subfield>
    <subfield code="x">översättningar</subfield>
    <subfield code="x">finska</subfield>
    <subfield code="x">engelska</subfield>
    <subfield code="2">bella</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">rikoskirjallisuus</subfield>
    <subfield code="x">käännökset</subfield>
    <subfield code="x">suomen kieli</subfield>
    <subfield code="x">englannin kieli</subfield>
    <subfield code="2">kaunokki</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">salapoliisikirjallisuus</subfield>
    <subfield code="z">Englanti</subfield>
    <subfield code="y">1800-luku</subfield>
    <subfield code="2">kaunokki</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">aateli</subfield>
    <subfield code="2">kaunokki</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">maaseutu</subfield>
    <subfield code="2">kaunokki</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">kummittelu</subfield>
    <subfield code="2">kaunokki</subfield>
  </datafield>
  <datafield tag="830" ind1=" " ind2="0">
    <subfield code="a">Koulun peruskirjasto;</subfield>
    <subfield code="v">22</subfield>
  </datafield>
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="2">ykl</subfield>
    <subfield code="c">BR</subfield>
  </datafield>
</record>
RECORD
push(@records, {record => $record});

$record = <<RECORD;
<record
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
    xmlns="http://www.loc.gov/MARC21/slim">

  <leader>01708cam a2200553zi 4500</leader>
  <controlfield tag="001">000035144</controlfield>
  <controlfield tag="003">FI-MELINDA</controlfield>
  <controlfield tag="005">20160304181804.0</controlfield>
  <controlfield tag="008">820317s1981    fi |||||||||||||||f|fin||</controlfield>
  <datafield tag="015" ind1=" " ind2=" ">
    <subfield code="a">fx37918</subfield>
    <subfield code="2">skl</subfield>
  </datafield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">9510107418</subfield>
    <subfield code="c">43,80 mk</subfield>
    <subfield code="q">sid.</subfield>
  </datafield>
  <datafield tag="035" ind1=" " ind2=" ">
    <subfield code="a">(FI-MELINDA)000035144</subfield>
  </datafield>
  <datafield tag="035" ind1=" " ind2=" ">
    <subfield code="a">(FI-MELINDA)000035144</subfield>
  </datafield>
  <datafield tag="040" ind1=" " ind2=" ">
    <subfield code="a">FI-NL</subfield>
  </datafield>
  <datafield tag="041" ind1="1" ind2=" ">
    <subfield code="a">fin</subfield>
    <subfield code="h">eng</subfield>
  </datafield>
  <datafield tag="042" ind1=" " ind2=" ">
    <subfield code="a">finb</subfield>
  </datafield>
  <datafield tag="072" ind1=" " ind2="7">
    <subfield code="a">87</subfield>
    <subfield code="2">kkaa</subfield>
  </datafield>
  <datafield tag="080" ind1=" " ind2=" ">
    <subfield code="a">820</subfield>
    <subfield code="x">-3</subfield>
  </datafield>
  <datafield tag="082" ind1="1" ind2="4">
    <subfield code="a">84.5</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">84.2</subfield>
    <subfield code="2">ykl</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">84.2</subfield>
    <subfield code="2">ykl</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">84.5</subfield>
    <subfield code="2">ykl</subfield>
  </datafield>
  <datafield tag="100" ind1="1" ind2=" ">
    <subfield code="a">Doyle, Arthur Conan.</subfield>
  </datafield>
  <datafield tag="240" ind1="1" ind2="4">
    <subfield code="a">The hound of the Baskervilles</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="0">
    <subfield code="a">Baskervillen koira /</subfield>
    <subfield code="c">Arthur Conan Doyle.</subfield>
  </datafield>
  <datafield tag="250" ind1=" " ind2=" ">
    <subfield code="a">10. p.</subfield>
  </datafield>
  <datafield tag="260" ind1=" " ind2=" ">
    <subfield code="a">Porvoo ;</subfield>
    <subfield code="a">Hki ;</subfield>
    <subfield code="a">Juva :</subfield>
    <subfield code="b">WSOY,</subfield>
    <subfield code="c">1981</subfield>
    <subfield code="e">(Porvoo)</subfield>
  </datafield>
  <datafield tag="300" ind1=" " ind2=" ">
    <subfield code="a">159, [1] s. ;</subfield>
    <subfield code="c">21 cm.</subfield>
  </datafield>
  <datafield tag="336" ind1=" " ind2=" ">
    <subfield code="a">Teksti</subfield>
  </datafield>
  <datafield tag="337" ind1=" " ind2=" ">
    <subfield code="a">ei välittävää laitetta</subfield>
  </datafield>
  <datafield tag="490" ind1="1" ind2=" ">
    <subfield code="a">Koulun peruskirjasto;</subfield>
    <subfield code="v">22</subfield>
  </datafield>
  <datafield tag="500" ind1=" " ind2=" ">
    <subfield code="a">9. p. 1972.</subfield>
  </datafield>
  <datafield tag="500" ind1=" " ind2=" ">
    <subfield code="a">Korjattu suomennos.</subfield>
  </datafield>
  <datafield tag="500" ind1=" " ind2=" ">
    <subfield code="a">Lisäpainokset: 11. p. 1983.</subfield>
  </datafield>
  <datafield tag="500" ind1=" " ind2=" ">
    <subfield code="a">Luokkataso: yläkoulu.</subfield>
  </datafield>
  <datafield tag="500" ind1=" " ind2=" ">
    <subfield code="a">9. P. 1972. - KORJATTU SUOMENNOS</subfield>
  </datafield>
  <datafield tag="500" ind1=" " ind2=" ">
    <subfield code="a">11. P. 1983</subfield>
  </datafield>
  <datafield tag="600" ind1="1" ind2="4">
    <subfield code="a">Holmes, Sherlock,</subfield>
    <subfield code="c">fikt.</subfield>
  </datafield>
  <datafield tag="600" ind1="1" ind2="4">
    <subfield code="a">Watson, John H.,</subfield>
    <subfield code="c">fikt.</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">kaunokirjallisuus</subfield>
    <subfield code="x">suomenkielinen kirjallisuus</subfield>
    <subfield code="2">ysa</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">kriminalfiktion</subfield>
    <subfield code="x">översättningar</subfield>
    <subfield code="x">finska</subfield>
    <subfield code="x">engelska</subfield>
    <subfield code="2">bella</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">rikoskirjallisuus</subfield>
    <subfield code="x">käännökset</subfield>
    <subfield code="x">suomen kieli</subfield>
    <subfield code="x">englannin kieli</subfield>
    <subfield code="2">kaunokki</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">salapoliisikirjallisuus</subfield>
    <subfield code="z">Englanti</subfield>
    <subfield code="y">1800-luku</subfield>
    <subfield code="2">kaunokki</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">aateli</subfield>
    <subfield code="2">kaunokki</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">maaseutu</subfield>
    <subfield code="2">kaunokki</subfield>
  </datafield>
  <datafield tag="650" ind1=" " ind2="7">
    <subfield code="a">kummittelu</subfield>
    <subfield code="2">kaunokki</subfield>
  </datafield>
  <datafield tag="830" ind1=" " ind2="0">
    <subfield code="a">Koulun peruskirjasto;</subfield>
    <subfield code="v">22</subfield>
  </datafield>
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="2">ykl</subfield>
    <subfield code="c">BR</subfield>
  </datafield>
</record>
RECORD
push(@records, {record => $record});

return t::lib::TestObjects::BiblioFactory->createTestGroup(\@records, undef, $testContext);
}
1;
