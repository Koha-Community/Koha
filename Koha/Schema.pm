use utf8;
package Koha::Schema;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces;


# Created by DBIx::Class::Schema::Loader v0.07025 @ 2013-10-14 20:56:21
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oDUxXckmfk6H9YCjW8PZTw

use Koha::Schema::ExceptionMapper;

=head1 UTILITY METHODS

=head2 connection

    my $schema = Koha::Schema->connection(@args);

Override connection to install our C<exception_action> handler. This ensures
all DBIx::Class exceptions are automatically translated into Koha exceptions
before they propagate to callers.

=cut

sub connection {
    my ( $class, @args ) = @_;

    my $self = $class->next::method(@args);

    $self->exception_action(
        sub {
            my ($msg) = @_;

            # Don't re-wrap Koha exceptions that DBIC is re-throwing (e.g. from txn_do)
            die $msg if ref($msg);

            # Attempt translation — throws a Koha exception on match
            # Handles both DBI errors and DBIC internal errors (e.g. "Not in database")
            Koha::Schema::ExceptionMapper->translate_exception($msg);

            # No match — wrap DBI errors so DBIx::Class::Exception never leaks
            if ( $msg =~ /^DBI Exception:/ ) {
                Koha::Exceptions::Object::UnhandledDBError->throw( error => $msg );
            }

            # Non-DBI DBIC internal errors: let DBIC handle normally
            DBIx::Class::Exception->throw($msg);
        }
    );

    return $self;
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
