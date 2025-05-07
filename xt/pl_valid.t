#!/usr/bin/env perl

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;
use threads;    # used for parallel
use Test::More;

use Test::NoWarnings;
use Pod::Checker;

use Parallel::ForkManager;
use Sys::CPU;

use Koha::Devel::CI::IncrementalRuns;

my $ci    = Koha::Devel::CI::IncrementalRuns->new( { context => 'valid' } );
my @files = $ci->get_files_to_test('pl');

my $ncpu;
if ( $ENV{KOHA_PROVE_CPUS} ) {
    $ncpu = $ENV{KOHA_PROVE_CPUS};
} else {
    $ncpu = Sys::CPU::cpu_count();
}

my $pm = Parallel::ForkManager->new($ncpu);
my %results;
$pm->run_on_finish(
    sub {
        my ( $pid, $exit_code, $ident, $exit_signal, $core_dump, $data ) = @_;
        $results{$ident} = $exit_code;
    }
);

plan tests => scalar(@files) + 1;

for my $file (@files) {
    $pm->start($file) and next;
    my $output = `perl -cw '$file' 2>&1`;
    chomp $output;
    my $exit_code = 0;
    if ($?) {
        fail("$file has syntax errors");
        diag($output);
        $exit_code = 1;
    } elsif ( $output =~ /^$file syntax OK$/ ) {
        pass("$file passed syntax check");
    } else {
        my @fails;
        for my $line ( split "\n", $output ) {
            next if $line =~ m{^$file syntax OK$};
            next if $line =~ m{^Subroutine .* redefined at};
            next if $line =~ m{^Constant subroutine .* redefined at};

            next if $line =~ m{Name "Lingua::Ispell::path" used only once: possible typo at C4/Tags.pm};
            push @fails, $line;
        }
        if (@fails) {
            fail("$file has syntax warnings.");
            diag( join "\n", @fails );
            $exit_code = 1;
        } else {
            pass("$file passed syntax check");
        }
    }
    $pm->finish($exit_code);
}

$pm->wait_all_children;

$ci->report_results( \%results );
