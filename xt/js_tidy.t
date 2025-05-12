#!/usr/bin/perl

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
use File::Slurp qw( read_file );
use Test::More;
use Test::NoWarnings;

use Koha::Devel::CI::IncrementalRuns;

my $ci = Koha::Devel::CI::IncrementalRuns->new( { context => 'tidy' } );

my @files = $ci->get_files_to_test('js');

plan tests => scalar @files + 1;

my %results;
foreach my $filepath (@files) {
    chomp $filepath;
    my $tidy    = qx{perl misc/devel/tidy.pl --silent --no-write $filepath};
    my $content = read_file $filepath;
    ok( $content eq $tidy, "$filepath should be kept tidy" ) or $results{$filepath} = 1;
}

$ci->report_results( \%results );
