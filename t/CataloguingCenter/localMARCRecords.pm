package t::CataloguingCenter::localMARCRecords;
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

    #This record has primary language of 'fin'
    $record = <<RECORD;
<record>
  <leader>01324cam a22003494a 4500</leader>
  <controlfield tag="001">301090</controlfield>
  <controlfield tag="003">VAARA</controlfield>
  <controlfield tag="005">20150728152229.0</controlfield>
  <controlfield tag="007">ta</controlfield>
  <controlfield tag="008">130619s2013    fi ||||j|dd   ||||0|fin|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">9789522402257</subfield>
    <subfield code="q">nid.</subfield>
    <subfield code="c">13,10 EUR</subfield>
  </datafield>
  <datafield tag="041" ind1="1" ind2=" ">
    <subfield code="a">fin</subfield>
    <subfield code="a">swe</subfield>
    <subfield code="h">eng</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">89.31038</subfield>
    <subfield code="2">ykl</subfield>
  </datafield>
  <datafield tag="100" ind1="1" ind2=" ">
    <subfield code="a">Amery, Heather.</subfield>
    <subfield code="9">7066</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="0">
    <subfield code="a">Tuhat sanaa ruotsiksi /</subfield>
    <subfield code="c">Heather Amery ; kuvitus: Stephen Cartwright ; [suomentanut Nina Tarvainen].</subfield>
  </datafield>
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="c">BK</subfield>
    <subfield code="1">2015-07-22T12:59:41</subfield>
    <subfield code="2">ykl</subfield>
  </datafield>
</record>
RECORD
    push(@records, {record => $record});

    $record = <<RECORD;
<record>
  <leader>01096cam a22003134i 4500</leader>
  <controlfield tag="001">4312727</controlfield>
  <controlfield tag="003">LUMME</controlfield>
  <controlfield tag="005">20160215150305.0</controlfield>
  <controlfield tag="007">ta</controlfield>
  <controlfield tag="008">160202s2016    fi ||||  d   |00| 0|fin|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">9789516566729</subfield>
    <subfield code="q">sid.</subfield>
    <subfield code="c">23.00</subfield>
  </datafield>
  <datafield tag="041" ind1="0" ind2=" ">
    <subfield code="a">lat</subfield>
    <subfield code="a">swe</subfield>
    <subfield code="a">eng</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">59.038</subfield>
    <subfield code="2">ykl</subfield>
  </datafield>
  <datafield tag="245" ind1="0" ind2="0">
    <subfield code="a">Lääketieteen termit :</subfield>
    <subfield code="b">sanastot: latina, englanti, ruotsi /</subfield>
    <subfield code="c">toimitus: Veijo Saano, päätoimittaja ... [et al.] ; toimituskunta: Tero Kivelä ... [et al.] ; Tom Pettersson, ruotsinkieliset termit.</subfield>
  </datafield>
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="2">ykl</subfield>
    <subfield code="c">BK</subfield>
    <subfield code="1">2016-02-15T15:03:05</subfield>
  </datafield>
</record>
RECORD
    push(@records, {record => $record});

    $record = <<RECORD;
<record>
  <leader>00618cam a22002294a 4500</leader>
  <controlfield tag="001">21937</controlfield>
  <controlfield tag="003">OUTI</controlfield>
  <controlfield tag="005">20150216234350.0</controlfield>
  <controlfield tag="008">820317s1981    fi |||||||||| ||||p|fin|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">9510108340</subfield>
    <subfield code="q">NID.</subfield>
    <subfield code="c">7.74 EUR</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="0">
    <subfield code="a">TYRANNIT VOIVAT HYVIN :</subfield>
    <subfield code="b">RUNOJA /</subfield>
    <subfield code="c">AKI LUOSTARINEN.</subfield>
  </datafield>
</record>
RECORD
    push(@records, {record => $record});

    $record = <<RECORD;
<record>
  <leader>00618cam a22002294a 4500</leader>
  <controlfield tag="001">21937</controlfield>
  <controlfield tag="003">OUTI</controlfield>
  <controlfield tag="005">20150216234350.0</controlfield>
  <controlfield tag="008">820317s1981    fi |||||||||| ||||p|fin|c</controlfield>
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
</record>
RECORD
    push(@records, {record => $record});

    $record = <<RECORD;
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
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="c">BK</subfield>
    <subfield code="1">1996-05-01 00:00:00</subfield>
  </datafield>
