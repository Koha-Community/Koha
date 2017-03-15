package t::db_dependent::Koha::BiblioDataElements;

use Modern::Perl;

use t::lib::TestObjects::BiblioFactory;
use t::lib::TestObjects::ObjectFactory;



sub context {
my @testContexts = @_;
my $records = [];
push(@$records, <<RECORD);
<record>
  <leader>00000cam a22000004c 4500</leader>
  <controlfield tag="001">BDE-tester-1</controlfield>
  <controlfield tag="003">BDE</controlfield>
  <controlfield tag="008">       1988    xxk|||||||||| ||||1|eng|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">BDE-tester-1</subfield>
  </datafield>
  <datafield tag="041" ind1=" " ind2=" ">
    <subfield code="a">swe</subfield>
    <subfield code="a">eng</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">84.4</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">BDE tester 1</subfield>
  </datafield>
  <datafield tag="942" ind1="1" ind2="4">
    <subfield code="c">BK</subfield>
  </datafield>
</record>
RECORD
push(@$records, <<RECORD);
<record>
  <leader>00000cam a2200000zc 4500</leader>
  <controlfield tag="001">BDE-tester-2</controlfield>
  <controlfield tag="003">BDE</controlfield>
  <controlfield tag="008">       1988    xxk|||||||||| ||||1|eng|c</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">BDE-tester-2</subfield>
  </datafield>
  <datafield tag="041" ind1=" " ind2=" ">
    <subfield code="a">swe</subfield>
    <subfield code="a">fin</subfield>
    <subfield code="a">eng</subfield>
  </datafield>
  <datafield tag="084" ind1=" " ind2=" ">
    <subfield code="a">78.8</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">BDE tester 2</subfield>
  </datafield>
  <datafield tag="942" ind1="1" ind2="4">
    <subfield code="c">AL</subfield>
  </datafield>
</record>
RECORD
return t::lib::TestObjects::BiblioFactory->createTestGroup($records, undef, @testContexts);
}


1;
