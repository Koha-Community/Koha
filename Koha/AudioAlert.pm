package Koha::AudioAlert;

# Copyright ByWater Solutions 2014
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

Koha::AudioAlert - Koha Audio Alert object class

=head1 API

=head2 Class Methods

=head3 store

Override base store to set default precedence
if there is not one set already.

=cut

sub store {
    my ($self) = @_;

    $self->precedence( Koha::AudioAlerts->get_next_precedence() ) unless defined $self->precedence();

    return $self->SUPER::store();
}

=head3 move

$alert->move('up');

Changes the alert's precedence up, down, top, or bottom

=cut

sub move {
    my ( $self, $where ) = @_;

    return Koha::AudioAlerts->move( { audio_alert => $self, where => $where } );
}

=head3 type

=cut

sub _type {
    return 'AudioAlert';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
