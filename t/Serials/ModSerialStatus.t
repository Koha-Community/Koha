#!/usr/bin/perl

# Copyright 2020 Rijksmuseum
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

# Testing private routine C4::Serials::_handle_seqno of ModSerialStatus

use Modern::Perl;
use Data::Dumper qw/Dumper/;

use Test::NoWarnings;
use Test::More tests => 9;

use C4::Serials;

# Testing C4::Serials::_handle_seqno
my $list = '2017 (No. 8); 2017 (No. 9); 2017 (No. 10)';
is( C4::Serials::_handle_seqno( '2017 (No. 8)', $list ),           $list,                     'Not added 8' );
is( C4::Serials::_handle_seqno( '2017 (No. 9)', $list ),           $list,                     'Not added 9' );
is( C4::Serials::_handle_seqno( '2017 (No. 10)', $list ),          $list,                     'Not added 10' );
is( C4::Serials::_handle_seqno( '2017 (No. 11)', $list ),          $list . '; 2017 (No. 11)', 'Added 11' );
is( C4::Serials::_handle_seqno( '2017 (No. 7)', $list, 'REMOVE' ), $list,                     'Not removed 7' );
is( C4::Serials::_handle_seqno( '2017 (No. 10)', $list, 'REMOVE' ) !~ /\(10\)/, 1,            'Removed 10' );
is( C4::Serials::_handle_seqno( '2017 (No. 8)', $list, 'CHECK' ),               1,            'Found 8' );
is( C4::Serials::_handle_seqno( '2017 (No. 11)', $list, 'CHECK' ),              q{},          'Not found 11' );
