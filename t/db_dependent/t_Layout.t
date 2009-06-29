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
    use_ok('C4::Labels::Layout');
}

my $default_layout = {
        barcode_type    =>      '',
        start_label     =>      2,
        printing_type   =>      '',
        layout_name     =>      'TEST',
        guidebox        =>      0,
        font_type       =>      '',
        ccode           =>      '',
        callnum_split   =>      0,
        text_justify    =>      '',
        format_string   =>      '',
    };

my $layout;

diag "Testing new layout object creation.";
ok($layout = C4::Labels::Layout->new(start_label => 2,layout_name => 'TEST'), "Object created");
is_deeply($layout, $default_layout, "Object verified");

diag "Testing get_attr method.";
foreach my $key (keys %{$default_layout}) {
    ok($default_layout->{$key} eq $layout->get_attr($key), "Got $key attribute.");
}

diag "Testing set_attr method.";
my $new_attr = {
        barcode_type    =>      'CODE39',
        start_label     =>      1,
        printing_type   =>      'BIBBAR',
        layout_name     =>      'TEST',
        guidebox        =>      1,
        font_type       =>      'TR',
        ccode           =>      'BOOK',
        callnum_split   =>      1,
        text_justify    =>      'L',
        format_string   =>      'callnumber, title, author, barcode',
    };

foreach my $key (keys %{$new_attr}) {
    $layout->set_attr($key, $new_attr->{$key});
    ok($new_attr->{$key} eq $layout->get_attr($key), "$key attribute is now set to " . $new_attr->{$key});
}

diag "Testing save method by saving a new record.";

my $sav_results = $layout->save();
ok($sav_results ne -1, "Record number $sav_results  saved.") || diag "Error encountered during save. See syslog for details.";

my $saved_layout;
if ($sav_results ne -1) {
    diag "Testing get method.";
    $new_attr->{'layout_id'} = $sav_results;
    diag "\$sav_results = $sav_results";
    $saved_layout = C4::Labels::Layout->retrieve(layout_id => $sav_results);
    is_deeply($saved_layout, $new_attr, "Get method verified.");
}

diag "Testing save method by updating a record.";

$saved_layout->set_attr("start_label",5);
my $upd_results = $saved_layout->save();
ok($upd_results ne -1, "Record number $upd_results  updated.") || diag "Error encountered during update. See syslog for details.";
my $updated_layout = C4::Labels::Layout->retrieve(layout_id => $sav_results);
is_deeply($updated_layout, $saved_layout, "Update verified.");

diag "Testing delete method.";

my $del_results = $updated_layout->delete();
ok($del_results eq 0, "Layout deleted.") || diag "Incorrect or non-existent record id. See syslog for details.";
