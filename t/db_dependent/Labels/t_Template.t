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

use Test::More tests => 54;
use C4::Context;

BEGIN {
    use_ok('C4::Labels::Template');
}

my $expect_template = {
        creator         =>      'Labels',
        profile_id      =>      0,
        template_code   =>      'DEFAULT TEMPLATE',
        template_desc   =>      'Default description',
        page_width      =>      8.5,
        page_height     =>      0,
        label_width     =>      0,
        label_height    =>      0,
        top_text_margin =>      0,
        left_text_margin =>      0,
        top_margin      =>      0,
        left_margin     =>      0,
        cols            =>      3,
        rows            =>      0,
        col_gap         =>      0,
        row_gap         =>      0,
        units           =>      'POINT',
        template_stat   =>      0,
};

my $template;

# Testing Template->new()
ok($template = C4::Labels::Template->new(page_width => 8.5,cols => 3),
    "Template->new() success.");
is_deeply($template, $expect_template,  "New template object verify success");

# Testing Template->get_attr()
foreach my $key (keys %{$expect_template}) {
    ok($expect_template->{$key} eq $template->get_attr($key),
        "Template->get_attr() success on attribute $key");
}

# Testing Template->set_attr()
my $new_attr = {
    creator             => 'Labels',
    profile_id          => 0,
    template_code       => 'Avery 5160 | 1 x 2-5/8',
    template_desc       => '3 columns, 10 rows of labels',
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
    template_stat       => 1,
};

foreach my $key (keys %{$new_attr}) {
    next if ($key eq 'template_stat');
    $template->set_attr($key, $new_attr->{$key});
    ok($new_attr->{$key} eq $template->get_attr($key),
       "Template->set_attr() success on attribute $key");
}

# Testing Template->save() with a new object
my $sav_results = $template->save();
ok($sav_results ne -1, "Template->save() success");

my $saved_template;
if ($sav_results ne -1) {
    # Testing Template->retrieve()
    $new_attr->{'template_id'} = $sav_results;
    ok($saved_template = C4::Labels::Template->retrieve(template_id => $sav_results),
       "Template->retrieve() success");
    is_deeply($saved_template, $new_attr,
              "Retrieved template object verify success");
}

# Testing Template->save with an updated object
$saved_template->set_attr(template_desc => 'A test template');
my $upd_results = $saved_template->save();
ok($upd_results ne -1, "Template->save() success");
my $updated_template = C4::Labels::Template->retrieve(template_id => $sav_results);
is_deeply($updated_template, $saved_template, "Updated template object verify success");

# Testing Template->retrieve() convert points option
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
    ok($expect_conv->{$key} eq $conv_template->get_attr($key),
       "Template->retrieve() convert points option success ($expect_conv->{$key})")
       || diag("Expected " . $expect_conv->{$key} . " but got " . $conv_template->get_attr($key) . ".");
}

# Testing Template->delete()
my $del_results = $updated_template->delete();
ok($del_results ne -1, "Template->delete() success");

1;
