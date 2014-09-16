package Koha::ItemType;

# This represents a single itemtype

# Copyright 2014 Catalyst IT
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

use Carp;

use C4::Koha;
use C4::Languages;
use Koha::Database;
use Koha::Localizations;

use base qw(Koha::Object);

=head1 NAME

Koha::ItemType - Koha Item type Object class

=head1 API

=head2 Class Methods

=cut

=head3 image_location

=cut

sub image_location {
    my ( $self, $interface ) = @_;
    return C4::Koha::getitemtypeimagelocation( $interface, $self->SUPER::imageurl );
}

=head3 translated_description

=cut

sub translated_description {
    my ( $self, $lang ) = @_;
    $lang ||= C4::Languages::getlanguage;
    my $translated_description = Koha::Localizations->search({
        code => $self->itemtype,
        entity => 'itemtypes',
        lang => $lang
    })->next;
    return $translated_description
         ? $translated_description->translation
         : $self->description;
}

=head3 translated_descriptions

=cut

sub translated_descriptions {
    my ( $self ) = @_;
    my @translated_descriptions = Koha::Localizations->search(
        {   entity => 'itemtypes',
            code   => $self->itemtype,
        }
    );
    return [ map {
        {
            lang => $_->lang,
            translation => $_->translation,
        }
    } @translated_descriptions ];
}

=head3 type

=cut

sub _type {
    return 'Itemtype';
}

1;
