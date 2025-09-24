#!/usr/bin/perl

# Copyright 2014 Rijksmuseum
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use File::Temp qw/tempfile/;
use Test::NoWarnings;
use Test::More tests => 34;
use Test::Warn;

use Koha::XSLT::Base;

my $engine = Koha::XSLT::Base->new;
is( ref $engine, 'Koha::XSLT::Base', 'Testing creation of handler object' );

$engine->transform('');
is( $engine->err, Koha::XSLT::Base::XSLTH_ERR_1, 'Engine returns error on no file' );

$engine->transform( '', 'thisfileshouldnotexist.%$#@' );
is( $engine->err,                   Koha::XSLT::Base::XSLTH_ERR_2, 'Engine returns error on bad file' );
is( $engine->refresh('asdjhaskjh'), 0,                             'Test on invalid refresh' );

#check first test xsl
my $xsl_1 = <<'XSL_1';
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
>
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:template match="record|marc:record">
      <record>
      <xsl:apply-templates/>
      <datafield tag="990" ind1='' ind2=''>
        <subfield code="a">
          <xsl:text>I saw you</xsl:text>
        </subfield>
      </datafield>
      </record>
  </xsl:template>

  <xsl:template match="node()">
    <xsl:copy select=".">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
XSL_1

# Testing not-xml strings (undef, empty, some text, malformed xml
# Undefined text tests
my $output;
$output = $engine->transform( { xml => undef, code => $xsl_1 } );
is( $engine->err, Koha::XSLT::Base::XSLTH_ERR_7, 'Engine returns error on undefined text' );

# Empty string tests
warning_like { $output = $engine->transform( { xml => '', code => $xsl_1 } ) }
qr/XSLT::Base: Empty String/,
    'Empty string warning detected';
is( $engine->err, Koha::XSLT::Base::XSLTH_ERR_5, 'Engine returns error on empty string' );

# Non-XML tests
$engine->print_warns(1);
warning_like { $output = $engine->transform( { xml => 'abcdef', code => $xsl_1 } ) }
qr{parser error : Start tag expected, '<' not found},
    "Non-XML warning correctly displayed";
is( $engine->err, Koha::XSLT::Base::XSLTH_ERR_5, 'Engine returns error on non-xml' );

# Malformed XML tests
warning_like { $output = $engine->transform( { xml => '<a></b>', code => $xsl_1 } ) }
qr{parser error : Opening and ending tag mismatch: a line (0|1) and b},
    "Malformed XML warning correctly displayed";
is( $engine->err, Koha::XSLT::Base::XSLTH_ERR_5, 'Engine returns error on malformed xml' );

#Test not returning source on failure when asked for
#Include passing do_not_return via constructor on second engine
my $secondengine = Koha::XSLT::Base->new(
    {
        do_not_return_source => 'very_true',
        some_unknown_attrib  => 'just_for_fun',
    }
);
$engine->do_not_return_source(1);
warning_like { $output = $engine->transform( { xml => '<a></b>', code => $xsl_1 } ) }
qr{parser error : Opening and ending tag mismatch: a line (0|1) and b},
    "Malformed XML warning correctly displayed";
is( defined $output ? 1 : 0, 0, 'Engine respects do_not_return_source==1' );
$secondengine->print_warns(1);
warning_like { $output = $secondengine->transform( { xml => '<a></b>', code => $xsl_1 } ) }
qr{parser error : Opening and ending tag mismatch: a line (0|1) and b},
    "Malformed XML warning correctly displayed";
is( defined $output ? 1 : 0, 0, 'Second engine respects it too' );
undef $secondengine;    #bye
$engine->do_not_return_source(0);
warning_like { $output = $engine->transform( { xml => '<a></b>', code => $xsl_1 } ) }
qr{parser error : Opening and ending tag mismatch: a line (0|1) and b},
    "Malformed XML warning correctly displayed";
is( defined $output ? 1 : 0, 1, 'Engine respects do_not_return_source==0' );

#Testing valid refresh now
my $xsltfile_1 = mytempfile($xsl_1);
$output = $engine->transform( '<records/>', $xsltfile_1 );
is( $engine->refresh($xsltfile_1), 1, 'Test on valid refresh' );
is( $engine->refresh,              1, 'Second refresh returns 1 for code xsl_1' );
is( $engine->refresh,              0, 'Third refresh: nothing left' );

