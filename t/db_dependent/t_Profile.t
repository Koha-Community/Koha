#!/usr/bin/perl
#
# Copyright 2007 Foundations Bible College.
#
# This file is part of Koha.
#       
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Koha; if not, write to the Free Software Foundation, Inc., 59 Temple Place,
# Suite 330, Boston, MA  02111-1307 USA

use strict;
use warnings;

use Test::More tests => 28;
use C4::Context;
use Data::Dumper;

BEGIN {
    use_ok('C4::Labels::Profile');
}

my $default_profile = {
    printer_name    => 'Circulation Desk',
    tmpl_id         => '',
    paper_bin       => 'bypass',
    offset_horz     => 0,
    offset_vert     => 0,
    creep_horz      => 0,
    creep_vert      => 0,
    unit            => 'POINT',
};

my $err = 0;

diag "Testing new template object creation.";
ok(my $profile = C4::Labels::Profile->new(printer_name => 'Circulation Desk',paper_bin => 'bypass'), "Object created");
is_deeply($profile, $default_profile, "Object verified");

diag "Testing get_attr method.";
foreach my $key (keys %{$default_profile}) {
    ok($default_profile->{$key} eq $profile->get_attr($key), "Got $key attribute.");
}

diag "Testing set_attr method.";
my $new_attr = {
    printer_name    => 'Cataloging Desk',
    tmpl_id         => '1',
    paper_bin       => 'tray 1',
    offset_horz     => 0.3,
    offset_vert     => 0.85,
    creep_horz      => 0.156,
    creep_vert      => 0.67,
    unit            => 'INCH',
};

foreach my $key (keys %{$new_attr}) {
    $err = $profile->set_attr($key, $new_attr->{$key});
    ok(($new_attr->{$key} eq $profile->get_attr($key)) && ($err lt 1), "$key attribute is now set to " . $new_attr->{$key});
}

diag "Testing save method by saving a new record.";

my $sav_results = $profile->save();
ok($sav_results ne -1, "Record number $sav_results  saved.") || diag "Error encountered during save. See syslog for details.";

my $saved_profile;
if ($sav_results ne -1) {
    diag "Testing get method.";
    $new_attr->{'prof_id'} = $sav_results;
    $saved_profile = C4::Labels::Profile->retrieve($sav_results);
    is_deeply($saved_profile, $new_attr, "Get method verified.");
}

diag "Testing conv_points method.";

$saved_profile->conv_points();
my $expect_conv = {
    offset_horz => 21.6,
    offset_vert => 61.2,
    creep_horz  => 11.232,
    creep_vert  => 48.24,
};

foreach my $key (keys %{$expect_conv}) {
    ok($expect_conv->{$key} eq $saved_profile->get_attr($key), "$key converted correctly.") || diag "Expected " . $expect_conv->{$key} . " but got " . $saved_profile->get_attr($key) . ".";
}


diag "Testing save method by updating a record.";

$err = 0; # Reset error code
$err = $saved_profile->set_attr(unit => 'CM');
my $upd_results = $saved_profile->save();
ok(($upd_results ne -1) && ($err lt 1), "Record number $upd_results updated.") || diag "Error encountered during update. See syslog for details.";
my $updated_profile = C4::Labels::Profile->retrieve($sav_results);
is_deeply($updated_profile, $saved_profile, "Update verified.");

#diag "Testing conv_points method.";

diag "Testing delete method.";

my $del_results = $updated_profile->delete();
ok($del_results eq 0, "Profile deleted.") || diag "Incorrect or non-existent record id. See syslog for details.";
