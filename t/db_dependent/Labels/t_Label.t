#!/usr/bin/perl

# This file is part of Koha.
#
# Copyright 2020 Koha Development team
# Copyright (C) 2017  Mark Tompsett
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
use Test::More tests => 7;
use t::lib::TestBuilder;
use t::lib::Mocks;

use MARC::Record;
use MARC::Field;
use Data::Dumper;

use C4::Items;
use C4::Biblio;
use C4::Labels::Layout;

use Koha::Database;

use_ok('C4::Labels::Label');

my $database = Koha::Database->new();
my $schema   = $database->schema();
$schema->storage->txn_begin();

my $batch_id;
my ( $llx, $lly ) = ( 0, 0 );
my $frameworkcode = q{};

## Setup Test
my $builder = t::lib::TestBuilder->new;

# Add branch
my $branch_1 = $builder->build( { source => 'Branch' } )->{branchcode};

# Add categories
my $category_1 = $builder->build( { source => 'Category' } )->{categorycode};

# Add an item type
my $itemtype = $builder->build( { source => 'Itemtype', value => { notforloan => 0 } } )->{itemtype};

t::lib::Mocks::mock_userenv( { branchcode => $branch_1 } );

my $bibnum = $builder->build_sample_biblio( { frameworkcode => $frameworkcode } )->biblionumber;

# Create a helper item instance for testing
my $item = $builder->build_sample_item(
    {
        library      => $branch_1,
        itype        => $itemtype,
        biblionumber => $bibnum,
        enumchron    => "enum",
        copynumber   => "copynum"
    }
);
my $itemnumber = $item->itemnumber;

# Modify item; setting barcode.
my $testbarcode = '97531';
$item->barcode($testbarcode)->store;

my $layout = C4::Labels::Layout->new( layout_name => 'TEST' );

my $dummy_template_values = {
    creator          => 'Labels',
    profile_id       => 0,
    template_code    => 'Avery 5160 | 1 x 2-5/8',
    template_desc    => '3 columns, 10 rows of labels',
    page_width       => 8.5,
    page_height      => 11,
    label_width      => 2.63,
    label_height     => 1,
    top_text_margin  => 0.139,
    left_text_margin => 0.0417,
    top_margin       => 0.35,
    left_margin      => 0.23,
    cols             => 3,
    rows             => 10,
    col_gap          => 0.13,
    row_gap          => 0,
    units            => 'INCH',
    template_stat    => 1,
    barcode_width    => 0.8,
    barcode_height   => 0.01
};

my $label_info = {
    batch_id         => $batch_id,
    item_number      => $item->itemnumber,
    llx              => $llx,
    lly              => $lly,
    width            => $dummy_template_values->{'label_width'},
    height           => $dummy_template_values->{'label_height'},
    top_text_margin  => $dummy_template_values->{'top_text_margin'},
    left_text_margin => $dummy_template_values->{'left_text_margin'},
    barcode_type     => $layout->get_attr('barcode_type'),
    printing_type    => 'BIB',
    guidebox         => $layout->get_attr('guidebox'),
    oblique_title    => $layout->get_attr('oblique_title'),
    font             => $layout->get_attr('font'),
    font_size        => $layout->get_attr('font_size'),
    callnum_split    => $layout->get_attr('callnum_split'),
    justify          => $layout->get_attr('text_justify'),
    text_wrap_cols   => $layout->get_text_wrap_cols(
        label_width      => $dummy_template_values->{'label_width'},
        left_text_margin => $dummy_template_values->{'left_text_margin'}
    ),
    scale_width  => $dummy_template_values->{barcode_width},
    scale_height => $dummy_template_values->{barcode_height},
};

my $format_string  = '100a 245a';
my $barcode_width  = $label_info->{scale_width} * $label_info->{width};
my $barcode_height = $label_info->{scale_height} * $label_info->{height};
my $label          = C4::Labels::Label->new( %$label_info, format_string => $format_string );
my $label_text     = $label->create_label();
ok( defined $label_text, 'Label Text Value defined.' );
my $label_csv_data = $label->csv_data();
is_deeply(
    $label_csv_data,
    [ sprintf( "%s %s", $item->biblio->author, $item->biblio->title ) ]
);

$format_string  = '100a 245a,enumchron copynumber';
$label          = C4::Labels::Label->new( %$label_info, format_string => $format_string );
$label_csv_data = $label->csv_data();
is_deeply(
    $label_csv_data,
    [
        sprintf( "%s %s", $item->biblio->author, $item->biblio->title ),
        sprintf( "%s %s", $item->enumchron,      $item->copynumber )
    ]
);
is( $barcode_width,  '2.104', );
is( $barcode_height, '0.01', );

$schema->storage->txn_rollback();

1;
