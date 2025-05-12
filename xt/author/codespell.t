#!/usr/bin/perl
use Modern::Perl;
use Test::PerlTidy;
use Test::More;

use Koha::Devel::Files;

my $codespell_version = qx{codespell --version};
chomp $codespell_version;
$codespell_version =~ s/-.*$//;
if ( ( $codespell_version =~ s/\.//gr ) < 220 ) {    # if codespell < 2.2.0
    plan skip_all => "codespell version $codespell_version too low, need at least 2.2.0";
}
my $dev_files = Koha::Devel::Files->new( { context => 'codespell' } );
my @files;
push @files, $dev_files->ls_perl_files;
push @files, $dev_files->ls_tt_files;
push @files, $dev_files->ls_js_files;

plan tests => scalar @files;

for my $file (@files) {
    my $output = qx{codespell -d --ignore-words .codespell-ignore $file};
    chomp $output;
    is( $output, q{} );
}
