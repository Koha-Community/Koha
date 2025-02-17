#!/usr/bin/perl
use Modern::Perl;
use Test::PerlTidy;
use Test::More;

my @files;
push @files, qx{git ls-files '*.pl' '*.PL' '*.pm' '*.t' ':(exclude)Koha/Schema/Result' ':(exclude)Koha/Schema.pm'};
push @files, qx{git ls-files svc opac/svc};    # Files without extension

plan tests => scalar @files;

for my $file (@files) {
    chomp $file;
    ok( Test::PerlTidy::is_file_tidy($file) );
}
