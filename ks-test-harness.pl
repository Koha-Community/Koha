#!/usr/bin/env perl

# Copyright 2017 KohaSuomi
#
# This file is part of Koha.
#

use 5.22.0;
use Carp;
use autodie;
$Carp::Verbose = 'true'; #die with stack trace
use English; #Use verbose alternatives for perl's strange $0 and $\ etc.
use Getopt::Long qw(:config no_ignore_case);
use Try::Tiny;
use Scalar::Util qw(blessed);

my ($help, $dryRun);
my ($verbose, $gitTailLength) = (0, 0);
my ($clover, $tar, $junit);
my ($run);
my ($testAll, $testUnit, $testXt, $testSip2, $testDb, $testCompile);

GetOptions(
    'h|help'                      => \$help,
    'v|verbose:i'                 => \$verbose,
    'dry-run'                     => \$dryRun,
    'clover'                      => \$clover,
    'tar'                         => \$tar,
    'junit'                       => \$junit,
    'run'                         => \$run,
    'c|compile'                   => \$testCompile,
    'a|all'                       => \$testAll,
    'u|unit'                      => \$testUnit,
    'x|xt'                        => \$testXt,
    's|sip2'                      => \$testSip2,
    'd|db'                        => \$testDb,
    'g|git=i'                     => \$gitTailLength,
);

my $usage = <<USAGE;

Runs a ton of tests with other metrics if needed

  -h --help             This friendly help!

  -v --verbose          Integer, the level of verbosity

  --tar                 Create a testResults.tar.gz from all tests and deliverables

  --dry-run             Don't run tests or other metrics. Simply show what would happen.

  --clover              Run Devel::Cover and output Clover-reports.
                        Clover reports are stored to testResults/clover/clover.xml

  --junit               Run test via TAP::Harness::Junit instead of TAP::Harness. Junit xml results
                        are stored to testResults/junit/*.xml

  --run                 Actually run the tests. Without this flag, the script will simply compile and run
                        without doing any work or changes.
                        You can use this to test that this script is actually compilable.

  -c --compile          Only check if Perl files compile, using t/00-load.t

  -a --all              Run all tests.

  -u --unit             Unit tests t/*.t

  -x --xt               XT tests

  -s --sip2             SIP2 tests

  -d --db               db_dependent tests

  --git                 Integer, look for this many git commits from HEAD and run
                        all '.t'-files that they have changed.
                        This is meaningful as a quick smoke test to verify that
                        the latest changes haven't been broken or work as expected.
                        Thus where the most probably reason for breakage occurs,
                        is tested first, before executing more lengthy test suites.

EXAMPLE

  ks-test-harness.pl --tar --clover --junit --run

USAGE

if ($help) {
    print $usage;
    exit 0;
}

use KSTestHarness;
use Git;


run() if $run;
sub run {
    my (@tests, $tests);
    push(@tests, @{_getCompileTest()})      if $testCompile;
    push(@tests, @{_getAllTests()})         if $testAll;
    push(@tests, @{_getUnitTests()})        if $testUnit;
    push(@tests, @{_getXTTests()})          if $testXt;
    push(@tests, @{_getSIPTests()})         if $testSip2;
    push(@tests, @{_getDbDependentTests()}) if $testDb;
    push(@tests, @{_getGitTailTests()})     if $gitTailLength;

    print "Selected the following test files:\n".join("\n",@tests)."\n" if $verbose;

    my $ksTestHarness = KSTestHarness->new(
        resultsDir => undef,
        tar        => $tar,
        clover     => $clover,
        junit      => $junit,
        testFiles  => \@tests,
        dryRun     => $dryRun,
        verbose    => $verbose,
        lib        => [$ENV{KOHA_PATH}.'/lib', $ENV{KOHA_PATH}],
    );
    $ksTestHarness->run();
}

sub _getCompileTest {
    return _getTests('t', '00-load.t');
}
sub _getAllTests {
    return _getTests('.', '*.t');
}
sub _getUnitTests {
    return _getTests('t', '*.t', 1); #maxdepth 1
}
sub _getXTTests {
    return _getTests('xt', '*.t');
}
sub _getSIPTests {
    return _getTests('C4/SIP/t', '*.t');
}
sub _getDbDependentTests {
    return _getTests('t/db_dependent', '*.t');
}
sub _getTests {
    my ($dir, $selector, $maxDepth) = @_;
    $maxDepth = 999 unless(defined($maxDepth));
    my $files = _shell("/usr/bin/find $dir -maxdepth $maxDepth -name '$selector'");
    my @files = split(/\n/, $files);
    return \@files;
}
sub _getGitTailTests {
    my $repo = Git->repository(Directory => '.');
    #We can read and print 10000 git commits in less than three seconds :) good Git!
    my @commits = $repo->command('show', '--pretty=oneline', '--no-patch', '-'.($gitTailLength+1)); #Diff tree needs to include one extra commit to diff properly.
    my $lastCommitHash = $commits[-1];
    if ($lastCommitHash =~ /^(\w+)\s/ && length($1) == 40) {
        $lastCommitHash = $1;
    }
    else {
        carp "Commit '$lastCommitHash' couldn't be parsed for it's leading commit hash";
    }
    my @changedFiles = $repo->command('diff-tree', '--no-commit-id', '--name-only', '-r', 'HEAD..'.$lastCommitHash);
    my @testFiles;
    foreach my $f (@changedFiles) {
        if ($f =~ /.+?\.t$/) {
            push(@testFiles, $f);
        }
    }
    print "Found these changed test files in Git history: @testFiles\n" if $verbose > 0;
    return \@testFiles;
}

###DUPLICATION WARNING Duplicates C4::KohaSuomi::TestRunner::shell
##Refactor this script to C4::KohaSuomi::TestRunner if major changes are needed.
sub _shell {
    my (@cmd) = @_;
    my $rv = `@cmd`;
    my $exitCode = ${^CHILD_ERROR_NATIVE} >> 8;
    my $killSignal = ${^CHILD_ERROR_NATIVE} & 127;
    my $coreDumpTriggered = ${^CHILD_ERROR_NATIVE} & 128;
    warn "Shell command: @cmd\n  exited with code '$exitCode'. Killed by signal '$killSignal'.".(($coreDumpTriggered) ? ' Core dumped.' : '')."\n  STDOUT: $rv\n"
        if $exitCode != 0;
    print "@cmd\n$rv\n" if $rv && $verbose > 0;
    return $rv;
}

