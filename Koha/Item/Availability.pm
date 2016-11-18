package Koha::Item::Availability;

# Copyright Koha-Suomi Oy 2016
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
use Scalar::Util qw(looks_like_number);

use base qw(Koha::Availability);

use Koha::Exceptions;
use Koha::Exceptions::Item;
use Koha::Exceptions::Patron;

=head1 NAME

Koha::Item::Availability - Koha Item Availability object class

=head1 SYNOPSIS

Parent class for different types of item availabilities.

=head1 DESCRIPTION

=head2 Class Methods

This class is for storing item availability information. It is a subclass of
Koha::Availability. For more documentation on usage, see Koha::Availability.

=cut

=head3 new

my $availability = Koha::Item::Availability->new({
    itemnumber => 123
});

REQUIRED PARAMETERS:
    item (Koha::Item) / itemnumber

OPTIONAL PARAMETERS:
    patron (Koha::Patron) / borrowernumber

Creates a new Koha::Item::Availability object.

=cut

sub new {
    my $class = shift;
    my ($params) = @_;
    my $self = $class->SUPER::new(@_);

    $self->{'item'} = undef;
    $self->{'patron'} = undef;

    if (exists $params->{'item'}) {
        unless (ref($params->{'item'}) eq 'Koha::Item') {
            Koha::Exceptions::BadParameter->throw(
                error => 'Parameter must be a Koha::Item object.',
                parameter => 'item',
            );
        }
        $self->item($params->{'item'});
    } elsif (exists $params->{'itemnumber'}) {
        unless (looks_like_number($params->{'itemnumber'})) {
            Koha::Exceptions::BadParameter->throw(
                error => 'Parameter must be a numeric value.',
                parameter => 'itemnumber',
            );
        }
        $self->item(Koha::Items->find($params->{'itemnumber'}));
        unless ($self->item) {
            Koha::Exceptions::Item::NotFound->throw(
                error => 'Item not found.',
                itemnumber => $params->{'itemnumber'},
            );
        }
    } else {
        Koha::Exceptions::MissingParameter->throw(
            error => "Missing one of parameters 'itemnumber, 'item'.",
            parameter => ["itemnumber", "item"],
        );
    }

    if (exists $params->{'patron'}) {
        unless (ref($params->{'patron'}) eq 'Koha::Patron') {
            Koha::Exceptions::BadParameter->throw(
                error => 'Parameter must be a Koha::Patron object.',
                parameter => 'patron',
            );
        }
        $self->patron($params->{'patron'});
    } elsif (exists $params->{'borrowernumber'}) {
        unless (looks_like_number($params->{'borrowernumber'})) {
            Koha::Exceptions::BadParameter->throw(
                error => 'Parameter must be a numeric value.',
                parameter => 'borrowernumber',
            );
        }
        $self->patron(Koha::Patrons->find($params->{'borrowernumber'}));
        unless ($self->patron) {
            Koha::Exceptions::Patron::NotFound->throw(
                error => 'Patron not found.',
                borrowernumber => $params->{'borrowernumber'},
            );
        }
    }

    return $self;
}

1;
