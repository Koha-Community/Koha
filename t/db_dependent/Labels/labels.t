use Modern::Perl;
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

use Test::More;
use JSON::XS;
use Text::Diff ();
use Cwd;

use C4::Labels::Sheet;
use C4::Labels::PdfCreator;

use t::lib::WebDriverFactory;
use t::lib::TestObjects::ObjectFactory;
use t::lib::TestObjects::BiblioFactory;
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
                        },
                        {'biblionumber' => $biblio->{biblionumber},
                         'homebranch'   => 'CPL',
                         'barcode'      => '1N002',
                        },
                        {'biblionumber' => $biblio->{biblionumber},
                         'homebranch'   => 'CPL',
                         'barcode'      => '1N003',
                        },
                        {'biblionumber' => $biblio->{biblionumber},
                         'homebranch'   => 'CPL',
                         'barcode'      => '1N004',
                        },
                        {'biblionumber' => $biblio->{biblionumber},
                         'homebranch'   => 'CPL',
                         'barcode'      => '1N005',
                        },
                    ], undef, $testContext);
my @itemBarcodes = map {$items->{$_}->barcode()} keys(%$items);

my $sheet = t::lib::TestObjects::Labels::SheetFactory->createTestGroup(
                    {name => 'Sheetilian',
                    },
                    undef, $testContext);

subtest "Instantiate Sheet from JSON" => \&instantiateSheetFromJSON;
sub instantiateSheetFromJSON {
    is($sheet->getName(), "Sheetilian", "Sheet name");
    is($sheet->getVersion(), 1.2, "Sheet version");
    is($sheet->getTimestamp()->minute(), 3, "Sheet timestamp");

    my $items = $sheet->getItems();
    is(scalar(@$items), 2, "Items count");
    is($items->[0]->getIndex(), 1, "Item index 1");
    is($items->[1]->getIndex(), 2, "Item index 3 adjusted to 2");

    my $regions = $items->[0]->getRegions();
    is(scalar(@$regions), 2, "Regions count");
    my $region = $regions->[0];
    is($region->getDimensions()->{width}, 193, "Region dimension width");
    is($region->getDimensions()->{height}, 168, "Region dimension height");
    is($region->getBoundingBox(), 1, "Region boundingBox");

    my $elements = $region->getElements();
    is(scalar(@$elements), 2, "Elements count");
    my $element = $elements->[1];
    is($element->getDataSource(), 'homebranch.branchname', "Element dataSource");
    is($element->getPosition()->{left}, 13, "Element position left");
    is($element->getPosition()->{top}, 78, "Element position top");
    is($element->getColour()->{r}, 128, "Element colour r");
    is($element->getColour()->{g}, 196, "Element colour g");
    is($element->getColour()->{b}, 0, "Element colour b");
    is($element->getParent(), $region, "Element parent");
}

my $expectedPdfFilePath = Cwd::abs_path(__FILE__);
$expectedPdfFilePath =~ s/\.\w{1,3}$/.expected.pdf/;
my $createdPdfFilePath = Cwd::abs_path(__FILE__);
$createdPdfFilePath =~ s/\.\w{1,3}$/.test.pdf/;

subtest "Don't crash while baking .pdf" => \&bakePdf;
sub bakePdf {
    eval {
        my $margins = {left => 5, top => 5};
        my $pdfCreator = C4::Labels::PdfCreator->new({sheet => $sheet, margins => $margins, file => $createdPdfFilePath});
        $pdfCreator->create(\@itemBarcodes);
    };
    if ($@) {
        ok(0, $@);
    }
    else {
        ok(1, "Didn't crash :)");
    }
}


subtest "Verify .pdf output" => \&verifyPdfOutput;
sub verifyPdfOutput {
    my $expectedText = `pdftotext -layout -enc UTF-8 -eol unix $expectedPdfFilePath -`;
    my $resultText   = `pdftotext -layout -enc UTF-8 -eol unix $createdPdfFilePath -`;
    my $difference = Text::Diff::diff(\$expectedText, \$resultText, {});
    ok(not($difference), "The .pdf persists");
}

subtest "REST interfaces" => \&restInterfaces;
sub restInterfaces {
    my ($t) = t::lib::WebDriverFactory::getUserAgentDrivers('mojolicious');

    $t = $t->post_ok('/labels/sheets' => json => undef);
    $t->json_is('/name',      $sheet->getName());
    $t->json_is('/version',   $sheet->getVersion());

    $t = $t->get_ok('/labels/sheets');
    $t->json_is('/0/name',    $sheet->getName());
    $t->json_is('/0/version', $sheet->getVersion());

    $t = $t->get_ok('/labels/sheets/'.$sheet->getId());
    $t->json_is('/name',      $sheet->getName());
    $t->json_is('/timestamp', $sheet->getTimestamp());

    my $sheetilaptor; #delme
    $t = $t->post_ok('/labels/sheets' => json => $sheetilaptor);
    $t->json_is('/name',      $sheetilaptor->{name});
    $t->json_is('/version',   $sheetilaptor->{version});

    $sheetilaptor->{name} = "unistar";
    $t = $t->put_ok('/labels/sheets/'.$sheetilaptor->{id} => json => $sheetilaptor);
    $t->json_is('/name',      $sheetilaptor->{name});

    #Get the old version since the last modified
    $t = $t->get_ok('/labels/sheets/'.$sheetilaptor->{id}+'/'+$sheetilaptor->{version});
    $t->json_is('/name',      "unititled");

    #Make a third revision of $sheetilaptor
    $sheetilaptor->{name} = "unisex";
    $t = $t->put_ok('/labels/sheets/'.$sheetilaptor->{id} => json => $sheetilaptor);
    $t->json_is('/name',      $sheetilaptor->{name});

    #Get all the sheets and their versions
    $t = $t->get_ok('/labels/sheets/versions');
    $t->json_has('/0/1.2');
    $t->json_has('/1/0.2');
    $t->json_has('/1/0.3');
    $t->json_has('/1/0.4');

    #Delete the default version (newest)
    $t = $t->delete_ok('/labels/sheets/'.$sheetilaptor->{id});
    #Fail getting the newest version, since it is deleted, instead get the second version
    $t = $t->get_ok('/labels/sheets/'+$sheetilaptor->{id});
    $t->json_is('/name',      "unititled");

    #Delete all sheetilaptor variants
    $t = $t->delete_ok('/labels/sheets/'.$sheetilaptor->{id}+'/631373.00');

    $t = $t->get_ok('/labels/sheets/versions');
    $t->json_has('/0/1.2');
}

t::lib::TestObjects::ObjectFactory->tearDownTestContext($testContext);
done_testing();
