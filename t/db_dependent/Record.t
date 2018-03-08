#!/usr/bin/perl

use Modern::Perl;

use Test::More tests => 14;
use MARC::Record;

use t::lib::Mocks;
use C4::Context;

BEGIN {
        use_ok('C4::Record');
}

my $dbh = C4::Context->dbh;
# Start transaction
$dbh->{AutoCommit} = 0;
$dbh->{RaiseError} = 1;

t::lib::Mocks::mock_preference( "BibtexExportAdditionalFields", q{} );

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

my $marcsrwdc=marc2dcxml( $marc, undef, undef, "srwdc" );
my $test2xml=qq(<?xml version="1.0" encoding="UTF-8"?>
<srw_dc:dc xmlns:srw_dc="info:srw/schema/1/dc-schema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="info:srw/schema/1/dc-schema http://www.loc.gov/z3950/agency/zing/srw/dc-schema.xsd">
  <type xmlns="http://purl.org/dc/elements/1.1/"/>
</srw_dc:dc>
);

is ($marcsrwdc, $test2xml, "testing SRWDC Metadata");

my $marcoaidc=marc2dcxml( $marc, undef, undef, "oaidc" );
my $test3xml=qq(<?xml version="1.0" encoding="UTF-8"?>
<oai_dc:dc xmlns:oai_dc="http://www.openarchives.org/OAI/2.0/oai_dc/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/oai_dc/ http://www.openarchives.org/OAI/2.0/oai_dc.xsd">
  <dc:type/>
  <dc:language/>
</oai_dc:dc>
);

is ($marcoaidc, $test3xml, "testing OAIDC Metadata");

my $marcrdfdc=marc2dcxml( $marc, undef, undef, "rdfdc" );
my $test4Axml=qq(<?xml version="1.0" encoding="UTF-8"?>
<rdf:Description xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <dc:type/>
  <dc:language/>
</rdf:Description>
);

is ($marcrdfdc, $test4Axml, "testing RDFDC Metadata");

my $marcdc=marc2dcxml( $marc, undef, undef, "dc" );
my $test4Bxml=qq(<?xml version="1.0" encoding="UTF-8"?>
<rdf:Description xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <dc:type/>
  <dc:language/>
</rdf:Description>
);

is ($marcrdfdc, $test4Bxml, "testing DC Metadata");

my $mods=marc2modsxml($marc);
my $test5xml=qq(<?xml version="1.0" encoding="UTF-8"?>
<mods xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.loc.gov/mods/v3" version="3.1" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-1.xsd">
  <typeOfResource/>
  <originInfo>
    <issuance/>
  </originInfo>
  <recordInfo/>
</mods>
);

is ($mods, $test5xml, "testing marc2modsxml");

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
my $test6xml=qq(\@book{testID,
	author = {Rowling, J.K.},
	title = {Harry potter},
	publisher = {Scholastic},
	year = {2001}
}
);

is ($bibtex, $test6xml, "testing bibtex");

t::lib::Mocks::mock_preference( "BibtexExportAdditionalFields", "'\@': 260\$b\ntest: 260\$b" );
$bibtex = marc2bibtex( $marc, 'testID' );
my $test7xml = qq(\@Scholastic{testID,
\tauthor = {Rowling, J.K.},
\ttitle = {Harry potter},
\tpublisher = {Scholastic},
\tyear = {2001},
\ttest = {Scholastic}
}
);
is( $bibtex, $test7xml, "testing bibtex" );
t::lib::Mocks::mock_preference( "BibtexExportAdditionalFields", q{} );

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








