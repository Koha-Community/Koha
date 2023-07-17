package Koha::Biblio::Metadata;

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

use MARC::File::XML;
use Scalar::Util qw( blessed );

use C4::Biblio qw( GetMarcFromKohaField );
use C4::Charset qw( StripNonXmlChars );
use C4::Items qw( GetMarcItem );
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

    $record = $biblio->metadata->record({
        {
            embed_items => 0|1
            itemnumbers => $itemnumbers,
            opac        => $opac
        }
    );

    Koha::Biblio::Metadata::record(
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

    my ($self, $params) = @_;

    my $record = $params->{record};
    my $embed_items = $params->{embed_items};
    my $format = blessed($self) ? $self->format : $params->{format};
    $format ||= 'marcxml';

    if ( !$record && !blessed($self) ) {
        Koha::Exceptions::Metadata->throw(
            'Koha::Biblio::Metadata->record must be called on an instantiated object or like a class method with a record passed in parameter'
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
    }
    else {
        Koha::Exceptions::Metadata->throw(
            'Koha::Biblio::Metadata->record called on unhandled format: ' . $format );
    }

    if ( $embed_items ) {
        $self->_embed_items({ %$params, format => $format, record => $record });
    }

    return $record;
}

=head3 record_strip_nonxml

my $record = $metadata->record_strip_nonxml;

This subroutine is intended for cases where we encounter a record that cannot be parsed, but want
to make a good effort to present the record (for harvesting, deletion, editing) rather than throwing
an exception

Will return undef if the record cannot be built

=cut

sub record_strip_nonxml {

    my ( $self, $params ) = @_;
    $params //= {};

    my $record;
    my $marcxml_error;

    eval {
        $record = MARC::Record->new_from_xml(
            StripNonXmlChars( $self->metadata ), 'UTF-8',
            $self->schema
        );
    };
    if ($@) {
        $marcxml_error = $@;
        chomp $marcxml_error;
        warn $marcxml_error;
        return;
    }

    return $self->record( { %$params, record => $record } );
}

=head2 Internal methods

=head3 _embed_items

=cut

sub _embed_items {
    my ( $self, $params ) = @_;

    my $record       = $params->{record};
    my $format       = $params->{format};
    my $biblionumber = $params->{biblionumber} || $self->biblionumber;
    my $itemnumbers = $params->{itemnumbers} // [];
    my $patron      = $params->{patron};
    my $opac        = $params->{opac};

    if ( $format eq 'marcxml' ) {

        # First remove the existing items from the MARC record
        my ( $itemtag, $itemsubfield ) = C4::Biblio::GetMarcFromKohaField( "items.itemnumber" );
        foreach my $field ( $record->field($itemtag) ) {
            $record->delete_field($field);
        }

        my $biblio = Koha::Biblios->find($biblionumber);

        my $items = $biblio->items;
        if ( @$itemnumbers ) {
            $items = $items->search({ itemnumber => { -in => $itemnumbers } });
        }
        if ( $opac ) {
            $items = $items->filter_by_visible_in_opac({ patron => $patron });
        }
        my @itemnumbers = $items->get_column('itemnumber');
        my @item_fields;
        for my $itemnumber ( @itemnumbers ) {
            my $item_marc = C4::Items::GetMarcItem( $biblionumber, $itemnumber );
            push @item_fields, $item_marc->field($itemtag);
        }
        $record->insert_fields_ordered( reverse @item_fields );
            # insert_fields_ordered with the reverse keeps 952s in right order

    }
    else {
        Koha::Exceptions::Metadata->throw(
            'Koha::Biblio::Metadata->embed_item called on unhandled format: ' . $format );
    }

    return $record;
}


=head3 _type

=cut

sub _type {
    return 'BiblioMetadata';
}

1;
