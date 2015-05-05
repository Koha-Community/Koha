#!/usr/bin/perl

# Copyright 2015 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use C4::Context;
use t::lib::Mocks qw(mock_preference);
use Test::More tests => 6;

BEGIN {
    use_ok('C4::External::OverDrive');
}

can_ok(
    'C4::External::OverDrive', qw(
      _request
      IsOverDriveEnabled
      GetOverDriveToken )
);

# ---------- Testing IsOverDriveEnabled ---------

t::lib::Mocks::mock_preference( "OverDriveClientKey",    0 );
t::lib::Mocks::mock_preference( "OverDriveClientSecret", 0 );

is( IsOverDriveEnabled(), 0, 'IsOverDriveEnabled fail' );

t::lib::Mocks::mock_preference( "OverDriveClientKey",    0 );
t::lib::Mocks::mock_preference( "OverDriveClientSecret", 1 );

is( IsOverDriveEnabled(), 0, 'IsOverDriveEnabled fail' );

t::lib::Mocks::mock_preference( "OverDriveClientKey",    1 );
t::lib::Mocks::mock_preference( "OverDriveClientSecret", 0 );

is( IsOverDriveEnabled(), 0, 'IsOverDriveEnabled fail' );

t::lib::Mocks::mock_preference( "OverDriveClientKey",    1 );
t::lib::Mocks::mock_preference( "OverDriveClientSecret", 1 );

is( IsOverDriveEnabled(), 1, 'IsOverDriveEnabled success' );
