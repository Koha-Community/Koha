package Koha::Old::Biblio;

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

use base qw(Koha::Object);

use Koha::Old::Biblio::Metadatas;

=head1 NAME

Koha::Old::Biblio - Koha Old::Biblio Object class

=head1 API

=head2 Class methods

=cut

=head3 metadata

my $metadata = $deleted_biblio->metadata();

Returns a Koha::Biblio::Metadata object

=cut

sub metadata {
    my ( $self ) = @_;

    my $metadata = $self->_result->metadata;
    return Koha::Old::Biblio::Metadata->_new_from_dbic($metadata);
}

=head3 record

my $record = $deleted_biblio->record();

Returns a Marc::Record object

=cut

sub record {
    my ( $self ) = @_;

    return $self->metadata->record;
}

=head3 record_schema

my $schema = $deleted_biblio->record_schema();

Returns the record schema (MARC21, USMARC or UNIMARC).

=cut

sub record_schema {
    my ( $self ) = @_;

    return $self->metadata->schema // C4::Context->preference("marcflavour");
}


=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Deletedbiblio';
}

1;
