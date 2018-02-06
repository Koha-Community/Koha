#!/usr/bin/perl

# Copyright 2015 BibLibre
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;
use Graphics::Magick;
use Test::More tests => 645;
use Test::MockModule;
use t::lib::Mocks;
use t::lib::TestBuilder;
use Koha::Database;
use Test::Warn;

BEGIN {
    use_ok('C4::Creators::Lib');
    use_ok('C4::Biblio');
    use_ok('C4::Context');
    use_ok('Koha::Patron');
    use_ok('MARC::Record');
}

can_ok(
    'C4::Creators::Lib', qw(
      get_all_templates
      get_all_layouts
      get_all_profiles
      get_all_image_names
      get_batch_summary
      get_label_summary
      get_card_summary
      get_barcode_types
      get_label_types
      get_font_types
      get_text_justification_types
      get_output_formats
      get_table_names
      get_unit_values
      html_table )
);

my $schema = Koha::Database->schema;
$schema->storage->txn_begin;
my $builder = t::lib::TestBuilder->new;

my $dbh = C4::Context->dbh;
$dbh->do('DELETE FROM issues');
$dbh->do('DELETE FROM creator_templates');
$dbh->do('DELETE FROM creator_layouts');
$dbh->do('DELETE FROM creator_images');
$dbh->do('DELETE FROM creator_batches');
$dbh->do('DELETE FROM printers_profile');
$dbh->do('DELETE FROM borrowers');
$dbh->do('DELETE FROM items');
$dbh->do('DELETE FROM biblioitems');

###########################################################
#                     Inserted data
###########################################################

my $library1 = $builder->build({
    source => 'Branch',
});
my $library2 = $builder->build({
    source => 'Branch',
});
my $library3 = $builder->build({
    source => 'Branch',
});

# ---------- Some Templates  --------------------
my $query = '
  INSERT INTO creator_templates
     (profile_id      , template_code, template_desc, page_width,
      page_height     , label_width  , label_height , top_text_margin,
      left_text_margin, top_margin   , left_margin  , cols,
      rows            , col_gap      , row_gap      , units,
      creator)
  VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
my $insert_sth = $dbh->prepare($query);
$insert_sth->execute( 1, 'TEMPL1', 'Template 1', 100, 150, 10, 15, 2, 3, 1, 4, 9, 6, 0.1, 0.2, 'POINT', 'Labels' );

$insert_sth->execute( 2, 'TEMPL2', 'Template 2', 101, 151, 11, 16, 3, 4, 2, 5, 10, 7, 0.2, 0.3, 'POINT', 'Labels' );
$query = '
  SELECT template_id, template_code
  FROM   creator_templates
  WHERE  profile_id = ?
  ';
my ( $template_id1, $template_code1 ) = $dbh->selectrow_array( $query, {}, 1 );

# ---------- Some Layouts -----------------------
$query = '
  INSERT INTO creator_layouts
    (barcode_type  , start_label , printing_type, layout_name,
     guidebox      , font        , font_size    , units      ,
     callnum_split , text_justify, format_string, layout_xml ,
     creator)
  VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)';
$insert_sth = $dbh->prepare($query);
$insert_sth->execute( 'COOP2OF5', 1, 'BAR1', 'NAME1', 1, 'TR', 11, 'POINT', 1, 'L', 'barcode', 'layout_xml1', 'Labels' );

$insert_sth->execute( 'EAN13', 2, 'BAR2', 'NAME2', 2, 'TR', 12, 'POINT', 2, 'L', 'barcode', 'layout_xml2', 'Labels' );

# ---------- Some Printers  ---------------------
$query = '
  INSERT INTO printers_profile
    (printer_name, template_id, paper_bin,
     offset_horz , offset_vert, creep_horz,
     creep_vert  , units      , creator)
  VALUES (?,?,?,?,?,?,?,?,?)';
$insert_sth = $dbh->prepare($query);
$insert_sth->execute( 'Layout1 Name', 1234, 'Bypass', 0.1, 0.2, 0.3, 0.4, 'POINT', 'Labels' );

$insert_sth->execute( 'Layout2 Name', 1235, 'Bypass', 0.2, 0.3, 0.4, 0.5, 'POINT', 'Labels' );

# ---------- Some Images  -----------------------
my $image1 = Graphics::Magick->new;
my $image2 = Graphics::Magick->new;

$query = '
  INSERT INTO creator_images
    (imagefile, image_name)
  VALUES (?,?)';
$insert_sth = $dbh->prepare($query);
$insert_sth->execute( "$image1->ImageToBlob()", 'Image 1' );
$insert_sth->execute( "$image2->ImageToBlob()", 'Image 2' );

# ---------- Some biblios -----------------------
my $title1  = 'Title 1';
my $title2  = 'Title 2';
my $title3  = 'Title 3';
my $author1 = 'Author 1';
my $author2 = 'Author 2';
my $author3 = 'Author 3';

$query = '
  INSERT INTO biblio
    (title, author, datecreated)
  VALUES (?,?, NOW())';
$insert_sth = $dbh->prepare($query);
$insert_sth->execute( $title1, $author1 );
$insert_sth->execute( $title2, undef );
$insert_sth->execute( $title3, $author3 );

$query = '
  SELECT biblionumber
  FROM   biblio
  WHERE  title = ?';
my $biblionumber1 = $dbh->selectrow_array( $query, {}, $title1 );
my $biblionumber2 = $dbh->selectrow_array( $query, {}, $title2 );
my $biblionumber3 = $dbh->selectrow_array( $query, {}, $title3 );

# ---------- Some biblio items  -------------------------
$query = '
  INSERT INTO biblioitems
    (biblionumber, itemtype)
  VALUES (?,?)';
$insert_sth = $dbh->prepare($query);
$insert_sth->execute( $biblionumber1, 'Book' );
$insert_sth->execute( $biblionumber2, 'Music' );
$insert_sth->execute( $biblionumber3, 'Book' );

$query = '
  SELECT biblioitemnumber
  FROM   biblioitems
  WHERE  biblionumber = ?';
my $biblioitemnumber1 = $dbh->selectrow_array( $query, {}, $biblionumber1 );
my $biblioitemnumber2 = $dbh->selectrow_array( $query, {}, $biblionumber2 );
my $biblioitemnumber3 = $dbh->selectrow_array( $query, {}, $biblionumber3 );

# ---------- Some items  -------------------------
my $barcode1 = '111111';
my $barcode2 = '222222';
my $barcode3 = '333333';

$query = '
  INSERT INTO items
    (biblionumber, biblioitemnumber, barcode, itype)
  VALUES (?,?,?,?)';
$insert_sth = $dbh->prepare($query);
$insert_sth->execute( $biblionumber1, $biblioitemnumber1, $barcode1, 'Book' );
$insert_sth->execute( $biblionumber2, $biblioitemnumber2, $barcode2, 'Music' );
$insert_sth->execute( $biblionumber3, $biblioitemnumber3, $barcode3, 'Book' );

$query = '
  SELECT itemnumber
  FROM   items
  WHERE  barcode = ?';
my $item_number1 = $dbh->selectrow_array( $query, {}, $barcode1 );
my $item_number2 = $dbh->selectrow_array( $query, {}, $barcode2 );
my $item_number3 = $dbh->selectrow_array( $query, {}, $barcode3 );

# ---------- Some borrowers  ---------------------
my $surname1     = 'Borrower 1';
my $surname2     = 'Borrower 2';
my $surname3     = 'Borrower 3';
my $firstname1   = 'firstname 1';
my $firstname2   = 'firstname 2';
my $firstname3   = 'firstname 3';
my $cardnumber1  = '00001';
my $cardnumber2  = '00002';
my $cardnumber3  = '00003';
my $categorycode = Koha::Database->new()->schema()->resultset('Category')->first()->categorycode();
my $branchcode   = Koha::Database->new()->schema()->resultset('Branch')->first()->branchcode();

$query = '
 INSERT INTO borrowers
    (surname, firstname, cardnumber, branchcode, categorycode)
  VALUES (?,?,?,?,?)';
$insert_sth = $dbh->prepare($query);
$insert_sth->execute( $surname1, $firstname1, $cardnumber1, $branchcode, $categorycode );
$insert_sth->execute( $surname2, $firstname2, $cardnumber2, $branchcode, $categorycode );
$insert_sth->execute( $surname3, $firstname3, $cardnumber3, $branchcode, $categorycode );

$query = '
  SELECT borrowernumber
  FROM   borrowers
  WHERE  surname = ?';
my $borrowernumber1 = $dbh->selectrow_array( $query, {}, $surname1 );
my $borrowernumber2 = $dbh->selectrow_array( $query, {}, $surname2 );
my $borrowernumber3 = $dbh->selectrow_array( $query, {}, $surname3 );

# ---------- Some batches  -----------------------
$query = '
  INSERT INTO creator_batches
    (batch_id , item_number, borrower_number,
     timestamp, branch_code, creator)
  VALUES (?,?,?,NOW(),?,?)';
$insert_sth = $dbh->prepare($query);
$insert_sth->execute( 11, $item_number1, $borrowernumber1, $library1->{branchcode}, 'Labels' );

$insert_sth->execute( 12, $item_number2, $borrowernumber2, $library2->{branchcode}, 'Labels' );

$insert_sth->execute( 12, $item_number3, $borrowernumber3, $library3->{branchcode}, 'Labels' );

###########################################################
#                     Testing Subs
###########################################################

# ---------- Testing get_all_templates --------------------
# Mocking $sth->err and $sth->errstr
{
    my $dbi_st = Test::MockModule->new( 'DBI::st', no_auto => 1 );
    $dbi_st->mock( 'err',    sub { return 1; } );
    $dbi_st->mock( 'errstr', sub { return 'something went wrong'; } );
    my $templates;
    warning_is { $templates = get_all_templates() } 'Database returned the following error: something went wrong',
      'get_all_templates() raises warning if something went wrong with the sql request execution';

    is( $templates, -1, '$templates return -1' );
}

# Without params ----------------------
my $templates = get_all_templates();

$query = '
  SELECT count(*)
  FROM   creator_templates
  ';
my $count = $dbh->selectrow_array($query);
is( $count,      2,      'There are 2 templates' );
is( @$templates, $count, 'There are 2 templates matching' );
isa_ok( $templates, 'ARRAY', '$templates is an ARRAY' );

