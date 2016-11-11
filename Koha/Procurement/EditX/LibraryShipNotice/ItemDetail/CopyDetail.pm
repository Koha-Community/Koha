#!/usr/bin/perl
package Koha::Procurement::EditX::LibraryShipNotice::ItemDetail::CopyDetail;

use Modern::Perl;
use Moose;

use Data::Dumper;
use Koha::Procurement::BranchLocationYear::Parser;
use Koha::Procurement::EditX::LibraryShipNotice::MarcHelper;
use XML::LibXML;
use Encode;
use HTML::Entities;

has 'xmlData' => (
    is => 'rw',
    reader => 'getXmlData',
    writer => 'setXmlData',
    isa => 'XML::LibXML::Element'
);

has 'documentXmlData' => (
    is => 'rw',
    reader => 'getDocumentXmlData',
    writer => 'setDocumentXmlData',
);

has 'parser' => (
    is => 'rw',
    reader => 'getParser',
    writer => 'setParser',
);

has 'branchLocationYear' => (
    is => 'rw',
    isa => 'Koha::Procurement::BranchLocationYear::Parser',
    reader => 'getBranchExtractor',
    writer => 'setBranchExtractor'
);

has 'parent ' => (
    is => 'rw',
    reader => 'getParent',
    writer => 'setParent'
);

has 'marcHelper' => (
    is => 'rw',
    reader => 'getMarcHelper',
    writer => 'setMarcHelper',
    isa => 'Koha::Procurement::EditX::LibraryShipNotice::MarcHelper'
);

has 'marcRecord' => (
    is => 'rw',
    reader => 'getMarcRecord',
    writer => 'setMarcRecord',
    isa => 'MARC::Record'
);

sub BUILD {
    my $self = shift;
    my $marcH = Koha::Procurement::EditX::LibraryShipNotice::MarcHelper->new;
    $self->setMarcHelper($marcH);
    $self->setBranchExtractor(Koha::Procurement::BranchLocationYear::Parser->new());
}

sub getItemDetail{
    my $self = shift;
    return $self->getParent();
}

sub getLibraryShipNotice {
    my $self = shift;
    my $result = 0;
    my $item = $self->getItemDetail();
    if($item && $item->can('getLibraryShipNotice')){
        $result = $item->getLibraryShipNotice();
    }
    return $result;
}

sub getMarcData{
    my $self = shift;
    my $xmlData = $self->getXmlData();
    my $documentXmlObject = $self->getDocumentXmlData();
    my ($marcXml, $marcXmlLiteral, $marcXmlString, $record, $parser);
    if(!$self->getMarcRecord()){
        my $query = $self->getMarcXmlQuery();
        if($self->getMessages() && $self->getMessages()->get_node(1)){
            $marcXml = $documentXmlObject->findnodes($query, $self->getMessages()->get_node(1));
            $marcXml = $marcXml->get_node(1);
            if($marcXml->hasChildNodes){
                $marcXml = $marcXml->firstChild;
            }
            $marcXmlLiteral = $marcXml->to_literal;
            $parser = eval { XML::LibXML->load_xml('string' => $marcXmlLiteral) };
            if($parser){
                $marcXmlString = $parser->toString;
            }
            else{
                $marcXmlString = $marcXml->toString;
            }
            # Dump marcxml on screen:
            # print Dumper $marcXmlString;
            my $xmlString = $self->getMarcHelper->normalizeXmlNamespace($marcXml, $marcXmlString);
            $record = $self->getMarcHelper()->createRecord($xmlString);
            if($record){
                $self->setMarcRecord($record);
            }
        }
    }
    return $self->getMarcRecord();
}

sub getMarcXmlQuery {
    my $self = shift;
    return '../Message[MessageType/text() = "04"]/MessageLine';
}

sub getMarcXml{
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $xml;

    if($marcRecord){
        $xml = $marcRecord->as_xml();
    }
    return $xml;
}

sub getYearOfPublication {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $yearOfPublication;

    if($marcRecord){
        $yearOfPublication = $marcRecord->subfield('260','c');
    }
    if(!$yearOfPublication || $yearOfPublication eq ''){
        my $item = $self->getItemDetail();
        my $xmlData = $item->getXmlData();
        $yearOfPublication = $xmlData->find('ItemDescription/YearOfPublication')->string_value;
    }
    if(!$yearOfPublication){
       $yearOfPublication = '';
    }
    return $yearOfPublication;
}

sub getPublisherName {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $publisherName;

    my $item = $self->getItemDetail();
    my $xmlData = $item->getXmlData();
    $publisherName = $xmlData->find('ItemDescription/PublisherName')->string_value;
    if($marcRecord && ($publisherName || $publisherName eq '')){
        $publisherName = $marcRecord->subfield('260','b');
    }

    if(!$publisherName){
       $publisherName = '';
    }
    return $publisherName;
}

