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

use Test::NoWarnings;
use Test::More tests => 59;

use C4::Context;
use Koha::Database;

BEGIN {
    use_ok('C4::Labels::Layout');
}

my $schema = Koha::Database->new->schema;
$schema->storage->txn_begin;

my $default_layout = {
    barcode_type  => 'CODE39',
    callnum_split => 0,
    creator       => 'Labels',
    font          => 'TR',
    font_size     => 3,
    format_string => 'title, author, isbn, issn, itemtype, barcode, itemcallnumber',
    guidebox      => 0,
    layout_name   => 'TEST',
    layout_xml    => '',
    oblique_title => 1,
    printing_type => 'BAR',
    scale_height  => 0.01,
    scale_width   => 0.8,
    start_label   => 1,
    text_justify  => 'L',
    units         => 'POINT',
};

my $layout;

# Testing Layout->new()
ok( $layout = C4::Labels::Layout->new( layout_name => 'TEST' ), "Layout->new() success" );
is_deeply( $layout, $default_layout, "New layout object is the expected" );

# Testing Layout->get_attr()
foreach my $key ( keys %{$default_layout} ) {
    ok(
        $default_layout->{$key} eq $layout->get_attr($key),
        "Layout->get_attr() success on attribute $key."
    );
}

# Testing Layout->set_attr()
my $new_attr = {
    barcode_type  => 'CODE39',
    callnum_split => 1,
    creator       => 'Labels',
    font          => 'TR',
    font_size     => 10,
    format_string => 'callnumber, title, author, barcode',
    guidebox      => 1,
    layout_name   => 'TEST',
    layout_xml    => '',
    oblique_title => 0,
    printing_type => 'BIBBAR',
    scale_height  => 0.02,
    scale_width   => 0.9,
    start_label   => 1,
    text_justify  => 'L',
    units         => 'POINT',
};

foreach my $key ( keys %{$new_attr} ) {
    $layout->set_attr( $key => $new_attr->{$key} );
    ok(
        $new_attr->{$key} eq $layout->get_attr($key),
        "Layout->set_attr() success on attribute $key."
    );
}

# Testing Layout->save() method with a new object
my $sav_results = $layout->save();
ok( $sav_results ne -1, "Layout->save() success" );

my $saved_layout;

# Testing Layout->retrieve()
$new_attr->{'layout_id'} = $sav_results;
ok(
    $saved_layout = C4::Labels::Layout->retrieve( layout_id => $sav_results ),
    "Layout->retrieve() success"
);

foreach my $key ( keys %{$new_attr} ) {
    if ( $key eq 'scale_height' || $key eq 'scale_width' ) {

        # workaround for is_deeply failing to compare scale_height and scale_width
        is( $saved_layout->{$key} + 0.00, $new_attr->{$key} );
    } else {
        is( $saved_layout->{$key}, $new_attr->{$key} );
    }
}

# Testing Layout->save() method with an updated object
$saved_layout->set_attr( font => 'C' );
my $upd_results = $saved_layout->save();
ok( $upd_results ne -1, "Layout->save() success" );
my $updated_layout = C4::Labels::Layout->retrieve( layout_id => $sav_results );
is_deeply( $updated_layout, $saved_layout, "Updated layout object is the expected" );

# Testing Layout->get_text_wrap_cols()
is(
    $updated_layout->get_text_wrap_cols( label_width => 180, left_text_margin => 18 ), 21,
    "Layout->get_text_wrap_cols()"
);

# Testing Layout->delete()
my $del_results = $updated_layout->delete();
ok( !defined($del_results), "Layout->delete() success" );

$schema->storage->txn_rollback;
