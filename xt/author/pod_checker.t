#!/usr/bin/env perl

use Modern::Perl;
use Test::More;
use Test::NoWarnings;
use Pod::Checker;

my @files;
push @files, qx{git ls-files '*.pl' '*.PL' '*.pm' '*.t'};
push @files, qx{git ls-files svc opac/svc};                 # Files without extension
chomp for @files;

plan tests => 1;

for my $file (@files) {
    podchecker($file);
}