isa_ok( $templates->[0], 'HASH', '$templates->[0]  is a HASH' );
is( $templates->[0]->{profile_id},       1,            'profile_id       is good' );
is( $templates->[0]->{template_code},    'TEMPL1',     'template_code    is good' );
is( $templates->[0]->{template_desc},    'Template 1', 'template_desc    is good' );
is( $templates->[0]->{page_width},       100,          'page_width       is good' );
is( $templates->[0]->{page_height},      150,          'page_height      is good' );
is( $templates->[0]->{label_width},      10,           'label_width      is good' );
is( $templates->[0]->{label_height},     15,           'label_height     is good' );
is( $templates->[0]->{top_text_margin},  2,            'top_text_margin  is good' );
is( $templates->[0]->{left_text_margin}, 3,            'left_text_margin is good' );
is( $templates->[0]->{top_margin},       1,            'top_margin       is good' );
is( $templates->[0]->{left_margin},      4,            'left_margin      is good' );
is( $templates->[0]->{cols},             9,            'cols             is good' );
is( $templates->[0]->{rows},             6,            'rows             is good' );
is( $templates->[0]->{col_gap},          0.1,          'col_gap          is good' );
is( $templates->[0]->{row_gap},          0.2,          'row_gap          is good' );
is( $templates->[0]->{units},            'POINT',      'units            is good' );
is( $templates->[0]->{creator},          'Labels',     'creator          is good' );

isa_ok( $templates->[1], 'HASH', '$templates->[1]  is a HASH' );
is( $templates->[1]->{profile_id},       2,            'profile_id       is good' );
is( $templates->[1]->{template_code},    'TEMPL2',     'template_code    is good' );
is( $templates->[1]->{template_desc},    'Template 2', 'template_desc    is good' );
is( $templates->[1]->{page_width},       101,          'page_width       is good' );
is( $templates->[1]->{page_height},      151,          'page_height      is good' );
is( $templates->[1]->{label_width},      11,           'label_width      is good' );
is( $templates->[1]->{label_height},     16,           'label_height     is good' );
is( $templates->[1]->{top_text_margin},  3,            'top_text_margin  is good' );
is( $templates->[1]->{left_text_margin}, 4,            'left_text_margin is good' );
is( $templates->[1]->{top_margin},       2,            'top_margin       is good' );
is( $templates->[1]->{left_margin},      5,            'left_margin      is good' );
is( $templates->[1]->{cols},             10,           'cols             is good' );
is( $templates->[1]->{rows},             7,            'rows             is good' );
is( $templates->[1]->{col_gap},          0.2,          'col_gap          is good' );
is( $templates->[1]->{row_gap},          0.3,          'row_gap          is good' );
is( $templates->[1]->{units},            'POINT',      'units            is good' );
is( $templates->[1]->{creator},          'Labels',     'creator          is good' );

# With field_list params --------------
$templates = get_all_templates( {fields=> [qw(units cols rows)] } );

$query = '
  SELECT count(*)
  FROM   creator_templates
  ';
$count = $dbh->selectrow_array($query);
is( $count,      2,      'There are 2 templates' );
is( @$templates, $count, 'There are 2 templates matching' );
isa_ok( $templates, 'ARRAY', '$templates is an ARRAY' );

isa_ok( $templates->[0], 'HASH', '$templates->[0]  is a HASH' );
isnt( exists $templates->[0]->{profile_id},       1,            'profile_id       is good' );
isnt( exists $templates->[0]->{template_code},    'TEMPL1',     'template_code    is good' );
isnt( exists $templates->[0]->{template_desc},    'Template 1', 'template_desc    is good' );
isnt( exists $templates->[0]->{page_width},       100,          'page_width       is good' );
isnt( exists $templates->[0]->{page_height},      150,          'page_height      is good' );
isnt( exists $templates->[0]->{label_width},      10,           'label_width      is good' );
isnt( exists $templates->[0]->{label_height},     15,           'label_height     is good' );
isnt( exists $templates->[0]->{top_text_margin},  2,            'top_text_margin  is good' );
isnt( exists $templates->[0]->{left_text_margin}, 3,            'left_text_margin is good' );
isnt( exists $templates->[0]->{top_margin},       1,            'top_margin       is good' );
isnt( exists $templates->[0]->{left_margin},      4,            'left_margin      is good' );
is  (        $templates->[0]->{cols},             9,            'cols             is good' );
is  (        $templates->[0]->{rows},             6,            'rows             is good' );
isnt( exists $templates->[0]->{col_gap},          0.1,          'col_gap          is good' );
isnt( exists $templates->[0]->{row_gap},          0.2,          'row_gap          is good' );
is  (        $templates->[0]->{units},            'POINT',      'units            is good' );
isnt( exists $templates->[0]->{creator},          'Labels',     'creator          is good' );

isa_ok( $templates->[1], 'HASH', '$templates->[1]  is a HASH' );
isnt( exists $templates->[1]->{profile_id},       2,            'profile_id       is good' );
isnt( exists $templates->[1]->{template_code},    'TEMPL2',     'template_code    is good' );
isnt( exists $templates->[1]->{template_desc},    'Template 2', 'template_desc    is good' );
isnt( exists $templates->[1]->{page_width},       101,          'page_width       is good' );
isnt( exists $templates->[1]->{page_height},      151,          'page_height      is good' );
isnt( exists $templates->[1]->{label_width},      11,           'label_width      is good' );
isnt( exists $templates->[1]->{label_height},     16,           'label_height     is good' );
isnt( exists $templates->[1]->{top_text_margin},  3,            'top_text_margin  is good' );
isnt( exists $templates->[1]->{left_text_margin}, 4,            'left_text_margin is good' );
isnt( exists $templates->[1]->{top_margin},       2,            'top_margin       is good' );
isnt( exists $templates->[1]->{left_margin},      5,            'left_margin      is good' );
is  (        $templates->[1]->{cols},             10,           'cols             is good' );
is  (        $templates->[1]->{rows},             7,            'rows             is good' );
isnt( exists $templates->[1]->{col_gap},          0.2,          'col_gap          is good' );
isnt( exists $templates->[1]->{row_gap},          0.3,          'row_gap          is good' );
is  (        $templates->[1]->{units},            'POINT',      'units            is good' );
isnt( exists $templates->[1]->{creator},          'Labels',     'creator          is good' );

# With filters params ------------------
$templates = get_all_templates( { filters => { rows => 7} } );

$query = '
  SELECT count(*)
  FROM   creator_templates
  WHERE  rows = 7
  ';
$count = $dbh->selectrow_array($query);
is( $count,      1,      'There is 1 template matching' );
is( @$templates, $count, 'There is 1 template matching' );
isa_ok( $templates, 'ARRAY', '$templates is an ARRAY' );

isa_ok( $templates->[0], 'HASH', '$templates->[0]  is a HASH' );
is( $templates->[0]->{profile_id},       2,            'profile_id       is good' );
is( $templates->[0]->{template_code},    'TEMPL2',     'template_code    is good' );
is( $templates->[0]->{template_desc},    'Template 2', 'template_desc    is good' );
is( $templates->[0]->{page_width},       101,          'page_width       is good' );
is( $templates->[0]->{page_height},      151,          'page_height      is good' );
is( $templates->[0]->{label_width},      11,           'label_width      is good' );
is( $templates->[0]->{label_height},     16,           'label_height     is good' );
is( $templates->[0]->{top_text_margin},  3,            'top_text_margin  is good' );
is( $templates->[0]->{left_text_margin}, 4,            'left_text_margin is good' );
is( $templates->[0]->{top_margin},       2,            'top_margin       is good' );
is( $templates->[0]->{left_margin},      5,            'left_margin      is good' );
is( $templates->[0]->{cols},             10,           'cols             is good' );
is( $templates->[0]->{rows},             7,            'rows             is good' );
is( $templates->[0]->{col_gap},          0.2,          'col_gap          is good' );
is( $templates->[0]->{row_gap},          0.3,          'row_gap          is good' );
is( $templates->[0]->{units},            'POINT',      'units            is good' );
is( $templates->[0]->{creator},          'Labels',     'creator          is good' );

$templates = get_all_templates( { filters => { rows => [-42, 7]} } );
is( @$templates, $count, 'There is 1 template matching' );
# With orderby param ------------------
$templates = get_all_templates( { orderby => 'rows DESC' } );

$query = '
  SELECT    count(*)
  FROM      creator_templates
  ORDER BY  rows DESC
  ';
$count = $dbh->selectrow_array($query);
is( $count,      2,      'There are 2 templates' );
is( @$templates, $count, 'There are 2 templates matching' );
isa_ok( $templates, 'ARRAY', '$templates is an ARRAY' );

isa_ok( $templates->[0], 'HASH', '$templates->[0]  is a HASH' );
is( $templates->[0]->{profile_id},       2,            'profile_id       is good' );
is( $templates->[0]->{template_code},    'TEMPL2',     'template_code    is good' );
is( $templates->[0]->{template_desc},    'Template 2', 'template_desc    is good' );
is( $templates->[0]->{page_width},       101,          'page_width       is good' );
is( $templates->[0]->{page_height},      151,          'page_height      is good' );
is( $templates->[0]->{label_width},      11,           'label_width      is good' );
is( $templates->[0]->{label_height},     16,           'label_height     is good' );
is( $templates->[0]->{top_text_margin},  3,            'top_text_margin  is good' );
is( $templates->[0]->{left_text_margin}, 4,            'left_text_margin is good' );
is( $templates->[0]->{top_margin},       2,            'top_margin       is good' );
is( $templates->[0]->{left_margin},      5,            'left_margin      is good' );
is( $templates->[0]->{cols},             10,           'cols             is good' );
is( $templates->[0]->{rows},             7,            'rows             is good' );
is( $templates->[0]->{col_gap},          0.2,          'col_gap          is good' );
is( $templates->[0]->{row_gap},          0.3,          'row_gap          is good' );
is( $templates->[0]->{units},            'POINT',      'units            is good' );
is( $templates->[0]->{creator},          'Labels',     'creator          is good' );

