package Koha::Holding;

# Copyright ByWater Solutions 2014
# Copyright 2017-2018 University of Helsinki (The National Library Of Finland)
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

use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Holding - Koha Holding Object class

=head1 API

=head2 Class Methods

=cut

=head3 items

my @items = $holding->items();
my $items = $holding->items();

Returns the related Koha::Items object for this holding in scalar context,
or list of Koha::Item objects in list context.

=cut

sub items {
    my ($self) = @_;

    $self->{_items} ||= Koha::Items->search( { holding_id => $self->holding_id() } );

    return wantarray ? $self->{_items}->as_list : $self->{_items};
}

=head3 type

=cut

sub _type {
    return 'Holding';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>
Ere Maijala <ere.maijala@helsinki.fi>

=cut

1;