#Testing a string that should not change too much
my $xml_1 = <<'EOT';
<just_a_tagname>
</just_a_tagname>
EOT
$output = $engine->transform( { xml => $xml_1, code => $xsl_1 } );
is( $engine->err,                             undef, 'Engine returned no error for xml_1' );
is( index( $output, '<just_a_tagname>' ) > 0, 1,     'No real change expected for xml_1' )
    ;    #Just very simple check if the tag was still there

#Test of adding a new datafield to rudimentary 'marc record'
my $xml_2 = <<'EOT';
<?xml version="1.0" encoding="UTF-8"?>
<collection>
<record>
<controlfield tag="001">1234</controlfield>
<datafield tag="245" ind1="1" ind2="0"><subfield tag="a">My favorite title</subfield></datafield>
</record>
</collection>
EOT
$output = $engine->transform($xml_2);

#note: second parameter not passed again
is( $engine->err,                      undef, 'Engine returned no error for xml_2' );
is( index( $output, 'I saw you' ) > 0, 1,     'Saw the expected change for xml_2' )
    ;    #Just very simple check if new datafield was added

#Test alternative parameter passing
my $output2;
$output2 = $engine->transform( { file => $xsltfile_1, xml => $xml_2 } );
is( $output, $output2, 'Try hash parameter file' );
$output2 = $engine->transform( { code => $xsl_1, xml => $xml_2 } );
is( $output, $output2, 'Try hash parameter code' );

#Check rerun on last code
$output2 = $engine->transform($xml_2);
is( $output, $output2, 'Rerun on previous passed code' );

#Check format xmldoc
is(
    ref $engine->transform(
        {
            file => $xsltfile_1, xml => $xml_2, format => 'xmldoc',
        }
    ),
    'XML::LibXML::Document',
    'Format parameter returns a xml document object'
);

#The second test xsl contains bad code
my $xsl_2 = <<'XSL_2';
<!-- This is BAD coded xslt stylesheet -->
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
>
  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

  <xsl:variable name="redefine" select="0"/>
  <xsl:variable name="redefine" select="1"/>
      <!-- Intentional redefine to generate parsing error -->
  <xsl:template match="record">
  </xsl:template>
</xsl:stylesheet>
XSL_2

$engine->print_warns(0);
$output = $engine->transform( { xml => $xml_2, code => $xsl_2 } );
is( $engine->err, Koha::XSLT::Base::XSLTH_ERR_4, 'Engine returned error for parsing bad xsl' );

#The third test xsl is okay again; main use is clearing two items from cache
my $xsl_3 = <<'XSL_3';
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
>
  <xsl:output method="xml" encoding="UTF-8" version="1.0" indent="yes"/>

  <xsl:template match="/">
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="node()">
    <xsl:copy select=".">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
XSL_3

$output = $engine->transform( { xml => $xml_2, code => $xsl_3 } );
is( $engine->err,     undef, 'Unexpected error on transform with third xsl' );
is( $engine->refresh, 3,     'Final test on clearing cache' );

# Test xsl no 4
my $xsl_4 = <<'XSL_4';
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:marc="http://www.loc.gov/MARC21/slim"
>
  <xsl:output method="xml" encoding="UTF-8" version="1.0" indent="yes"/>
  <xsl:param name="injected_variable" />

  <xsl:template match="/">
      <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="node()">
    <xsl:copy>
   <xsl:value-of select="$injected_variable"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
XSL_4

my $parameters = { injected_variable => "'this is a test'", };
$output = $engine->transform(
    {
        xml        => $xml_1,
        code       => $xsl_4,
        parameters => $parameters,
    }
);
require XML::LibXML;
my $dom    = XML::LibXML->load_xml( string => $output );
my $result = $dom->find('/just_a_tagname');
is( $result->to_literal(), 'this is a test', "Successfully injected string into XSLT parameter/variable" );

$output = $engine->transform(
    {
        xml  => $xml_1,
        code => $xsl_4,
    }
);
$dom    = XML::LibXML->load_xml( string => $output );
$result = $dom->find('/just_a_tagname');
is( $result->to_literal(), '', "As expected, no XSLT parameters/variables were added" );

sub mytempfile {
    my ( $fh, $fn ) = tempfile( SUFFIX => '.xsl', UNLINK => 1 );
    print $fh $_[0] // '';
    close $fh;
    return $fn;
}