sub getCopyRightDate{
    my $self = shift;
    my $xmlData = $self->getXmlData();

    my $result = $xmlData->find('ItemDescription/ProductForm')->string_value;
    return $result;
}

sub getMessages{
    my $self = shift;
    my $xmlObject = $self->getXmlData();
    my $parser = $self->getParser();
    my $messages = $xmlObject->findnodes('Message',$parser);
    return $messages;
}

sub getCopyQuantity {
    my $self = shift;
    my $xmlObject = $self->getXmlData();

    my $result = $xmlObject->findnodes('CopyQuantity')->string_value;
    return $result;
}

sub getFundNumber{
    my $self = shift;
    my $xmlObject = $self->getXmlData();
    return $xmlObject->findnodes('FundDetail/FundNumber')->string_value;
}

sub getFundMonetaryAmount {
    my $self = shift;
    my $xmlObject = $self->getXmlData();
    return $xmlObject->findnodes('FundDetail/MonetaryAmount')->string_value;
}

sub getDeliverToLocation {
    my $self = shift;
    my $xmlObject = $self->getXmlData();
    return $xmlObject->findnodes('DeliverToLocation')->string_value;
}

sub initBranchLocationYear {
    my $self = shift;
    my $branchExtractor = $self->getBranchExtractor();
    if(!$branchExtractor->getBranchCode() || !$branchExtractor->getLocation() || !$branchExtractor->getYear() ){
        $branchExtractor->extract($self->getDeliverToLocation());
    }
}

sub getBranchCode {
    my $self = shift;
    my $branchCode = '';
    my $branchExtractor = $self->getBranchExtractor();
    if($branchExtractor){
        $self->initBranchLocationYear();
        $branchCode = $branchExtractor->getBranchCode();
    }
    return $branchCode;
}

sub getLocation {
    my $self = shift;
    my $location = '';
    my $branchExtractor = $self->getBranchExtractor();
    if($branchExtractor){
        $self->initBranchLocationYear();
        $location = $branchExtractor->getLocation();
    }
    return $location;
}

sub getFundYear {
    my $self = shift;
    my $year = '';
    my $branchExtractor = $self->getBranchExtractor();
    if($branchExtractor){
        $self->initBranchLocationYear();
        $year = $branchExtractor->getYear();
    }
    return $year;
}

sub getIsbns {
    my $self = shift;
    my $isbns = [];
    return $isbns;
}

sub getEditionStatement {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $editionStatement;
    if($marcRecord){
        $editionStatement = $marcRecord->subfield('250','a');
    }
    if(!$editionStatement){
       $editionStatement = '';
    }
    return $editionStatement;
}

sub getImageDescrition {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $image;

    if($marcRecord){
        $image = $marcRecord->subfield('856','u');
    }
    if(!$image){
       $image = '';
    }
    return $image;
}

sub getPages {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $pages;

    if($marcRecord){
        $pages = $marcRecord->subfield('300','a');
    }
    if(!$pages){
       $pages = '';
    }
    return $pages;
}

sub getPlace {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $place;

    if($marcRecord){
        $place = $marcRecord->subfield('260','a');
    }
    if(!$place){
       $place = '';
    }
    return $place;
}

sub getIsbn {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $result;

    if($marcRecord){
        $result = $marcRecord->subfield('020','a');
    }
    if(!$result){
       $result = '';
    }
    return $result;
}

sub getMarcStdIdentifier {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $result;

    if($marcRecord){
        $result = $marcRecord->subfield('024','a');
    }
    if(!$result){
       $result = '';
    }
    return $result;
}

sub getMarcPublisherIdentifier {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $result;

    if($marcRecord){
        $result = $marcRecord->subfield('028','a');
    }
    if(!$result){
       $result = '';
    }
    return $result;
}

sub getMarcPublisher {
    my $self = shift;
    my $marcRecord = $self->getMarcData();
    my $result;

    if($marcRecord){
        $result = $marcRecord->subfield('028','b');
    }
    if(!$result){
       $result = '';
    }
    return $result;
}

sub addMarc942 {
    my $self = shift;
    my $productForm = $_[0];
    my $record = $self->getMarcHelper()->addMarc942($productForm, $self->getMarcData());
    $self->setMarcRecord($record);
}

sub fixMarcIsbn {
    my $self = shift;
    my $record = $self->getMarcHelper()->fixMarcIsbn($self->getMarcData());
    $self->setMarcRecord($record);
}


1;
