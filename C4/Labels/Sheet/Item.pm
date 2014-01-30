package C4::Labels::Sheet::Item;
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

use C4::Labels::Sheet::Region;

use Koha::Exception::BadParameter;

sub new {
    my ($class, $sheet, $params) = @_;

    my $self = {};
    bless($self, $class);
    $self->setIndex($params->{index});
    $self->setParent($sheet);
    $self->setRegions($params->{regions});
    return $self;
}
sub toHash {
    my ($self) = @_;
    my $obj = {};
    $obj->{index} = $self->getIndex();
    $obj->{regions} = [];
    foreach my $region (@{$self->getRegions()}) {
        my $rj = $region->toHash();
        push @{$obj->{regions}}, $rj;
    }
    return $obj;
}
sub setIndex {
    my ($self, $index) = @_;
    unless ($index =~ /^\d+$/) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'index' is missing or is not a digit");
    }
    $self->{index} = $index;
}
sub getIndex { return shift->{index}; }
sub setRegions {
    my ($self, $regions) = @_;
    unless (ref($regions) eq 'ARRAY') {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'regions' is not an array");
    }
    $self->{regions} = [];
    foreach my $region (@$regions) {
        push(@{$self->{regions}}, C4::Labels::Sheet::Region->new($self, $region));
    }
}
sub getRegions { return shift->{regions}; }
sub setParent {
    my ($self, $sheet) = @_;
    unless (blessed($sheet) && $sheet->isa('C4::Labels::Sheet')) {
        Koha::Exception::BadParameter->throw(error => __PACKAGE__.":: Parameter 'parent' is not a Sheet-object");
    }
    $self->{parent} = $sheet;
}
sub getParent { return shift->{parent}; }
sub getSheet {
    my ($self) = @_;
    return $self->getParent();
}

return 1;
