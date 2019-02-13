#!/usr/bin/perl
# Patron blocking with Mikroväylä self-service library door (un)locking system
# Written by Pasi Korkalo / OUTI Kirjastot / Koha-Suomi Oy

# GNU GPL3 or later applies
# For full license text see https://www.gnu.org/licenses/gpl.html

# This will create Mikroväylä self-service library compatible XML
# patron blocklist based on self-service library blocks set in Koha

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
use YAML::XS;
use Data::Dumper;

# Nag about missing targetfile
die "No target filename given." unless $ARGV[0];

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

# Get self service rules and build query
my $ssrules = C4::Context->preference('SSRules');
my $rules = YAML::XS::Load($ssrules);

print Dumper $rules if $ENV{'DEBUG'};

die "BorrowerCategories not defined in SSRules" unless $rules->{BorrowerCategories}; # Allowed borrower categories will need to be defined
my $categories="'" . $rules->{BorrowerCategories} . "'";
   $categories=~s/ +/', '/g;

my $blocks="SELECT borrowernumber FROM borrower_attributes WHERE code='SSBAN' AND attribute IN ('1', 'BANNED'"; # Always block explicitly banned
   $blocks.=", 'NOTACCEPTED'" if $rules->{TaC};
   $blocks.=", 'NOPERMISSION'" if $rules->{Permission};
   $blocks.=")"; 

my $options;
   $options.="OR lost='1' " if $rules->{CardLost};
   $options.="OR dateexpiry<NOW() " if $rules->{CardExpired};
   $options.="OR debarred IS NOT NULL " if $rules->{Debarred};

warn "MinimumAge, OpeningHours and/or MaxFines is defined in SSRules, but not supported" if ( $rules->{MinimumAge} || $rules->{OpeningHours} || $rules->{MaxFines} ); 

# Get the patrons to be blocked and put their cardnumbers in XML
my $dbh=C4::Context->dbh();

warn "SELECT DISTINCT cardnumber FROM borrowers WHERE categorycode NOT IN ($categories) OR borrowernumber IN ($blocks) $options;" if $ENV{'DEBUG'};
my $sth=$dbh->prepare ("SELECT DISTINCT cardnumber FROM borrowers WHERE categorycode NOT IN ($categories) OR borrowernumber IN ($blocks) $options;");
$sth->execute();

while (my @patron = $sth->fetchrow_array()) {
    $xml.="  <patronaccess>\n    <patronid_pac>" . $patron[0] . "</patronid_pac>\n    <type_pac>1</type_pac>\n  </patronaccess>\n" unless $patron[0] eq '';
}
$xml.="</NewDataSet>\n";

$sth->finish();
$dbh->disconnect();

# Validate and write XML to a file. Validation is very basic, but not much can go wrong here.
die "The XML is not valid, will not write a targetfile." unless XML::Parser->new->parse($xml);

open XML, '>encoding(utf8)', $ARGV[0] or die "Can't write targetfile.";
print XML $xml;
close XML;

print "New blocklist written to " . $ARGV[0] . ".\n";
exit 0;
