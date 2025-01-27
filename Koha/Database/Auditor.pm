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

use Koha::I18N qw(__);

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
    return $self;
}

=head3 run

Compares the current database schema with the expected schema from the
`kohastructure.sql` file. Generates SQL commands to update the database schema
if differences are found. Returns a hash reference containing the differences,
a flag indicating if differences were found, a message, and a title.

=cut

sub run {
    my ( $self, $args ) = @_;

    if ( !-f $self->{filename} ) {
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

        my $diff_found = 1;
        my $message    = __(
            "These commands are only suggestions. They are not a replacement for the database update scripts run during installations and updates.\nReview the database, the atomic update files and the table definitions in kohastructure.sql before running any of the commands below:"
        );
        my $title = __("Warning!");

        if ( $diff =~ /No differences found/ ) {
            $diff_found = 0;
            $message    = __("The installed database schema is correct.");
            $title      = __("All is well");
        }

        return {
            diff       => $diff,
            diff_found => $diff_found,
            message    => $message,
            title      => $title,
        };
    }
}

=head3 _get_db

Retrieves the database schema, removes auto-increment from the schema, and returns the modified schema.

=cut

sub _get_db {
    my ($self) = @_;

    my $database_name = C4::Context->config("database");
    print sprintf( __("Parsing schema for database %s\n"), $database_name ) if $self->{is_cli};
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

    print sprintf( __("Parsing schema for file %s\n"), $self->{filename} ) if $self->{is_cli};
    my $translator = SQL::Translator->new();
    $translator->parser("MySQL");
    my $schema = $translator->translate( $self->{filename} );
    return $schema;
}

1;
