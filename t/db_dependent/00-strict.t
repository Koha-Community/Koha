#!/usr/bin/perl
# This script is called by the pre-commit git hook to test modules compile

use Modern::Perl;

use threads;    # used for parallel
use Test::NoWarnings qw( had_no_warnings );
use Test::More;
use Test::Strict;
use Parallel::ForkManager;
use Sys::CPU;

use lib("misc/translator");
use lib("installer");

my @dirs = (
    'acqui',             'admin',
    'authorities',       'basket',
    'catalogue',         'cataloguing',
    'changelanguage.pl', 'circ',
    'debian',            'docs',
    'errors',            'fix-perl-path.PL', 'help.pl',
    'installer',         'kohaversion.pl',   'labels',
    'mainpage.pl',       'Makefile.PL',
    'members',           'misc',
    'offline_circ',      'opac',
    'patroncards',       'reports',
    'reserve',           'reviews',
    'rewrite-config.PL', 'rotating_collections',
    'serials',           'services',
    'skel',              'suggestion',
    'svc',               'tags',
    'tools',             'virtualshelves'
);

$Test::Strict::TEST_STRICT = 0;

my $ncpu;
if ( $ENV{KOHA_PROVE_CPUS} ) {
    $ncpu = $ENV{KOHA_PROVE_CPUS};    # set number of cpus to use
} else {
    $ncpu = Sys::CPU::cpu_count();
}

my $pm = Parallel::ForkManager->new($ncpu);

foreach my $d (@dirs) {
    $pm->start and next;              # do the fork

    all_perl_files_ok($d);

    $pm->finish;                      # do the exit in the child process
}

$pm->wait_all_children;

had_no_warnings;
done_testing();
