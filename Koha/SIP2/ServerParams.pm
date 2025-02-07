package Koha::SIP2::ServerParams;

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

use Koha::SIP2::ServerParam;

use base qw(Koha::Objects);

=head1 NAME

Koha::SIP2::ServerParams- Koha Sip Server Param Object set class

=head1 API

=head2 Class Methods

=cut

=head3 get_for_config

Returns the server params hashref as expected by C4/SIP/Sip/Configuration->new;

=cut

sub get_for_config {
    my ($self) = @_;

    my $server_params = $self->search();
    my $return_hash;

    while ( my $server_param = $server_params->next() ) {
        next if $server_param->key eq 'config_timestamp';
        $return_hash->{ $server_param->key } = $server_param->value;
    }
    return $return_hash;
}

=head3 type

=cut

sub _type {
    return 'SipServerParam';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::SIP2::ServerParam';
}

1;
