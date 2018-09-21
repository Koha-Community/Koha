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
        my $item = Koha::Items->find($params->{'itemnumber'});
        $self->item($item);
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
            ) if $params->{'patron'};
        }
        $self->patron($params->{'patron'});
    } elsif (exists $params->{'borrowernumber'}) {
        unless (looks_like_number($params->{'borrowernumber'})) {
            Koha::Exceptions::BadParameter->throw(
                error => 'Parameter must be a numeric value.',
                parameter => 'borrowernumber',
            );
        }
        my $patron = Koha::Patrons->find($params->{'borrowernumber'});
        $self->patron($patron);
        unless ($self->patron) {
            Koha::Exceptions::Patron::NotFound->throw(
                error => 'Patron not found.',
                borrowernumber => $params->{'borrowernumber'},
            );
        }
    }

    return $self;
}

=head3 swaggerize

Returns a HASHref that contains item availability information.

Numifies numbers for Swagger to be numbers instead of strings.

=cut

sub swaggerize {
    my ($self) = @_;

    my $confirmations = $self->SUPER::_swaggerize_exception($self->confirmations);
    my $notes = $self->SUPER::_swaggerize_exception($self->notes);
    my $unavailabilities = $self->SUPER::_swaggerize_exception($self->unavailabilities);
    my $item = $self->item;
    my $availability = {
        available => $self->available
                         ? Mojo::JSON->true
                         : Mojo::JSON->false,
    };
    if (keys %{$confirmations} > 0) {
        $availability->{'confirmations'} = $confirmations;
    }
    if (keys %{$notes} > 0) {
        $availability->{'notes'} = $notes;
    }
    if (keys %{$unavailabilities} > 0) {
        # Don't reveal borrowernumber through REST API.
        foreach my $key (keys %{$unavailabilities}) {
            delete $unavailabilities->{$key}{'borrowernumber'};
        }

        $availability->{'unavailabilities'} = $unavailabilities;
    }

    my $ccode_desc = Koha::AuthorisedValues->search({
        category => 'CCODE',
        authorised_value => $item->ccode
    })->next;
    my $loc_desc = Koha::AuthorisedValues->search({
        category => 'LOC',
        authorised_value => $item->location
    })->next;
    my $subloc_desc = Koha::AuthorisedValues->search({
        category => 'SUBLOC',
        authorised_value => $item->sub_location
    })->next;
    $ccode_desc = $ccode_desc->lib if defined $ccode_desc;
    $loc_desc   = $loc_desc->lib if defined $loc_desc;
    $subloc_desc = $subloc_desc->lib if defined $subloc_desc;
    my $hash = {
        itemnumber => 0+$item->itemnumber,
        biblionumber => 0+$item->biblionumber,
        biblioitemnumber => 0+$item->biblioitemnumber,
        availability => $availability,
        barcode => $item->barcode,
        enumchron => $item->enumchron,
        holdingbranch => $item->holdingbranch,
        homebranch => $item->homebranch,
        itemcallnumber => $item->itemcallnumber,
        itemcallnumber_display => $item->cn_sort, # FIXME: Find a proper solution
        itemnotes => $item->itemnotes,
        location => $item->location,
        location_description => $loc_desc,
        ccode => $item->ccode,
        ccode_description => $ccode_desc,
        holding_id => $item->holding_id,
        sub_location => $item->sub_location,
        sub_description => $subloc_desc,
    };
    $hash->{'hold_queue_length'} = Koha::Holds->search({
        itemnumber => $item->itemnumber
    })->count;
    return $hash;
}

1;
