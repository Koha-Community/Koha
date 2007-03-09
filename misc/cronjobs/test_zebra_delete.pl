#!/usr/bin/perl
use C4::Context;
use C4::Biblio;

use strict;

my $Zconn=C4::Context->Zconn('biblioserver', 0, 1);
my $Zpackage = $Zconn->package();
$Zpackage->option(action => 'recordDelete');
$Zpackage->option(record => '<?xml version="1.0" encoding="UTF-8"?>
<record
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/ standards/marcxml/schema/MARC21slim.xsd"
 xmlns="http://www.loc.gov/MARC21/slim">

 <leader>00577    a2200193   4500</leader>
 <controlfield tag="005">19980415162006.0</controlfield>
 <datafield tag="035" ind1=" " ind2=" ">
   <subfield code="a">TOB*M*9074254</subfield>
 </datafield>
 <datafield tag="090" ind1=" " ind2=" ">
   <subfield code="9">8</subfield>
   <subfield code="a">8</subfield>
 </datafield>
 <datafield tag="100" ind1=" " ind2=" ">
   <subfield code="a">19910405d1976       y1frea0103    ba</subfield>
 </datafield>
 <datafield tag="101" ind1="0" ind2=" ">
   <subfield code="a">fre</subfield>
 </datafield>
 <datafield tag="200" ind1="1" ind2=" ">
   <subfield code="a">Lune vole fJacqueline Held, et Claude Held</subfield>
   <subfield code="g">illustrations d\' Yvan Pommaux</subfield>
   <subfield code="b">LIVR</subfield>
 </datafield>
 <datafield tag="210" ind1=" " ind2=" ">
   <subfield code="c">Ecole des loisirs</subfield>
   <subfield code="d">cop. 1976</subfield>
 </datafield>
 <datafield tag="215" ind1=" " ind2=" ">
   <subfield code="a">20p</subfield>
 </datafield>
 <datafield tag="225" ind1="0" ind2=" ">
   <subfield code="a">Chanterime</subfield>
 </datafield>
 <datafield tag="309" ind1=" " ind2=" ">
   <subfield code="a">Migration GEAC</subfield>
 </datafield>
 <datafield tag="700" ind1=" " ind2="1">
   <subfield code="a">Held</subfield>
   <subfield code="b">Jacqueline</subfield>
   <subfield code="9">187392</subfield>
 </datafield>
 <datafield tag="913" ind1="0" ind2="0">
   <subfield code="a">HELLVOL99000</subfield>
 </datafield>
 <datafield tag="949" ind1=" " ind2=" ">
   <subfield code="a">MIRMJE</subfield>
   <subfield code="a">ISTISP</subfield>
 </datafield>
 <datafield tag="995" ind1=" " ind2=" ">
   <subfield code="a">IST</subfield>
   <subfield code="c">IST</subfield>
   <subfield code="f">9991088063</subfield>
   <subfield code="k">P HEL</subfield>
   <subfield code="m">2004-06-22</subfield>
   <subfield code="v">2.9</subfield>
   <subfield code="r">LIVR</subfield>
   <subfield code="s">14</subfield>
   <subfield code="b">J</subfield>
   <subfield code="9">16</subfield>
 </datafield>
</record>');
$Zpackage->send("update");
$Zpackage->send('commit');
$Zpackage->destroy();
$Zconn->destroy();
