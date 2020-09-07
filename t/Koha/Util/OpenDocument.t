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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use File::Temp qw/tempfile/;
use Test::More tests => 4;

BEGIN { use_ok('Koha::Util::OpenDocument'); }

my ( $ret, $filepath, $content );

$ret = generate_ods( $filepath, $content );
ok( !defined $ret, 'Call generate_ods with undef args' );

my $fh1 = File::Temp->new( UNLINK => 1 );
$filepath = $fh1->filename;
my $content1 = [];
$ret = generate_ods( $filepath, $content1 );
ok( defined $ret, 'Call generate_ods with empty content' );
close $fh1;

my $fh2 = File::Temp->new( UNLINK => 1 );
$filepath = $fh2->filename;
my $content2 = [ [ 'A', 'B' ], [ '1', '2' ] ];
$ret = generate_ods( $filepath, $content2 );
ok( defined $ret, 'Call generate_ods with 2x2 content' );
close $fh2;
