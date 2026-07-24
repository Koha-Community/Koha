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
use Cwd            qw( abs_path );
use File::Basename qw( basename );
use FindBin        qw( $Bin );

my $analyzer = qx(which systemd-analyze 2>/dev/null);
chomp $analyzer;
plan( skip_all => 'systemd-analyze not found; install the systemd package' )
    unless $analyzer;

my $units_dir = abs_path("$Bin/../debian/systemd");
plan( skip_all => 'debian/systemd not found' )
    unless $units_dir && -d $units_dir;

opendir( my $dh, $units_dir ) or die "Cannot open $units_dir: $!";
my @units =
    sort
    grep { /\.(service|target|socket|timer)$/ } readdir $dh;
closedir $dh;

plan( skip_all => 'No unit files found in debian/systemd' ) unless @units;

plan tests => scalar(@units) + 1;

# Loaded after the plan because Test::NoWarnings adds a test at END time,
# which turns every skip_all above into a 'Bad plan' failure under prove
require Test::NoWarnings;
Test::NoWarnings->import;

# The trailing colon appends the default unit path so dependencies like
# sysinit.target still resolve
$ENV{SYSTEMD_UNIT_PATH} = "$units_dir:";

for my $unit (@units) {
    my $output = qx(systemd-analyze verify --man=no --no-pager $unit 2>&1);
    my $rc     = $? >> 8;
    if ( $rc != 0 ) {
        my @errors = grep { !ignorable($_) } split /\n/, $output;
        $rc = 0 unless @errors;
    }
    ok( $rc == 0, "Valid unit file: $unit" ) or diag $output;
}

sub ignorable {
    my ($line) = @_;

    return 1 unless $line =~ /\S/;

    # systemd rewrites legacy /var/run paths itself and only warns
    return 1 if $line =~ /references a path below legacy directory/;

    # Helper scripts the units call are only installed to /usr/sbin by the
    # koha-systemd and koha-core packages, so on a dev checkout ignore
    # 'not executable' errors for commands this repo ships
    if ( $line =~ /Command (\S+) is not executable/ ) {
        my $script = basename($1);
        return 1
            if -e "$Bin/../debian/scripts/$script"
            || -e "$Bin/../debian/systemd/$script";
    }

    return 0;
}
