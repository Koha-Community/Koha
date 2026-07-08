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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use MARC::File::XML;
use Scalar::Util qw( blessed );

use C4::Biblio  qw( GetMarcFromKohaField );
use C4::Charset qw( StripNonXmlChars );
use C4::Items   qw( GetMarcItem );

use Koha::Biblio::Metadata::Error;
use Koha::Biblio::Metadata::Errors;
use Koha::Database;
use Koha::Exceptions::Metadata;
use Koha::Logger;
use Koha::RecordSources;

use base qw(Koha::Object);

=head1 NAME

=encoding utf-8

Koha::Metadata - Koha Metadata Object class

=head1 API

=head2 Class methods

=cut

=head3 store

Metadata specific store method to catch errant characters prior
to committing to the database.

If the MARCXML cannot be parsed but can be recovered, the recovered version is
saved and an error row per fault is written to C<biblio_metadata_errors> so
callers and the UI can notify the user. Two recoverable faults are currently
handled, and either or both may apply to the same record:

=over 4

=item * non-XML characters (recorded as C<nonxml_stripped>, recovered via
C<StripNonXmlChars>)

=item * datafields with no subfields at all, which C<MARC::File::XML> refuses
to parse (recorded as C<empty_datafield_stripped>, recovered by removing the
empty datafield)

=back

Any pre-existing error row is left alone when the record parses cleanly - they
are review flags requiring explicit human resolution and should not be
silently cleared by a routine re-save.

If the MARCXML cannot be recovered at all, a
I<Koha::Exceptions::Metadata::Invalid> exception is thrown.

=cut

sub store {
    my $self = shift;

    # Reset messages so object_messages reflects only this store call
    $self->{_messages} = [];

    my %recoveries;    # error_type => arrayref of occurrences, for faults that were fixed

    # Check marcxml will roundtrip
    if ( $self->format eq 'marcxml' ) {

        my $marcxml = eval {
            MARC::Record::new_from_xml(
                $self->metadata, 'UTF-8',
                $self->schema
            );
        };
        my $marcxml_error = $@;
        chomp $marcxml_error;

        unless ($marcxml) {
            my ( $stripped_record, $stripped_metadata, $stripped_recoveries ) =
                $self->repair_marcxml( $self->metadata, $self->schema );

            if ($stripped_record) {

                Koha::Logger->get->warn(
                    sprintf(
                        "Metadata for bibliographic record (biblionumber=%s) was automatically repaired before saving: %s",
                        $self->biblionumber // 'N/A', $marcxml_error
                    )
                );
                $self->metadata($stripped_metadata);
                %recoveries = %$stripped_recoveries;
            } else {

                # Truly unrecoverable
                Koha::Logger->get->warn($marcxml_error);
                Koha::Exceptions::Metadata::Invalid->throw(
                    id             => $self->id,
                    biblionumber   => $self->biblionumber,
                    format         => $self->format,
                    schema         => $self->schema,
                    decoding_error => $marcxml_error,
                );
            }
        }
    }

    $self->SUPER::store;

    # If this save triggered a fresh repair, record each fault as a DB error row and
    # signal the event via object_messages. A fault already on record for this metadata_id
    # (same error_type and message) is left as-is rather than duplicated, so re-harvesting or
    # re-importing a source record that is still dirty doesn't pile up repeat rows for the
    # same underlying issue.
    for my $error_type ( sort keys %recoveries ) {
        my $occurrences = $recoveries{$error_type};
        my $formatter   = _error_message_formatter($error_type);
        if (@$occurrences) {
            for my $occ (@$occurrences) {
                $self->_add_error_once( $error_type, $formatter->($occ), $occ );
            }
        } else {

            # Fallback: couldn't pinpoint individual occurrences – store a generic message
            $self->_add_error_once( $error_type, 'details unavailable' );
        }

        $self->add_message(
            {
                message => $error_type,
                type    => 'warning',
                payload => ( join( "\n", map { $formatter->($_) } @$occurrences ) || 'details unavailable' ),
            }
        );
    }

    return $self;
}

=head3 metadata_errors

    my $errors = $metadata->metadata_errors;

Returns a I<Koha::Biblio::Metadata::Errors> resultset for errors associated
with this metadata record.

=cut

sub metadata_errors {
    my ($self) = @_;
    return Koha::Biblio::Metadata::Errors->_new_from_dbic( scalar $self->_result->biblio_metadata_errors );
}

=head3 _add_error_once

    $self->_add_error_once( $error_type, $message, $occurrence );

