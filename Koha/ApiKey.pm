package Koha::ApiKey;

# Copyright BibLibre 2015
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

use C4::Log         qw( logaction );
use Koha::AuthUtils qw(hash_password);
use Koha::Exceptions::ApiKey;
use Koha::Exceptions::Object;

use List::MoreUtils qw(any);
use UUID;

use base qw(Koha::Object);

=head1 NAME

Koha::ApiKey - Koha API Key Object class

=head1 API

=head2 Class methods

=head3 store

    my $api_key = Koha::ApiKey->new({ patron_id => $patron_id })->store;

Overloaded I<store> method.

=cut

sub store {
    my ( $self, $params ) = @_;
    $params //= {};

    my $is_new = !$self->in_storage;

    if ( $self->in_storage ) {
        my %dirty_columns = $self->_result->get_dirty_columns;

        # only allow 'description' and 'active' to be updated
        for my $property ( keys %dirty_columns ) {
            Koha::Exceptions::Object::ReadOnlyProperty->throw( property => $property )
                if $property ne 'description' and $property ne 'active';
        }
    } else {
        $self->{_plain_text_secret} = $self->_generate_unused_uuid('secret');
        $self->set(
            {
                secret    => Koha::AuthUtils::hash_password( $self->{_plain_text_secret} ),
                client_id => $self->_generate_unused_uuid('client_id'),
                active    => 1,
            }
        );
    }

    my $result = $self->SUPER::store();

    # Log the action unless explicitly skipped
    if ( !$params->{skip_log} && C4::Context->preference('ApiKeyLog') ) {
        if ($is_new) {
            logaction(
                'APIKEYS', 'CREATE', $self->patron_id,
                sprintf( "Client ID: %s, Description: %s", $self->client_id, $self->description )
            );
        }
    }

    return $result;
}

=head3 validate_secret

    if ( $api_key->validate_secret( $secret ) ) { ... }

Returns a boolean that tells if the passed secret matches the one on the DB.

=cut

sub validate_secret {
    my ( $self, $secret ) = @_;

    my $digest = Koha::AuthUtils::hash_password( $secret, $self->secret );

    return ( $self->secret eq $digest ) ? 1 : 0;
}

=head3 plain_text_secret

    my $generated_secret = $api_key->store->plain_text_secret;

Returns the generated I<secret> so it can be displayed to  the end user.
This is only accessible when the object is new and has just been stored.

Returns I<undef> if the object was retrieved from the database.

=cut

sub plain_text_secret {
    my ($self) = @_;

    return $self->{_plain_text_secret}
        if $self->{_plain_text_secret};

    return;
}

=head3 delete

    $api_key->delete;

Overloaded delete method to add logging.

=cut

sub delete {
    my ($self) = @_;

    my $client_id   = $self->client_id;
    my $description = $self->description;
    my $patron_id   = $self->patron_id;

    my $result = $self->SUPER::delete();

    if ( C4::Context->preference('ApiKeyLog') ) {
        logaction(
            'APIKEYS', 'DELETE', $patron_id,
            sprintf( "Client ID: %s, Description: %s", $client_id, $description )
        );
    }

    return $result;
}

=head3 revoke

    $api_key->revoke;

Revokes the API key by setting active to 0.
Throws an exception if the key is already revoked.

=cut

sub revoke {
    my ($self) = @_;

    Koha::Exceptions::ApiKey::AlreadyRevoked->throw
        if !$self->active;

    $self->active(0)->store( { skip_log => 1 } );

    if ( C4::Context->preference('ApiKeyLog') ) {
        logaction(
            'APIKEYS', 'REVOKE', $self->patron_id,
            sprintf( "Client ID: %s, Description: %s", $self->client_id, $self->description )
        );
    }

    return $self;
}

=head3 activate

    $api_key->activate;

Activates the API key by setting active to 1.
Throws an exception if the key is already active.

=cut

sub activate {
    my ($self) = @_;

    Koha::Exceptions::ApiKey::AlreadyActive->throw
        if $self->active;

    $self->active(1)->store( { skip_log => 1 } );

    if ( C4::Context->preference('ApiKeyLog') ) {
        logaction(
            'APIKEYS', 'ACTIVATE', $self->patron_id,
            sprintf( "Client ID: %s, Description: %s", $self->client_id, $self->description )
        );
    }

    return $self;
}

=head2 Internal methods

=cut

=head3 _type

=cut

sub _type {
    return 'ApiKey';
}

=head3 _generate_unused_uuid

    my $string = $self->_generate_unused_uuid($column);

$column can be 'client_id' or 'secret'.

=cut

sub _generate_unused_uuid {
    my ( $self, $column ) = @_;

    my ( $uuid, $uuidstring );

    UUID::generate($uuid);
    UUID::unparse( $uuid, $uuidstring );

    while ( Koha::ApiKeys->search( { $column => $uuidstring } )->count > 0 ) {

        # Make sure $secret is unique
        UUID::generate($uuid);
        UUID::unparse( $uuid, $uuidstring );
    }

    return $uuidstring;
}

1;
