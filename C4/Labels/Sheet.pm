package C4::Labels::Sheet;
# Copyright 2015 KohaSuomi
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

use DateTime;
use DateTime::Format::HTTP;

use C4::Labels::Sheet::Item;
use C4::Context;

use Koha::Exception::BadParameter;

sub new {
    my ($class, $params) = @_;

    my $self = {};
    bless($self, $class);
    $self->setName($params->{name});
    $self->setId($params->{id});
    $self->setDpi($params->{dpi});
    $self->setDimensions($params->{dimensions});
    $self->setVersion($params->{version});
    $self->setAuthor($params->{author});
    $self->setTimestamp($params->{timestamp});
    $self->setBoundingBox($params->{boundingBox});
    $self->setItems($params->{items});
    return $self;
}

=head toJSON

Use this to serialize this object and all attached components, items, regions and elements.

=cut

sub toJSON {
    my ($self) = @_;
    my $obj = $self->toHash();
    my $json = JSON::XS->new()->encode($obj);
    return $json;
}
=head toHash
Strips special object-stuff and returns a simplified easy-to-JSON hash.
=cut
sub toHash {
    my ($self) = @_;
    my $obj = {};
    $obj->{id} = $self->getId();
    $obj->{dpi} = $self->getDpi();
    $obj->{name} = $self->getName();
    $obj->{dimensions} = $self->getDimensions();
    $obj->{version} = $self->getVersion();
    $obj->{author} = $self->getAuthor();
    $obj->{timestamp} = $self->getTimestamp()->iso8601();
    $obj->{boundingBox} = ($self->getBoundingBox() == 1) ? 'true' : 'false';
    $obj->{items} = [];
    foreach my $item (@{$self->getItems()}) {
        my $ij = $item->toHash();
        push @{$obj->{items}}, $ij;
    }
    return $obj;
}
sub setName {
    my ($self, $name) = @_;
    unless ($name =~ /^.+$/) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'name' is missing");
    }
    $self->{name} = $name;
}
sub getName { return shift->{name}; }
sub setDpi {
    my ($self, $dpi) = @_;
    unless ($dpi =~ /^\d+$/) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'dpi' is missing or is not a digit");
    }
    unless ($dpi > 0) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'dpi' must be greater than 0");
    }
    $self->{dpi} = $dpi;
    $self->{pdfDpi} = 100/$dpi;
}
sub getDpi { return shift->{dpi}; }
sub getPdfDpi { return shift->{pdfDpi}; }
sub setId {
    my ($self, $id) = @_;
    unless ($id =~ /^\d+$/) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'id' is missing or is not a digit");
    }
    $self->{id} = $id;
}
sub getId { return shift->{id}; }
sub setDimensions {
    my ($self, $dimensions) = @_;
    unless ($dimensions && ref($dimensions) eq "HASH") {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'dimensions' is missing, or is not an object/hash");
    }
    unless ($dimensions->{width} =~ /^\d+$/ && $dimensions->{height} =~ /^\d+$/) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'dimensions' has bad width and/or height");
    }
    $self->{dimensions} = $dimensions;

    my $dpi = $self->getPdfDpi();
    $self->{pdfDimensions} = {};
    $self->{pdfDimensions}->{width} = $dpi * $dimensions->{width};
    $self->{pdfDimensions}->{height} = $dpi * $dimensions->{height};
}
sub getDimensions { return shift->{dimensions}; }
sub getPdfDimensions {return shift->{pdfDimensions}};
sub setPdfPosition {
    my ($self, $origo) = @_;

    my $dpi = $self->getPdfDpi();
    my $dimensions = $self->getPdfDimensions();
    $self->{x} = $dpi * ($origo->[0] + 0);
    $self->{y} = $dpi * ($dimensions->{height} + $origo->[1]);
}
sub getPdfPosition {
    my ($self) = @_;
    return {x => $self->{x}, y => $self->{y}};
}
sub setVersion {
    my ($self, $version) = @_;
    unless ($version =~ /^\d+\.?\d*$/) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'version' is not a float");
    }
    $self->{version} = $version;
}
sub getVersion { return shift->{version}; }
sub setAuthor {
    my ($self, $author) = @_;
    unless (ref($author) eq 'HASH' && $author->{borrowernumber} =~ /^\d+$/) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'author' is missing 'borrowernumber'-property");
    }
    $self->{author} = $author;
}
sub getAuthor { return shift->{author}; }
sub setTimestamp {
    my ($self, $timestamp) = @_;
    eval {
        my $dt = DateTime::Format::HTTP->parse_datetime( $timestamp );
        $self->{timestamp} = $dt;
    };
    if ($@) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'timestamp': $@");
    }
}
sub getTimestamp { return shift->{timestamp}; }
sub setBoundingBox {
    my ($self, $boundingBox) = @_;
    unless ($boundingBox =~ /^(1|0|true|false)$/) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'boundingBox' is not 'true|1' or 'false|0'");
    }
    if ($boundingBox =~ /(1|true)/) {
        $self->{boundingBox} = 1;
    }
    else {
        $self->{boundingBox} = 0;
    }
}
sub getBoundingBox { return shift->{boundingBox}; }
sub setItems {
    my ($self, $items) = @_;
    unless (ref($items) eq 'ARRAY') {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'items' is not an array");
    }
    $self->{items} = [];
    foreach my $item (@$items) {
        push(@{$self->{items}}, C4::Labels::Sheet::Item->new($self, $item));
    }

    #Remove index gaps for smoothly iterating printable labels groups in the correct order.
    my @sorted = sort {$a->getIndex() <=> $b->getIndex()} @{$self->{items}};
    for (my $i=0 ; $i<@sorted ; $i++) {
        $sorted[$i]->setIndex($i+1);
    }
}
sub getItems { return shift->{items}; }

return 1;