Records a C<biblio_metadata_errors> row for this metadata record, unless an
identical row (same C<error_type> and C<message>) already exists - so
re-triggering the same fault on a source record that stays dirty across
repeated saves doesn't pile up duplicate rows. C<$occurrence> is the optional
occurrence hashref produced by C<_find_nonxml_chars>/C<_find_empty_datafields>;
when its C<field> key looks like C<TAG$sub> or C<TAG>, the C<tag>/C<subfield>
columns are populated so callers (e.g. the cataloguing UI) don't need to parse
them back out of the free-text message.

=cut

sub _add_error_once {
    my ( $self, $error_type, $message, $occurrence ) = @_;

    return
        if Koha::Biblio::Metadata::Errors->search(
        {
            metadata_id => $self->id,
            error_type  => $error_type,
            message     => $message,
        }
        )->count;

    my ( $tag, $subfield ) =
        ( $occurrence && $occurrence->{field} ) ? _split_field_ref( $occurrence->{field} ) : ( undef, undef );

    Koha::Biblio::Metadata::Error->new(
        {
            metadata_id => $self->id,
            error_type  => $error_type,
            message     => $message,
            tag         => $tag,
            subfield    => $subfield,
        }
    )->store;
}

=head3 _split_field_ref

    my ( $tag, $subfield ) = _split_field_ref( $field_ref );

Splits a human-readable field reference such as C<245$a> into its tag and
subfield parts. Field references with no subfield (control fields, or a
datafield reported as a whole e.g. from C<_find_empty_datafields>) return an
undefined subfield.

=cut

