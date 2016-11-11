#!/usr/bin/perl
package Koha::Procurement::EditX::LibraryShipNotice::MarcHelper;

use Modern::Perl;
use Moose;
use Data::Dumper;
use Encode;
use utf8;
no utf8;

use MARC::Record;
use MARC::File::XML ( BinaryEncoding => 'utf8', RecordFormat => 'MARC21' );
use MARC::Field;

sub createRecord{
     my $self = shift;
     my ($xmlString) = @_;
     my $record = MARC::Record->new_from_xml( $xmlString );
}

sub addMarc942 {
    my $self = shift;
    my $productForm = $_[0];
    my $marcrecord = $_[1];
    my $field = MARC::Field->new('942','','','c' => $productForm);
    $marcrecord->append_fields($field);
    return $marcrecord;
}

sub fixMarcIsbn {
    my $self = shift;
    my $marcrecord = $_[0];
    my $isbn;
    my $isbnField = $marcrecord->field('020');

    if(defined $isbnField){
        $isbn = $isbnField->subfield("a");
    }

    if(defined $isbn){
        my ($isbna,$isbnq) = split(' ', $isbn);

        $isbna =~ s/-//g;
        if(defined $isbnq){
            $isbnq =~ s/\(//g;
             $isbnq =~ s/\)//g;
        }

        if(defined $isbna){
            my $isbnaField = MARC::Field->new(
                '020', '', '',
                'a' => $isbna,
            );
            if(defined $isbnq && defined $isbnaField){
               $isbnaField->add_subfields( "q", $isbnq );
            }
            $isbnField->replace_with($isbnaField);
        }
    }
    return $marcrecord;
}

sub normalizeXmlNamespace{
    my $self = shift;
    my $documentXmlObject = $_[0];
    my $marcXml = $_[1];
    my $xmlString = '';

    if($marcXml){
        $xmlString = $marcXml;
        my %namespaces;
        my ($name, $value);
        foreach my $node ($documentXmlObject->findnodes('namespace::*')) {
            $name = $node->getLocalName();
            $value = $node->getValue();

            if(!$name){
                $name = 'xmlns';
            }
            if(!$value){
                $value = '';
            }
            $namespaces{$name} = $value;
        }

        for my $ns (keys %namespaces) {
            $xmlString =~ s/$ns://g;
            $xmlString =~ s/$ns="$namespaces{$ns}"//;
        }
        my $marcDocument = XML::LibXML->load_xml('string' => $xmlString);
        $marcDocument->createAttributeNS( 'http://www.loc.gov/MARC21/slim', 'xmlns' );
        $xmlString = $marcDocument->toString;
        #$xmlString = utf8::decode($xmlString);
        #$xmlString = encode('UTF-8', $xmlString, Encode::FB_CROAK);
    }
    return $xmlString;
}

1;
