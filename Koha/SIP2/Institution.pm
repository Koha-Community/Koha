package Koha::SIP2::Institution;

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

use base qw(Koha::SIP2::Object);

=head1 NAME

Koha::SIP2::Institution- Koha SipInstitution Object class

=head1 API

=head2 Class Methods

=cut

=head3 get_for_config

Returns the institution hashref as expected by C4/SIP/Sip/Configuration->new;

=cut

sub get_for_config {
    my ($self) = @_;

    return {
        'id'             => $self->name,
        'implementation' => $self->implementation,
        'policy'         => {
            'checkin'  => $self->checkin  ? 'true' : 'false',
            'checkout' => $self->checkout ? 'true' : 'false',
            defined $self->offline ? ( 'offline' => $self->offline ? 'true' : 'false' ) : (),
            'renewal' => $self->renewal ? 'true' : 'false',
            'retries' => $self->retries,
            defined $self->status_update ? ( 'status_update' => $self->status_update ? 'true' : 'false' ) : (),
            'timeout' => $self->timeout,
        }
    };
}

=head3 type

=cut

sub _type {
    return 'SipInstitution';
}

1;
