#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 7;
BEGIN {
    use_ok('C4::Charset');
}

my $octets = "abc";
ok(IsStringUTF8ish($octets), "verify octets are valid UTF-8 (ASCII)");

$octets = "flamb\c3\a9";
ok(!utf8::is_utf8($octets), "verify that string does not have Perl UTF-8 flag on");
ok(IsStringUTF8ish($octets), "verify octets are valid UTF-8 (LATIN SMALL LETTER E WITH ACUTE)");
ok(!utf8::is_utf8($octets), "verify that IsStringUTF8ish does not magically turn Perl UTF-8 flag on");

$octets = "a\xc2" . "c";
ok(!IsStringUTF8ish($octets), "verify octets are not valid UTF-8");

ok(!SetUTF8Flag(), 'Testing SetUTF8Flag' );
