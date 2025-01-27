#!/usr/bin/perl
#
#  Copyright 2020 Koha Development Team
#
#  This file is part of Koha.
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

use Koha::Script;
use Getopt::Long qw( GetOptions :config no_ignore_case );
use C4::Context;
use C4::Installer;

sub print_usage {
    ( my $basename = $0 ) =~ s|.*/||;
    print <<USAGE;

$basename
 Load file in YAML format into database.

Usage:
$0 [--file=FILE]
$0 -h
 -h, --help              Show this help
 -f, --file=FILE         File to load.
 --load                  Load the file into the database

USAGE
}

# Getting parameters
my ( @files, $load, $help );

GetOptions(
    'help|h'    => \$help,
    'load'      => \$load,
    'file|f=s@' => \@files,
) or print_usage, exit 1;

if ( $help or not @files or not $load ) {
    print_usage;
    exit;
}

my $installer = C4::Installer->new;
if ($load) {
    for my $f (@files) {
        my $error = $installer->load_sql($f);
        say $error if $error;
    }
}
