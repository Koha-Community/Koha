package Koha::Biblio::Availability;

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
use Koha::Exceptions::Biblio;
use Koha::Exceptions::Patron;

=head1 NAME

Koha::Biblio::Availability - Koha Biblio Availability object class

=head1 SYNOPSIS

Parent class for different types of biblio availabilities.

=head1 DESCRIPTION

=head2 Class Methods

This class is for storing biblio availability information. It is a subclass of
Koha::Availability. For more documentation on usage, see Koha::Availability.

=cut

=head3 new

my $availability = Koha::Biblio::Availability->new({
    biblionumber => 123
});

REQUIRED PARAMETERS:
    biblio (Koha::Biblio) / biblionumber

OPTIONAL PARAMETERS:
    patron (Koha::Patron) / borrowernumber

Creates a new Koha::Biblio::Availability object.

=cut

sub new {
    my $class = shift;
    my ($params) = @_;
    my $self = $class->SUPER::new(@_);

    $self->{'biblio'} = undef;
    $self->{'patron'} = undef;

    # ARRAYref of Koha::Item::Availability objects
    # ...for available items
    $self->{'item_availabilities'} = [];
    # ...for unavailabile items
    $self->{'item_unavailabilities'} = [];

    if (exists $params->{'biblio'}) {
        unless (ref($params->{'biblio'}) eq 'Koha::Biblio') {
            Koha::Exceptions::BadParameter->throw(
                error => 'Parameter must be a Koha::Biblio object.',
                parameter => 'biblio',
            );
        }
        $self->biblio($params->{'biblio'});
    } elsif (exists $params->{'biblionumber'}) {
        unless (looks_like_number($params->{'biblionumber'})) {
            Koha::Exceptions::BadParameter->throw(
                error => 'Parameter must be a numeric value.',
                parameter => 'biblionumber',
            );
        }
        $self->biblio(Koha::Biblios->find($params->{'biblionumber'}));
        unless ($self->biblio) {
            Koha::Exceptions::Biblio::NotFound->throw(
                error => 'Biblio not found.',
                biblionumber => $params->{'biblionumber'},
            );
        }
    } else {
        Koha::Exceptions::MissingParameter->throw(
            error => "Missing one of parameters 'biblionumber, 'biblio'.",
            parameter => ["biblionumber", "biblio"],
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
