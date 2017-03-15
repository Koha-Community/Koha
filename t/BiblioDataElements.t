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


use Koha::BiblioDataElement;

###############################################################################
#### SETTING THE TEST CONTEXT #################################################
###############################################################################
my ($recordPriFin, $recordPriSwe, $recordPriFinEasy, $recordPriOther);
my ($bdePriFin, $bdePriSwe, $bdePriFinEasy, $bdePriOther);
#This record has primary language of 'fin'
$recordPriFin = <<RECORD;
<record>
  <leader>01324cam a22003494a 4500</leader>
  <controlfield tag="001">301090</controlfield>
  <controlfield tag="003">BTJ03</controlfield>
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
    <subfield code="c">KI</subfield>
    <subfield code="1">2015-07-22T12:59:41</subfield>
    <subfield code="2">ykl</subfield>
  </datafield>
</record>
RECORD
$recordPriFin = MARC::Record::new_from_xml( $recordPriFin, "utf8", 'marc21' );

$recordPriSwe = <<RECORD;
<record>
  <leader>01096cam a22003134i 4500</leader>
  <controlfield tag="001">4312727</controlfield>
  <controlfield tag="003">FI-BTJ</controlfield>
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
    <subfield code="c">KI</subfield>
    <subfield code="1">2016-02-15T15:03:05</subfield>
  </datafield>
</record>
RECORD
$recordPriSwe = MARC::Record::new_from_xml( $recordPriSwe, "utf8", 'marc21' );

$recordPriFinEasy = <<RECORD;
<record>
  <leader>00618cam a22002294a 4500</leader>
  <controlfield tag="001">21937</controlfield>
  <controlfield tag="003">LIPER</controlfield>
  <controlfield tag="005">20150216234350.0</controlfield>
  <controlfield tag="008">820317s1981    fi |||||||||| ||||p|fin|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">9510108340</subfield>
    <subfield code="q">NID.</subfield>
    <subfield code="c">7.74 EUR</subfield>
  </datafield>
  <datafield tag="041" ind1="0" ind2=" ">
    <subfield code="a">fin</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">82.2</subfield>
    <subfield code="2">ykl</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="0">
    <subfield code="a">TYRANNIT VOIVAT HYVIN :</subfield>
    <subfield code="b">RUNOJA /</subfield>
    <subfield code="c">AKI LUOSTARINEN.</subfield>
  </datafield>
  <datafield tag="942" ind1=" " ind2=" ">
    <subfield code="c">KI</subfield>
    <subfield code="1">2002-11-30 00:00:00</subfield>
  </datafield>
</record>
RECORD
$recordPriFinEasy = MARC::Record::new_from_xml( $recordPriFinEasy, "utf8", 'marc21' );

$recordPriOther = <<RECORD;
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">300841</controlfield>
  <controlfield tag="003">JOKUN</controlfield>
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
    <subfield code="c">KI</subfield>
    <subfield code="1">1996-05-01 00:00:00</subfield>
  </datafield>
</record>
RECORD
$recordPriOther = MARC::Record::new_from_xml( $recordPriOther, "utf8", 'marc21' );



###############################################################################
#### TESTING CONTEXT ##########################################################
###############################################################################



subtest "Languages extraction" => \&languagesExtraction;
sub languagesExtraction {
    eval {
    my ($bde);

    $bde = {dbi => 1};
    Koha::BiblioDataElement::setLanguages($bde, $recordPriFin);
    is($bde->{primary_language}, 'fin', "Primary language fin");
    is($bde->{languages}, 'a:fin,a:swe,h:eng', "Languages ok");

    $bde = {dbi => 1};
    Koha::BiblioDataElement::setLanguages($bde, $recordPriSwe);
    is($bde->{primary_language}, 'swe', "Primary language swe");
    is($bde->{languages}, 'a:lat,a:swe,a:eng', "Languages ok");

    $bde = {dbi => 1};
    Koha::BiblioDataElement::setLanguages($bde, $recordPriFinEasy);
    is($bde->{primary_language}, 'fin', "Primary language fin, simple case");
    is($bde->{languages}, 'a:fin', "Languages ok");

    $bde = {dbi => 1};
    Koha::BiblioDataElement::setLanguages($bde, $recordPriOther);
    is($bde->{primary_language}, 'eng', "Primary language eng, no fin or swe, so defaulting to first 041\$a");
    is($bde->{languages}, 'a:eng,a:vie', "Languages ok");

    };
    if ($@) {
        ok(0, $@);
    }
}

done_testing();