</record>
RECORD
    push(@records, {record => $record});

    return t::lib::TestObjects::BiblioFactory->createTestGroup(\@records, undef, $testContext);
} #EO prepareContext()



sub createCNI_and_isbn {
    my ($testContext) = @_;
    my ($record, @records);

    $record = <<RECORD;
<record>
  <leader>01324cam a22003494a 4500</leader>
  <controlfield tag="001">13371337</controlfield>
  <controlfield tag="003">CNI-TEST</controlfield>
  <controlfield tag="008">130619s2013    fi ||||j|dd   ||||0|fin|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">-just-a-unique-id-</subfield>
  </datafield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">thiz-isbn-doeznt-match</subfield>
    <subfield code="1">Used to to test multi-ISBN record searching</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="0">
    <subfield code="a">Tuhat sanaa ruotsiksi</subfield>
  </datafield>
</record>
RECORD
    push(@records, {record => $record});

    $record = <<RECORD;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">this-must-not-match</controlfield>
  <controlfield tag="003">KYYTI</controlfield>
  <controlfield tag="008">       1988    xxk|||||||||| ||||1|eng|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">0233982213</subfield>
    <subfield code="1">Matches testCluster -> batchOverlayContext.pm</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">THE TOIVOMUS PUU</subfield>
  </datafield>
</record>
RECORD
    push(@records, {record => $record});

    return t::lib::TestObjects::BiblioFactory->createTestGroup(\@records, undef, $testContext);
} #EO prepareContext()



sub create_isbn_strangers {
    my ($testContext) = @_;
    my ($record, @records);

    $record = <<RECORD;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">this-must-not-match</controlfield>
  <controlfield tag="003">KYYTI</controlfield>
  <controlfield tag="008">       1988    xxk|||||||||| ||||1|eng|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">i-dont-exist-in-remote-1111</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">THE TOIVOMUS PUU</subfield>
  </datafield>
</record>
RECORD
    push(@records, {record => $record});

    $record = <<RECORD;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">this-must-not-match</controlfield>
  <controlfield tag="003">KYYTI</controlfield>
  <controlfield tag="008">       1988    xxk|||||||||| ||||1|eng|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">i-dont-exist-in-remote-2222</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">THE TOIVOMUS PUU 2</subfield>
  </datafield>
</record>
RECORD
    push(@records, {record => $record});

    return t::lib::TestObjects::BiblioFactory->createTestGroup(\@records, undef, $testContext);
} #EO prepareContext()



sub create_host_record {
    my ($testContext) = @_;
    my ($record, @records);

    $record = <<RECORD;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">host-record</controlfield>
  <controlfield tag="003">HOST-RECORD</controlfield>
  <controlfield tag="008">       1988    xxk|||||||||| ||||1|eng|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">host-record-isbn</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">Host recordzzz</subfield>
  </datafield>
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="c">BK</subfield>
  </datafield>
  <datafield tag="999" ind1=" " ind2=" ">
    <subfield code="b">BOOKS</subfield>
  </datafield>
</record>
RECORD
    push(@records, {record => $record});

    return t::lib::TestObjects::BiblioFactory->createTestGroup(\@records, undef, $testContext);
} #EO prepareContext()



sub create_lowlyRecords {
    my ($testContext) = @_;
    my ($record, @records);

    #We use 0 instead of '#' because otherwise Zebra throws "" CCL parsing error (10014) Single character mask not supported ZOOM for query: rcn='lowly-#-0' and cni='lowlyRecordTest' at C4/Search.pm line 276. ""
    #We don't need '#' here, only the lowly catalogued levels
    my @encLevels = ('0', '1', '2', '3', '4', '5', '5', '5', '6', '6', '6', '7', '7', '7', '8', '8', '8', 'u', 'u', 'u', 'z', 'z', 'z');
    for (my $i=0 ; $i<scalar(@encLevels) ; $i++) {
        my $encLevel = $encLevels[$i];
        $record = <<RECORD;
<record>
  <leader>00000cam a2200000${encLevel}c 4500</leader>
  <controlfield tag="001">lowly-${encLevel}-$i</controlfield>
  <controlfield tag="003">lowlyRecordTest</controlfield>
  <controlfield tag="008">       1988    xxk|||||||||| ||||1|eng|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">lowly-${encLevel}-$i</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">lowly-${encLevel}-$i</subfield>
  </datafield>
</record>
RECORD
        push(@records, {record => $record});
    }
    return t::lib::TestObjects::BiblioFactory->createTestGroup(\@records, undef, $testContext);
} #EO prepareContext()

1;
