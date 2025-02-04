package Koha::SIP2::Listener;

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

=head1 NAME

Koha::SIP2::Listener- Koha Sip Listener Object class

=head1 API

=head2 Class Methods

=cut

=head3 get_for_config

Returns the listener hashref as expected by C4/SIP/Sip/Configuration->new;

=cut

sub get_for_config {
    my ($self) = @_;

    my $return_hash = $self->unblessed;
    delete $return_hash->{sip_listener_id};
    foreach my $key ( keys %$return_hash ) {
        delete $return_hash->{$key}                   if !defined $return_hash->{$key};
        $return_hash->{$key} = "$return_hash->{$key}" if defined $return_hash->{$key};
    }
    return $return_hash;
}

=head3 type

=cut

sub _type {
    return 'SipListener';
}

1;