isa_ok( $templates->[1], 'HASH', '$templates->[1]  is a HASH' );
is( $templates->[1]->{profile_id},       1,            'profile_id       is good' );
is( $templates->[1]->{template_code},    'TEMPL1',     'template_code    is good' );
is( $templates->[1]->{template_desc},    'Template 1', 'template_desc    is good' );
is( $templates->[1]->{page_width},       100,          'page_width       is good' );
is( $templates->[1]->{page_height},      150,          'page_height      is good' );
is( $templates->[1]->{label_width},      10,           'label_width      is good' );
is( $templates->[1]->{label_height},     15,           'label_height     is good' );
is( $templates->[1]->{top_text_margin},  2,            'top_text_margin  is good' );
is( $templates->[1]->{left_text_margin}, 3,            'left_text_margin is good' );
is( $templates->[1]->{top_margin},       1,            'top_margin       is good' );
is( $templates->[1]->{left_margin},      4,            'left_margin      is good' );
is( $templates->[1]->{cols},             9,            'cols             is good' );
is( $templates->[1]->{rows},             6,            'rows             is good' );
is( $templates->[1]->{col_gap},          0.1,          'col_gap          is good' );
is( $templates->[1]->{row_gap},          0.2,          'row_gap          is good' );
is( $templates->[1]->{units},            'POINT',      'units            is good' );
is( $templates->[1]->{creator},          'Labels',     'creator          is good' );

# ---------- Testing get_all_layouts ----------------------
# Mocking $sth->err and $sth->errstr
{
    my $dbi_st = Test::MockModule->new( 'DBI::st', no_auto => 1 );
    $dbi_st->mock( 'err',    sub { return 1; } );
    $dbi_st->mock( 'errstr', sub { return 'something went wrong'; } );
    my $layouts;
    warning_is { $layouts = get_all_layouts() } 'Database returned the following error: something went wrong',
      'get_all_layouts() raises warning if something went wrong with the sql request execution';

    is( $layouts, -1, '$layouts return -1' );
}

# Without params ----------------------
my $layouts = get_all_layouts();

$query = '
  SELECT count(*)
  FROM   creator_layouts
  ';
$count = $dbh->selectrow_array($query);
is( $count,    2,      'There are 2 layouts' );
is( @$layouts, $count, 'There are 2 layouts matching' );
isa_ok( $layouts, 'ARRAY', '$layouts is an ARRAY' );

isa_ok( $layouts->[0], 'HASH', '$layouts->[0]  is a HASH' );
is( $layouts->[0]->{barcode_type},  'COOP2OF5',    'barcode_type   is good' );
is( $layouts->[0]->{start_label},   1,             'start_label    is good' );
is( $layouts->[0]->{printing_type}, 'BAR1',        'printing_type  is good' );
is( $layouts->[0]->{layout_name},   'NAME1',       'layout_name    is good' );
is( $layouts->[0]->{guidebox},      1,             'guidebox       is good' );
is( $layouts->[0]->{font},          'TR',          'font           is good' );
is( $layouts->[0]->{font_size},     11,            'font_size      is good' );
is( $layouts->[0]->{units},         'POINT',       'units          is good' );
is( $layouts->[0]->{callnum_split}, 1,             'callnum_split  is good' );
is( $layouts->[0]->{text_justify},  'L',           'text_justify   is good' );
is( $layouts->[0]->{format_string}, 'barcode',     'format_string  is good' );
is( $layouts->[0]->{layout_xml},    'layout_xml1', 'layout_xml     is good' );
is( $layouts->[0]->{creator},       'Labels',      'creator        is good' );

isa_ok( $layouts->[1], 'HASH', '$layouts->[1]  is a HASH' );
is( $layouts->[1]->{barcode_type},  'EAN13',       'barcode_type   is good' );
is( $layouts->[1]->{start_label},   2,             'start_label    is good' );
is( $layouts->[1]->{printing_type}, 'BAR2',        'printing_type  is good' );
is( $layouts->[1]->{layout_name},   'NAME2',       'layout_name    is good' );
is( $layouts->[1]->{guidebox},      2,             'guidebox       is good' );
is( $layouts->[1]->{font},          'TR',          'font           is good' );
is( $layouts->[1]->{font_size},     12,            'font_size      is good' );
is( $layouts->[1]->{units},         'POINT',       'units          is good' );
is( $layouts->[1]->{callnum_split}, 2,             'callnum_split  is good' );
is( $layouts->[1]->{text_justify},  'L',           'text_justify   is good' );
is( $layouts->[1]->{format_string}, 'barcode',     'format_string  is good' );
is( $layouts->[1]->{layout_xml},    'layout_xml2', 'layout_xml     is good' );
is( $layouts->[1]->{creator},       'Labels',      'creator        is good' );

# With field_list params --------------
$layouts = get_all_layouts( { fields => [qw(barcode_type layout_name font)] });

$query = '
  SELECT count(*)
  FROM   creator_layouts
  ';
$count = $dbh->selectrow_array($query);
is( $count,    2,      'There are 2 layouts' );
is( @$layouts, $count, 'There are 2 layouts matching' );
isa_ok( $layouts, 'ARRAY', '$layouts is an ARRAY' );

isa_ok( $layouts->[0], 'HASH', '$layouts->[0]  is a HASH' );
is  (        $layouts->[0]->{barcode_type},  'COOP2OF5',    'barcode_type   is good' );
isnt( exists $layouts->[0]->{start_label},   1,             'start_label    is good' );
isnt( exists $layouts->[0]->{printing_type}, 'BAR1',        'printing_type  is good' );
is  (        $layouts->[0]->{layout_name},   'NAME1',       'layout_name    is good' );
isnt( exists $layouts->[0]->{guidebox},      1,             'guidebox       is good' );
is  (        $layouts->[0]->{font},         'TR',           'font           is good' );
isnt( exists $layouts->[0]->{font_size},     11,            'font_size      is good' );
isnt( exists $layouts->[0]->{units},         'POINT',       'units          is good' );
isnt( exists $layouts->[0]->{callnum_split}, 1,             'callnum_split  is good' );
isnt( exists $layouts->[0]->{text_justify},  'L',           'text_justify   is good' );
isnt( exists $layouts->[0]->{format_string}, 'barcode',     'format_string  is good' );
isnt( exists $layouts->[0]->{layout_xml},    'layout_xml1', 'layout_xml     is good' );
isnt( exists $layouts->[0]->{creator},       'Labels',      'creator        is good' );

isa_ok( $layouts->[1], 'HASH', '$layouts->[1] is a HASH' );
is  (        $layouts->[1]->{barcode_type},   'EAN13',      'barcode_type   is good' );
isnt( exists $layouts->[1]->{start_label},    2,            'start_label    is good' );
isnt( exists $layouts->[1]->{printing_type},  'BAR2',       'printing_type  is good' );
is  (        $layouts->[1]->{layout_name},    'NAME2',      'layout_name    is good' );
isnt( exists $layouts->[1]->{guidebox},       2,            'guidebox       is good' );
is  (        $layouts->[1]->{font},          'TR',          'font           is good' );
isnt( exists $layouts->[1]->{font_size},      12,           'font_size      is good' );
isnt( exists $layouts->[1]->{units},         'POINT',       'units          is good' );
isnt( exists $layouts->[1]->{callnum_split},  2,            'callnum_split  is good' );
isnt( exists $layouts->[1]->{text_justify},  'L',           'text_justify   is good' );
isnt( exists $layouts->[1]->{format_string}, 'barcode',     'format_string  is good' );
isnt( exists $layouts->[1]->{layout_xml},    'layout_xml2', 'layout_xml     is good' );
isnt( exists $layouts->[1]->{creator},       'Labels',      'creator        is good' );

# With filters params ------------------
$layouts = get_all_layouts( { filters => { font_size => 12 } } );

$query = '
  SELECT count(*)
  FROM   creator_layouts
  WHERE  font_size = 12
  ';
$count = $dbh->selectrow_array($query);
is( $count,    1,      'There is 1 layout matching' );
is( @$layouts, $count, 'There is 1 layout matching' );
isa_ok( $layouts, 'ARRAY', '$layouts is an ARRAY' );

isa_ok( $layouts->[0], 'HASH', '$layouts->[0]  is a HASH' );
is( $layouts->[0]->{barcode_type},  'EAN13',       'barcode_type   is good' );
is( $layouts->[0]->{start_label},   2,             'start_label    is good' );
is( $layouts->[0]->{printing_type}, 'BAR2',        'printing_type  is good' );
is( $layouts->[0]->{layout_name},   'NAME2',       'layout_name    is good' );
is( $layouts->[0]->{guidebox},      2,             'guidebox       is good' );
is( $layouts->[0]->{font},          'TR',          'font           is good' );
is( $layouts->[0]->{font_size},     12,            'font_size      is good' );
is( $layouts->[0]->{units},         'POINT',       'units          is good' );
is( $layouts->[0]->{callnum_split}, 2,             'callnum_split  is good' );
is( $layouts->[0]->{text_justify},  'L',           'text_justify   is good' );
is( $layouts->[0]->{format_string}, 'barcode',     'format_string  is good' );
is( $layouts->[0]->{layout_xml},    'layout_xml2', 'layout_xml     is good' );
is( $layouts->[0]->{creator},       'Labels',      'creator        is good' );

# With orderby param ------------------
$layouts = get_all_layouts( { orderby => 'font_size DESC' } );

$query = '
  SELECT   count(*)
  FROM     creator_layouts
  ORDER BY font_size DESC
  ';
$count = $dbh->selectrow_array($query);
is( $count,    2,      'There are layout matching' );
is( @$layouts, $count, 'There are 2 layouts matching' );
isa_ok( $layouts, 'ARRAY', '$layouts is an ARRAY' );

