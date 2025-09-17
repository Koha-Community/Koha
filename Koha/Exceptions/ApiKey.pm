package Koha::Exceptions::ApiKey;

use Modern::Perl;

use Koha::Exception;

use Exception::Class (
    'Koha::Exceptions::ApiKey' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::ApiKey::AlreadyRevoked' => {
        isa         => 'Koha::Exceptions::ApiKey',
        description => 'API key is already revoked'
    },
    'Koha::Exceptions::ApiKey::AlreadyActive' => {
        isa         => 'Koha::Exceptions::ApiKey',
        description => 'API key is already active'
    },
);

=head1 NAME

Koha::Exceptions::ApiKey - Base class for API key exceptions

=head1 Exceptions

=head2 Koha::Exceptions::ApiKey

Generic API key exception.

=head2 Koha::Exceptions::ApiKey::AlreadyRevoked

Exception thrown when trying to revoke an already revoked API key.

=head2 Koha::Exceptions::ApiKey::AlreadyActive

Exception thrown when trying to activate an already active API key.

=cut

1;
