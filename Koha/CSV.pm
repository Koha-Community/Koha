package Koha::CSV;

# Copyright 2026 Theke Solutions
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

use Text::CSV_XS;
use C4::Context;

use base qw(Class::Accessor);

__PACKAGE__->mk_accessors(qw( binary formula always_quote eol sep_char ));

=head1 NAME

Koha::CSV - Wrapper around Text::CSV_XS with Koha-specific defaults

=head1 SYNOPSIS

    my $csv = Koha::CSV->new();
    $csv->combine(@fields);
    my $line = $csv->string();

    # Override defaults
    my $csv = Koha::CSV->new( { sep_char => ';', always_quote => 1 } );

=head1 DESCRIPTION

This class wraps Text::CSV_XS providing consistent defaults and methods
used across Koha for CSV generation and parsing.

Configuration is inherited from Koha system preferences where applicable,
but can be overridden per instance.

=head2 Configuration Inheritance

=over 4

=item * B<sep_char> - Defaults to I<CSVDelimiter> system preference (or ',' if not set)

=item * B<binary> - Always 1 (required for UTF-8 support)

=item * B<formula> - Always 'empty' (security: prevents formula injection)

=item * B<always_quote> - Defaults to 0, can be overridden

=item * B<eol> - Defaults to "\n", can be overridden

=back

=cut

=head2 new

    my $csv = Koha::CSV->new();
    my $csv = Koha::CSV->new({ sep_char => ';', always_quote => 1 });

Creates a new Koha::CSV object. Accepts optional parameters to override defaults.

Parameters:
- sep_char: CSV delimiter (defaults to CSVDelimiter system preference)
- always_quote: Whether to quote all fields (defaults to 0)
- eol: End of line character (defaults to "\n")

Note: binary and formula parameters are fixed for security and cannot be overridden.

=cut

sub new {
    my ( $class, $params ) = @_;
    $params //= {};

    # Get delimiter from Koha configuration if not explicitly provided
    my $sep_char = $params->{sep_char} // C4::Context->csv_delimiter();

    my $self = $class->SUPER::new(
        {
            binary       => 1,                                  # Always 1 for UTF-8
            formula      => 'empty',                            # Always 'empty' for security
            always_quote => $params->{always_quote} // 0,       # Overridable
            eol          => $params->{eol}          // "\n",    # Overridable
            sep_char     => $sep_char,                          # From Koha config or override
        }
    );

    $self->{_csv} = Text::CSV_XS->new(
        {
            binary       => $self->binary,
            formula      => $self->formula,
            always_quote => $self->always_quote,
            eol          => $self->eol,
            sep_char     => $self->sep_char,
        }
    );

    return $self;
}

=head2 combine

    $csv->combine(@fields);

Combines fields into a CSV line. Returns true on success.

=cut

sub combine {
    my ( $self, @fields ) = @_;
    return $self->{_csv}->combine(@fields);
}

=head2 string

    my $line = $csv->string();

Returns the combined CSV line as a string.

=cut

sub string {
    my ($self) = @_;
    return $self->{_csv}->string();
}

=head2 add_row

    my $line = $csv->add_row(@fields);
    # or
    my $line = $csv->add_row(\@fields);

Convenience method that combines fields and returns the CSV line as a string.
Accepts either an array or arrayref of fields.

=cut

sub add_row {
    my ( $self, @fields ) = @_;

    # Handle arrayref or array
    @fields = @{ $fields[0] } if @fields == 1 && ref $fields[0] eq 'ARRAY';

    $self->combine(@fields) or return;
    return $self->string();
}

=head2 parse

    $csv->parse($line);

Parses a CSV line. Returns true on success.

=cut

sub parse {
    my ( $self, $line ) = @_;
    return $self->{_csv}->parse($line);
}

=head2 fields

    my @fields = $csv->fields();

Returns the parsed fields from the last parse() call.

=cut

sub fields {
    my ($self) = @_;
    return $self->{_csv}->fields();
}

=head2 print

    $csv->print($fh, \@fields);

Prints fields to a filehandle as a CSV line.

=cut

sub print {
    my ( $self, $fh, $fields ) = @_;
    return $self->{_csv}->print( $fh, $fields );
}

=head2 getline

    my $fields = $csv->getline($fh);

Reads and parses a line from a filehandle. Returns arrayref of fields.

=cut

sub getline {
    my ( $self, $fh ) = @_;
    return $self->{_csv}->getline($fh);
}

=head2 error_diag

    my $error = $csv->error_diag();

Returns error diagnostics from the last operation.

=cut

sub error_diag {
    my ($self) = @_;
    return $self->{_csv}->error_diag();
}

1;
