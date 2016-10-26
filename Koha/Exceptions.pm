package Koha::Exceptions;

use Modern::Perl;

use Exception::Class (

    # General exceptions
    'Koha::Exceptions::Exception' => {
        description => 'Something went wrong!',
    },

    'Koha::Exceptions::BadParameter' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'A bad parameter was given',
        fields => ['parameter'],
    },
    'Koha::Exceptions::BadSystemPreference' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'System preference value is incomprehensible',
        fields => ['preference'],
    },
    'Koha::Exceptions::NoChanges' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'No changes were made',
    },
    'Koha::Exceptions::DuplicateObject' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'Same object already exists',
    },
    'Koha::Exceptions::ObjectNotFound' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'The required object doesn\'t exist',
    },
    'Koha::Exceptions::CannotDeleteDefault' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'The default value cannot be deleted'
    },
    'Koha::Exceptions::InvalidDate' => {
        isa => 'Koha::Exceptions::Exception',
        description => "Date is invalid.",
        fields => ["date"],
    },
    'Koha::Exceptions::MissingParameter' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'A required parameter is missing',
        fields => ["parameter"],
    },
    'Koha::Exceptions::AuthenticationRequired' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'Auhtentication is required.',
    },
    'Koha::Exceptions::NoPermission' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'No permission to access this resource.',
        fields => ["required_permissions"]
    },
    'Koha::Exceptions::NotImplemented' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'A subroutine is not implemented',
        fields => ["subroutine"]
    },
    'Koha::Exceptions::TooManyParameters' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'Too many parameters given',
        fields => ['parameter'],
    },
    'Koha::Exceptions::WrongParameter' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'One or more parameters are wrong',
    },
    'Koha::Exceptions::CannotAddLibraryLimit' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'General problem adding a library limit'
    },
    'Koha::Exceptions::UnblessedReference' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'Calling unblessed reference'
    },
    'Koha::Exceptions::UnderMaintenance' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'Koha is under maintenance.'
    },
    # Virtualshelves exceptions
    'Koha::Exceptions::Virtualshelves::DuplicateObject' => {
        isa => 'Koha::Exceptions::DuplicateObject',
        description => "Duplicate shelf object",
    },
    'Koha::Exceptions::Virtualshelves::InvalidInviteKey' => {
        isa => 'Koha::Exceptions::Exception',
        description => 'Invalid key on accepting the share',
    },
    'Koha::Exceptions::Virtualshelves::InvalidKeyOnSharing' => {
        isa => 'Koha::Exceptions::Exception',
        description=> 'Invalid key on sharing a shelf',
    },
    'Koha::Exceptions::Virtualshelves::ShareHasExpired' => {
        isa => 'Koha::Exceptions::Exception',
        description=> 'Cannot share this shelf, the share has expired',
    },
    'Koha::Exceptions::Virtualshelves::UseDbAdminAccount' => {
        isa => 'Koha::Exceptions::Exception',
        description => "Invalid use of database administrator account",
    }
);

use Mojo::JSON;
use Scalar::Util qw( blessed );

=head1 NAME

Koha::Exceptions

=head1 API

=head2 Class Methods

=head3 rethrow_exception

    try {
        # ..
    } catch {
        # ..
        Koha::Exceptions::rethrow_exception($e);
    }

A function for re-throwing any given exception C<$e>. This also includes other
exceptions than Koha::Exceptions.

=cut

sub rethrow_exception {
    my ($e) = @_;

    die $e unless blessed($e);
    die $e if ref($e) eq 'Mojo::Exception'; # Mojo::Exception is rethrown by die
    die $e unless $e->can('rethrow');
    $e->rethrow;
}

=head3 to_str

A function for representing any given exception C<$e> as string.

C<to_str> is aware of some of the most common exceptions and how to stringify
them, however, also stringifies unknown exceptions by encoding them into JSON.

=cut

sub to_str {
    my ($e) = @_;

    return (ref($e) ? ref($e) ." => " : '') . _stringify_exception($e);
}

sub _stringify_exception {
    my ($e) = @_;

    return $e unless blessed($e);

    # Stringify a known exception
    return $e->to_string      if ref($e) eq 'Mojo::Exception';
    return $e->{'msg'}        if ref($e) eq 'DBIx::Class::Exception';
    return $e->error          if $e->isa('Koha::Exception');

    # Stringify an unknown exception by attempting to use some methods
    return $e->to_str         if $e->can('to_str');
    return $e->to_string      if $e->can('to_string');
    return $e->error          if $e->can('error');
    return $e->message        if $e->can('message');
    return $e->string         if $e->can('string');
    return $e->str            if $e->can('str');

    # Finally, handle unknown exception by encoding it into JSON text
    return Mojo::JSON::encode_json({%$e});
}

1;
