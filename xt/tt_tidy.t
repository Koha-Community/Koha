#/usr/bin/perl

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use threads;    # used for parallel
use File::Slurp qw( read_file );
use Test::More;
use Test::Strict;
use Parallel::ForkManager;
use Sys::CPU;

use Koha::Devel::Files;

my $dev_files = Koha::Devel::Files->new( { context => 'tidy' } );
my @tt_files  = $dev_files->ls_tt_files;

$Test::Strict::TEST_STRICT = 0;

my $ncpu;
if ( $ENV{KOHA_PROVE_CPUS} ) {
    $ncpu = $ENV{KOHA_PROVE_CPUS};
} else {
    $ncpu = Sys::CPU::cpu_count();
}

my $pm = Parallel::ForkManager->new($ncpu);

foreach my $filepath (@tt_files) {
    $pm->start and next;

    my $tidy    = qx{perl misc/devel/tidy.pl --silent --no-write $filepath};
    my $content = read_file $filepath;
    ok( $content eq $tidy, "$filepath should be kept tidy" );

    $pm->finish;
}

$pm->wait_all_children;

done_testing;
