package Koha::AudioAlerts;

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

use Koha::AudioAlert;

use base qw(Koha::Objects);

=head1 NAME

Koha::AudioAlerts - Koha Audio Alert object set class

=head1 API

=head2 Class Methods

=head3 search

Overrides default search such that
the default ordering is by precedence

=cut

sub search {
    my ( $self, $params, $attributes ) = @_;

    $attributes->{order_by} ||= 'precedence';

    return $self->SUPER::search( $params, $attributes );
}

=head3 get_next_precedence

Gets the next precedence value for audio alerts

=cut

sub get_next_precedence {
    my ($self) = @_;

    return $self->get_last_precedence() + 1;
}

=head3 get_last_precedence

Gets the last precedence value for audio alerts

=cut

sub get_last_precedence {
    my ($self) = @_;

    return $self->_resultset()->get_column('precedence')->max() || 0;
}

=head3 move

Koha::AudioAlerts->move( { audio_alert => $audio_alert, where => $where } );

Moves the given alert precedence 'up', 'down', 'top' or 'bottom'

=cut

sub move {
    my ( $self, $params ) = @_;

    my $alert = $params->{audio_alert};
    my $where = $params->{where};

    return unless ( $alert && $where );

    if ( $where eq 'up' ) {
        unless ( $alert->precedence() == 1 ) {
            my ($other) = $self->search( { precedence => $alert->precedence() - 1 } );
            $other->precedence( $alert->precedence() )->store();
            $alert->precedence( $alert->precedence() - 1 )->store();
        }
    }
    elsif ( $where eq 'down' ) {
        unless ( $alert->precedence() == $self->get_last_precedence() ) {
            my ($other) = $self->search( { precedence => $alert->precedence() + 1 } );
            $other->precedence( $alert->precedence() )->store();
            $alert->precedence( $alert->precedence() + 1 )->store();
        }
    }
    elsif ( $where eq 'top' ) {
        $alert->precedence(0)->store();
        $self->fix_precedences();
    }
    elsif ( $where eq 'bottom' ) {
        $alert->precedence( $self->get_next_precedence() )->store();
        $self->fix_precedences();
    }
}

=head3 fix_precedences

Koha::AudioAlerts->fix_precedences();

Updates precedence numbers to start with 1
and to have no gaps

=cut

sub fix_precedences {
    my ($self) = @_;

    my @alerts = $self->search();

    my $i = 1;
    map { $_->precedence( $i++ )->store() } @alerts;
}

=head3 type

=cut

sub _type {
    return 'AudioAlert';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::AudioAlert';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
