#!/usr/bin/perl
use Modern::Perl;
use Test::PerlTidy;
use Test::More;
use Test::NoWarnings;

use Koha::Devel::CI::IncrementalRuns;

my $ci    = Koha::Devel::CI::IncrementalRuns->new( { context => 'tidy' } );
my @files = $ci->get_files_to_test('pl');

plan tests => scalar(@files) + 1;

my %results;
for my $file (@files) {
    ok( Test::PerlTidy::is_file_tidy($file) ) or $results{$file} = 1;
}

$ci->report_results( \%results );