isa_ok( $layouts->[0], 'HASH', '$layouts->[0]  is a HASH' );
is( $layouts->[0]->{barcode_type},  'EAN13',       'barcode_type   is good' );
is( $layouts->[0]->{start_label},   2,             'start_label    is good' );
is( $layouts->[0]->{printing_type}, 'BAR2',        'printing_type  is good' );
is( $layouts->[0]->{layout_name},   'NAME2',       'layout_name    is good' );
is( $layouts->[0]->{guidebox},      2,             'guidebox       is good' );
is( $layouts->[0]->{font},          'TR',          'font           is good' );
is( $layouts->[0]->{font_size},     12,            'font_size      is good' );
is( $layouts->[0]->{units},         'POINT',       'units          is good' );
is( $layouts->[0]->{callnum_split}, 2,             'callnum_split  is good' );
is( $layouts->[0]->{text_justify},  'L',           'text_justify   is good' );
is( $layouts->[0]->{format_string}, 'barcode',     'format_string  is good' );
is( $layouts->[0]->{layout_xml},    'layout_xml2', 'layout_xml     is good' );
is( $layouts->[0]->{creator},       'Labels',      'creator        is good' );

isa_ok( $layouts->[1], 'HASH', '$layouts->[1]  is a HASH' );
is( $layouts->[1]->{barcode_type},  'COOP2OF5',    'barcode_type   is good' );
is( $layouts->[1]->{start_label},   1,             'start_label    is good' );
is( $layouts->[1]->{printing_type}, 'BAR1',        'printing_type  is good' );
is( $layouts->[1]->{layout_name},   'NAME1',       'layout_name    is good' );
is( $layouts->[1]->{guidebox},      1,             'guidebox       is good' );
is( $layouts->[1]->{font},          'TR',          'font           is good' );
is( $layouts->[1]->{font_size},     11,            'font_size      is good' );
is( $layouts->[1]->{units},         'POINT',       'units          is good' );
is( $layouts->[1]->{callnum_split}, 1,             'callnum_split  is good' );
is( $layouts->[1]->{text_justify},  'L',           'text_justify   is good' );
is( $layouts->[1]->{format_string}, 'barcode',     'format_string  is good' );
is( $layouts->[1]->{layout_xml},    'layout_xml1', 'layout_xml     is good' );
is( $layouts->[1]->{creator},       'Labels',      'creator        is good' );

# ---------- Testing get_all_profiles ---------------------
# Mocking $sth->err and $sth->errstr
{
    my $dbi_st = Test::MockModule->new( 'DBI::st', no_auto => 1 );
    $dbi_st->mock( 'err',    sub { return 1; } );
    $dbi_st->mock( 'errstr', sub { return 'something went wrong'; } );
    my $profiles;
    warning_is { $profiles = get_all_profiles() } 'Database returned the following error: something went wrong',
      'get_all_profiles() raises warning if something went wrong with the sql request execution';

    is( $profiles, -1, '$profiles return -1' );
}

# Without params ----------------------
my $profiles = get_all_profiles();

$query = '
  SELECT count(*)
  FROM   printers_profile
  ';
$count = $dbh->selectrow_array($query);
is( $count,     2,      'There are 2 profiles' );
is( @$profiles, $count, 'There are 2 profiles matching' );
isa_ok( $profiles, 'ARRAY', '$profiles is an ARRAY' );

isa_ok( $profiles->[0], 'HASH', '$profiles->[0] is a HASH' );
is( $profiles->[0]->{printer_name}, 'Layout1 Name', 'printer_name   is good' );
is( $profiles->[0]->{template_id},  1234,           'template_id    is good' );
is( $profiles->[0]->{paper_bin},    'Bypass',       'paper_bin      is good' );
is( $profiles->[0]->{offset_horz},  0.1,            'offset_horz    is good' );
is( $profiles->[0]->{offset_vert},  0.2,            'offset_vert    is good' );
is( $profiles->[0]->{creep_horz},   0.3,            'creep_horz     is good' );
is( $profiles->[0]->{creep_vert},   0.4,            'creep_vert     is good' );
is( $profiles->[0]->{units},        'POINT',        'units          is good' );
is( $profiles->[0]->{creator},      'Labels',       'creator        is good' );

isa_ok( $profiles->[1], 'HASH', '$profiles->[1] is a HASH' );
is( $profiles->[1]->{printer_name}, 'Layout2 Name', 'printer_name   is good' );
is( $profiles->[1]->{template_id},  1235,           'template_id    is good' );
is( $profiles->[1]->{paper_bin},    'Bypass',       'paper_bin      is good' );
is( $profiles->[1]->{offset_horz},  0.2,            'offset_horz    is good' );
is( $profiles->[1]->{offset_vert},  0.3,            'offset_vert    is good' );
is( $profiles->[1]->{creep_horz},   0.4,            'creep_horz     is good' );
is( $profiles->[1]->{creep_vert},   0.5,            'creep_vert     is good' );
is( $profiles->[1]->{units},        'POINT',        'units          is good' );
is( $profiles->[1]->{creator},      'Labels',       'creator        is good' );

# With field_list params --------------
$profiles = get_all_profiles( { fields => [qw(printer_name template_id)] });

$query = '
  SELECT count(*)
  FROM   printers_profile
  ';
$count = $dbh->selectrow_array($query);
is( $count,     2,      'There are 2 profiles' );
is( @$profiles, $count, 'There are 2 profiles matching' );
isa_ok( $profiles, 'ARRAY', '$profiles is an ARRAY' );

isa_ok( $profiles->[0], 'HASH', '$profiles->[0] is a HASH' );
is  (        $profiles->[0]->{printer_name},  'Layout1 Name', 'printer_name   is good' );
is  (        $profiles->[0]->{template_id},   1234,           'template_id    is good' );
isnt( exists $profiles->[0]->{paper_bin},     'Bypass',       'paper_bin      is good' );
isnt( exists $profiles->[0]->{offset_horz},   0.1,            'offset_horz    is good' );
isnt( exists $profiles->[0]->{offset_vert},   0.2,            'offset_vert    is good' );
isnt( exists $profiles->[0]->{creep_horz},    0.3,            'creep_horz     is good' );
isnt( exists $profiles->[0]->{creep_vert},    0.4,            'creep_vert     is good' );
isnt( exists $profiles->[0]->{units},         'POINT',        'units          is good' );
isnt( exists $profiles->[0]->{creator},       'Labels',       'creator        is good' );

isa_ok( $profiles->[1], 'HASH', '$profiles->[1] is a HASH' );
is  (        $profiles->[1]->{printer_name},  'Layout2 Name', 'printer_name   is good' );
is  (        $profiles->[1]->{template_id},   1235,           'template_id    is good' );
isnt( exists $profiles->[1]->{paper_bin},     'Bypass',       'paper_bin      is good' );
isnt( exists $profiles->[1]->{offset_horz},   0.2,            'offset_horz    is good' );
isnt( exists $profiles->[1]->{offset_vert},   0.3,            'offset_vert    is good' );
isnt( exists $profiles->[1]->{creep_horz},    0.4,            'creep_horz     is good' );
isnt( exists $profiles->[1]->{creep_vert},    0.5,            'creep_vert     is good' );
isnt( exists $profiles->[1]->{units},         'POINT',        'units          is good' );
isnt( exists $profiles->[1]->{creator},       'Labels',       'creator        is good' );

# With filters params ------------------
$profiles = get_all_profiles( { filters => { template_id => 1235 } } );

$query = '
  SELECT count(*)
  FROM   printers_profile
  WHERE  template_id = 1235
  ';
$count = $dbh->selectrow_array($query);
is( $count,     1,      'There is 1 profile matching' );
is( @$profiles, $count, 'There is 1 profile matching' );
isa_ok( $profiles, 'ARRAY', '$profiles is an ARRAY' );

isa_ok( $profiles->[0], 'HASH', '$profiles->[0] is a HASH' );
is  (        $profiles->[0]->{printer_name},  'Layout2 Name', 'printer_name   is good' );
is  (        $profiles->[0]->{template_id},   1235,           'template_id    is good' );
isnt( exists $profiles->[0]->{paper_bin},     'Bypass',       'paper_bin      is good' );
isnt( exists $profiles->[0]->{offset_horz},   0.2,            'offset_horz    is good' );
isnt( exists $profiles->[0]->{offset_vert},   0.3,            'offset_vert    is good' );
isnt( exists $profiles->[0]->{creep_horz},    0.4,            'creep_horz     is good' );
isnt( exists $profiles->[0]->{creep_vert},    0.5,            'creep_vert     is good' );
isnt( exists $profiles->[0]->{units},         'POINT',        'units          is good' );
isnt( exists $profiles->[0]->{creator},       'Labels',       'creator        is good' );

# ---------- Testing get_all_image_names ------------------

# Mocking $sth->err and $sth->errstr
{
    my $dbi_st = Test::MockModule->new( 'DBI::st', no_auto => 1 );
    $dbi_st->mock( 'err',    sub { return 1; } );
    $dbi_st->mock( 'errstr', sub { return 'something went wrong'; } );
    my $images;
    warning_is { $images = get_all_image_names() } 'Database returned the following error: something went wrong',
      'get_all_image_names() raises warning if something went wrong with the sql request execution';

    is( $images, -1, '$images return -1' );
}

# Without params ----------------------
my $images = get_all_image_names();

$query = '
  SELECT count(*)
  FROM   creator_images
  ';
$count = $dbh->selectrow_array($query);
is( $count,   2,      'There are 2 images' );
is( @$images, $count, 'There are 2 images matching' );
isa_ok( $images, 'ARRAY', '$images is an ARRAY' );

isa_ok( $images->[0], 'HASH', '$images->[0] is a HASH' );
is( $images->[0]->{name},     'Image 1',            'name         is good' );
is( $images->[0]->{selected}, 0,                    'selected     is good' );
is( $images->[0]->{type},     $images->[0]->{name}, 'type         is good' );

isa_ok( $images->[1], 'HASH', '$images->[1] is a HASH' );
is( $images->[1]->{name},     'Image 2',            'name         is good' );
is( $images->[1]->{selected}, 0,                    'selected     is good' );
is( $images->[1]->{type},     $images->[1]->{name}, 'type         is good' );

# ---------- Testing get_batch_summary --------------------

# Mocking $sth->err and $sth->errstr
{
    my $dbi_st = Test::MockModule->new( 'DBI::st', no_auto => 1 );
    $dbi_st->mock( 'err',    sub { return 1; } );
    $dbi_st->mock( 'errstr', sub { return 'something went wrong'; } );
    my $batches;
    warning_is { $batches = get_batch_summary() } 'Database returned the following error on attempted SELECT: something went wrong',
      'get_batch_summary() raises warning if something went wrong with the sql request execution';

    is( $batches, -1, '$batches return -1' );
}

