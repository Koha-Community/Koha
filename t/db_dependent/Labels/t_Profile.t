#!/usr/bin/perl
#
# Copyright 2007 Foundations Bible College.
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

use strict;
use warnings;

use Test::More tests => 27;
use C4::Context;
use Data::Dumper;

BEGIN {
    use_ok('C4::Labels::Profile');
}

my $expected_profile = {
        creator         => 'Labels',
        printer_name    => 'Circulation Desk',
        template_id     => '',
        paper_bin       => 'bypass',
        offset_horz     => 0,
        offset_vert     => 0,
        creep_horz      => 0,
        creep_vert      => 0,
        units           => 'POINT',
};

my $err = 0;

diag "Testing Profile->new() method.";
ok(my $profile = C4::Labels::Profile->new(printer_name => 'Circulation Desk',paper_bin => 'bypass')) || diag"Profile->new() FAILED.";
is_deeply($profile, $expected_profile) || diag "New profile object FAILED to verify.";

diag "Testing Profile->get_attr() method.";
foreach my $key (keys %{$expected_profile}) {
    ok($expected_profile->{$key} eq $profile->get_attr($key)) || diag "Profile->get_attr() FAILED on attribute $key.";
}

diag "Testing Profile->set_attr() method.";
my $new_attr = {
    printer_name    => 'Cataloging Desk',
    template_id     => '1',
    paper_bin       => 'tray 1',
    offset_horz     => 0.3,
    offset_vert     => 0.85,
    creep_horz      => 0.156,
    creep_vert      => 0.67,
    units           => 'INCH',
    creator         => 'Labels',
};

foreach my $key (keys %{$new_attr}) {
    $err = $profile->set_attr($key, $new_attr->{$key});
    ok(($new_attr->{$key} eq $profile->get_attr($key)) && ($err lt 1)) || diag "Profile->set_attr() FAILED on attribute $key.";
}

diag "Testing Profile->save() method with a new object.";

my $sav_results = $profile->save();
ok($sav_results ne -1) || diag "Profile->save() FAILED.";

my $saved_profile;
if ($sav_results ne -1) {
    diag "Testing Profile->retrieve() method.";
    $new_attr->{'profile_id'} = $sav_results;
    ok($saved_profile = C4::Labels::Profile->retrieve(profile_id => $sav_results)) || diag "Profile->retrieve() FAILED.";
    is_deeply($saved_profile, $new_attr) || diag "Retrieved profile object FAILED to verify.";
}

diag "Testing Profile->save() method with an updated object.";

$err = 0; # Reset error code
$err = $saved_profile->set_attr(units => 'CM');
my $upd_results = $saved_profile->save();
ok(($upd_results ne -1) && ($err lt 1)) || diag "Profile->save() FAILED.";
my $updated_profile = C4::Labels::Profile->retrieve(profile_id => $sav_results);
is_deeply($updated_profile, $saved_profile) || diag "Updated layout object FAILED to verify.";

diag "Testing Profile->delete() method.";

my $del_results = $updated_profile->delete();
ok($del_results ne -1) || diag "Profile->delete() FAILED.";
