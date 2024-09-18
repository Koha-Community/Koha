package Koha::Exceptions::REST;

use Modern::Perl;

use Koha::Exception;

use Exception::Class (
    'Koha::Exceptions::REST' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::REST::Public::Authentication::Required' => {
        description => "This public route requires authentication",
    },
    'Koha::Exceptions::REST::Public::Unauthorized' => {
        description => "Unprivileged user cannot access another user's resources",
    },
    'Koha::Exceptions::REST::Query::InvalidOperator' => {
        description => "Invalid operator found in query",
        fields      => ['operator']
    },
);

=head1 NAME

Koha::Exceptions::REST - Base class for REST API exceptions

=head1 Exceptions

=head2 Koha::Exceptions::REST

Generic REST API exception.

=head2 Koha::Exceptions::REST::Query::InvalidOperator

The passed query is not allowed.

=cut

1;
