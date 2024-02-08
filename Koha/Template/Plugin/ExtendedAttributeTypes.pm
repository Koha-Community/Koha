package Koha::Template::Plugin::ExtendedAttributeTypes;

# Copyright ByWater Solutions 2023

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# Koha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Template::Plugin;
use base qw( Template::Plugin );

use C4::Koha;
use C4::Context;
use Koha::Patron::Attribute::Types;

sub all {
    my ( $self, $params ) = @_;
    return Koha::Patron::Attribute::Types->search($params);
}

sub codes {
    my ( $self, $params ) = @_;

    return Koha::Patron::Attribute::Types->search($params)->get_column('code');

}

1;

=head1 NAME

Koha::Template::Plugin::ExtendedAttributeTypes - TT Plugin for retrieving patron attribute types

=head1 SYNOPSIS

[% USE ExtendedAttributeTypes %]

[% ExtendedAttributeTypes.all() %]

=head1 ROUTINES

=head2 all

In a template, you can get the searchable attribute types with
the following TT code: [% ExtendedAttributes.all( staff_searchable => 1 ) %]

The function returns the Koha::Patron::Attribute::Type objects

=head2 codes

In a template, you can get the searchable attribute type codes with
the following TT code: [% ExtendedAttributes.codes( staff_searchable => 1 ) %]

The function returns the Koha::Patron::Attribute::Type codes as an array

=head1 AUTHOR

Nick Clemens <nick@bywatersolutions.com>

=cut
