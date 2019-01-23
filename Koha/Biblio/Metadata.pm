package Koha::Biblio::Metadata;

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

use Modern::Perl;

use MARC::Record;
use MARC::File::XML;

use Koha::Database;
use Koha::Exceptions::Metadata;

use base qw(Koha::Object);

=head1 NAME

Koha::Metadata - Koha Metadata Object class

=head1 API

=head2 Class methods

=cut

=head3 record

my $record = $metadata->record;

Returns an object representing the metadata record. The expected record type
corresponds to this table:

    -------------------------------
    | format     | object type    |
    -------------------------------
    | marcxml    | MARC::Record   |
    -------------------------------

=head4 Error handling

=over

=item If an unsupported format is found, it throws a I<Koha::Exceptions::Metadata> exception.

=item If it fails to create the record object, it throws a I<Koha::Exceptions::Metadata::Invalid> exception.

=back

=cut

sub record {

    my ($self) = @_;

    my $record;

    if ( $self->format eq 'marcxml' ) {
        $record = eval { MARC::Record::new_from_xml( $self->metadata, 'utf-8', $self->schema ); };
        unless ($record) {
            Koha::Exceptions::Metadata::Invalid->throw(
                id     => $self->id,
                format => $self->format,
                schema => $self->schema
            );
        }
    }
    else {
        Koha::Exceptions::Metadata->throw(
            'Koha::Biblio::Metadata->record called on unhandled format: ' . $self->format );
    }

    return $record;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'BiblioMetadata';
}

1;
