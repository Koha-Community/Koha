#!/usr/bin/perl

# Copyright KohaSuomi 2016
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
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

use Modern::Perl;
use Test::More;

use t::lib::TestObjects::SystemPreferenceFactory;
use C4::Context;

my $subtestContext = {};

# take syspref 'opacuserlogin' and save its current value
my $current_pref_value = C4::Context->preference("opacuserlogin");

is($current_pref_value, $current_pref_value, "System Preference 'opacuserlogin' original value '".(($current_pref_value) ? $current_pref_value : 0)."'");

# reverse the value for testing
my $pref_new_value = !$current_pref_value || 0;

my $objects = t::lib::TestObjects::SystemPreferenceFactory->createTestGroup([
                {preference => 'opacuserlogin',
                value      => $pref_new_value # set the reversed value
                },
                ], undef, $subtestContext, undef, undef);

is(C4::Context->preference("opacuserlogin"), $pref_new_value, "System Preference opacuserlogin reversed to '".(($pref_new_value) ? $pref_new_value:0)."'");

# let's change it again to test that only the original preference value is saved
$objects = t::lib::TestObjects::SystemPreferenceFactory->createTestGroup([
        {preference => 'opacuserlogin',
         value      => 2 # set the reversed value
        },
        ], undef, $subtestContext, undef, undef);

is(C4::Context->preference("opacuserlogin"), 2, "System Preference opacuserlogin set to '2'");

#Delete them
t::lib::TestObjects::ObjectFactory->tearDownTestContext($subtestContext);
is(C4::Context->preference("opacuserlogin"), $current_pref_value, "System Preference opacuserlogin restored to '".(($current_pref_value) ? $current_pref_value:0)."' after test group deletion");

done_testing();
