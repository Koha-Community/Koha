#!/usr/bin/perl
#
use strict;
use warnings;

use Test::More tests => 22;

BEGIN {
        use_ok('C4::Biblio');
}

# test returns if undef record passed
# carp messages appear on stdout

my @arr = AddBiblio(undef, q{});
my $elements = @arr;

is($elements, 0, 'Add Biblio returns empty array for undef record');

my $ret = ModBiblio(undef, 0, '');

is( $ret, 0, 'ModBiblio returns zero if not passed rec');

$ret = BiblioAutoLink(undef, q{});

is( $ret, 0, 'BiblioAutoLink returns zero if not passed rec');

$ret = GetRecordValue('100', undef, q{});
ok( !defined $ret, 'GetRecordValue returns undef if not passed rec');

@arr = LinkBibHeadingsToAuthorities(q{}, q{});
is($arr[0], 0, 'LinkBibHeadingsToAuthorities correct error return');

$ret = GetCOinSBiblio();
ok( !defined $ret, 'GetCOinSBiblio returns undef if not passed rec');

$ret = GetMarcPrice(undef, 'MARC21');
ok( !defined $ret, 'GetMarcPrice returns undef if not passed rec');

$ret = GetMarcQuantity(undef, 'MARC21');
ok( !defined $ret, 'GetMarcQuantity returns undef if not passed rec');

$ret = GetMarcControlnumber();
ok( !defined $ret, 'GetMarcControlnumber returns undef if not passed rec');

$ret = GetMarcISBN();
ok( !defined $ret, 'GetMarcISBN returns undef if not passed rec');

$ret = GetMarcISSN();
ok( !defined $ret, 'GetMarcISSN returns undef if not passed rec');

$ret = GetMarcNotes();
ok( !defined $ret, 'GetMarcNotes returns undef if not passed rec');

$ret = GetMarcSubjects();
ok( !defined $ret, 'GetMarcSubjects returns undef if not passed rec');

$ret = GetMarcAuthors();
ok( !defined $ret, 'GetMarcAuthors returns undef if not passed rec');

$ret = GetMarcUrls();
ok( !defined $ret, 'GetMarcUrls returns undef if not passed rec');

$ret = GetMarcSeries();
ok( !defined $ret, 'GetMarcSeries returns undef if not passed rec');

$ret = GetMarcHosts();
ok( !defined $ret, 'GetMarcHosts returns undef if not passed rec');

my $hash_ref = TransformMarcToKoha(undef, undef);

isa_ok( $hash_ref, 'HASH');

$elements = keys %{$hash_ref};

is($elements, 0, 'Empty hashref returned for undefined record in TransformMarcToKoha');

$ret = ModBiblioMarc();
ok( !defined $ret, 'ModBiblioMarc returns undef if not passed rec');

$ret = RemoveAllNsb();
ok( !defined $ret, 'RemoveAllNsb returns undef if not passed rec');
