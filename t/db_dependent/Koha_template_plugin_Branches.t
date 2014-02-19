#!/usr/bin/perl

# Copyright 2013-2014 Equinox Software, Inc.
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

use Test::More tests => 7;

use C4::Context;
BEGIN {
    use_ok('Koha::Template::Plugin::Branches');
}

my $plugin = Koha::Template::Plugin::Branches->new();
ok($plugin, "initialized Branches plugin");

my $name = $plugin->GetName('CPL');
is($name, 'Centerville', 'retrieved expected name for CPL');

$name = $plugin->GetName('__ANY__');
is($name, '', 'received empty string as name of the "__ANY__" placeholder library code');

$name = $plugin->GetName(undef);
is($name, '', 'received empty string as name of NULL/undefined library code');

my $library = $plugin->GetLoggedInBranchcode();
is($library, '', 'no active library if there is no active user session');

C4::Context->_new_userenv('DUMMY_SESSION_ID');
C4::Context::set_userenv(123, 'userid', 'usercnum', 'First name', 'Surname', 'MYLIBRARY', 'My Library', 0);
$library = $plugin->GetLoggedInBranchcode();
is($library, 'MYLIBRARY', 'GetLoggedInBranchcode() returns active library');
