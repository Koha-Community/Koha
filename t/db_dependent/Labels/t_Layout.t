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

use Test::More tests => 36;
use C4::Context;
use Data::Dumper;

BEGIN {
    use_ok('C4::Labels::Layout');
}

my $default_layout = {
        creator         =>      'Labels',
        layout_xml      =>      '',
        units           =>      'POINT',
        start_label     =>      1,
        barcode_type    =>      'CODE39',
        printing_type   =>      'BAR',
        layout_name     =>      'TEST',
        guidebox        =>      0,
        font            =>      'TR',
        font_size       =>      3,
        callnum_split   =>      0,
        text_justify    =>      'L',
        format_string   =>      'title, author, isbn, issn, itemtype, barcode, itemcallnumber',
    };

my $layout;

diag "Testing Layout->new() method.";
ok($layout = C4::Labels::Layout->new(layout_name => 'TEST')) || diag "Layout->new() FAILED";
is_deeply($layout, $default_layout) || diag "New layout object FAILED to verify.";

diag "Testing Layout->get_attr() method.";
foreach my $key (keys %{$default_layout}) {
    ok($default_layout->{$key} eq $layout->get_attr($key)) || diag "Layout->get_attr() FAILED on attribute $key.";
}

diag "Testing Layout->set_attr() method.";
my $new_attr = {
        creator         =>      'Labels',
        layout_xml      =>      '',
        units           =>      'POINT',
        start_label     =>      1,
        barcode_type    =>      'CODE39',
        printing_type   =>      'BIBBAR',
        layout_name     =>      'TEST',
        guidebox        =>      1,
        font            =>      'TR',
        font_size       =>      10,
        callnum_split   =>      1,
        text_justify    =>      'L',
        format_string   =>      'callnumber, title, author, barcode',
    };

foreach my $key (keys %{$new_attr}) {
    $layout->set_attr($key => $new_attr->{$key});
    ok($new_attr->{$key} eq $layout->get_attr($key)) || diag "Layout->set_attr() FAILED on attribute $key.";
}

diag "Testing Layout->save() method with a new object.";

my $sav_results = $layout->save();
ok($sav_results ne -1) || diag "Layout->save() FAILED";

my $saved_layout;
if ($sav_results ne -1) {
    diag "Testing Layout->retrieve() method.";
    $new_attr->{'layout_id'} = $sav_results;
    ok($saved_layout = C4::Labels::Layout->retrieve(layout_id => $sav_results)) || diag "Layout->retrieve() FAILED";
    is_deeply($saved_layout, $new_attr) || diag "Retrieved layout object FAILED to verify.";
}

diag "Testing Layout->save() method with an updated object.";

$saved_layout->set_attr(font => 'C');
my $upd_results = $saved_layout->save();
ok($upd_results ne -1) || diag "Layout->save() FAILED";
my $updated_layout = C4::Labels::Layout->retrieve(layout_id => $sav_results);
is_deeply($updated_layout, $saved_layout) || diag "Updated layout object FAILED to verify.";

diag "Testing Layout->get_text_wrap_cols() method.";

is($updated_layout->get_text_wrap_cols(label_width => 180, left_text_margin => 18), 23, "Layout->get_text_wrap_cols()");

diag "Testing Layout->delete() method.";

my $del_results = $updated_layout->delete();
ok($del_results ne -1) || diag "Layout->delete() FAILED";
