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

use Modern::Perl;

use Test::More tests => 38;
use C4::Context;

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
        oblique_title   =>      1,
        font            =>      'TR',
        font_size       =>      3,
        callnum_split   =>      0,
        text_justify    =>      'L',
        format_string   =>      'title, author, isbn, issn, itemtype, barcode, itemcallnumber',
    };

my $layout;

# Testing Layout->new()
ok($layout = C4::Labels::Layout->new(layout_name => 'TEST'), "Layout->new() success");
is_deeply($layout, $default_layout, "New layout object is the expected");

# Testing Layout->get_attr()
foreach my $key (keys %{$default_layout}) {
    ok($default_layout->{$key} eq $layout->get_attr($key),
        "Layout->get_attr() success on attribute $key.");
}

# Testing Layout->set_attr()
my $new_attr = {
        creator         =>      'Labels',
        layout_xml      =>      '',
        units           =>      'POINT',
        start_label     =>      1,
        barcode_type    =>      'CODE39',
        printing_type   =>      'BIBBAR',
        layout_name     =>      'TEST',
        guidebox        =>      1,
        oblique_title   =>      0,
        font            =>      'TR',
        font_size       =>      10,
        callnum_split   =>      1,
        text_justify    =>      'L',
        format_string   =>      'callnumber, title, author, barcode',
    };

foreach my $key (keys %{$new_attr}) {
    $layout->set_attr($key => $new_attr->{$key});
    ok($new_attr->{$key} eq $layout->get_attr($key),
        "Layout->set_attr() success on attribute $key.");
}


# Testing Layout->save() method with a new object
my $sav_results = $layout->save();
ok($sav_results ne -1, "Layout->save() success");

my $saved_layout;
if ($sav_results ne -1) {
    # Testing Layout->retrieve()
    $new_attr->{'layout_id'} = $sav_results;
    ok($saved_layout = C4::Labels::Layout->retrieve(layout_id => $sav_results),
        "Layout->retrieve() success");
    is_deeply($saved_layout, $new_attr,
        "Retrieved layout object is the expected");
}

# Testing Layout->save() method with an updated object
$saved_layout->set_attr(font => 'C');
my $upd_results = $saved_layout->save();
ok($upd_results ne -1, "Layout->save() success");
my $updated_layout = C4::Labels::Layout->retrieve(layout_id => $sav_results);
is_deeply($updated_layout, $saved_layout, "Updated layout object is the expected");

# Testing Layout->get_text_wrap_cols()
is($updated_layout->get_text_wrap_cols(label_width => 180, left_text_margin => 18), 21,
    "Layout->get_text_wrap_cols()");

# Testing Layout->delete()
my $del_results = $updated_layout->delete();
ok( ! defined($del_results) , "Layout->delete() success");

1;
