# Copyright 2010 Galen Charlton
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

use Koha::Devel::Files;

my $dev_files = Koha::Devel::Files->new( { context => 'full' } );
my @files     = $dev_files->ls_all_files( [qw(ico jpg gif ogg pdf png psd)] );

plan tests => scalar @files + 1;

for my $file (@files) {
    my $has_conflicts;
    open my $fh, '<', $file or die "Cannot open $file: $!";
    while ( my $line = <$fh> ) {

        # Could check for ^=====, but that's often used in text files
        if ( $line =~ /^<<<<<<<|^>>>>>>>/ ) {
            $has_conflicts = 1;
        }
    }
    ok( !$has_conflicts, "$file should not contain merge conflict markers" );
    close $fh;
}
