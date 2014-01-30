# Copyright 2015 KohaSuomi
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
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;
use Test::More;
use PDF::Reuse;

use C4::Labels::DataSourceSelector;
use C4::Labels::DataSourceManager;
use C4::Labels::DataSourceFormatter;
use C4::Labels::PdfCreator;

use t::lib::TestObjects::ObjectFactory;
use t::lib::TestObjects::BiblioFactory;
use t::lib::TestObjects::PatronFactory;
use t::lib::TestObjects::ItemFactory;
use t::lib::TestObjects::Labels::SheetFactory;

my $testContext = {};
my $biblio = t::lib::TestObjects::BiblioFactory->createTestGroup(
                        {'biblio.title' => 'I wish I met your mother',
                         'biblio.author'   => 'Pertti Kurikka',
                         'biblio.copyrightdate' => '1960',
                         'biblioitems.isbn'     => 'kuri1',
                         'biblioitems.itemtype' => 'BK',
                        }, undef, $testContext);
my $items = t::lib::TestObjects::ItemFactory->createTestGroup([
                        {'biblionumber' => $biblio->{biblionumber},
                         'homebranch'   => 'CPL',
                         'barcode'      => '1N001',
                         'itype'        => 'BK',
                        },
                        {'biblionumber' => $biblio->{biblionumber},
                         'homebranch'   => 'CPL',
                         'barcode'      => '1N002',
                         'itype'        => 'BK',
                        },
                    ], undef, $testContext);
my @itemBarcodes = map {$items->{$_}->barcode()} sort keys(%$items);
my $borrower = t::lib::TestObjects::PatronFactory->createTestGroup(
                        {firstname => 'Olli-Antti',
                         surname   => 'Kivi',
                         cardnumber => '11A001',
                         branchcode     => 'CPL',
                        }, undef, $testContext);
my $sheet = t::lib::TestObjects::Labels::SheetFactory->createTestGroup({
                            name => 'Sheetilian'
                        },
                    undef, $testContext);