# Without creator params --------------
my $batches = get_batch_summary( { filters => { creator => 'Labels' } } );

$query = '
  SELECT   batch_id, count(batch_id)
  FROM     creator_batches
  WHERE    creator = ?
  GROUP BY batch_id
  ';
my $sth = $dbh->prepare($query);
$sth->execute('Labels');
$count = $sth->rows;
is( $count,    2,      'There are 2 batches' );
is( @$batches, $count, 'There are 2 batches matching' );
isa_ok( $batches, 'ARRAY', '$batches is an ARRAY' );

$query = '
  SELECT count(batch_id)
  FROM   creator_batches
  WHERE  creator = ?
    AND  batch_id = ?
  ';
$count = $dbh->selectrow_array( $query, {}, 'Labels', 11 );
is( $count, 1, 'There is 1 batch where batch_id = 11' );

isa_ok( $batches->[0], 'HASH', '$batches->[0] is a HASH' );
is( $batches->[0]->{batch_id},    11,     'batch_id      is good' );
is( $batches->[0]->{_item_count}, $count, 'item_number   is good for this batch_id' );

$count = $dbh->selectrow_array( $query, {}, 'Labels', 12 );
is( $count, 2, 'There are 2 batches where batch_id = 12' );

isa_ok( $batches->[1], 'HASH', '$batches->[1] is a HASH' );
is( $batches->[1]->{batch_id},    12,     'batch_id      is good' );
is( $batches->[1]->{_item_count}, $count, 'item_number   is good for this batch_id' );

# Without filters -----
$batches = get_batch_summary( { filters => { branch_code => $library1->{branchcode}, creator => 'Labels' } } );
is( @$batches, 1, 'There is 1 batch matching' );

$query = '
  SELECT   batch_id, count(batch_id)
  FROM     creator_batches
  WHERE    creator = ?
    AND    branch_code = ?
  GROUP BY batch_id
  ';
my ( $id, $nb ) = $dbh->selectrow_array( $query, {}, 'Labels', $library1->{branchcode} );

is( $batches->[0]->{batch_id},    $id, 'batch_id    is good' );
is( $batches->[0]->{_item_count}, $nb, 'item_number is good for this batch_id' );

# ---------- Testing get_label_summary --------------------
# Mocking $sth->err and $sth->errstr
{
    my $dbi_st = Test::MockModule->new( 'DBI::st', no_auto => 1 );
    $dbi_st->mock( 'err',    sub { return 1; } );
    $dbi_st->mock( 'errstr', sub { return 'something went wrong'; } );
    my $labels;
    my @items = [ { item_number => $item_number1 } ];

    warning_is { $labels = get_label_summary( items => @items ) } 'Database returned the following error on attempted SELECT: something went wrong',
      'get_label_summary() raises warning if something went wrong with the sql request execution';

    is( $labels, -1, '$labels return -1' );
}

# Without params ----------------------
my $labels = get_label_summary();

isa_ok( $labels, 'ARRAY', '$labels is an ARRAY' );
is( @$labels, 0, '$labels is empty' );

# With items param --------------------
$query = '
  SELECT biblionumber, title, author
  FROM   biblio
  WHERE  biblionumber = ?
  ';
my ( $b_biblionumber1, $b_title1, $b_author1 ) = $dbh->selectrow_array( $query, {}, $biblionumber1 );
my ( $b_biblionumber2, $b_title2, $b_author2 ) = $dbh->selectrow_array( $query, {}, $biblionumber2 );

$query = '
  SELECT biblionumber, biblioitemnumber, itemtype
  FROM   biblioitems
  WHERE  biblioitemnumber = ?
  ';
my ( $bi_biblionumber1, $bi_biblioitemnumber1, $bi_itemtype1 ) = $dbh->selectrow_array( $query, {}, $biblioitemnumber1 );
my ( $bi_biblionumber2, $bi_biblioitemnumber2, $bi_itemtype2 ) = $dbh->selectrow_array( $query, {}, $biblioitemnumber2 );

$query = '
  SELECT biblionumber, biblioitemnumber, itemnumber, barcode, itype
  FROM   items
  WHERE  itemnumber = ?
  ';
my ( $i_biblionumber1, $i_biblioitemnumber1, $i_itemnumber1, $i_barcode1, $i_itype1 ) = $dbh->selectrow_array( $query, {}, $item_number1 );
my ( $i_biblionumber2, $i_biblioitemnumber2, $i_itemnumber2, $i_barcode2, $i_itype2 ) = $dbh->selectrow_array( $query, {}, $item_number2 );

$query = '
  SELECT label_id, batch_id, item_number
  FROM   creator_batches
  WHERE  item_number = ?
  ';
my ( $c_label_id1, $c_batch_id1, $c_item_number1 ) = $dbh->selectrow_array( $query, {}, $item_number1 );
my ( $c_label_id2, $c_batch_id2, $c_item_number2 ) = $dbh->selectrow_array( $query, {}, $item_number2 );

is( $c_item_number1,      $i_itemnumber1,        'CREATOR_BATCHES.item_number == ITEMS.itemnumber' );
is( $i_biblioitemnumber1, $bi_biblioitemnumber1, 'ITEMS.biblioitemnumber      == BIBLIOITEMS.biblioitemnumber' );
is( $bi_biblionumber1,    $b_biblionumber1,      'BIBLIOITEMS.biblionumber    == BIBLIO.biblionumber' );

is( $c_item_number2,      $i_itemnumber2,        'CREATOR_BATCHES.item_number == ITEMS.itemnumber' );
is( $i_biblioitemnumber2, $bi_biblioitemnumber2, 'ITEMS.biblioitemnumber      == BIBLIOITEMS.biblioitemnumber' );
is( $bi_biblionumber2,    $b_biblionumber2,      'BIBLIOITEMS.biblionumber    == BIBLIO.biblionumber' );

my @items = [
    {   item_number => $item_number1,
        label_id    => $c_label_id1,
    }
];
$labels = get_label_summary( items => @items, batch_id => $c_batch_id1 );

is( @$labels, 1, 'There is 1 label for $item_number1' );
isa_ok( $labels,      'ARRAY', '$labels      is an array' );
isa_ok( $labels->[0], 'HASH',  '$labels->[0] is an hash' );

my $record_author = $b_author1;
my $record_title  = $b_title1;
$record_author =~ s/[^\.|\w]$//;
$record_title  =~ s/\W*$//;
$record_title = '<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=' . $b_biblionumber1 . '"> ' . $b_title1 . '</a>';
my $summary1        = $record_title . " | " . ( $b_author1 ? $b_author1 : 'N/A' );
my $itemtypes_pref  = C4::Context->preference("item-level_itypes");
my $record_itemtype = $itemtypes_pref ? $i_itype1 : $bi_itemtype1;

is( $labels->[0]->{_label_number}, 1,                '_label_number  is good' );
is( $labels->[0]->{_summary},      $summary1,        '_summary       is good' );
is( $labels->[0]->{_item_type},    $record_itemtype, '_item_type     is good' );
is( $labels->[0]->{_barcode},      $i_barcode1,      '_barcode       is good' );
is( $labels->[0]->{_item_number},  $i_itemnumber1,   '_item_number   is good' );
is( $labels->[0]->{_label_id},     $c_label_id1,     '_label_id      is good' );

# record without author
@items = [
    {   item_number => $item_number2,
        label_id    => $c_label_id2,
    }
];
$labels = get_label_summary( items => @items, batch_id => $c_batch_id2 );

is( @$labels, 1, 'There is 1 label for $item_number2' );
isa_ok( $labels,      'ARRAY', '$labels      is an array' );
isa_ok( $labels->[0], 'HASH',  '$labels->[0] is an hash' );

$record_author = $b_author2;
$record_title  = $b_title2;
$record_author =~ s/[^\.|\w]$// if $b_author2;
$record_title =~ s/\W*$//;
$record_title = '<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=' . $b_biblionumber2 . '"> ' . $b_title2 . '</a>';
my $summary2 = $record_title . " | " . ( $b_author2 ? $b_author2 : 'N/A' );
$itemtypes_pref = C4::Context->preference("item-level_itypes");
$record_itemtype = $itemtypes_pref ? $i_itype2 : $bi_itemtype2;

is( $labels->[0]->{_label_number}, 1,                '_label_number  is good' );
is( $labels->[0]->{_summary},      $summary2,        '_summary       is good' );
is( $labels->[0]->{_item_type},    $record_itemtype, '_item_type     is good' );
is( $labels->[0]->{_barcode},      $i_barcode2,      '_barcode       is good' );
is( $labels->[0]->{_item_number},  $i_itemnumber2,   '_item_number   is good' );
is( $labels->[0]->{_label_id},     $c_label_id2,     '_label_id      is good' );

#Mocking C4::Context->preference("item-level_itypes")
{
    t::lib::Mocks::mock_preference( "item-level_itypes", 0 );
    my $h = C4::Context->preference("item-level_itypes");

    my @items = [
        {   item_number => $item_number1,
            label_id    => $c_label_id1,
        }
    ];
    $labels = get_label_summary( items => @items, batch_id => $c_batch_id1 );

    is( @$labels, 1, 'There is 1 label for $item_number1' );
    isa_ok( $labels,      'ARRAY', '$labels      is an array' );
    isa_ok( $labels->[0], 'HASH',  '$labels->[0] is an hash' );

    my $record_author = $b_author1;
    my $record_title  = $b_title1;
    $record_author =~ s/[^\.|\w]$//;
    $record_title  =~ s/\W*$//;
    $record_title = '<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=' . $b_biblionumber1 . '"> ' . $b_title1 . '</a>';
    my $summary1        = $record_title . " | " . ( $b_author1 ? $b_author1 : 'N/A' );
    my $itemtypes_pref  = C4::Context->preference("item-level_itypes");
    my $record_itemtype = $itemtypes_pref ? $i_itype1 : $bi_itemtype1;

    is( $labels->[0]->{_label_number}, 1,                '_label_number  is good' );
    is( $labels->[0]->{_summary},      $summary1,        '_summary       is good' );
    is( $labels->[0]->{_item_type},    $record_itemtype, '_item_type     is good' );
    is( $labels->[0]->{_barcode},      $i_barcode1,      '_barcode       is good' );
    is( $labels->[0]->{_item_number},  $i_itemnumber1,   '_item_number   is good' );
    is( $labels->[0]->{_label_id},     $c_label_id1,     '_label_id      is good' );
}

