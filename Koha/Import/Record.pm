package Koha::Import::Record;

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

use Carp;
use MARC::Record;

use C4::Context;
use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Import::Record - Koha Import Record Object class

=head1 API

=head2 Public methods

=head3 get_marc_record

Returns a MARC::Record object

    my $marc_record = $import_record->get_marc_record({ embed_items => $embed_items })

If $embed_items is true then items from import_items are embedded into the
MARC::Record returned

=cut

sub get_marc_record {
    my ($self, $args) = @_;

    my $marcflavour = C4::Context->preference('marcflavour');

    my $format = $marcflavour eq 'UNIMARC' ? 'UNIMARC' : 'USMARC';
    if ($marcflavour eq 'UNIMARC' && $self->record_type eq 'auth') {
        $format = 'UNIMARCAUTH';
    }

    my $record = MARC::Record->new_from_xml($self->marcxml, $self->encoding, $format);

    if ($self->record_type eq 'biblio' && $args->{embed_items}) {
        require C4::ImportBatch;
        C4::ImportBatch::EmbedItemsInImportBiblio($record, $self->id);
    }

    return $record;
}

=head2 Internal methods

=head3 _type

Returns name of corresponding DBIC resultset

=cut

sub _type {
    return 'ImportRecord';
}

1;