subtest "DataSourceFormatter::_formatLines()" => \&dataSourceFormatterFormatLines;
sub dataSourceFormatterFormatLines {
    eval {
    PDF::Reuse::prFile('/tmp/pdf_reuse_test');
    my $element = $sheet->getItems()->[0]->getRegions()->[0]->getElements()->[0];
    $element->setFontSize(20);
    $element->setDimensions({width => 100, height => 33});

    my $veryLongText = "Bared on your tomb, I'm a prayer for your loneliness, And would you ever soon, Come above onto me? For once upon a time, On the binds of your loneliness, I could always find the right slot for your sacred key";
    my $longText = "Archangel, Dark Angel";
    my $mediumText = "Black goddess";
    my $mediumTextWhitespace = "Black                     goddess";
    my $shortText = "Succubi";
    my $tinyText = "CoF";
    my ($pos, $lines, $fontSize, $font, $colour);

    #oneLiner()
    ($pos, $lines, $fontSize, $font, $colour) = C4::Labels::DataSourceFormatter::_formatLines($element, $shortText, 'oneLiner');
    is($lines->[0].' <and> '.$fontSize,
       "$shortText <and> 20",
       "oneLiner() fits to width, font size same");
    ($pos, $lines, $fontSize, $font, $colour) = C4::Labels::DataSourceFormatter::_formatLines($element, $longText, 'oneLiner');
    is($lines->[0].' <and> '.$fontSize,
       'Archange <and> 20',
       "oneLiner() cut to width, font size same");

    #oneLinerShrinkText()
    ($pos, $lines, $fontSize, $font, $colour) = C4::Labels::DataSourceFormatter::_formatLines($element, $veryLongText, 'oneLinerShrink');
    is($lines->[0].' <and> '.$fontSize,
       "Bared on your tomb <and> 10",
       "oneLinerShrink() maximum shrinkage 10 points");
    ($pos, $lines, $fontSize, $font, $colour) = C4::Labels::DataSourceFormatter::_formatLines($element, $mediumText, 'oneLinerShrink');
    is($lines->[0] . ' <and> ' . $fontSize,
       "$mediumText <and> 14",
       "oneLinerShrink() moderate shrinkage 5 points");
    ($pos, $lines, $fontSize, $font, $colour) = C4::Labels::DataSourceFormatter::_formatLines($element, $shortText, 'oneLinerShrink');
    is($lines->[0].' <and> '.$fontSize,
       "$shortText <and> 20",
       "oneLinerShrink() dont have to shrink");

    #twoLiner()
    ($pos, $lines, $fontSize, $font, $colour) = C4::Labels::DataSourceFormatter::_formatLines($element, $veryLongText, 'twoLiner');
    is($lines->[0],
       'Bared on ',
       "twoLiner() first row cut");
    is($lines->[1],
       "your tom",
       "twoLiner() second row cut");
    ($pos, $lines, $fontSize, $font, $colour) = C4::Labels::DataSourceFormatter::_formatLines($element, $mediumText, 'twoLiner');
    is($lines->[0],
       'Black god',
       "twoLiner() first row cut");
    is($lines->[1],
       'dess',
       "twoLiner() second fits");
    ($pos, $lines, $fontSize, $font, $colour) = C4::Labels::DataSourceFormatter::_formatLines($element, $shortText, 'twoLiner');
    is($lines->[0],
       $shortText,
       "twoLiner() first row fits");
    is($lines->[1],
       undef,
       "twoLiner() no second row");

    #trim leading whitespace
    ($pos, $lines, $fontSize, $font, $colour) = C4::Labels::DataSourceFormatter::_formatLines($element, $mediumTextWhitespace, 'twoLiner');
    is($lines->[0],
       'Black       ',
       "twoLiner() whitespace trimming first row cut");
    is($lines->[1],
       'goddess',
       "twoLiner() whitespace trimming second fits");

    #twoLinerShrink()
    ($pos, $lines, $fontSize, $font, $colour) = C4::Labels::DataSourceFormatter::_formatLines($element, $veryLongText, 'twoLinerShrink');
    is($lines->[0].' <and> '.$fontSize,
       'Bared on your <and> 14',
       "twoLinerShrink() first row cut and font shrunk by 30%");
    ok(not(   $lines->[1] =~ /^\s+/   ),
       "twoLinerShrink() second row has leading whitespace trimmed");
    is($lines->[1].' <and> '.$fontSize,
       "tomb, I'm a pr <and> 14",
       "twoLinerShrink() second row cut and font shrunk by 30%");
    ($pos, $lines, $fontSize, $font, $colour) = C4::Labels::DataSourceFormatter::_formatLines($element, $longText, 'twoLinerShrink');
    is($lines->[0].' <and> '.$fontSize,
       'Archangel,  <and> 17',
       "twoLinerShrink() first row cut");
    is($lines->[1].' <and> '.$fontSize,
       'Dark Angel <and> 17',
       "twoLinerShrink() second fits");
    ($pos, $lines, $fontSize, $font, $colour) = C4::Labels::DataSourceFormatter::_formatLines($element, $mediumText, 'twoLinerShrink');
    is($lines->[0].' <and> '.$fontSize,
       "Black god <and> 20",
       "twoLinerShrink() first row cut to fit");
    is($lines->[1],
       "dess",
       "twoLinerShrink() no second row");
    ($pos, $lines, $fontSize, $font, $colour) = C4::Labels::DataSourceFormatter::_formatLines($element, $shortText, 'twoLinerShrink');
    is($lines->[0].' <and> '.$fontSize,
       "$shortText <and> 20",
       "twoLinerShrink() first row fits");
    is($lines->[1],
       undef,
       "twoLinerShrink() no second row");

    };
    if ($@) {
        ok(0, $@);
    }
    eval {
        PDF::Reuse::prEnd();
    };
    if ($@) {
        ok(0, $@);
    }
}