sub _split_field_ref {
    my ($field_ref) = @_;
    return $field_ref =~ /^(\w+)\$(\w)$/ ? ( $1, $2 ) : ( $field_ref, undef );
}

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

    my ( $self, $params ) = @_;

    my $record      = $params->{record};
    my $embed_items = $params->{embed_items};
    my $format      = blessed($self) ? $self->format : $params->{format};
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
    } else {
        Koha::Exceptions::Metadata->throw( 'Koha::Biblio::Metadata->record called on unhandled format: ' . $format );
    }

    # FIXME: Remove existing items from the MARC record. This should be handled
    #        at store() time or pre-filtering in {Add|Mod}Biblio. Remove the FIXME
    #        once we reach some consensus on how to handle this.
    my ( $itemtag, $itemsubfield ) = C4::Biblio::GetMarcFromKohaField("items.itemnumber");
    $record->delete_field( ( $record->field($itemtag) ) );

    if ($embed_items) {
        $self->_embed_items( { %$params, format => $format, record => $record } );
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

=head3 source_allows_editing

    if ( $metadata->source_allows_editing ) { ... }

Returns a boolean denoting whether the metadata's record source allows
it to be edited.

=cut

sub source_allows_editing {
    my ($self) = @_;

    my $rs = $self->_result->record_source;
    return 1 unless $rs;
    return $rs->can_be_edited;
}

=head3 record_source

    my $record_source = $metadata->record_source;

Returns a I<Koha::RecordSource> object for the linked record source.

=cut

sub record_source {
    my ($self) = @_;

    my $rs = $self->_result->record_source;
    return unless $rs;
    return Koha::RecordSource->_new_from_dbic($rs);
}

=head2 Internal methods

=head3 _embed_items

=cut

sub _embed_items {
    my ( $self, $params ) = @_;

    my $record       = $params->{record};
    my $format       = $params->{format};
    my $biblionumber = $params->{biblionumber} || $self->biblionumber;
    my $itemnumbers  = $params->{itemnumbers} // [];
    my $patron       = $params->{patron};
    my $opac         = $params->{opac};

    if ( $format eq 'marcxml' ) {

        my ( $itemtag, $itemsubfield ) = C4::Biblio::GetMarcFromKohaField("items.itemnumber");
        my $biblio = Koha::Biblios->find($biblionumber);

        my $items = $biblio->items;
        if (@$itemnumbers) {
            $items = $items->search( { itemnumber => { -in => $itemnumbers } } );
        }
        if ($opac) {
            $items = $items->filter_by_visible_in_opac( { patron => $patron } );
        }
        my @itemnumbers = $items->get_column('itemnumber');
        my @item_fields;
        for my $itemnumber (@itemnumbers) {
            my $item_marc = C4::Items::GetMarcItem( $biblionumber, $itemnumber );
            push @item_fields, $item_marc->field($itemtag);
        }
        $record->insert_fields_ordered( reverse @item_fields );

        # insert_fields_ordered with the reverse keeps 952s in right order

    } else {
        Koha::Exceptions::Metadata->throw(
            'Koha::Biblio::Metadata->embed_item called on unhandled format: ' . $format );
    }

    return $record;
}

=head3 _context_snippet

    my $snippet = _context_snippet( \@chars, $pos_0, $char_ord );

Given an array-ref of characters C<\@chars>, a 0-based position C<$pos_0> of
a bad character, and its ordinal C<$char_ord>, returns a two-line string:

=over 4

=item * Line 1 – up to 30 characters of context either side of the bad
character, with the bad character replaced by a visible glyph (Unicode
Control Pictures U+2400–U+241F for C0 controls, C<␡> for DEL, C<?>
otherwise) and ellipses when the window is truncated.

=item * Line 2 – a caret (C<^>) aligned beneath the visible glyph.

=back

Example output (4-space indent):

    t $xtac arr␈\ $btxt V $2rdacontent
               ^

=cut

sub _context_snippet {
    my ( $chars_ref, $pos_0, $char_ord ) = @_;

    # Visible stand-in for the removed character:
    #   C0 controls (U+0000–U+001F) → Unicode Control Pictures (U+2400–U+241F)
    #   DEL (U+007F)                → U+2421 SYMBOL FOR DELETE (␡)
    #   anything else               → U+FFFD REPLACEMENT CHARACTER (?)
    my $visible =
          $char_ord <= 0x1F ? chr( $char_ord + 0x2400 )
        : $char_ord == 0x7F ? "\x{2421}"
        :                     "\x{FFFD}";

    my $last = $#{$chars_ref};
    my $win  = 30;

    my $pre_start = ( $pos_0 > $win )         ? $pos_0 - $win : 0;
    my $post_end  = ( $pos_0 + $win < $last ) ? $pos_0 + $win : $last;

    my $pre  = $pos_0 > 0     ? join( '', @{$chars_ref}[ $pre_start .. $pos_0 - 1 ] ) : '';
    my $post = $pos_0 < $last ? join( '', @{$chars_ref}[ $pos_0 + 1 .. $post_end ] )  : '';

    my $prefix = ( $pos_0 > $win )         ? '...' : '';
    my $suffix = ( $pos_0 + $win < $last ) ? '...' : '';

    my $indent    = '    ';
    my $line      = "$indent$prefix$pre$visible$post$suffix";
    my $caret_col = length($indent) + length($prefix) + length($pre);

    return "$line\n" . ( ' ' x $caret_col ) . '^';
}

=head3 repair_marcxml

    my ( $record, $repaired_xml, $recoveries ) =
        Koha::Biblio::Metadata->repair_marcxml( $marcxml, $marc_schema );

Attempts to repair a MARCXML string that fails to parse, by stripping
whichever of the known-recoverable faults (non-XML characters,
subfield-less datafields) are present. This is the same recovery logic used
by C<store>, exposed as a class method so other callers that parse MARCXML
ahead of a C<Koha::Biblio::Metadata> save - such as C<Koha::Import::Record>
staging records - benefit from the same repair capability instead of
re-implementing a weaker version of it.

Returns, on success, the repaired C<MARC::Record>, the repaired XML string,
and a hashref of C<< error_type => \@occurrences >> (see
C<_find_nonxml_chars>/C<_find_empty_datafields>) describing what was fixed.
Returns an empty list if the XML has none of the known-recoverable faults,
or if it still doesn't parse once they're stripped.

=cut

sub repair_marcxml {
    my ( $class, $marcxml, $marc_schema ) = @_;

    my @nonxml_chars     = _find_nonxml_chars($marcxml);
    my @empty_datafields = _find_empty_datafields($marcxml);

    return unless @nonxml_chars || @empty_datafields;

    my $stripped_metadata = $marcxml;
    $stripped_metadata = StripNonXmlChars($stripped_metadata)        if @nonxml_chars;
    $stripped_metadata = _strip_empty_datafields($stripped_metadata) if @empty_datafields;

    my $stripped_record = eval { MARC::Record::new_from_xml( $stripped_metadata, 'UTF-8', $marc_schema ); };
    return unless $stripped_record;

    my %recoveries;
    $recoveries{ Koha::Biblio::Metadata::Error::NONXML_STRIPPED() }          = \@nonxml_chars     if @nonxml_chars;
    $recoveries{ Koha::Biblio::Metadata::Error::EMPTY_DATAFIELD_STRIPPED() } = \@empty_datafields if @empty_datafields;

    return ( $stripped_record, $stripped_metadata, \%recoveries );
}

=head3 _find_nonxml_chars

    my @occurrences = _find_nonxml_chars( $marcxml_string );

Scans a raw MARC XML string for every individual character that is illegal
in XML 1.0.  Returns a list of hashrefs (one per character occurrence) with
the following keys:

=over 4

=item * C<field> - human-readable field reference, e.g. C<245$a> or C<001>

=item * C<char_ord> - ordinal (decimal) value of the bad character

=item * C<position> - 1-based character offset within the field value

=item * C<snippet> - two-line string with context window and caret pointer (see C<_context_snippet>)

=back

The same character class is used as L<C4::Charset/StripNonXmlChars>, so
every occurrence returned here is exactly one that would be stripped.

=cut

sub _find_nonxml_chars {
    my ($marcxml) = @_;

    # Characters illegal in XML 1.0 – identical to the set stripped by StripNonXmlChars
    my $non_xml_re = qr/[^\x09\x0A\x0D\x{0020}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]/;

    my @occurrences;

    my $scan = sub {
        my ( $field_ref, $val ) = @_;
        my @chars = split //, $val;
        for my $i ( 0 .. $#chars ) {
            if ( $chars[$i] =~ $non_xml_re ) {
                push @occurrences, {
                    field    => $field_ref,
                    char_ord => ord( $chars[$i] ),
                    position => $i + 1,
                    snippet  => _context_snippet( \@chars, $i, ord( $chars[$i] ) ),
                };
            }
        }
    };

    # Scan every subfield inside every datafield
    while ( $marcxml =~ m{<datafield\b[^>]*\btag="(\w+)"[^>]*>(.*?)</datafield>}gs ) {
        my ( $tag, $content ) = ( $1, $2 );
        while ( $content =~ m{<subfield\b[^>]*\bcode="(\w)"[^>]*>(.*?)</subfield>}gs ) {
            $scan->( "$tag\$$1", $2 );
        }
    }

    # Scan control fields
    while ( $marcxml =~ m{<controlfield\b[^>]*\btag="(\w+)"[^>]*>(.*?)</controlfield>}gs ) {
        $scan->( $1, $2 );
    }

    return @occurrences;
}

=head3 _find_empty_datafields

    my @occurrences = _find_empty_datafields( $marcxml_string );

Scans a raw MARC XML string for C<< <datafield> >> elements with no
C<< <subfield> >> children at all. C<MARC::File::XML> refuses to parse such
a field (it dies with "Field NNN must have at least one subfield"), which
happens with legacy data saved before this validation existed.

Returns a list of hashrefs (one per occurrence) with the single key
C<field>, the datafield's tag.

=cut

sub _find_empty_datafields {
    my ($marcxml) = @_;

    my @occurrences;
    while ( $marcxml =~ m{<datafield\b([^>]*)>\s*</datafield>|<datafield\b([^>]*)/>}gs ) {
        my $attrs = defined $1 ? $1 : $2;
        my ($tag) = $attrs =~ /\btag="(\w+)"/;
        push @occurrences, { field => $tag // 'unknown' };
    }

    return @occurrences;
}

=head3 _strip_empty_datafields

    my $cleaned_marcxml = _strip_empty_datafields( $marcxml_string );

Removes every C<< <datafield> >> element with no C<< <subfield> >> children
from a raw MARC XML string, so the record can be parsed and saved. The
removed field's data cannot be recovered - callers should record an error
row (see C<_find_empty_datafields>) so a cataloguer can review and re-add it.

=cut

sub _strip_empty_datafields {
    my ($marcxml) = @_;

    return $marcxml unless defined $marcxml;
    $marcxml =~ s{<datafield\b[^>]*>\s*</datafield>}{}gs;
    $marcxml =~ s{<datafield\b[^>]*/>}{}gs;

    return $marcxml;
}

=head3 _error_message_formatter

    my $formatter = _error_message_formatter( $error_type );
    my $message   = $formatter->( $occurrence );

Returns a coderef that turns one occurrence hashref (as produced by
C<_find_nonxml_chars> or C<_find_empty_datafields>) into a human-readable
message line for the given C<$error_type>.

=cut

sub _error_message_formatter {
    my ($error_type) = @_;

    return sub {
        my ($occ) = @_;
        return sprintf(
            "%s: invalid char value %d (U+%04X) at position %d\n%s",
            $occ->{field}, $occ->{char_ord}, $occ->{char_ord}, $occ->{position}, $occ->{snippet}
        );
        }
        if $error_type eq Koha::Biblio::Metadata::Error::NONXML_STRIPPED;

    return sub {
        my ($occ) = @_;
        return sprintf( "%s: field removed, it had no subfields", $occ->{field} );
        }
        if $error_type eq Koha::Biblio::Metadata::Error::EMPTY_DATAFIELD_STRIPPED;

    return sub { 'details unavailable' };
}

=head3 _type

=cut

sub _type {
    return 'BiblioMetadata';
}

1;