# ---------- Testing get_card_summary ---------------------
# Mocking $sth->err and $sth->errstr
{
    my $dbi_st = Test::MockModule->new( 'DBI::st', no_auto => 1 );
    $dbi_st->mock( 'err',    sub { return 1; } );
    $dbi_st->mock( 'errstr', sub { return 'something went wrong'; } );
    my $cards;
    my @items = [ { item_number => $item_number1 } ];

    warning_is { $cards = get_card_summary( items => @items ) } 'Database returned the following error on attempted SELECT: something went wrong',
      'get_card_summary() raises warning if something went wrong with the sql request execution';

    is( $cards, -1, '$cards return -1' );
}

# Without params ----------------------
my $cards = get_card_summary();

isa_ok( $cards, 'ARRAY', '$cards is an ARRAY' );
is( @$cards, 0, '$cards is empty' );

# With items param --------------------
$query = '
  SELECT surname, firstname, cardnumber
  FROM   borrowers
  WHERE  borrowernumber = ?
  ';
my ( $b_surname1, $b_firstname1, $b_cardnumber1 ) = $dbh->selectrow_array( $query, {}, $borrowernumber1 );

@items = [
    {   item_number     => $item_number1,
        label_id        => $c_label_id1,
        borrower_number => $borrowernumber1,
    }
];
$cards = get_card_summary( items => @items );

is( @$cards, 1, 'There is 1 card for $item_number1' );
isa_ok( $cards,      'ARRAY', '$cards      is an array' );
isa_ok( $cards->[0], 'HASH',  '$cards->[0] is an hash' );

my $name1 = "$b_surname1, $b_firstname1";
is( $cards->[0]->{_card_number},   1,                '_card_number   is good' );
is( $cards->[0]->{_summary},       $name1,           '_summary       is good' );
is( $cards->[0]->{borrowernumber}, $borrowernumber1, 'borrowernumber is good' );
is( $cards->[0]->{_label_id},      $c_label_id1,     '_label_id      is good' );

# ---------- Testing get_barcode_types --------------------
my $barcode_types = get_barcode_types();

is( @$barcode_types, 6, 'There are 6 barcodes types' );
isa_ok( $barcode_types, 'ARRAY', '$barcode_types is an ARRAY' );

isa_ok( $barcode_types->[0], 'HASH', '$barcode_types->[0] is a HASH' );
is( $barcode_types->[0]->{type},     'CODE39',                                                                                                              'type is good' );
is( $barcode_types->[0]->{name},     'Code 39',                                                                                                             'name is good' );
is( $barcode_types->[0]->{desc},     'Translates the characters 0-9, A-Z, \'-\', \'*\', \'+\', \'$\', \'%\', \'/\', \'.\' and \' \' to a barcode pattern.', 'desc is good' );
is( $barcode_types->[0]->{selected}, 0,                                                                                                                     'selected is good' );

isa_ok( $barcode_types->[1], 'HASH', '$barcode_types->[1] is a HASH' );
is( $barcode_types->[1]->{type}, 'CODE39MOD',          'type is good' );
is( $barcode_types->[1]->{name}, 'Code 39 + Modulo43', 'name is good' );
is( $barcode_types->[1]->{desc},
    'Translates the characters 0-9, A-Z, \'-\', \'*\', \'+\', \'$\', \'%\', \'/\', \'.\' and \' \' to a barcode pattern. Encodes Mod 43 checksum.',
    'desc is good'
);
is( $barcode_types->[1]->{selected}, 0, 'selected is good' );

isa_ok( $barcode_types->[2], 'HASH', '$barcode_types->[2] is a HASH' );
is( $barcode_types->[2]->{type},     'CODE39MOD10',        'type is good' );
is( $barcode_types->[2]->{name},     'Code 39 + Modulo10', 'name is good' );
is( $barcode_types->[2]->{desc},     'Translates the characters 0-9, A-Z, \'-\', \'*\', \'+\', \'$\', \'%\', \'/\', \'.\' and \' \' to a barcode pattern. Encodes Mod 10 checksum.', 'desc is good');
is( $barcode_types->[2]->{selected}, 0,                    'selected is good' );

isa_ok( $barcode_types->[3], 'HASH', '$barcode_types->[3] is a HASH' );
is( $barcode_types->[3]->{type},     'COOP2OF5', 'type is good' );
is( $barcode_types->[3]->{name},     'COOP2of5', 'name is good' );
is( $barcode_types->[3]->{desc},     'Creates COOP2of5 barcodes from a string consisting of the numeric characters 0-9', 'desc is good' );
is( $barcode_types->[3]->{selected}, 0,          'selected is good' );

isa_ok( $barcode_types->[4], 'HASH', '$barcode_types->[4] is a HASH' );
is( $barcode_types->[4]->{type},     'EAN13',     'type is good' );
is( $barcode_types->[4]->{name},     'EAN13',     'name is good' );
is( $barcode_types->[4]->{desc},     'Creates EAN13 barcodes from a string of 12 or 13 digits. The check number (the 13:th digit) is calculated if not supplied.', 'desc is good' );
is( $barcode_types->[4]->{selected}, 0,           'selected is good' );

isa_ok( $barcode_types->[5], 'HASH', '$barcode_types->[5] is a HASH' );
is( $barcode_types->[5]->{type},     'INDUSTRIAL2OF5', 'type is good' );
is( $barcode_types->[5]->{name},     'Industrial2of5', 'name is good' );
is( $barcode_types->[5]->{desc},     'Creates Industrial2of5 barcodes from a string consisting of the numeric characters 0-9', 'desc is good' );
is( $barcode_types->[5]->{selected},  0,               'selected is good' );

# ---------- Testing get_label_types ----------------------
my $label_types = get_label_types();

is( @$label_types, 5, 'There are 5 label types' );
isa_ok( $label_types, 'ARRAY', '$label_types is an ARRAY' );

isa_ok( $label_types->[0], 'HASH', '$label_types->[0] is a HASH' );
is( $label_types->[0]->{type},     'BIB',                                     'type     is good' );
is( $label_types->[0]->{name},     'Biblio',                                  'name     is good' );
is( $label_types->[0]->{desc},     'Only the bibliographic data is printed.', 'desc     is good' );
is( $label_types->[0]->{selected}, 0,                                         'selected is good' );

isa_ok( $label_types->[1], 'HASH', '$label_types->[1] is a HASH' );
is( $label_types->[1]->{type},     'BARBIB',                               'type     is good' );
is( $label_types->[1]->{name},     'Barcode/Biblio',                       'name     is good' );
is( $label_types->[1]->{desc},     'Barcode proceeds bibliographic data.', 'desc     is good' );
is( $label_types->[1]->{selected}, 0,                                      'selected is good' );

isa_ok( $label_types->[2], 'HASH', '$label_types->[2] is a HASH' );
is( $label_types->[2]->{type},     'BIBBAR',                               'type     is good' );
is( $label_types->[2]->{name},     'Biblio/Barcode',                       'name     is good' );
is( $label_types->[2]->{desc},     'Bibliographic data proceeds barcode.', 'desc     is good' );
is( $label_types->[2]->{selected}, 0,                                      'selected is good' );

isa_ok( $label_types->[3], 'HASH', '$label_types->[3] is a HASH' );
is( $label_types->[3]->{type},     'ALT',                                                               'type     is good' );
is( $label_types->[3]->{name},     'Alternating',                                                       'name     is good' );
is( $label_types->[3]->{desc},     'Barcode and bibliographic data are printed on alternating labels.', 'desc     is good' );
is( $label_types->[3]->{selected}, 0,                                                                   'selected is good' );

isa_ok( $label_types->[4], 'HASH', '$label_types->[4] is a HASH' );
is( $label_types->[4]->{type},     'BAR',                          'type     is good' );
is( $label_types->[4]->{name},     'Barcode',                      'name     is good' );
is( $label_types->[4]->{desc},     'Only the barcode is printed.', 'desc     is good' );
is( $label_types->[4]->{selected}, 0,                              'selected is good' );

# ---------- Testing get_font_types -----------------------
my $font_types = get_font_types();

is( @$font_types, 12, 'There are 12 font types' );
isa_ok( $font_types, 'ARRAY', '$font_types is an ARRAY' );

isa_ok( $font_types->[0], 'HASH', '$font_types->[0] is a HASH' );
is( $font_types->[0]->{type},     'TR',                      'type     is good' );
is( $font_types->[0]->{name},     'Times-Roman',             'name     is good' );
is( $font_types->[0]->{selected}, 0,                         'selected is good' );

isa_ok( $font_types->[1], 'HASH', '$font_types->[1] is a HASH' );
is( $font_types->[1]->{type},     'TB',                      'type     is good' );
is( $font_types->[1]->{name},     'Times-Bold',              'name     is good' );
is( $font_types->[1]->{selected}, 0,                         'selected is good' );

isa_ok( $font_types->[2], 'HASH', '$font_types->[2] is a HASH' );
is( $font_types->[2]->{type},     'TI',                      'type     is good' );
is( $font_types->[2]->{name},     'Times-Italic',            'name     is good' );
is( $font_types->[2]->{selected}, 0,                         'selected is good' );

isa_ok( $font_types->[3], 'HASH', '$font_types->[3] is a HASH' );
is( $font_types->[3]->{type},     'TBI',                     'type     is good' );
is( $font_types->[3]->{name},     'Times-Bold-Italic',       'name     is good' );
is( $font_types->[3]->{selected}, 0,                         'selected is good' );

isa_ok( $font_types->[4], 'HASH', '$font_types->[4] is a HASH' );
is( $font_types->[4]->{type},     'C',                       'type     is good' );
is( $font_types->[4]->{name},     'Courier',                 'name     is good' );
is( $font_types->[4]->{selected}, 0,                         'selected is good' );

isa_ok( $font_types->[5], 'HASH', '$font_types->[5] is a HASH' );
is( $font_types->[5]->{type},     'CB',                      'type     is good' );
is( $font_types->[5]->{name},     'Courier-Bold',            'name     is good' );
is( $font_types->[5]->{selected}, 0,                         'selected is good' );

