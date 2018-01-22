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

use Modern::Perl;
use Carp;
use C4::Context;
use base qw(Class::Accessor);

use vars qw($database);

__PACKAGE__->mk_accessors(qw( ));

# _new_schema
# Internal helper function (not a method!). This creates a new
# database connection from the data given in the current context, and
# returns it.
sub _new_schema {

    require Koha::Schema;

    my $context = C4::Context->new();

    my $db_driver = $context->{db_driver};

    my $db_name   = $context->config("database");
    my $db_host   = $context->config("hostname");
    my $db_port   = $context->config("port") || '';
    my $db_user   = $context->config("user");
    my $db_passwd = $context->config("pass");
    my $tls = $context->config("tls");
    my $tls_options;
    if( $tls && $tls eq 'yes' ) {
        my $ca = $context->config('ca');
        my $cert = $context->config('cert');
        my $key = $context->config('key');
        $tls_options = ";mysql_ssl=1;mysql_ssl_client_key=".$key.";mysql_ssl_client_cert=".$cert.";mysql_ssl_ca_file=".$ca;
    }



    my ( %encoding_attr, $encoding_query, $tz_query, $sql_mode_query );
    my $tz = $ENV{TZ};
    if ( $db_driver eq 'mysql' ) {
        %encoding_attr = ( mysql_enable_utf8 => 1 );
        $encoding_query = "set NAMES 'utf8mb4'";
        $tz_query = qq(SET time_zone = "$tz") if $tz;
        $sql_mode_query = q{SET sql_mode = 'IGNORE_SPACE,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'};
    }
    elsif ( $db_driver eq 'Pg' ) {
        $encoding_query = "set client_encoding = 'UTF8';";
        $tz_query = qq(SET TIME ZONE = "$tz") if $tz;
    }
    my $schema = Koha::Schema->connect(
        {
            dsn => "dbi:$db_driver:database=$db_name;host=$db_host;port=$db_port".($tls_options? $tls_options : ""),
            user => $db_user,
            password => $db_passwd,
            %encoding_attr,
            RaiseError => $ENV{DEBUG} ? 1 : 0,
            PrintError => 1,
            unsafe => 1,
            quote_names => 1,
            on_connect_do => [
                $encoding_query || (),
                $tz_query || (),
                $sql_mode_query || (),
            ]
        }
    );

    my $dbh = $schema->storage->dbh;
    eval {
        $dbh->{RaiseError} = 1;
        if ( $ENV{KOHA_DB_DO_NOT_RAISE_OR_PRINT_ERROR} ) {
            $dbh->{RaiseError} = 0;
            $dbh->{PrintError} = 0;
        }
        $dbh->do(q|
            SELECT * FROM systempreferences WHERE 1 = 0 |
        );
        $dbh->{RaiseError} = $ENV{DEBUG} ? 1 : 0;
    };
    $dbh->{RaiseError} = 0 if $@;

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
    my $params = shift;

    unless ( $params->{new} ) {
        return $database->{schema} if defined $database->{schema};
    }

    $database->{schema} = &_new_schema();
    return $database->{schema};
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
    push @{ $database->{schema_stack} }, $database->{schema};
    $database->{schema} = $new_schema;
}

=head2 restore_schema

  $database->restore_schema;

Restores the database handle saved by an earlier call to
C<$database-E<gt>set_schema>.

=cut

sub restore_schema {
    my $self = shift;

    if ( $#{ $database->{schema_stack} } < 0 ) {

        # Stack underflow
        die "SCHEMA stack underflow";
    }

    # Pop the old database handle and set it.
    $database->{schema} = pop @{ $database->{schema_stack} };

    # FIXME - If it is determined that restore_context should
    # return something, then this function should, too.
}

=head2 get_schema_cached

=cut

sub get_schema_cached {
    return $database->{schema};
}

=head2 flush_schema_cache

=cut

sub flush_schema_cache {
    delete $database->{schema};
    return 1;
}

=head2 EXPORT

None by default.


=head1 AUTHOR

Chris Cormack, E<lt>chrisc@catalyst.net.nzE<gt>

=cut

1;

__END__
