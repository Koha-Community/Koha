package C4::Labels::Sheet::Region;
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

use Scalar::Util qw(blessed);

use C4::Labels::Sheet::Element;

use Koha::Exception::BadParameter;

sub new {
    my ($class, $item, $params) = @_;

    my $self = {};
    bless($self, $class);
    $self->setParent($item);
    $self->setDimensions($params->{dimensions});
    $self->setPosition($params->{position});
    $self->setBoundingBox($params->{boundingBox});
    $self->setElements($params->{elements});
    return $self;
}
sub toHash {
    my ($self) = @_;
    my $obj = {};
    $obj->{dimensions} = $self->getDimensions();
    $obj->{position} = $self->getPosition();
    $obj->{boundingBox} = ($self->getBoundingBox() == 1) ? 'true' : 'false';
    $obj->{elements} = [];
    foreach my $element (@{$self->getElements()}) {
        my $ej = $element->toHash();
        push @{$obj->{elements}}, $ej;
    }
    return $obj;
}
sub setDimensions {
    my ($self, $dimensions) = @_;
    unless ($dimensions && ref($dimensions) eq "HASH") {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'dimensions' is missing, or is not an object/hash");
    }
    unless ($dimensions->{width} =~ /^\d+$/ && $dimensions->{height} =~ /^\d+$/) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'dimensions' has bad width and/or height");
    }
    $self->{dimensions} = $dimensions;

    my $dpi = $self->getSheet()->getPdfDpi();
    $self->{pdfDimensions} = {};
    $self->{pdfDimensions}->{width} = $dpi * $dimensions->{width};
    $self->{pdfDimensions}->{height} = $dpi * $dimensions->{height};
}
sub getDimensions { return shift->{dimensions}; }
sub getPdfDimensions {return shift->{pdfDimensions}};
sub setPosition {
    my ($self, $position) = @_;
    unless ($position && ref($position) eq "HASH") {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'position' is missing, or is not an object/hash");
    }
    unless ($position->{left} =~ /^-?\d+$/ && $position->{top} =~ /^-?\d+$/) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'position' has bad 'left' and/or 'top'");
    }
    $self->{position} = $position;
}
sub getPosition { return shift->{position}; }
sub setPdfPosition {
    my ($self, $origo) = @_;
    my $sheet = $self->getParent()->getParent();
    my $sPos = $sheet->getPdfPosition();
    my $cssPosition = $self->getPosition();
    my $dpi = $self->getSheet()->getPdfDpi();

    $self->{x} = $sPos->{x} + ($dpi * $cssPosition->{left});
    $self->{y} = $sPos->{y} - ($dpi * $cssPosition->{top});
}
sub getPdfPosition {
    my ($self) = @_;
    return {x => $self->{x}, y => $self->{y}};
}
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
sub setElements {
    my ($self, $elements) = @_;
    unless (ref($elements) eq 'ARRAY') {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'elements' is not an array");
    }
    $self->{elements} = [];
    foreach my $element (@$elements) {
        push(@{$self->{elements}}, C4::Labels::Sheet::Element->new($self, $element));
    }
}
sub getElements { return shift->{elements}; }
sub setParent {
    my ($self, $item) = @_;
    unless (blessed($item) && $item->isa('C4::Labels::Sheet::Item')) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'parent' is not a C4::Labels::Sheet::Item-object");
    }
    $self->{parent} = $item;
}
sub getParent { return shift->{parent}; }
sub getSheet {
    my ($self) = @_;
    return $self->getParent()->getParent();
}
sub getItem {
    my ($self) = @_;
    return $self->getParent();
}

return 1;
