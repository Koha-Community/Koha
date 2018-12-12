#!/usr/bin/perl

# This file is part of Koha.
#
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

use Test::More tests => 3;
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
my $itemtype =
  $builder->build( { source => 'Itemtype', value => { notforloan => undef } } )
  ->{itemtype};

t::lib::Mocks::mock_userenv({ branchcode => $branch_1 });

my $bibnum = $builder->build_sample_biblio({ frameworkcode => $frameworkcode })->biblionumber;

# Create a helper item instance for testing
my ( $item_bibnum, $item_bibitemnum, $itemnumber ) = AddItem(
    {
        homebranch    => $branch_1,
        holdingbranch => $branch_1,
        itype         => $itemtype
    },
    $bibnum
);

# Modify item; setting barcode.
my $testbarcode = '97531';
ModItem( { barcode => $testbarcode }, $bibnum, $itemnumber );

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
};

my $label = C4::Labels::Label->new(
    batch_id         => $batch_id,
    item_number      => $itemnumber,
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
    format_string    => $layout->get_attr('format_string'),
    text_wrap_cols   => $layout->get_text_wrap_cols(
        label_width      => $dummy_template_values->{'label_width'},
        left_text_margin => $dummy_template_values->{'left_text_margin'}
    ),
);

my $label_text = $label->create_label();
ok( defined $label_text, 'Label Text Value defined.' );

my $label_csv_data = $label->csv_data();
ok( defined $label_csv_data, 'Label CSV Data defined' );

$schema->storage->txn_rollback();

1;