isa_ok( $font_types->[6], 'HASH', '$font_types->[6] is a HASH' );
is( $font_types->[6]->{type},     'CO',                      'type     is good' );
is( $font_types->[6]->{name},     'Courier-Oblique',         'name     is good' );
is( $font_types->[6]->{selected}, 0,                         'selected is good' );

isa_ok( $font_types->[7], 'HASH', '$font_types->[7] is a HASH' );
is( $font_types->[7]->{type},     'CBO',                     'type     is good' );
is( $font_types->[7]->{name},     'Courier-Bold-Oblique',    'name     is good' );
is( $font_types->[7]->{selected}, 0,                         'selected is good' );

isa_ok( $font_types->[8], 'HASH', '$font_types->[8] is a HASH' );
is( $font_types->[8]->{type},     'H',                       'type     is good' );
is( $font_types->[8]->{name},     'Helvetica',               'name     is good' );
is( $font_types->[8]->{selected}, 0,                         'selected is good' );

isa_ok( $font_types->[9], 'HASH', '$font_types->[9] is a HASH' );
is( $font_types->[9]->{type},     'HO',                      'type     is good' );
is( $font_types->[9]->{name},     'Helvetica-Oblique',       'name     is good' );
is( $font_types->[9]->{selected}, 0,                         'selected is good' );

isa_ok( $font_types->[10], 'HASH', '$font_types->[10] is a HASH' );
is( $font_types->[10]->{type},     'HB',                     'type     is good' );
is( $font_types->[10]->{name},     'Helvetica-Bold',         'name     is good' );
is( $font_types->[10]->{selected}, 0,                        'selected is good' );

isa_ok( $font_types->[11], 'HASH', '$font_types->[11] is a HASH' );
is( $font_types->[11]->{type},     'HBO',                    'type     is good' );
is( $font_types->[11]->{name},     'Helvetica-Bold-Oblique', 'name     is good' );
is( $font_types->[11]->{selected}, 0,                        'selected is good' );

# ---------- Testing get_text_justification_types ---------
my $text_justification_types = get_text_justification_types();

is( @$text_justification_types, 3, 'There are 3 text justification types' );
isa_ok( $text_justification_types, 'ARRAY', '$text_justification_types is an ARRAY' );

isa_ok( $text_justification_types->[0], 'HASH', '$font_types->[0] is a HASH' );
is( $text_justification_types->[0]->{type},     'L',         'type     is good' );
is( $text_justification_types->[0]->{name},     'Left',      'name     is good' );
is( $text_justification_types->[0]->{selected}, 0,           'selected is good' );

isa_ok( $text_justification_types->[1], 'HASH', '$font_types->[1] is a HASH' );
is( $text_justification_types->[1]->{type},     'C',         'type     is good' );
is( $text_justification_types->[1]->{name},     'Center',    'name     is good' );
is( $text_justification_types->[1]->{selected}, 0,           'selected is good' );

isa_ok( $text_justification_types->[2], 'HASH', '$font_types->[2] is a HASH' );
is( $text_justification_types->[2]->{type},     'R',         'type     is good' );
is( $text_justification_types->[2]->{name},     'Right',     'name     is good' );
is( $text_justification_types->[2]->{selected}, 0,           'selected is good' );

# ---------- Testing get_unit_values ----------------------
my $unit_values = get_unit_values();

is( @$unit_values, 5, 'There are 5 unit values' );
isa_ok( $unit_values, 'ARRAY', '$unit_values is an ARRAY' );

isa_ok( $unit_values->[0], 'HASH', '$unit_values->[0] is a HASH' );
is( $unit_values->[0]->{type},     'POINT',                  'type     is good' );
is( $unit_values->[0]->{desc},     'PostScript Points',      'desc     is good' );
is( $unit_values->[0]->{value},    1,                        'value    is good' );
is( $unit_values->[0]->{selected}, 0,                        'selected is good' );

isa_ok( $unit_values->[1], 'HASH', '$unit_values->[1] is a HASH' );
is( $unit_values->[1]->{type},     'AGATE',                  'type     is good' );
is( $unit_values->[1]->{desc},     'Adobe Agates',           'desc     is good' );
is( $unit_values->[1]->{value},    5.1428571,                'value    is good' );
is( $unit_values->[1]->{selected}, 0,                        'selected is good' );

isa_ok( $unit_values->[2], 'HASH', '$unit_values->[2] is a HASH' );
is( $unit_values->[2]->{type},     'INCH',                   'type     is good' );
is( $unit_values->[2]->{desc},     'US Inches',              'desc     is good' );
is( $unit_values->[2]->{value},    72,                       'value    is good' );
is( $unit_values->[2]->{selected}, 0,                        'selected is good' );

isa_ok( $unit_values->[3], 'HASH', '$unit_values->[3] is a HASH' );
is( $unit_values->[3]->{type},     'MM',                     'type     is good' );
is( $unit_values->[3]->{desc},     'SI Millimeters',         'desc     is good' );
is( $unit_values->[3]->{value},    2.83464567,               'value    is good' );
is( $unit_values->[3]->{selected}, 0,                        'selected is good' );

isa_ok( $unit_values->[4], 'HASH', '$unit_values->[4] is a HASH' );
is( $unit_values->[4]->{type},     'CM',                     'type     is good' );
is( $unit_values->[4]->{desc},     'SI Centimeters',         'desc     is good' );
is( $unit_values->[4]->{value},    28.3464567,               'value    is good' );
is( $unit_values->[4]->{selected}, 0,                        'selected is good' );

# ---------- Testing get_output_formats -------------------
my $output_formats = get_output_formats();

is( @$output_formats, 2, 'There are 2 output format' );
isa_ok( $output_formats, 'ARRAY', '$output_formats is an ARRAY' );

isa_ok( $output_formats->[0], 'HASH', '$output_formats->[0] is a HASH' );
is( $output_formats->[0]->{type}, 'pdf',      'type is good' );
is( $output_formats->[0]->{desc}, 'PDF File', 'name is good' );

isa_ok( $output_formats->[1], 'HASH', '$output_formats->[1] is a HASH' );
is( $output_formats->[1]->{type}, 'csv',      'type is good' );
is( $output_formats->[1]->{desc}, 'CSV File', 'name is good' );

# ---------- Testing get_table_names ----------------------
my $table_names   = get_table_names("aq");
my $KOHA_PATH     = C4::Context->config("intranetdir");
my $kohastructure = "$KOHA_PATH/installer/data/mysql/kohastructure.sql";

open( my $fh, '<', $kohastructure ) or die $!;

