package Koha::Auth::Identity::Provider;

# Copyright Theke Solutions 2022
#
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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use base qw(Koha::Object Koha::Object::JSONFields);

use Koha::Auth::Identity::Provider::Domains;
use Koha::Exceptions;

=head1 NAME

Koha::Auth::Identity::Provider - Koha Auth Provider Object class

=head1 API

=head2 Class methods

=head3 domains

    my $domains = $provider->domains;

Returns the related I<Koha::Auth::Identity::Provider::Domains> iterator.

=cut

sub domains {
    my ($self) = @_;

    return Koha::Auth::Identity::Provider::Domains->_new_from_dbic( scalar $self->_result->domains );
}

=head3 get_config

    my $config = $provider->get_config;

Returns a I<hashref> containing the configuration parameters for the provider.

=cut

sub get_config {
    my ($self) = @_;

    return $self->decode_json_field( { field => 'config' } );
}

=head3 set_config

    # OAuth
    $provider->set_config(
        {
            key           => 'APP_ID',
            secret        => 'SECRET_KEY',
            authorize_url => 'https://provider.example.com/auth',
            token_url     => 'https://provider.example.com/token',
        }
    );

    # OIDC
    $provider->set_config(
        {
            key           => 'APP_ID',
            secret        => 'SECRET_KEY',
            well_known_url => 'https://login.microsoftonline.com/tenant-id/v2.0/.well-known/openid-configuration',
        }
    );

This method stores the passed config in JSON format.

=cut

sub set_config {
    my ( $self, $config ) = @_;

    my @mandatory = $self->mandatory_config_attributes;

    for my $param (@mandatory) {
        unless ( defined( $config->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw( parameter => $param );
        }
    }

    return $self->set_encoded_json_field( { data => $config, field => 'config' } );
}

=head3 get_mapping

    my $mapping = $provider->get_mapping;

Returns a I<hashref> containing the attribute mapping for the provider.

=cut

sub get_mapping {
    my ($self) = @_;

    return $self->decode_json_field( { field => 'mapping' } );
}

=head3 set_mapping

    $provider->mapping( $mapping );

This method stores the passed mappings in JSON format.

=cut

sub set_mapping {
    my ( $self, $mapping ) = @_;

    return $self->set_encoded_json_field( { data => $mapping, field => 'mapping' } );
}

=head3 upgrade_class

    my $upgraded_object = $provider->upgrade_class

Returns a new instance of the object, with the right class.

=cut

sub upgrade_class {
    my ($self) = @_;
    my $protocol = $self->protocol;

    my $class = $self->protocol_to_class_mapping->{$protocol};

    Koha::Exception->throw( $protocol . ' is not a valid protocol' )
        unless $class;

    eval "require $class";
    return $class->_new_from_dbic( $self->_result );
}

=head2 Internal methods

=head3 to_api

    my $json = $provider->to_api;

Overloaded method that returns a JSON representation of the Koha::Auth::Identity::Provider object,
suitable for API output.

=cut

sub to_api {
    my ( $self, $params ) = @_;

    my $config  = $self->get_config;
    my $mapping = $self->get_mapping;

    my $json = $self->SUPER::to_api($params);
    $json->{config}  = $config;
    $json->{mapping} = $mapping;

    return $json;
}

=head3 _type

=cut

sub _type {
    return 'IdentityProvider';
}

=head3 protocol_to_class_mapping

    my $mapping = Koha::Auth::Identity::Provider::protocol_to_class_mapping

Internal method that returns a mapping between I<protocol> codes and
implementing I<classes>. To be used by B<upgrade_class>.

=cut

sub protocol_to_class_mapping {
    return {
        OAuth => 'Koha::Auth::Identity::Provider::OAuth',
        OIDC  => 'Koha::Auth::Identity::Provider::OIDC',
    };
}

=head3 mandatory_config_attributes

Stub method for raising exceptions on invalid protocols.

=cut

sub mandatory_config_attributes {
    my ($self) = @_;
    Koha::Exception->throw("This method needs to be subclassed");
}

1;
