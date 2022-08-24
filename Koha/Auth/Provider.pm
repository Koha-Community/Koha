package Koha::Auth::Provider;

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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use base qw(Koha::Object);

use JSON qw( decode_json encode_json );
use Try::Tiny;

use Koha::Auth::Provider::Domains;
use Koha::Exceptions;
use Koha::Exceptions::Object;

=head1 NAME

Koha::Auth::Provider - Koha Auth Provider Object class

=head1 API

=head2 Class methods

=head3 domains

    my $domains = $provider->domains;

Returns the related I<Koha::Auth::Provider::Domains> iterator.

=cut

sub domains {
    my ($self) = @_;

    return Koha::Auth::Provider::Domains->_new_from_dbic( scalar $self->_result->domains );
}

=head3 get_config

    my $config = $provider->get_config;

Returns a I<hashref> containing the configuration parameters for the provider.

=cut

sub get_config {
    my ($self) = @_;

    return try {
        return decode_json( $self->config );
    }
    catch {
        Koha::Exceptions::Object::BadValue->throw("Error reading JSON data: $_");
    };
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
    my ($self, $config) = @_;

    my @mandatory;

    if ( $self->protocol eq 'OIDC' ) {
        @mandatory = qw(key secret well_known_url);
    }
    elsif ( $self->protocol eq 'OAuth' ) {
        @mandatory = qw(key secret authorize_url token_url);
    }
    else {
        Koha::Exception->throw( 'Unsupported protocol ' . $self->protocol );
    }

    for my $param (@mandatory) {
        unless ( defined( $config->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw(
                error => "The $param parameter is mandatory" );
        }
    }

    try {
        my $encoded_config = encode_json($config);
        $self->config($encoded_config)->store;
    } catch {
        Koha::Exceptions::Object::BadValue->throw("Error serializing data into JSON: $_");
    };

    return $self;
}

=head3 get_mapping

    my $mapping = $provider->get_mapping;

Returns a I<hashref> containing the attribute mapping for the provider.

=cut

sub get_mapping {
    my ($self) = @_;

    return try {
        return decode_json( $self->mapping );
    }
    catch {
        Koha::Exceptions::Object::BadValue->throw("Error reading JSON data: $_");
    };
}

=head3 set_mapping

    $provider->mapping( $mapping );

This method stores the passed mappings in JSON format.

=cut

sub set_mapping {
    my ($self, $mapping) = @_;

    try {
        my $encoded_mapping = encode_json( $mapping );
        $self->mapping( $encoded_mapping )->store;
    }
    catch {
        Koha::Exceptions::Object::BadValue->throw("Error serializing data into JSON: $_");
    };

    return $self;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'AuthProvider';
}

1;
