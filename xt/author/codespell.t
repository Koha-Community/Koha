#!/usr/bin/perl
use Modern::Perl;
use Test::PerlTidy;
use Test::More;
use Test::NoWarnings;

use Koha::Devel::CI::IncrementalRuns;

my $codespell_version = qx{codespell --version};
chomp $codespell_version;
$codespell_version =~ s/-.*$//;
if ( ( $codespell_version =~ s/\.//gr ) < 220 ) {    # if codespell < 2.2.0
    plan skip_all => "codespell version $codespell_version too low, need at least 2.2.0";
}

my $ci = Koha::Devel::CI::IncrementalRuns->new( { context => 'codespell' } );
my @files;
push @files, $ci->get_files_to_test('pl');
push @files, $ci->get_files_to_test('tt');
push @files, $ci->get_files_to_test('js');

plan tests => scalar(@files) + 1;

my %results;
for my $file (@files) {
    my $output = qx{codespell -d --ignore-words .codespell-ignore $file};
    chomp $output;
    is( $output, q{} ) or $results{$file} = 1;
}

$ci->report_results( \%results );
