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

use Test::More tests => 42;
use Test::Warn;

BEGIN {
        use_ok('C4::Biblio');
}

my @arr;
my $ret;

warning_is { @arr = AddBiblio(undef, q{}) }
           { carped => 'AddBiblio called with undefined record'},
           "AddBiblio returns carped warning on undef record";

my $elements = @arr;

is($elements, 0, 'Add Biblio returns empty array for undef record');

warning_is { $ret = ModBiblio(undef, 0, '') }
           { carped => 'No record passed to ModBiblio'},
           "ModBiblio returns carped warning on undef record";

is( $ret, 0, 'ModBiblio returns zero if not passed rec');

warning_is { $ret = BiblioAutoLink(undef, q{}) }
           { carped => 'Undefined record passed to BiblioAutoLink'},
           "BiblioAutoLink returns carped warning on undef record";

is( $ret, 0, 'BiblioAutoLink returns zero if not passed rec');

warning_is { $ret = GetRecordValue('100', undef, q{}) }
           { carped => 'GetRecordValue called with undefined record'},
           "GetRecordValue returns carped warning on undef record";

ok( !defined $ret, 'GetRecordValue returns undef if not passed rec');

warning_is { @arr = LinkBibHeadingsToAuthorities(q{}, q{}) }
           { carped => 'LinkBibHeadingsToAuthorities called on undefined bib record'},
           "LinkBibHeadingsToAuthorities returns carped warning on undef record";

is($arr[0], 0, 'LinkBibHeadingsToAuthorities correct error return');

warning_is { $ret = GetCOinSBiblio() }
           { carped => 'GetCOinSBiblio called with undefined record'},
           "GetCOinSBiblio returns carped warning on undef record";

ok( !defined $ret, 'GetCOinSBiblio returns undef if not passed rec');

warning_is { $ret = GetMarcPrice(undef, 'MARC21') }
           { carped => 'GetMarcPrice called on undefined record'},
           "GetMarcPrice returns carped warning on undef record";

ok( !defined $ret, 'GetMarcPrice returns undef if not passed rec');

warning_is { $ret = GetMarcQuantity(undef, 'MARC21') }
           { carped => 'GetMarcQuantity called on undefined record'},
           "GetMarcQuantity returns carped warning on undef record";

ok( !defined $ret, 'GetMarcQuantity returns undef if not passed rec');

warning_is { $ret = GetMarcControlnumber() }
           { carped => 'GetMarcControlnumber called on undefined record'},
           "GetMarcControlnumber returns carped warning on undef record";

ok( !defined $ret, 'GetMarcControlnumber returns undef if not passed rec');

warning_is { $ret = GetMarcISBN() }
           { carped => 'GetMarcISBN called on undefined record'},
           "GetMarcISBN returns carped warning on undef record";

ok( !defined $ret, 'GetMarcISBN returns undef if not passed rec');

warning_is { $ret = GetMarcISSN() }
           { carped => 'GetMarcISSN called on undefined record'},
           "GetMarcISSN returns carped warning on undef record";

ok( !defined $ret, 'GetMarcISSN returns undef if not passed rec');

warning_is { $ret = GetMarcNotes() }
           { carped => 'GetMarcNotes called on undefined record'},
           "GetMarcNotes returns carped warning on undef record";

ok( !defined $ret, 'GetMarcNotes returns undef if not passed rec');

warning_is { $ret = GetMarcSubjects() }
           { carped => 'GetMarcSubjects called on undefined record'},
           "GetMarcSubjects returns carped warning on undef record";

ok( !defined $ret, 'GetMarcSubjects returns undef if not passed rec');

warning_is { $ret = GetMarcAuthors() }
           { carped => 'GetMarcAuthors called on undefined record'},
           "GetMarcAuthors returns carped warning on undef record";

ok( !defined $ret, 'GetMarcAuthors returns undef if not passed rec');

warning_is { $ret = GetMarcUrls() }
           { carped => 'GetMarcUrls called on undefined record'},
           "GetMarcUrls returns carped warning on undef record";

ok( !defined $ret, 'GetMarcUrls returns undef if not passed rec');

warning_is { $ret = GetMarcSeries() }
           { carped => 'GetMarcSeries called on undefined record'},
           "GetMarcSeries returns carped warning on undef record";

ok( !defined $ret, 'GetMarcSeries returns undef if not passed rec');

warning_is { $ret = GetMarcHosts() }
           { carped => 'GetMarcHosts called on undefined record'},
           "GetMarcHosts returns carped warning on undef record";

ok( !defined $ret, 'GetMarcHosts returns undef if not passed rec');

my $hash_ref;

warning_is { $hash_ref = TransformMarcToKoha(undef, undef) }
           { carped => 'TransformMarcToKoha called with undefined record'},
           "TransformMarcToKoha returns carped warning on undef record";

isa_ok( $hash_ref, 'HASH');

$elements = keys %{$hash_ref};

is($elements, 0, 'Empty hashref returned for undefined record in TransformMarcToKoha');

warning_is { $ret = ModBiblioMarc() }
           { carped => 'ModBiblioMarc passed an undefined record'},
           "ModBiblioMarc returns carped warning on undef record";

ok( !defined $ret, 'ModBiblioMarc returns undef if not passed rec');

warning_is { $ret = RemoveAllNsb() }
           { carped => 'RemoveAllNsb called with undefined record'},
           "RemoveAllNsb returns carped warning on undef record";

ok( !defined $ret, 'RemoveAllNsb returns undef if not passed rec');

1;
