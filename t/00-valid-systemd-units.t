# Copyright 2026 Martin Renvoize
#
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

use Test::More;
use Test::NoWarnings;
use Cwd     qw( abs_path );
use FindBin qw( $Bin );

my $analyzer = qx(which systemd-analyze 2>/dev/null);
chomp $analyzer;
plan( skip_all => 'systemd-analyze not found; install the systemd package' )
    unless $analyzer;

my $units_dir = abs_path("$Bin/../debian/systemd");
plan( skip_all => 'debian/systemd not found' )
    unless $units_dir && -d $units_dir;

my $probe = qx(systemd-analyze verify --unit-path=/tmp /bin/true 2>&1);
plan( skip_all => 'systemd-analyze --unit-path not supported; upgrade systemd' )
    if $probe =~ /unrecognized option/;

opendir( my $dh, $units_dir ) or die "Cannot open $units_dir: $!";
my @units =
    sort
    grep { /\.(service|target|socket|timer)$/ } readdir $dh;
closedir $dh;

plan( skip_all => 'No unit files found in debian/systemd' ) unless @units;

plan tests => scalar(@units) + 1;

for my $unit (@units) {
    my $output = qx(systemd-analyze verify --no-pager "--unit-path=$units_dir" $unit 2>&1);
    my $rc     = $? >> 8;
    ok( $rc == 0, "Valid unit file: $unit" ) or diag $output;
}
