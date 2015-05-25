#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 12;
use MARC::Record;

use C4::Context;

BEGIN {
        use_ok('C4::Record');
}

my $dbh = C4::Context->dbh;
# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

C4::Context->set_preference( "BibtexExportAdditionalFields", q{} );

my @marcarray=marc2marc;
is ($marcarray[0],"Feature not yet implemented\n","error works");

my $marc=new MARC::Record;
my $marcxml=marc2marcxml($marc);
my $testxml=qq(<?xml version="1.0" encoding="UTF-8"?>
<record
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
    xmlns="http://www.loc.gov/MARC21/slim">

  <leader>         a              </leader>
</record>
);
is ($marcxml, $testxml, "testing marc2xml");

my $rawmarc=$marc->as_usmarc;
$marcxml=marc2marcxml($rawmarc);
$testxml=qq(<?xml version="1.0" encoding="UTF-8"?>
<record
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.loc.gov/MARC21/slim http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd"
    xmlns="http://www.loc.gov/MARC21/slim">

  <leader>00026    a2200025   4500</leader>
</record>
);
is ($marcxml, $testxml, "testing marc2xml");

my $marcconvert=marcxml2marc($marcxml);
is ($marcconvert->as_xml,$marc->as_xml, "testing xml2marc");

my $marcdc=marc2dcxml($marc);
my $test2xml=qq(<?xml version="1.0" encoding="UTF-8"?>
<metadata
  xmlns="http://example.org/myapp/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://example.org/myapp/ http://example.org/myapp/schema.xsd"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/">
</metadata>);

is ($marcdc, $test2xml, "testing marc2dcxml");

my $marcqualified=marc2dcxml($marc,1);
my $test3xml=qq(<?xml version="1.0" encoding="UTF-8"?>
<metadata
  xmlns="http://example.org/myapp/"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://example.org/myapp/ http://example.org/myapp/schema.xsd"
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:dcterms="http://purl.org/dc/terms/">
</metadata>);

is ($marcqualified, $test3xml, "testing marcQualified");

my $mods=marc2modsxml($marc);
my $test4xml=qq(<?xml version="1.0" encoding="UTF-8"?>
<mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" version="3.1" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-1.xsd">
  <typeOfResource/>
  <originInfo>
    <issuance/>
  </originInfo>
  <recordInfo/>
</mods>
);

is ($mods, $test4xml, "testing marc2modsxml");

$marc->append_fields(MARC::Field->new(
    '100', ' ', ' ', a => 'Rowling, J.K.'
));
my $field = MARC::Field->new('245','','','a' => "Harry potter");
$marc->append_fields($field);
$marc->append_fields(MARC::Field->new(
    '260', ' ', ' ', b => 'Scholastic', c => '2001'
));

#my $endnote=marc2endnote($marc->as_usmarc);
#print $endnote;

my $bibtex=marc2bibtex($marc, 'testID');
my $test5xml=qq(\@book{testID,
	author = {Rowling, J.K.},
	title = {Harry potter},
	publisher = {Scholastic},
	year = {2001}
}
);

is ($bibtex, $test5xml, "testing bibtex");

C4::Context->set_preference( "BibtexExportAdditionalFields", "'\@': 260\$b\ntest: 260\$b" );
$bibtex = marc2bibtex( $marc, 'testID' );
my $test6xml = qq(\@Scholastic{testID,
\tauthor = {Rowling, J.K.},
\ttitle = {Harry potter},
\tpublisher = {Scholastic},
\tyear = {2001},
\ttest = {Scholastic}
}
);
is( $bibtex, $test6xml, "testing bibtex" );
C4::Context->set_preference( "BibtexExportAdditionalFields", q{} );

$marc->append_fields(MARC::Field->new(
    '264', '3', '1', b => 'Reprints', c => '2011'
));
$bibtex = marc2bibtex($marc, 'testID');
my $rdabibtex = qq(\@book{testID,
	author = {Rowling, J.K.},
	title = {Harry potter},
	publisher = {Reprints},
	year = {2011}
}
);
is ($bibtex, $rdabibtex, "testing bibtex with RDA 264 field");

my @entity=C4::Record::_entity_encode("Björn");
is ($entity[0], "Bj&#xC3;&#xB6;rn", "Html umlauts");








