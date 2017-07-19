use Modern::Perl;
use Test::More tests => 1;
use MARC::Record;

use t::lib::Mocks;
use C4::Biblio;

t::lib::Mocks::mock_preference('marcflavour', 'MARC21');

my $record = C4::Biblio::TransformKohaToMarc({
    "biblioitems.illus"   => "Other physical details", # 300$b
    "biblioitems.pages"   => "Extent",                 # 300$a
    "biblioitems.size"    => "Dimensions",             # 300$c
});

my @subfields = $record->field('300')->subfields();
is_deeply( \@subfields, [
          [
            'a',
            'Extent'
          ],
          [
            'b',
            'Other physical details'
          ],
          [
            'c',
            'Dimensions'
          ]
        ],
'TransformKohaToMarc should returns sorted subfields (regression test for bug 12343)' );
