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
my ($clover, $tar, $reinstall);
my ($testAll, $testBasic, $testXt, $testSip2, $testDb);


GetOptions(
    'h|help'                      => \$help,
    'v|verbose:i'                 => \$verbose,
    'reinstall'                   => \$reinstall,
    'dry-run'                     => \$dryRun,
    'clover'                      => \$clover,
    'tar'                         => \$tar,
    'a|all'                       => \$testAll,
    'b|basic'                     => \$testBasic,
    'x|xt'                        => \$testXt,
    's|sip2'                      => \$testSip2,
    'd|db'                        => \$testDb,
    'g|git:i'                     => \$gitTailLength,
);

my $usage = <<USAGE;

Runs a ton of tests with other metrics if needed

  -h --help             This friendly help!

  -v --verbose          Integer, the level of verbosity

  --reinstall           Reinstall the default Koha database. This operation is only allowed
                        on databases whose name starts with "koha_ci"

  --tar                 Create a testResults.tar.gz from all tests and deliverables

  --dry-run             Don't run tests or other metrics. Simply show what would happen.

  --clover              Run Devel::Cover and output Clover-reports

  -a --all              Run all tests.

  -b --basic            Basic tests t/*.t

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

    ##First run a smoke test for latest changes
    ks-test-harness.pl --git 5 --tar
    ##Then run a big test suite
    ks-test-harness.pl --all --tar

    ##Just fiddling with options here
    ks-test-harness.pl --basic --db -v 1

USAGE

if ($help) {
    print $usage;
    exit 0;
}

use File::Basename;
use TAP::Harness::JUnit;
use Git;
use C4::Installer;

my $dir = File::Basename::dirname($0);
chdir $dir;


##Prepare directories to store test results
my $testResultsDir = 'testResults';
my $testResultsArchive = 'testResults.tar.gz';
my $junitDir =  $testResultsDir.'/junit';
my $cloverDir = $testResultsDir.'/clover';
my @archivableDirs = ($junitDir, $cloverDir);
mkdir $testResultsDir unless -d $testResultsDir;
_shell("rm -r $junitDir");
_shell("rm -r $cloverDir");
mkdir $junitDir unless -d $junitDir;
mkdir $cloverDir unless -d $cloverDir;
unlink $testResultsArchive if -e $testResultsArchive;


run();
sub run {
    clearCoverDb() if $clover;
    C4::Installer::reinstall($verbose) if $reinstall;
    runharness(_getAllTests()) if $testAll;
    runharness(_getBasicTests()) if $testBasic;
    runharness(_getXTTests()) if $testXt;
    runharness(_getSIPTests()) if $testSip2;
    runharness(_getDbDependentTests()) if $testDb;
    runharness(_getGitTailTests()) if $gitTailLength;
    createCoverReport() if $clover;
    tar() if $tar;
}

=head2 clearCoverDb

Empty previous coverage test results

=cut

sub clearCoverDb {
    my $cmd = "/usr/bin/cover -delete $testResultsDir/cover_db";
    print "$cmd\n" if $dryRun;
    _shell($cmd) unless $dryRun;
}

=head2 createCoverReport

Create Clover coverage reports

=cut

sub createCoverReport {
    my $cmd = "/usr/bin/cover -report clover -outputdir $testResultsDir/clover $testResultsDir/cover_db";
    print "$cmd\n" if $dryRun;
    _shell($cmd) unless $dryRun;
}

=head2 tar

Create a tar.gz-package out of test deliverables

=cut

sub tar {
    my $cmd = "/bin/tar -czf $testResultsArchive @archivableDirs";
    print "$cmd\n" if $dryRun;
    _shell($cmd) unless $dryRun;
}

=head2 runharness

Runs all given test files

=cut

sub runharness {
    my ($files) = @_;
    unless (ref($files) eq 'HASH') {
        carp "\$files is not a HASHRef";
    }

    foreach my $dir (sort keys %$files) {
        my @tests = sort @{$files->{$dir}};
        unless (scalar(@tests)) {
            carp "\@tests is empty?";
        }

        ##Prepare test harness params
        my $dirToPackage = $dir;
        $dirToPackage =~ s!^\./!!; #Drop leading "current"-dir chars
        $dirToPackage =~ s!/!\.!gsm; #Change directories to dot-separated packages
        my $xmlfile = $testResultsDir.'/junit'.'/'.$dirToPackage.'.xml';
        my @exec = (
            $EXECUTABLE_NAME,
            '-w',
        );
        push(@exec, '-MDevel::Cover=-silent,1,-coverage,all') if $clover;

        if ($dryRun) {
            print "TAP::Harness::JUnit would run tests with this config:\nxmlfile => $xmlfile\npackage => $dirToPackage\nexec => @exec\ntests => @tests\n";
        }
        else {
            my $harness = TAP::Harness::JUnit->new({
                xmlfile => $xmlfile,
#                package => $dirToPackage,
                package => "",
                verbosity => 1,
                namemangle => 'perl',
                exec       => \@exec,
            });
            $harness->runtests(@tests);
        }
    }
}

sub _getAllTests {
    return _getTests('.', '*.t');
}
sub _getBasicTests {
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
    return _sortFilesByDir(\@files);
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
    return {} unless scalar(@testFiles);
    return _sortFilesByDir(\@testFiles);
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

=head2 _sortFilesByDir

Sort files in arrays by directory
@RETURNS HASHRef of directory-name keys and test file names
        {
            't/db_dependent' => [
                't/db_dependent/01-test.t',
            ],
            ...
        }
=cut

sub _sortFilesByDir {
    my ($files) = @_;
    unless (ref($files) eq 'ARRAY') {
        carp "\$files is not an ARRAYRef";
    }
    unless (scalar(@$files)) {
        carp "\$files is an ampty array?";
    }

    my %dirsWithFiles;
    foreach my $f (@$files) {
        my $dir = File::Basename::dirname($f);
        $dirsWithFiles{$dir} = [] unless $dirsWithFiles{$dir};
        push (@{$dirsWithFiles{$dir}}, $f);
    }
    return \%dirsWithFiles;
}
