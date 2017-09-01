#!/usr/bin/perl
# This script is called by the pre-commit git hook to test modules compile

use strict;
use warnings;

use threads;    # used for parallel
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
    'edithelp.pl',       'errors',
    'fix-perl-path.PL',  'help.pl',
    'installer',         'koha_perl_deps.pl',
    'kohaversion.pl',    'labels',
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
$Test::Strict::TEST_SKIP = [ 'misc/kohalib.pl', 'misc/plack/koha.psgi' ];

my $ncpu;
if ( $ENV{KOHA_PROVE_CPUS} ) {
    $ncpu = $ENV{KOHA_PROVE_CPUS} ; # set number of cpus to use
} else {
    $ncpu = Sys::CPU::cpu_count();
}

print "Using $ncpu CPUs...\n"
    if $ENV{DEBUG};

my $pm   = new Parallel::ForkManager($ncpu);

foreach my $d (@dirs) {
    $pm->start and next;    # do the fork

    all_perl_files_ok($d);

    $pm->finish;            # do the exit in the child process
}

$pm->wait_all_children;

done_testing();
