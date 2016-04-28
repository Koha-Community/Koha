#!/bin/bash/perl

# Copyright (C) 2016 KohaSuomi
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
use Test::More tests => 1;

use C4::Record;



subtest "Koha::Filter::MARC::ISBNTrim", \&MARCISBNTrim;
sub MARCISBNTrim {
    require Koha::Filter::MARC::ISBNTrim;

    my ($error, $record) = C4::Record::marcxml2marc(<<RECORD, undef, 'MARC21');
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">host-record</controlfield>
  <controlfield tag="003">HOST-RECORD</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">978-0-596-52724-2 (nid.)</subfield>
  </datafield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">978 (nid.)</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">Host recordzzz</subfield>
  </datafield>
  <datafield tag="999" ind1=" " ind2=" ">
    <subfield code="c">1337</subfield>
  </datafield>
</record>
RECORD
    $record = Koha::Filter::MARC::ISBNTrim->filter($record);
    my @f020s = $record->field('020');
    is($f020s[0]->subfield('a'), '978-0-596-52724-2', 'ISBN-13 fixed');
    is($f020s[0]->subfield('q'), '(nid.)', '020q populated');
    is($f020s[1]->subfield('a'), '978 (nid.)', 'Bad ISBN remains for manual fixing');
    is($f020s[1]->subfield('q'), undef, '020q no created');


    ($error, $record) = C4::Record::marcxml2marc(<<RECORD, undef, 'MARC21');
<record>
  <leader>00510cam a22002054a 4500</leader>
  <controlfield tag="001">host-record</controlfield>
  <controlfield tag="003">HOST-RECORD</controlfield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">978-0-596-52724-X (nid.)</subfield>
    <subfield code="q">(bug.)</subfield>
  </datafield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">1-56592-257-3 (nid.)</subfield>
  </datafield>
  <datafield tag="020" ind1=" " ind2=" ">
    <subfield code="a">1565922573</subfield>
  </datafield>
  <datafield tag="245" ind1="1" ind2="4">
    <subfield code="a">Host recordzzz</subfield>
  </datafield>
  <datafield tag="999" ind1=" " ind2=" ">
    <subfield code="c">1337</subfield>
  </datafield>
</record>
RECORD
    $record = Koha::Filter::MARC::ISBNTrim->filter($record);
    @f020s = $record->field('020');
    is($f020s[0]->subfield('a'), '978-0-596-52724-X', 'ISBN-13 fixed');
    is($f020s[0]->subfield('q'), '(nid.)', '020q populated');
    is($f020s[1]->subfield('a'), '1-56592-257-3', 'ISBN-10 fixed');
    is($f020s[1]->subfield('q'), '(nid.)', '020q populated');
    is($f020s[2]->subfield('a'), '1565922573', 'ISBN10 unchanged');
    is($f020s[2]->subfield('q'), undef, 'no 020q to create');
}
