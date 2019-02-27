#!/usr/bin/perl
package Koha::Procurement::EditX::LibraryShipNotice;

use Modern::Perl;
use Moose;
use Data::Dumper;
use POSIX qw(strftime);
use Koha::Procurement::Logger;

has 'fileName' => (
    is => 'rw',
    reader => 'getFileName',
    writer => 'setFileName',
);

has 'xmlData' => (
    is => 'rw',
    reader => 'getXmlData',
    writer => '_setXmlData',
);

has 'parser' => (
    is => 'rw',
    reader => 'getParser',
    writer => 'setParser',
);

has 'itemDetailObjectName' => (
    is => 'rw',
    reader => 'getItemObjectName',
    writer => 'setItemObjectName'
);

has 'items' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getItems',
    writer => 'setItems'
);

has 'localTime' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    reader => 'getLocalTime',
    writer => 'setLocalTime'
);

has 'logger' => (
    is => 'rw',
    isa => 'Koha::Procurement::Logger',
    reader => 'getLogger',
    writer => 'setLogger'
);

sub BUILD {
    my $self = shift;
    $self->setItemObjectName('Koha::Procurement::EditX::LibraryShipNotice::ItemDetail');
    my @localTm = localtime;
    $self->setLocalTime(\@localTm);
    $self->setLogger(new Koha::Procurement::Logger);
}

sub setXmlData {
    my $self = shift;
    my $xmlData = $_[0];
    $xmlData = $self->setXmlDataHook($xmlData);
    $self->_setXmlData($xmlData);
}

sub setXmlDataHook{
    my $self = shift;
    my $xmlData = $_[0];
    return $xmlData;
}

sub validateHeader{
    my $self = shift;
    my ($xmlObject, $parser) = @_;

    my $result = 0;

    return $result;
}

sub getHeader {
    my $self = shift;
    my ($xmlObject, $parser) = @_;

    my $header = $xmlObject->findnodes('/LibraryShipNotice/Header', $parser);

    if($header && $header->size() == 1){
        $header = $header->get_node(1);
    }
    return $header;
}

sub getItemDetails {
    my $self = shift;
    my ($xmlObject, $parser) = @_;

    return $xmlObject->findnodes('/LibraryShipNotice/ItemDetail',$parser);
}

sub getCopydetails{
    my $self = shift;
    my ($xmlObject, $parser) = @_;

    return $xmlObject->findnodes('CopyDetail',$parser);
}

sub getCopyMessages{
    my $self = shift;
    my ($xmlObject, $parser) = @_;

    my $messages = $xmlObject->findnodes('Message',$parser);
    return $messages;
}

sub getSellerName{
    my $self = shift;
    my ($xmlObject, $parser) = @_;

    return $xmlObject->findnodes('SellerParty/PartyName/NameLine',$parser)->string_value();
}

sub getSellerId {
    my $self = shift;
    my $xmlObject = $self->getXmlData();
    my $parser = $self->getParser();
    my $header = $self->getHeader($xmlObject, $parser);

    return $header->findnodes('SellerParty/PartyID/Identifier',$parser)->string_value();
}

sub addItem{
    my $self = shift;
    my $item = $_[0];

    if($item && $item->isa($self->getItemObjectName())){
        push @{$self->{items}}, $item;
    }
}

sub getDateCreated {
    my $self = shift;
    my $time = $self->getLocalTime();
    return strftime "%Y-%m-%d", @$time;
}

sub getTimeStamp {
    my $self = shift;
    my $time = $self->getLocalTime();
    return strftime("%Y-%m-%d %H.%M.%S", @$time);
}

sub getBasketName{
    my $self = shift;
    my $xmlObject = $self->getXmlData();
    my $parser = $self->getParser();

    my $header = $self->getHeader($xmlObject, $parser);
    return $header->findnodes('ShipNoticeNumber',$parser)->string_value();
}

sub getPersonName {
    my $self = shift;
    my $xmlObject = $self->getXmlData();
    my $parser = $self->getParser();

    my $header = $self->getHeader($xmlObject, $parser);
    return $header->findnodes('BuyerParty/ContactPerson/PersonName',$parser)->string_value();
}

sub getVendorAssignedId {
    my $self = shift;
    my $xmlObject = $self->getXmlData();
    my $parser = $self->getParser();

    my $header = $self->getHeader($xmlObject, $parser);
    return $header->findnodes('BuyerParty/PartyID[PartyIDType/text() = "VendorAssignedID"]/Identifier',$parser)->string_value();
}

sub getBuyerAssignedId {
    my $self = shift;
    my $xmlObject = $self->getXmlData();
    my $parser = $self->getParser();

    my $header = $self->getHeader($xmlObject, $parser);
    return $header->findnodes('SellerParty/PartyID[PartyIDType/text() = "BuyerAssignedID"]/Identifier',$parser)->string_value();
}

sub normalizeEncoding {
    my $self = shift;
    my $value = $_[0];
    return $value;
}


1;