subtest "C4::Labels::DataSourceSelector" => \&C4LabelsDataSourceSelector;
sub C4LabelsDataSourceSelector {
    eval {
    my $element = $sheet->getItems()->[0]->getRegions()->[0]->getElements()->[0];
    my $dataSource;

    $dataSource = '245$a || biblio.title && biblio.author';
    $element->setDataSource($dataSource);
    is(C4::Labels::DataSourceManager::executeDataSource($element, $itemBarcodes[0]),
       'I wish I met your mother',
       $dataSource);

    $dataSource = 'biblio.title && "," && biblio.author || 245$a';
    $element->setDataSource($dataSource);
    is(C4::Labels::DataSourceManager::executeDataSource($element, $itemBarcodes[0]),
       'I wish I met your mother , Pertti Kurikka',
       $dataSource);

    $dataSource = 'homebranch.branchcode && 100$a';
    $element->setDataSource($dataSource);
    is(C4::Labels::DataSourceManager::executeDataSource($element, $itemBarcodes[0]),
       'CPL Pertti Kurikka',
       $dataSource);

    $dataSource = '"freetext" and biblio.copyrightdate && 100$a';
    $element->setDataSource($dataSource);
    is(C4::Labels::DataSourceManager::executeDataSource($element, $itemBarcodes[0]),
       'freetext 1960 Pertti Kurikka',
       $dataSource);

    $dataSource = 'signum()';
    $element->setDataSource($dataSource);
    is(C4::Labels::DataSourceManager::executeDataSource($element, $itemBarcodes[0]),
       'PER',
       $dataSource);

    $dataSource = 'itemtype()';
    $element->setDataSource($dataSource);
    is(C4::Labels::DataSourceManager::executeDataSource($element, $itemBarcodes[0]),
       'Books',
       $dataSource);

    $dataSource = 'item.barcode';
    $element->setDataSource($dataSource);
    is(C4::Labels::DataSourceManager::executeDataSource($element, $itemBarcodes[0]),
       '1N001',
       $dataSource);

    $dataSource = 'title()';
    $element->setDataSource($dataSource);
    is(C4::Labels::DataSourceManager::executeDataSource($element, $itemBarcodes[0]),
       'I wish I met your mother',
       $dataSource);
    };
    if ($@) {
        ok(0, $@);
    }
}



subtest "Label Printing List" => \&labelPrintingList;
sub labelPrintingList {
    # eval {
    # C4::VirtualShelves::addItemToLabelPrintingList($biblio->{biblionumber}, $borrower->borrowernumber, $items->{'1N001'}->itemnumber);
    # C4::VirtualShelves::addItemToList($biblio->{biblionumber}, 'labels printing', $borrower->borrowernumber, $items->{'1N002'}->itemnumber);
    # my $lpItems = C4::VirtualShelves::getLabelPrintingListItems($borrower->borrowernumber);
    # is($lpItems->[0]->{itemnumber}, $items->{'1N001'}->itemnumber,
    #    "Put and got item1 for label printing");
    # is($lpItems->[1]->{itemnumber}, $items->{'1N002'}->itemnumber,
    #    "Put and got item2 for label printing");

    # my $list = C4::VirtualShelves::getLabelPrintingList($borrower->borrowernumber);
    # is($list->{shelfname}, 'labels printing', "Got the labels printing list for this borrower");

    # C4::VirtualShelves::removeLabelPrintingListItems($borrower->borrowernumber);
    # $lpItems = C4::VirtualShelves::getLabelPrintingListItems($borrower->borrowernumber);
    # is(ref($lpItems), 'ARRAY',
    #    "Returns an array after emptying the list");
    # is(scalar(@$lpItems), 0,
    #    "The array is empty");
    # };
    # if ($@) {
    #     ok(0, $@);
    # }
}



subtest "DataSourceFunctions", \&dataSourceFunctions;
sub dataSourceFunctions {
    eval {
        my $params = [
            {biblio => {}, biblioitem => {}, item => {}, homebranch => {}}, #HASHRef of database tables
            {}, #MARC::Record stub
            {}, #C4::Labels::Sheet::Element
            [], #ARRAYRef of dataSourceFunction's parameters
        ];


        ## public_yklKyyti()
        $params->[0]->{item} = {itemcallnumber => '84.2 SLO PK N'};
        is(C4::Labels::DataSource::public_yklKyyti($params), '84.2',      "Ykl Kyyti 1");
        $params->[0]->{item} = {itemcallnumber => '79.31 JAL PK N'};
        is(C4::Labels::DataSource::public_yklKyyti($params), '79.31',     "Ykl Kyyti 2");
        $params->[0]->{item} = {itemcallnumber => '32.182809 OUT PK A'};
        is(C4::Labels::DataSource::public_yklKyyti($params), '32.182809', "Ykl Kyyti 3");


    };
    if ($@) {
        ok(0, $@);
    }
}

t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
done_testing();
