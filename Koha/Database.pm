package Koha::Database;

# Copyright 2013 Catalyst IT
# chrisc@catalyst.net.nz
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

=head1 NAME

Koha::Database

=head1 SYNOPSIS

  use Koha::Database;
  my $database = Koha::Database->new();
  my $schema = $database->schema();

=head1 FUNCTIONS

=cut

$ENV{'DBIC_DONT_VALIDATE_RELS'} = 1; # FIXME once the DBIx schema has its schema adjusted we should remove this

use Modern::Perl;
use Carp;
use C4::Context;
use Koha::Schema;
use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw( ));

# _new_schema
# Internal helper function (not a method!). This creates a new
# database connection from the data given in the current context, and
# returns it.
sub _new_schema {
    my $db_driver;
    my $context = C4::Context->new();
    if ( $context->config("db_scheme") ) {
        $db_driver = $context->db_scheme2dbi( $context->config("db_scheme") );
    }
    else {
        $db_driver = "mysql";
    }

    my $db_name   = $context->config("database");
    my $db_host   = $context->config("hostname");
    my $db_port   = $context->config("port") || '';
    my $db_user   = $context->config("user");
    my $db_passwd = $context->config("pass");
    my $schema    = Koha::Schema->connect(
        "DBI:$db_driver:dbname=$db_name;host=$db_host;port=$db_port",
        $db_user, $db_passwd );
    return $schema;
}

=head2 schema

    $schema = $database->schema;

Returns a database handle connected to the Koha database for the
current context. If no connection has yet been made, this method
creates one, and connects to the database.

This database handle is cached for future use: if you call
C<$database-E<gt>schema> twice, you will get the same handle both
times. If you need a second database handle, use C<&new_schema> and
possibly C<&set_schema>.

=cut

sub schema {
    my $self = shift;
    my $sth;
    if ( defined( $self->{"schema"} ) && $self->{"schema"}->storage->connected() ) {
        return $self->{"schema"};
    }

    # No database handle or it died . Create one.
    $self->{"schema"} = &_new_schema();

    return $self->{"schema"};
}

=head2 new_schema

  $schema = $database->new_schema;

Creates a new connection to the Koha database for the current context,
and returns the database handle (a C<DBI::db> object).

The handle is not saved anywhere: this method is strictly a
convenience function; the point is that it knows which database to
connect to so that the caller doesn't have to know.

=cut

#'
sub new_schema {
    my $self = shift;

    return &_new_schema();
}

=head2 set_schema

  $my_schema = $database->new_schema;
  $database->set_schema($my_schema);
  ...
  $database->restore_schema;

C<&set_schema> and C<&restore_schema> work in a manner analogous to
C<&set_context> and C<&restore_context>.

C<&set_schema> saves the current database handle on a stack, then sets
the current database handle to C<$my_schema>.

C<$my_schema> is assumed to be a good database handle.

=cut

sub set_schema {
    my $self       = shift;
    my $new_schema = shift;

    # Save the current database handle on the handle stack.
    # We assume that $new_schema is all good: if the caller wants to
    # screw himself by passing an invalid handle, that's fine by
    # us.
    push @{ $self->{"schema_stack"} }, $self->{"schema"};
    $self->{"schema"} = $new_schema;
}

=head2 restore_schema

  $database->restore_schema;

Restores the database handle saved by an earlier call to
C<$database-E<gt>set_schema>.

=cut

sub restore_schema {
    my $self = shift;

    if ( $#{ $self->{"schema_stack"} } < 0 ) {

        # Stack underflow
        die "SCHEMA stack underflow";
    }

    # Pop the old database handle and set it.
    $self->{"schema"} = pop @{ $self->{"schema_stack"} };

    # FIXME - If it is determined that restore_context should
    # return something, then this function should, too.
}

=head2 EXPORT

None by default.


=head1 AUTHOR

Chris Cormack, E<lt>chrisc@catalyst.net.nzE<gt>

=cut

1;

__END__
