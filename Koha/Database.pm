package Koha::Database;

# Copyright 2013 Catalyst IT
# chrisc@catalyst.net.nz
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

=head1 NAME

Koha::Database

=head1 SYNOPSIS

  use Koha::Database;
  my $schema = Koha::Database->schema();

=head1 FUNCTIONS

=cut

use Modern::Perl;
use DBI;
use Koha::Config;

our $database;

=head2 new

    $schema = Koha::Database->new->schema;

    FIXME: It is useless to have a Koha::Database object since all methods
    below act as class methods
    Koha::Database->new->schema is exactly the same as Koha::Database->schema
    We should use Koha::Database->schema everywhere and remove the `new` method

=cut

sub new { bless {}, shift }

=head2 dbh

    Returns a database handler without loading the DBIx::Class schema.

=cut

sub dbh {
    my $config = Koha::Config->get_instance;
    my $driver = db_scheme2dbi($config->get('db_scheme'));
    my $user = $config->get("user"),
    my $pass = $config->get("pass"),
    my $dsn = sprintf(
        'dbi:%s:database=%s;host=%s;port=%s',
        $driver,
        $config->get("database_test") || $config->get("database"),
        $config->get("hostname"),
        $config->get("port") || '',
    );

    my $attr = {
        RaiseError => 1,
        PrintError => 1,
    };

    if ($driver eq 'mysql') {
        my $tls = $config->get("tls");
        if ($tls && $tls eq 'yes') {
            $dsn .= sprintf(
                ';mysql_ssl=1;mysql_ssl_client_key=%s;mysql_ssl_client_cert=%s;mysql_ssl_ca_file=%s',
                $config->get('key'),
                $config->get('cert'),
                $config->get('ca'),
            );
        }

        $attr->{mysql_enable_utf8} = 1;
    }

    my $dbh = DBI->connect($dsn, $user, $pass, $attr);

    if ($dbh) {
        my @queries;
        my $tz = $config->timezone;
        $tz = '' if $tz eq 'local';

        if ($driver eq 'mysql') {
            push @queries, "SET NAMES 'utf8mb4'";
            push @queries, qq{SET time_zone = "$tz"} if $tz;
            if (   $config->get('strict_sql_modes')
                || ( exists $ENV{_} && $ENV{_} =~ m|prove| )
                || $ENV{KOHA_TESTING}
            ) {
                push @queries, q{
                    SET sql_mode = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'
                };
            } else {
                push @queries, q{SET sql_mode = 'IGNORE_SPACE,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION'}
            }
        } elsif ($driver eq 'Pg') {
            push @queries, qq{SET TIME ZONE = "$tz"} if $tz;
            push @queries, q{set client_encoding = 'UTF8'};
        }

        foreach my $query (@queries) {
            $dbh->do($query);
        }
    }

    return $dbh;
}


# _new_schema
# Internal helper function (not a method!). This creates a new
# database connection from the data given in the current context, and
# returns it.
sub _new_schema {

    require Koha::Schema;

    my $schema = Koha::Schema->connect({
        dbh_maker => \&Koha::Database::dbh,
        quote_names => 1,
        auto_savepoint => 1,
    });

    my $dbh = $schema->storage->dbh;
    eval {
        my $HandleError = $dbh->{HandleError};
        if ( $ENV{KOHA_DB_DO_NOT_RAISE_OR_PRINT_ERROR} ) {
            $dbh->{HandleError} = sub { return 1 };
        }
        $dbh->do(q|
            SELECT * FROM systempreferences WHERE 1 = 0 |
        );
        $dbh->{HandleError} = $HandleError;
    };

    if ( $@ ) {
        $dbh->{HandleError} = sub { warn $_[0]; return 1 };
    }

    return $schema;
}

=head2 schema

    $schema = Koha::Database->schema;
    $schema = Koha::Database->schema({ new => 1 });

Returns a database handle connected to the Koha database for the
current context. If no connection has yet been made, this method
creates one, and connects to the database.

This database handle is cached for future use: if you call
C<$database-E<gt>schema> twice, you will get the same handle both
times. If you need a second database handle, use C<&new_schema> and
possibly C<&set_schema>.

=cut

sub schema {
    my ($class, $params) = @_;

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

=head2 db_scheme2dbi

    my $dbd_driver_name = Koha::Database::db_scheme2dbi($scheme);

This routines translates a database type to part of the name
of the appropriate DBD driver to use when establishing a new
database connection.  It recognizes 'mysql' and 'Pg'; if any
other scheme is supplied it defaults to 'mysql'.

=cut

sub db_scheme2dbi {
    my $scheme = shift // '';
    return $scheme eq 'Pg' ? $scheme : 'mysql';
}

=head2 EXPORT

None by default.


=head1 AUTHOR

Chris Cormack, E<lt>chrisc@catalyst.net.nzE<gt>

=cut

1;

__END__
