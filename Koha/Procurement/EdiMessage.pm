#!/usr/bin/perl
package Koha::Procurement::EdiMessage;

use C4::Context;
use Data::Dumper;
use File::Basename;
use XML::LibXML;

my $singleton;

sub new {
    my $class = shift;
    $singleton ||= bless {}, $class;
}

sub add {
    my $self = shift;
    my $messagefile = $_[0];
    my $raw_message = $_[1];
    my $dbh = C4::Context->dbh;
    $dbh->do("DELETE FROM edifact_messages WHERE filename='$messagefile'");
    my $sth = $dbh->prepare("INSERT INTO edifact_messages (message_type, transfer_date, raw_msg, filename) VALUES ('EDItX', NOW(), ?, ?)");
    $sth->execute($raw_message, $messagefile);
}

sub update {
    my $self = shift;
    my $messagefile = $_[0];
    my $status = $_[1];
    my $dbh = C4::Context->dbh;
    my $sth = $dbh->prepare("UPDATE edifact_messages SET status=? WHERE filename=?");
    $sth->execute($status, $messagefile);
}

sub findBookseller {
    my $self = shift;
    my $messagefile = $_[0];
    my $dbh = C4::Context->dbh;
    my $san = XML::LibXML->new()->parse_file($messagefile)->findnodes('/LibraryShipNotice/Header/BuyerParty/PartyID[PartyIDType/text() = "VendorAssignedID"]/Identifier')->string_value();
    my $sth = $dbh->prepare("SELECT vendor_id FROM vendor_edi_accounts WHERE san = ? AND id_code_qualifier='91' AND transport='FILE' AND orders_enabled='1'");
    $sth->execute($san);
    my $vendor_id = $sth->fetchrow_array();
    my $basename = basename($messagefile);
    $dbh->do("UPDATE edifact_messages SET vendor_id='$vendor_id' WHERE filename='$basename'");
}

1;
