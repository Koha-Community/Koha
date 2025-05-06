#!/usr/bin/perl
use Modern::Perl;
use Test::PerlTidy;
use Test::More;

my $codespell_version = qx{codespell --version};
chomp $codespell_version;
$codespell_version =~ s/-.*$//;
if ( ( $codespell_version =~ s/\.//gr ) < 220 ) {    # if codespell < 2.2.0
    plan skip_all => "codespell version $codespell_version too low, need at least 2.2.0";
}
my @files;
push @files,
    qx{git ls-files '*.pl' '*.PL' '*.pm' '*.t' ':(exclude)installer/data/mysql/updatedatabase.pl' ':(exclude)installer/data/mysql/update22to30.pl' ':(exclude)installer/data/mysql/db_revs/241200035.pl' ':(exclude)misc/cronjobs/build_browser_and_cloud.pl'};
push @files, qx{git ls-files svc opac/svc};          # Files without extension
push @files, qx{git ls-files '*.tt' '*.inc'};
push @files,
    qx{git ls-files '*.js' '*.ts' '*.vue' ':(exclude)koha-tmpl/intranet-tmpl/lib' ':(exclude)koha-tmpl/intranet-tmpl/js/Gettext.js' ':(exclude)koha-tmpl/opac-tmpl/lib' ':(exclude)koha-tmpl/opac-tmpl/bootstrap/js/Gettext.js'};

plan tests => scalar @files;

for my $file (@files) {
    chomp $file;
    my $output = qx{codespell -d --ignore-words .codespell-ignore $file};
    chomp $output;
    is( $output, q{} );
}
