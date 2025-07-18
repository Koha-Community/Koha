#!/usr/bin/perl
use Modern::Perl;
use Test::PerlTidy;
use Test::More;
use Test::NoWarnings;

use Koha::Devel::Files;

my $dev_files = Koha::Devel::Files->new( { context => 'tidy' } );
my @files     = $dev_files->ls_perl_files;

plan tests => scalar(@files) + 1;

for my $file (@files) {
    ok( Test::PerlTidy::is_file_tidy($file) );
}
