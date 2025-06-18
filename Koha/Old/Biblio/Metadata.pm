package Koha::Old::Biblio::Metadata;

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

use MARC::File::XML;
use Scalar::Util qw( blessed );

use C4::Biblio qw( GetMarcFromKohaField );
use C4::Items  qw( GetMarcItem );
use Koha::Database;
use Koha::Exceptions::Metadata;

use base qw(Koha::Object);

=head1 NAME

Koha::Old::Biblio::Metadata - Koha Deleted Biblio Metadata Object class

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

    $record = $deleted_biblio->metadata->record({
        {
            embed_items => 0|1
            itemnumbers => $itemnumbers,
            opac        => $opac
        }
    );

    Koha::Old::Biblio::Metadata::record(
        {
            record       => $record,
            embed_items  => 1,
            biblionumber => $biblionumber,
            itemnumbers  => $itemnumbers,
            opac         => $opac
        }
    );

Given a MARC::Record object containing a bib record,
modify it to include the items attached to it as 9XX
per the bib's MARC framework.
if $itemnumbers is defined, only specified itemnumbers are embedded.

If $opac is true, then opac-relevant suppressions are included.

If opac filtering will be done, patron should be passed to properly
override if necessary.


=head4 Error handling

=over

=item If an unsupported format is found, it throws a I<Koha::Exceptions::Metadata> exception.

=item If it fails to create the record object, it throws a I<Koha::Exceptions::Metadata::Invalid> exception.

=back

=cut

sub record {

    my ( $self, $params ) = @_;

    my $record = $params->{record};
    my $format = blessed($self) ? $self->format : $params->{format};
    $format ||= 'marcxml';

    if ( !$record && !blessed($self) ) {
        Koha::Exceptions::Metadata->throw(
            'Koha::Old::Biblio::Metadata->record must be called on an instantiated object or like a class method with a record passed in parameter'
        );
    }

    if ( $format eq 'marcxml' ) {
        $record ||= eval { MARC::Record::new_from_xml( $self->metadata, 'UTF-8', $self->schema ); };
        my $marcxml_error = $@;
        chomp $marcxml_error;
        unless ($record) {
            warn $marcxml_error;
            Koha::Exceptions::Metadata::Invalid->throw(
                id             => $self->id,
                biblionumber   => $self->biblionumber,
                format         => $self->format,
                schema         => $self->schema,
                decoding_error => $marcxml_error,
            );
        }
    } else {
        Koha::Exceptions::Metadata->throw(
            'Koha::Old::Biblio::Metadata->record called on unhandled format: ' . $format );
    }

    return $record;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'DeletedbiblioMetadata';
}

1;
