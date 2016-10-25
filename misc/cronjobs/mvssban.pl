#!/usr/bin/perl
# Patron blocking with Mikroväylä self-service library door (un)locking system
# Written by Pasi Korkalo / OUTI Kirjastot / Koha-Suomi Oy

# GNU GPL3 or later applies
# For full license text see https://www.gnu.org/licenses/gpl.html

# This will create Mikroväylä self-service library compatible XML
# patron blocklist based on self-service library blocks set in Koha
# (borrowerattribute SSBAN or OMATO).

# Enter the location of the output file as a parameter, i.e. where
# Mikroväylä will be able to fetch it to their machines. Old targetfile
# with the same name will always be replaced by a new one, provided
# that the new one is valid XML.

# Koha HTTP(S) server with http-auth (digest) is an obvious choice for
# the location of blocklist.

use utf8;
use strict;
use C4::Context;
use XML::Parser;

# Nag about missing targetfile
if ( $ARGV[0] eq '' ) {
    print "No target filename given.\n";
    exit 1;
}

# Initialize the XML blocklist
my $xml = << 'HEAD_END';
<?xml version="1.0" standalone="yes"?>
<NewDataSet>
  <xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
    <xs:element name="NewDataSet" msdata:IsDataSet="true" msdata:MainDataTable="patronaccess" msdata:UseCurrentLocale="true">
      <xs:complexType>
        <xs:choice minOccurs="0" maxOccurs="unbounded">
          <xs:element name="patronaccess">
            <xs:complexType>
              <xs:sequence>
                <xs:element name="patronid_pac" type="xs:string" />
                <xs:element name="type_pac" type="xs:byte" minOccurs="0" />
              </xs:sequence>
            </xs:complexType>
          </xs:element>
        </xs:choice>
      </xs:complexType>
      <xs:unique name="Constraint1" msdata:PrimaryKey="true">
        <xs:selector xpath=".//patronaccess" />
        <xs:field xpath="patronid_pac" />
      </xs:unique>
    </xs:element>
  </xs:schema>
HEAD_END

# Get the patrons to be blocked and put their cardnumbers in XML
my $dbh=C4::Context->dbh();
my $blockme=$dbh->prepare ("SELECT DISTINCT cardnumber FROM borrowers WHERE borrowernumber IN (SELECT borrowernumber FROM borrower_attributes WHERE code='SSBAN' OR code='OMATO') OR lost='1' OR categorycode='YHTEISO';"); # FIXME - YHTEISO is hardcoded here, get rid of it one way or another
$blockme->execute();
while (my @patron = $blockme->fetchrow_array()) {
    $xml = $xml . "  <patronaccess>\n    <patronid_pac>" . $patron[0] . "</patronid_pac>\n    <type_pac>1</type_pac>\n  </patronaccess>\n" unless $patron[0] eq '';
}
$xml = $xml . "</NewDataSet>\n";
$dbh->disconnect;

# Validate and write XML to a file. Validation is very basic, but not much can go wrong here.
if ( XML::Parser->new->parse($xml) ) {
    open XML, '>encoding(utf8)', $ARGV[0] or die "Can't write targetfile.";
    print XML $xml;
    close XML;
    print "New blocklist written to " . $ARGV[0] . ".\n";
} else {
    print "The XML is not valid, will not write a targetfile.\n";
    exit 1;
}

exit 0;