my $tables_names_matching = [];
while ( my $intext = <$fh> ) {
    while ( $intext =~ /CREATE TABLE `*\w*aq\w*`*/g ) {
        my @tables_names_matching = split( /\ /, $intext );
        if ( $tables_names_matching[2] =~ /`*`/ ) {
            $tables_names_matching[2] =~ s/`//g;
        }
        push( @$tables_names_matching, "$tables_names_matching[2]" );
    }
}
close $fh;
@$tables_names_matching = sort @$tables_names_matching;
is_deeply( $table_names, $tables_names_matching, 'get_table_names return all tables matching' );

# ---------- Testing html_table ---------------------------
my $display_columns = [
    { _label_number  => { label => 'Label Number',  link_field => 0 } },
    { _summary       => { label => 'Summary',       link_field => 0 } },
    { _item_type     => { label => 'Item Type',     link_field => 0 } },
    { _barcode       => { label => 'Barcode',       link_field => 1 } },
    { _template_code => { label => 'Template Name', link_field => 0 } },
    { select         => { label => 'Select',        value      => '_label_id' } },
];

#without $data param ------------------
my $db_rows = [];
my $table = html_table( $display_columns, $db_rows );
is( $table, undef, 'No need to generate a table if there is not data to display' );

#with $data param ---------------------
$db_rows = [
    {   _label_number => 1,
        _summary      => $summary1,
        _item_type    => 'Book',
        _barcode      => $barcode1,
        _label_id     => 'Label ID',
        template_id   => $template_id1,
    }
];

$table = html_table( $display_columns, $db_rows );

isa_ok( $table, 'ARRAY', '$table is an ARRAY' );

#POPULATE HEADER
isa_ok( $table->[0]->{header_fields}, 'ARRAY', '$table->[0]->{header_fields} is an ARRAY' );
is( scalar( @{ $table->[0]->{header_fields} } ), 6, 'There are 7 header_fields' );

my $field_value = $display_columns->[0]->{_label_number}->{label};
is( $table->[0]->{header_fields}->[0]->{hidden},       0,                '[Label Number]   hidden        field is good' );
is( $table->[0]->{header_fields}->[0]->{select_field}, 0,                '[Label Number]   select_field  field is good' );
is( $table->[0]->{header_fields}->[0]->{field_name},   '_label_number',  '[Label Number]   field_name    field is good' );
is( $table->[0]->{header_fields}->[0]->{field_label},  $field_value,     '[Label Number]   field_label   field is good' );

$field_value = $display_columns->[1]->{_summary}->{label};
is( $table->[0]->{header_fields}->[1]->{hidden},       0,                '[Summary]        hidden        field is good' );
is( $table->[0]->{header_fields}->[1]->{select_field}, 0,                '[Summary]        select_field  field is good' );
is( $table->[0]->{header_fields}->[1]->{field_name},   '_summary',       '[Summary]        field_name    field is good' );
is( $table->[0]->{header_fields}->[1]->{field_label},  $field_value,     '[Summary]        field_label   field is good' );

$field_value = $display_columns->[2]->{_item_type}->{label};
is( $table->[0]->{header_fields}->[2]->{hidden},       0,                '[Item Type]      hidden        field is good' );
is( $table->[0]->{header_fields}->[2]->{select_field}, 0,                '[Item Type]      select_field  field is good' );
is( $table->[0]->{header_fields}->[2]->{field_name},   '_item_type',     '[Item Type]      field_name    field is good' );
is( $table->[0]->{header_fields}->[2]->{field_label},  $field_value,     '[Item Type]      field_label   field is good' );

$field_value = $display_columns->[3]->{_barcode}->{label};
is( $table->[0]->{header_fields}->[3]->{hidden},       0,                '[Barcode]        hidden        field is good' );
is( $table->[0]->{header_fields}->[3]->{select_field}, 0,                '[Barcode]        select_field  field is good' );
is( $table->[0]->{header_fields}->[3]->{field_name},   '_barcode',       '[Barcode]        field_name    field is good' );
is( $table->[0]->{header_fields}->[3]->{field_label},  $field_value,     '[Barcode]        field_label   field is good' );

$field_value = $display_columns->[4]->{_template_code}->{label};
is( $table->[0]->{header_fields}->[4]->{hidden},       0,                '[Template Code]  hidden        field is good' );
is( $table->[0]->{header_fields}->[4]->{select_field}, 0,                '[Template Code]  select_field  field is good' );
is( $table->[0]->{header_fields}->[4]->{field_name},   '_template_code', '[Template Code]  field_name    field is good' );
is( $table->[0]->{header_fields}->[4]->{field_label},  $field_value,     '[Template Code]  field_label   field is good' );

$field_value = $display_columns->[5]->{select}->{label};
is( $table->[0]->{header_fields}->[5]->{hidden},       0,                '[Select]         hidden        field is good' );
is( $table->[0]->{header_fields}->[5]->{select_field}, 0,                '[Select]         select_field  field is good' );
is( $table->[0]->{header_fields}->[5]->{field_name},   'select',         '[Select]         field_name    field is good' );
is( $table->[0]->{header_fields}->[5]->{field_label},  $field_value,     '[Select]         field_label   field is good' );

#POPULATE TABLE
isa_ok( $table->[1]->{text_fields}, 'ARRAY', '$table->[0]->{text_fields} is an ARRAY' );
is( scalar( @{ $table->[1]->{text_fields} } ), 6, 'There are 6 text_fields' );

#test : if (grep {$table_column eq $_} keys %$db_row)
my $link_field = $display_columns->[0]->{_label_number}->{link_field};
my $field_name = "$table->[0]->{header_fields}->[0]->{field_name}_tbl";
$field_value = $db_rows->[0]->{_label_number};
is( $table->[1]->{text_fields}->[0]->{hidden},       0,               '[Label Number]   hidden        field is good' );
is( $table->[1]->{text_fields}->[0]->{link_field},   $link_field,     '[Label Number]   link_field    field is good' );
is( $table->[1]->{text_fields}->[0]->{select_field}, 0,               '[Label Number]   select_field  field is good' );
is( $table->[1]->{text_fields}->[0]->{field_name},   $field_name,     '[Label Number]   field_name    field is good' );
is( $table->[1]->{text_fields}->[0]->{field_value},  $field_value,    '[Label Number]   field_value   field is good' );

$link_field  = $display_columns->[1]->{_summary}->{link_field};
$field_value = $db_rows->[0]->{_summary};
$field_name  = "$table->[0]->{header_fields}->[1]->{field_name}_tbl";
is( $table->[1]->{text_fields}->[1]->{hidden},       0,               '[Summary]        hidden        field is good' );
is( $table->[1]->{text_fields}->[1]->{link_field},   $link_field,     '[Summary]        link_field    field is good' );
is( $table->[1]->{text_fields}->[1]->{select_field}, 0,               '[Summary]        select_field  field is good' );
is( $table->[1]->{text_fields}->[1]->{field_name},   $field_name,     '[Summary]        field_name    field is good' );
is( $table->[1]->{text_fields}->[1]->{field_value},  $field_value,    '[Summary]        field_value   field is good' );

$link_field  = $display_columns->[2]->{_item_type}->{link_field};
$field_name  = "$table->[0]->{header_fields}->[2]->{field_name}_tbl";
$field_value = $db_rows->[0]->{_item_type};
is( $table->[1]->{text_fields}->[2]->{hidden},       0,               '[Item Type]      hidden        field is good' );
is( $table->[1]->{text_fields}->[2]->{link_field},   $link_field,     '[Item Type]      link_field    field is good' );
is( $table->[1]->{text_fields}->[2]->{select_field}, 0,               '[Item Type]      select_field  field is good' );
is( $table->[1]->{text_fields}->[2]->{field_name},   $field_name,     '[Item Type]      field_name    field is good' );
is( $table->[1]->{text_fields}->[2]->{field_value},  $field_value,    '[Item Type]      field_value   field is good' );

$link_field  = $display_columns->[3]->{_barcode}->{link_field};
$field_name  = "$table->[0]->{header_fields}->[3]->{field_name}_tbl";
$field_value = $db_rows->[0]->{_barcode};
is( $table->[1]->{text_fields}->[3]->{hidden},       0,               '[Barcode]        hidden        field is good' );
is( $table->[1]->{text_fields}->[3]->{link_field},   $link_field,     '[Barcode]        link_field    field is good' );
is( $table->[1]->{text_fields}->[3]->{select_field}, 0,               '[Barcode]        select_field  field is good' );
is( $table->[1]->{text_fields}->[3]->{field_name},   $field_name,     '[Barcode]        field_name    field is good' );
is( $table->[1]->{text_fields}->[3]->{field_value},  $field_value,    '[Barcode]        field_value   field is good' );

#test : elsif ($table_column =~ m/^_((.*)_(.*$))/)
$link_field = $display_columns->[4]->{_template_code}->{link_field};
$field_name = "$table->[0]->{header_fields}->[4]->{field_name}_tbl";
is( $table->[1]->{text_fields}->[4]->{hidden},       0,               '[Template Code]  hidden        field is good' );
is( $table->[1]->{text_fields}->[4]->{link_field},   $link_field,     '[Template Code]  link_field    field is good' );
is( $table->[1]->{text_fields}->[4]->{select_field}, 0,               '[Template Code]  select_field  field is good' );
is( $table->[1]->{text_fields}->[4]->{field_name},   $field_name,     '[Template Code]  field_name    field is good' );
is( $table->[1]->{text_fields}->[4]->{field_value},  $template_code1, '[Template Code]  field_value   field is good' );

#test : elsif ($table_column eq 'select')
$field_value = $db_rows->[0]->{_label_id};
is( $table->[1]->{text_fields}->[5]->{hidden},       0,               '[Select]         hidden        field is good' );
is( $table->[1]->{text_fields}->[5]->{select_field}, 1,               '[Select]         select_field  field is good' );
is( $table->[1]->{text_fields}->[5]->{field_name},   'select',        '[Select]         field_name    field is good' );
is( $table->[1]->{text_fields}->[5]->{field_value},  $field_value,    '[Select]         field_value   field is good' );

# ---------- Testing _SELECT ---------------------------
# Mocking $sth->err and $sth->errstr
{
    my $dbi_st = Test::MockModule->new( 'DBI::st', no_auto => 1 );
    $dbi_st->mock( 'err',    sub { return 1; } );
    $dbi_st->mock( 'errstr', sub { return 'something went wrong'; } );
    my $records;
    warning_is { $records = C4::Creators::Lib::_SELECT( '*', 'borrowers', "borrowernumber = $borrowernumber1" ) } 'Database returned the following error: something went wrong',
      '_SELECT raises warning if something went wrong with the sql request execution';

    is( $records, 1, '$record return 1' );
}

#without $params[2] -------------------
my $records = C4::Creators::Lib::_SELECT( 'surname, firstname, cardnumber, branchcode, categorycode', 'borrowers' );

is( @$records, 3, 'There are 3 borrowers' );
isa_ok( $records, 'ARRAY', '$records is an ARRAY' );

isa_ok( $records->[0], 'HASH', '$records->[0] is a HASH' );
is( $records->[0]->{surname},      $surname1,     'surname      is good' );
is( $records->[0]->{firstname},    $firstname1,   'firstname    is good' );
is( $records->[0]->{cardnumber},   $cardnumber1,  'cardnumber   is good' );
is( $records->[0]->{branchcode},   $branchcode,   'branchcode   is good' );
is( $records->[0]->{categorycode}, $categorycode, 'categorycode is good' );

isa_ok( $records->[1], 'HASH', '$records->[1] is a HASH' );
is( $records->[1]->{surname},      $surname2,     'surname      is good' );
is( $records->[1]->{firstname},    $firstname2,   'firstname    is good' );
is( $records->[1]->{cardnumber},   $cardnumber2,  'cardnumber   is good' );
is( $records->[1]->{branchcode},   $branchcode,   'branchcode   is good' );
is( $records->[1]->{categorycode}, $categorycode, 'categorycode is good' );

isa_ok( $records->[2], 'HASH', '$records->[2] is a HASH' );
is( $records->[2]->{surname},      $surname3,     'surname      is good' );
is( $records->[2]->{firstname},    $firstname3,   'firstname    is good' );
is( $records->[2]->{cardnumber},   $cardnumber3,  'cardnumber   is good' );
is( $records->[2]->{branchcode},   $branchcode,   'branchcode   is good' );
is( $records->[2]->{categorycode}, $categorycode, 'categorycode is good' );

#with $params[2] ----------------------
$records = C4::Creators::Lib::_SELECT( 'surname, firstname, cardnumber, branchcode, categorycode', 'borrowers', "borrowernumber = $borrowernumber1" );

is( @$records, 1, 'There is 1 borrower where borrowernumber = $borrowernumber1' );
isa_ok( $records, 'ARRAY', '$records is an ARRAY' );

isa_ok( $records->[0], 'HASH', '$records->[0] is a HASH' );
is( $records->[0]->{surname},      $surname1,     'surname      is good' );
is( $records->[0]->{firstname},    $firstname1,   'firstname    is good' );
is( $records->[0]->{cardnumber},   $cardnumber1,  'cardnumber   is good' );
is( $records->[0]->{branchcode},   $branchcode,   'branchcode   is good' );
is( $records->[0]->{categorycode}, $categorycode, 'categorycode is good' );

# ---------- Sub ------------------------------------------
my %preferences;

sub mock_preference {
    my $context = new Test::MockModule('C4::Context');
    my ( $pref, $value ) = @_;
    $preferences{$pref} = $value;
    $context->mock(
        'preference',
        sub {
            my ( $self, $pref ) = @_;
            if ( exists $preferences{$pref} ) {
                return $preferences{$pref};
            } else {
                my $method = $context->original('preference');
                return $method->( $self, $pref );
            }
        }
    );
}
