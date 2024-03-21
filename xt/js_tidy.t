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
use File::Slurp qw( read_file );
use File::Find;
use FindBin();
use Data::Dumper qw( Dumper );
use Test::More tests => 1;

my $cmd      = q{git grep -l '/\* keep tidy \*/'  -- '*.js'};
my @js_files = qx{$cmd};

my @not_tidy;
foreach my $filepath (@js_files) {
    chomp $filepath;
    my $tidy    = qx{yarn --silent run prettier --trailing-comma es5 --arrow-parens avoid $filepath};
    my $content = read_file $filepath;
    if ( $content ne $tidy ) {
        push @not_tidy, $filepath;
    }
}

is( scalar(@not_tidy), 0, sprintf( 'No .js file should be messy %s/%s', scalar(@not_tidy), scalar(@js_files) ) )
    or diag Dumper \@not_tidy;
