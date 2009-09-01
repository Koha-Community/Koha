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

use Test::More tests => 54;
use C4::Context;
use Data::Dumper;

BEGIN {
    use_ok('C4::Labels::Template');
}

my $expect_template = {
    tmpl_code           => '',
    tmpl_desc           => '',
    page_width          => 8.5,
    page_height         => 0,
    label_width         => 0,
    label_height        => 0,
    top_text_margin     => 0,
    left_text_margin    => 0,
    top_margin          => 0,
    left_margin         => 0,
    cols                => 3,
    rows                => 0,
    col_gap             => 0,
    row_gap             => 0,
    units               => 'POINT',
    font_size           => 3,
    font                => 'TR',
    tmpl_stat           => 0,
};

my $template;

diag "Testing new template object creation.";
ok($template = C4::Labels::Template->new(page_width => 8.5,cols => 3), "Object created");
is_deeply($template, $expect_template, "Object verified");

diag "Testing get_attr method.";
foreach my $key (keys %{$expect_template}) {
    ok($expect_template->{$key} eq $template->get_attr($key), "Got $key attribute.");
}

diag "Testing set_attr method.";
my $new_attr = {
    tmpl_code           => 'Avery 5160 | 1 x 2-5/8',
    tmpl_desc           => '3 columns, 10 rows of labels',
    page_width          => 8.5,
    page_height         => 11,
    label_width         => 2.63,
    label_height        => 1,
    top_text_margin     => 0.139,
    left_text_margin    => 0.0417,
    top_margin          => 0.35,
    left_margin         => 0.23,
    cols                => 3,
    rows                => 10,
    col_gap             => 0.13,
    row_gap             => 0,
    units               => 'INCH',
    font_size           => 7,
    font                => 'C',
    tmpl_stat           => 1,
};

foreach my $key (keys %{$new_attr}) {
    next if ($key eq 'tmpl_stat');
    $template->set_attr($key, $new_attr->{$key});
    ok($new_attr->{$key} eq $template->get_attr($key), "$key attribute is now set to " . $new_attr->{$key});
}

diag "Testing save method by saving a new record.";

my $sav_results = $template->save();
ok($sav_results ne -1, "Record number $sav_results  saved.") || diag "Error encountered during save. See syslog for details.";

my $saved_template;
if ($sav_results ne -1) {
    diag "Testing retrieve method.";
    $new_attr->{'tmpl_id'} = $sav_results;
    $saved_template = C4::Labels::Template->retrieve(template_id => $sav_results);
    is_deeply($saved_template, $new_attr, "Retrieve method verified.");
}

diag "Testing save method by updating a record.";

$saved_template->set_attr(start_label => 5);
my $upd_results = $saved_template->save();
ok($upd_results ne -1, "Record number $upd_results  updated.") || diag "Error encountered during update. See syslog for details.";
my $updated_template = C4::Labels::Template->retrieve(template_id => $sav_results);
is_deeply($updated_template, $saved_template, "Update verified.");

diag "Testing conv_points method.";

my $conv_template = C4::Labels::Template->retrieve(template_id => $sav_results, convert => 1);
my $expect_conv = {
    page_width          => 612,
    page_height         => 792,
    label_width         => 189.36,
    label_height        => 72,
    top_text_margin     => 10.008,
    left_text_margin    => 3.0024,
    top_margin          => 25.2,
    left_margin         => 16.56,
    col_gap             => 9.36,
    row_gap             => 0,
};

foreach my $key (keys %{$expect_conv}) {
    ok($expect_conv->{$key} eq $conv_template->get_attr($key), "$key converted correctly.") || diag "Expected " . $expect_conv->{$key} . " but got " . $conv_template->get_attr($key) . ".";
}

diag "Testing get_text_wrap_cols method.";
ok ($conv_template->get_text_wrap_cols eq 43, "Get_text_wrap_cols verified.");

diag "Testing delete method.";

my $del_results = $updated_template->delete();
ok($del_results eq 0, "Template deleted.") || diag "Incorrect or non-existent record id. See syslog for details.";
