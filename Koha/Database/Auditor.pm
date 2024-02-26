package Koha::Database::Auditor;

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

use SQL::Translator;
use SQL::Translator::Diff;

use C4::Context;

=head1 NAME

Koha::Database::Auditor

=head1 SYNOPSIS

use Koha::Database::Auditor;

=head1 API

=head2 Methods

=head3 new

Constructor for creating a new object with specified parameters

=cut

sub new {
    my ( $class, $params ) = @_;
    my $self = bless $params // {}, $class;
    $self->{filename} = $params->{filename} // './installer/data/mysql/kohastructure.sql';
    $self->{is_cli}   = $params->{is_cli};
    return $self;
}

=head3 run

Run the database audit with the given arguments, including the filename
    and whether it is a command-line interface(CLI).
Returns $diff only if $is_cli is false. Else it just prints $diff.

=cut

sub run {
    my ( $self, $args ) = @_;

    if ( !-f $self->{filename} ) {
        unless ( $self->{is_cli} ) {
            return 'Database schema file not found';
        }
        die("Filename '$self->{filename}' does not exist\n");
    }

    my $sql_schema = $self->_get_kohastructure();
    my $db_schema  = $self->_get_db();

    if ( $sql_schema && $db_schema ) {
        my $diff = SQL::Translator::Diff->new(
            {
                output_db     => 'MySQL',
                source_schema => $db_schema,
                target_schema => $sql_schema,
            }
        )->compute_differences->produce_diff_sql;

        return $diff unless $self->{is_cli};
        print $diff . $self->get_warning;
    }
}

=head3 get_warning

Retrieve a warning message.

=cut

sub get_warning {
    my ($self) = @_;

    return
          "\n"
        . "WARNING!!!\n"
        . "These commands are only suggestions! They are not a replacement for updatedatabase.pl!\n"
        . "Review the database, updatedatabase.pl, and kohastructure.sql before making any changes!\n" . "\n";
}

=head3 _get_db

Retrieves the database schema, removes auto-increment from the schema, and returns the modified schema.

=cut

sub _get_db {
    my ($self) = @_;

    my $database_name = C4::Context->config("database");
    print "Parsing schema for database '$database_name'\n" if $self->{is_cli};
    my $dbh    = C4::Context->dbh;
    my $parser = SQL::Translator->new(
        parser      => 'DBI',
        parser_args => {
            dbh => $dbh,
        },
    );
    my $schema = $parser->translate();

    #NOTE: Hack the schema to remove autoincrement
    #Otherwise, that difference will cause options for all tables to be reset unnecessarily
    my @tables = $schema->get_tables();
    foreach my $table (@tables) {
        my @new_options     = ();
        my $replace_options = 0;
        my $options         = $table->{options};
        foreach my $hashref (@$options) {
            if ( $hashref->{AUTO_INCREMENT} ) {
                $replace_options = 1;
            } else {
                push( @new_options, $hashref );
            }
        }
        if ($replace_options) {
            @{ $table->{options} } = @new_options;
        }
    }
    return $schema;
}

=head3 _get_kohastructure

Retrieves and returns the schema using SQL::Translator for the given file

=cut

sub _get_kohastructure {
    my ($self) = @_;

    print "Parsing schema for file $self->{filename} \n" if $self->{is_cli};
    my $translator = SQL::Translator->new();
    $translator->parser("MySQL");
    my $schema = $translator->translate( $self->{filename} );
    return $schema;
}

1;
