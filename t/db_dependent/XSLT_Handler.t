#!/usr/bin/perl

# Copyright 2014 Rijksmuseum
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

use FindBin;
use File::Slurp;
use Test::More tests => 35;
use Test::Warn;

use Koha::XSLT_Handler;

my $engine=Koha::XSLT_Handler->new;
is( ref $engine, 'Koha::XSLT_Handler', 'Testing creation of handler object' );

$engine->transform('');
is( $engine->err, Koha::XSLT_Handler::XSLTH_ERR_1, 'Engine returns error on no file' );

$engine->transform( '', 'thisfileshouldnotexist.%$#@' );
is( $engine->err, Koha::XSLT_Handler::XSLTH_ERR_2, 'Engine returns error on bad file' );
is( $engine->refresh( 'asdjhaskjh'), 0, 'Test on invalid refresh' );

#check first test xsl
my $path= $FindBin::Bin.'/XSLT_Handler/';
my $xsltfile_1 = 'test01.xsl';
is( -e $path.$xsltfile_1, 1, "Found my test stylesheet $xsltfile_1" );
exit if !-e $path.$xsltfile_1;
$xsltfile_1= $path.$xsltfile_1;

#Testing not-xml strings (undef, empty, some text, malformed xml
my $output;

# Undefined text tests
$output = $engine->transform( undef, $xsltfile_1 );
is( $engine->err, Koha::XSLT_Handler::XSLTH_ERR_7, 'Engine returns error on undefined text' );

# Empty string tests
$output = $engine->transform( '', $xsltfile_1 );
is( $engine->err, Koha::XSLT_Handler::XSLTH_ERR_5, 'Engine returns error on empty string' );

# Non-XML tests
$engine->print_warns(1);
warning_like { $output = $engine->transform( 'abcdef', $xsltfile_1 ) }
    qr{parser error : Start tag expected, '<' not found},
    "Non-XML warning correctly displayed";
is( $engine->err, Koha::XSLT_Handler::XSLTH_ERR_5, 'Engine returns error on non-xml' );

# Malformed XML tests
warning_like { $output = $engine->transform( '<a></b>', $xsltfile_1 ) }
    qr{parser error : Opening and ending tag mismatch: a line 1 and b},
    "Malformed XML warning correctly displayed";
is( $engine->err, Koha::XSLT_Handler::XSLTH_ERR_5, 'Engine returns error on malformed xml' );

#Test not returning source on failure when asked for
#Include passing do_not_return via constructor on second engine
my $secondengine=Koha::XSLT_Handler->new( {
    do_not_return_source => 'very_true',
    some_unknown_attrib  => 'just_for_fun',
});
$engine->do_not_return_source(1);
warning_like { $output = $engine->transform( '<a></b>', $xsltfile_1 ) }
    qr{parser error : Opening and ending tag mismatch: a line 1 and b},
    "Malformed XML warning correctly displayed";
is( defined $output? 1: 0, 0, 'Engine respects do_not_return_source==1');
$secondengine->print_warns(1);
warning_like { $output = $secondengine->transform( '<a></b>', $xsltfile_1 ) }
    qr{parser error : Opening and ending tag mismatch: a line 1 and b},
    "Malformed XML warning correctly displayed";
is( defined $output? 1: 0, 0, 'Second engine respects it too');
undef $secondengine; #bye
$engine->do_not_return_source(0);
warning_like { $output = $engine->transform( '<a></b>', $xsltfile_1 ) }
    qr{parser error : Opening and ending tag mismatch: a line 1 and b},
    "Malformed XML warning correctly displayed";
is( defined $output? 1: 0, 1, 'Engine respects do_not_return_source==0');

#Testing valid refresh now
is( $engine->refresh($xsltfile_1), 1, 'Test on valid refresh' );
#A second time (for all) should return 0 now
is( $engine->refresh, 0, 'Test on repeated refresh' );

#Testing a string that should not change too much
my $xml_1=<<'EOT';
<just_a_tagname>
</just_a_tagname>
EOT
$output= $engine->transform( $xml_1, $xsltfile_1 );
is( $engine->err, undef, 'Engine returned no error for xml_1' );
is( index($output,'<just_a_tagname>')>0, 1, 'No real change expected for xml_1' ); #Just very simple check if the tag was still there

#Test of adding a new datafield to rudimentary 'marc record'
my $xml_2=<<'EOT';
<?xml version="1.0" encoding="UTF-8"?>
<collection>
<record>
<controlfield tag="001">1234</controlfield>
<datafield tag="245" ind1="1" ind2="0"><subfield tag="a">My favorite title</subfield></datafield>
</record>
</collection>
EOT
$output= $engine->transform( $xml_2 );
    #note: second parameter (file) not passed again
is( $engine->err, undef, 'Engine returned no error for xml_2' );
is( index($output,'I saw you')>0, 1, 'Saw the expected change for xml_2' ); #Just very simple check if new datafield was added
#Test alternative parameter passing
my $output2;
$output2 = $engine->transform( { file => $xsltfile_1, xml => $xml_2 } );
is( $output, $output2, 'Try hash parameter file');
my $code = read_file( $xsltfile_1 );
$output2 = $engine->transform( { code => $code, xml => $xml_2 } );
is( $output, $output2, 'Try hash parameter code');
#Check rerun on last code
$output2 = $engine->transform( $xml_2 );
is( $output, $output2, 'Rerun on previous passed code');
#Check format xmldoc
is( ref $engine->transform({
    file => $xsltfile_1, xml => $xml_2, format => 'xmldoc',
}), 'XML::LibXML::Document',
'Format parameter returns a xml document object' );

#The second test xsl contains bad code
my $xsltfile_2 = 'test02.xsl';
is( -e $path.$xsltfile_2, 1, "Found my test stylesheet $xsltfile_2" );
exit if !-e $path.$xsltfile_2;
$xsltfile_2= $path.$xsltfile_2;

$engine->print_warns(0);
$output = $engine->transform( $xml_2, $xsltfile_2 );
is( $engine->err, Koha::XSLT_Handler::XSLTH_ERR_4, 'Engine returned error for parsing bad xsl' );

#The third test xsl is okay again; main use is clearing two items from cache
my $xsltfile_3 = 'test03.xsl';
is( -e $path.$xsltfile_3, 1, "Found my test stylesheet $xsltfile_3" );
exit if !-e $path.$xsltfile_3;
$xsltfile_3= $path.$xsltfile_3;
$output= $engine->transform( $xml_2, $xsltfile_3 );
is( $engine->err, undef, 'Unexpected error on transform with third xsl' );
is( $engine->refresh, 3, 'Final test on clearing cache' );

my $xsltfile_4 = 'test04.xsl';
is( -e $path.$xsltfile_4, 1, "Found my test stylesheet $xsltfile_4" );
exit if !-e $path.$xsltfile_4;
$xsltfile_4 = $path.$xsltfile_4;

my $parameters = { injected_variable => "'this is a test'",};
$output = $engine->transform({
            xml => $xml_1,
            file => $xsltfile_4,
            parameters => $parameters,
        });
require XML::LibXML;
my $dom = XML::LibXML->load_xml(string => $output);
my $result = $dom->find( '/just_a_tagname' );
is ( $result->to_literal(), 'this is a test', "Successfully injected string into XSLT parameter/variable");

$output = $engine->transform({
            xml => $xml_1,
            file => $xsltfile_4,
        });
$dom = XML::LibXML->load_xml(string => $output);
$result = $dom->find( '/just_a_tagname' );
is ( $result->to_literal(), '', "As expected, no XSLT parameters/variables were added");
#End of tests
