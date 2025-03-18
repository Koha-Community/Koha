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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More;
use Test::NoWarnings;
use Pod::Coverage;

# Note that we are using Pod::Coverage instead of Test::Pod::Coverage
# We do not want to fail if no pod exists in the file.
# That could be a next step

my @files;
push @files, qx{git ls-files '*.pm'};
chomp for @files;

plan tests => scalar(@files) + 1;

for my $file (@files) {
    my @uncovered = check_pod_coverage($file);
    is( scalar(@uncovered), 0, "POD coverage for $file" ) or diag( join ", ", @uncovered );

}

sub check_pod_coverage {
    my ($file) = @_;

    my $package_name = $file;
    $package_name =~ s|/|::|g;
    $package_name =~ s|\.pm$||;

    my $coverage = Pod::Coverage->new( package => $package_name );
    return $coverage->uncovered;
}
