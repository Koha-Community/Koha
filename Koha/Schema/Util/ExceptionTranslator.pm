package Koha::Schema::Util::ExceptionTranslator;

# Copyright 2025 Koha Development team
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

use Koha::Exceptions::Object;

=encoding utf8

=head1 NAME

Koha::Schema::Util::ExceptionTranslator - Centralized DBIx::Class exception translation

=head1 SYNOPSIS

    use Koha::Schema::Util::ExceptionTranslator;

    # Called automatically via Koha::Schema's exception_action hook.
    # No manual invocation needed in normal code.

=head1 DESCRIPTION

This utility class provides centralized exception translation from database
error messages to Koha-specific exceptions. It is installed as the
C<exception_action> handler on L<Koha::Schema>, so all DBIx::Class exceptions
are automatically translated before they propagate to callers.

=head1 METHODS

=head2 translate_exception

    Koha::Schema::Util::ExceptionTranslator->translate_exception($msg);

Attempts to translate a database error message into a Koha exception and
throw it. If the message does not match any known pattern, returns without
throwing, allowing the default DBIx::Class exception handling to proceed.

=cut

sub translate_exception {
    my ( $class, $msg ) = @_;

    # Foreign key constraint failures (insert/update)
    if ( $msg =~ /Cannot add or update a child row: a foreign key constraint fails/ ) {

        # FIXME: MySQL error, if we support more DB engines we should implement this for each
        if ( $msg =~ /FOREIGN KEY \(`(?<column>.*?)`\)/ ) {
            Koha::Exceptions::Object::FKConstraint->throw(
                error     => 'Broken FK constraint',
                broken_fk => $+{column}
            );
        }
    }

    # Foreign key constraint failures (delete)
    elsif ( $msg =~
        /Cannot delete or update a parent row\: a foreign key constraint fails \(\`(?<database>.*?)\`\.`(?<table>.*?)`, CONSTRAINT \`(?<constraint>.*?)\` FOREIGN KEY \(\`(?<fk>.*?)\`\) REFERENCES \`.*\` \(\`(?<column>.*?)\`\)/
        )
    {
        Koha::Exceptions::Object::FKConstraintDeletion->throw(
            column     => $+{column},
            constraint => $+{constraint},
            fk         => $+{fk},
            table      => $+{table},
        );
    }

    # Duplicate key violations
    elsif ( $msg =~ /Duplicate entry '(.*?)' for key '(?<key>.*?)'/ ) {
        Koha::Exceptions::Object::DuplicateID->throw(
            error        => 'Duplicate ID',
            duplicate_id => $+{key}
        );
    }

    # Invalid data type values
    elsif ( $msg =~ /Incorrect (?<type>\w+) value: '(?<value>.*)' for column \W?(?<property>\S+)/ ) {

        # The optional \W in the regex might be a quote or backtick
        my $type     = $+{type};
        my $value    = $+{value};
        my $property = $+{property};
        $property =~ s/['`]//g;

        Koha::Exceptions::Object::BadValue->throw(
            type     => $type,
            value    => $value,
            property => $property =~ /(\w+\.\w+)$/
            ? $1
            : $property,    # results in table.column without quotes or backticks
        );
    }

    # Data truncation for enum columns
    elsif ( $msg =~ /Data truncated for column \W?(?<property>\w+)/ ) {
        my $property = $+{property};

        Koha::Exceptions::Object::BadValue->throw(
            type     => 'enum',
            property => $property =~ /(\w+\.\w+)$/
            ? $1
            : $property,
            value => 'Invalid enum value',
        );
    }

    # NOT NULL violations
    elsif ($msg =~ /Column '(?<property>\w+)' cannot be null/
        || $msg =~ /'(?<property>\w+)' doesn't have a default value/ )
    {
        Koha::Exceptions::Object::NotNull->throw(
            property => $+{property},
        );
    }

    # Object not in storage (fires for update, but not for delete on detached Rows)
    elsif ( $msg =~ /Not in database/ ) {
        Koha::Exceptions::Object::NotInStorage->throw();
    }

    # No match — return without throwing so DBIC's default handling proceeds
    return;
}

=head1 AUTHOR

Koha Development Team

=cut

1;
