package Koha::SIP2::Object;

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

use base qw(Koha::Object);

use DateTime;

=head1 NAME

Koha::SIP2::Object - Base class for SIP2 objects

=head1 SYNOPSIS

This is the base class for SIP2 objects in the Koha library system.

=head1 API

=head2 Class Methods

=cut

=head3 store

store

=cut

sub store {
    my ($self) = @_;

    _update_config_timestamp();
    return $self->SUPER::store;
}

sub delete {
    my ($self) = @_;

    _update_config_timestamp();
    return $self->SUPER::delete;
}

sub _update_config_timestamp {
    return 1;

    #TODO: Reimplement config_timestamp
    # my $timestamp = DateTime->now;

    # my $config_timestamp = Koha::SIP2::ServerParams->find( { key => 'config_timestamp' } )
    #     || Koha::SIP2::ServerParam->new( { key => 'config_timestamp' } );
    # $config_timestamp->value( DateTime->now->epoch )->store;
}

1;

