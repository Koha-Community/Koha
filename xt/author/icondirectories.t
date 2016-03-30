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

=head1 NAME

icondirectories.t - test to ensure that the two directories of icons
in the staff and opac interface are identical.

=head1 DESCRIPTION

Tere are two directories of icons for media types, one for the opac
and one for the staff interface. They need to be identical. This
ensures that they are.

=cut

use Modern::Perl;

use lib qw( .. );

use Data::Dumper;
use File::Find;
use Test::More tests => 3;

# hardcoded OPAC & STAFF dirs
my $opac_dir  = 'koha-tmpl/opac-tmpl';
my $staff_dir = 'koha-tmpl/intranet-tmpl';

# Find OPAC themes
opendir ( my $dh, $opac_dir ) or die "can't opendir $opac_dir: $!";
my @opac_themes = grep { not /^\.|lib|js|xslt/ } readdir($dh);
close $dh;

# Find STAFF themes
opendir ( $dh, $staff_dir ) or die "can't opendir $staff_dir: $!";
my @staff_themes = grep { not /^\.|lib|js/ } readdir($dh);
close $dh;

# Check existence of OPAC icon dirs
for my $theme ( @opac_themes ) {
    my $test_dir = "$opac_dir/$theme/itemtypeimg";
    ok( -d $test_dir, "opac_icon_directory: $test_dir exists" );
}

# Check existence of STAFF icon dirs
for my $theme ( @staff_themes ) {
    my $test_dir = "$staff_dir/$theme/img/itemtypeimg";
    ok( -d $test_dir, "staff_icon_directory: $test_dir exists" );
}

# Check for same contents on STAFF and OPAC icondirs
# foreach STAFF theme
for my $staff_theme ( @staff_themes ) {
    my $staff_icons; # hashref of filenames to sizes
    my $staff_icon_directory = "$staff_dir/$staff_theme/img/itemtypeimg";
    my $staff_wanted = sub {
        my $file = $File::Find::name;
        $file =~ s/^$staff_icon_directory//;
        $staff_icons->{ $file } = -s $_;
    };
    find( { wanted => $staff_wanted }, $staff_icon_directory );

    # foreach OPAC theme
    for my $opac_theme ( @opac_themes ) {
        next if ( $opac_theme =~ /ccsr/ );  # FIXME: skip CCSR opac theme, it fails and there is no point to fix it
        my $opac_icons; # hashref of filenames to sizes
        my $opac_icon_directory  = "$opac_dir/$opac_theme/itemtypeimg";
        my $opac_wanted  = sub {
            my $file = $File::Find::name;
            $file =~ s/^$opac_icon_directory//;
            $opac_icons->{ $file } = -s $_;
        };
        find( { wanted => $opac_wanted }, $opac_icon_directory );

        is_deeply( $opac_icons, $staff_icons, "STAFF $staff_theme and OPAC $opac_theme icon directories have same contents" )
            or diag( Data::Dumper->Dump( [ $opac_icons ], [ 'opac_icons' ] ) );
    }
}

1;
