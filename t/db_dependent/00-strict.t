#!/usr/bin/perl
# This script is called by the pre-commit git hook to test modules compile

use Modern::Perl;

use threads;    # used for parallel
use Test::NoWarnings;
use Test::More;
use Test::Strict;
use Parallel::ForkManager;
use Sys::CPU;

use Koha::Devel::Files;

use lib("misc/translator");
use lib("installer");

my $dev_files = Koha::Devel::Files->new( { context => 'strict' } );
my @files     = $dev_files->ls_perl_files;
plan tests => scalar @files + 1;

$Test::Strict::TEST_STRICT = 0;

my $ncpu;
if ( $ENV{KOHA_PROVE_CPUS} ) {
    $ncpu = $ENV{KOHA_PROVE_CPUS};    # set number of cpus to use
} else {
    $ncpu = Sys::CPU::cpu_count();
}

my $pm = Parallel::ForkManager->new($ncpu);

foreach my $f (@files) {
    $pm->start and next;              # do the fork

    strict_ok($f);

    $pm->finish;                      # do the exit in the child process
}

$pm->wait_all_children;
