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
use Test::More;

my @js_files = qx{git ls-files '*.js' '*.ts'};

plan tests => scalar @js_files;

foreach my $filepath (@js_files) {
    chomp $filepath;
    my $tidy    = qx{perl misc/devel/tidy.pl --silent --no-write $filepath};
    my $content = read_file $filepath;
    ok( $content eq $tidy, "$filepath should be kept tidy" );
}
