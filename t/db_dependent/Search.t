#!/usr/bin/perl
#
# This Koha test module is a stub!
# Add more tests here!!!

use strict;
use warnings;
use YAML;

use C4::Debug;
use C4::Context;
use C4::Search;

use Test::More tests => 3;

BEGIN {
    use_ok('C4::Search');
}
foreach my $string ("Leçon","mod\xc3\xa8les"){
my @results=C4::Search::_remove_stopwords($string,"kw");
$debug && warn "$string ",Dump(@results);
ok($results[0] eq $string,"$string is not modified");
}
foreach my $string ("Les chaussettes de l'archiduchesse"){
my @results=C4::Search::_remove_stopwords($string,"kw");
$debug && warn "$string ",Dump(@results);
ok($results[0] ne $string,"$results[0] from $string");
}
