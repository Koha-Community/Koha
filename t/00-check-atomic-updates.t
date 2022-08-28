# Copyright 2022 Mason James
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Test::More;
use File::Find;

SKIP: {
    skip "Building custom packages", 1, if $ENV{'CUSTOM_PACKAGE'};

    my $dir = ('installer/data/mysql/atomicupdate');
    my @files;

    find( \&wanted, $dir );

    sub wanted {
        push @files, $_;
        return;
    }

    foreach my $f (@files) {
        next if $f eq 'skeleton.pl';
        unlike( $f, qr/.*pl$/, "check for unhandled atomic updates: $f" );
    }
};

done_testing();
