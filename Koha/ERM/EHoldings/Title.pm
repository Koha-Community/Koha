package Koha::ERM::EHoldings::Title;

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

use POSIX        qw( floor );
use MIME::Base64 qw( decode_base64 );

use Koha::Database;

use base qw(Koha::Object::Mixin::AdditionalFields Koha::Object);

use C4::Biblio qw( AddBiblio TransformKohaToMarc GetMarcFromKohaField );

use Koha::ERM::EHoldings::Resources;

=head1 NAME

Koha::ERM::EHoldings::Title - Koha ERM Title Object class

=head1 API

=head2 Class Methods

=head3 store

=cut

sub store {
    my ( $self, $args ) = @_;

    my $create_linked_biblio = $args->{create_linked_biblio} || 0;

    # FIXME This is terrible and ugly, we need to:
    # * Provide a mapping for each attribute of title
    # * Create a txn

    if ($create_linked_biblio) {

        # If the 'title' is already linked to a biblio, then we update the title subfield only
        if ( $self->biblio_id ) {
            my $biblio = Koha::Biblios->find( $self->biblio_id );
            my ( $title_tag, $title_subfield ) = GetMarcFromKohaField('biblio.title');
            my $record      = $biblio->metadata->record();
            my $title_field = $record->field($title_tag);
            $title_field->update( $title_subfield => $self->publication_title );
            C4::Biblio::ModBiblio( $record, $self->biblio_id, '', { skip_record_index => 1 } );
        } else {

            # If it's not linked, we create a simple biblio and save the biblio id to the 'title'
            my $marc_record = TransformKohaToMarc(
                {
                    'biblio.title' => $self->publication_title,
                }
            );
            my ($biblio_id) = C4::Biblio::AddBiblio( $marc_record, '', { skip_record_index => 1 } );
            $self->biblio_id($biblio_id);
        }
    }

    $self = $self->SUPER::store;
    return $self;

}

=head3 resources

Returns the resources linked to this title

=cut

sub resources {
    my ( $self, $resources ) = @_;

    if ($resources) {
        my $schema = $self->_result->result_source->schema;
        $schema->txn_do(
            sub {
                $self->resources->delete;

                # Cannot use the dbic RS, we need to trigger ->store overwrite
                for my $resource (@$resources) {
                    Koha::ERM::EHoldings::Resource->new( { %$resource, title_id => $self->title_id } )->store;
                }
            }
        );
    }
    my $resources_rs = $self->_result->erm_eholdings_resources;
    return Koha::ERM::EHoldings::Resources->_new_from_dbic($resources_rs);
}

=head3 read_file

Reads a KBART file of titles to provide report headers and lines to be processed.
Automatically detects whether the file is TSV or CSV based on the first 5 lines

=cut

sub read_file {
    my ($file) = @_;

    my $file_content = defined( $file->{file_content} ) ? decode_base64( $file->{file_content} ) : "";
    my ( $delimiter, $quote_char ) = _detect_delimiter_and_quote($file_content);

    return ( undef, undef, "unknown_delimiter" ) unless $delimiter;

    open my $fh, "<", \$file_content or die "Could not open file $file->{filename}: $!";
    my $csv = Text::CSV_XS->new(
        {
            sep_char           => $delimiter,
            quote_char         => $quote_char,
            binary             => 1,
            allow_loose_quotes => 1,
            formula            => 'empty',
        }
    );

    my $headers_to_check = $csv->getline($fh);
    my $column_headers   = _rescue_EBSCO_files($headers_to_check);
    my $lines            = $csv->getline_all( $fh, 0 );
    close($fh);

    unless ( $csv->eof() ) {
        my ( $cde, $str, $pos ) = $csv->error_diag();
        my $error = $cde ? "$cde, $str, $pos" : "";
        Koha::Exceptions::FileNotParsed->throw( filename => $file->{filename}, error => $error );
    }

    return ( $column_headers, $lines, '' );
}

=head3 get_valid_headers

Returns a list of permitted headers in a KBART phase II file

=cut

sub get_valid_headers {
    return (
        'publication_title',
        'print_identifier',
        'online_identifier',
        'date_first_issue_online',
        'num_first_vol_online',
        'num_first_issue_online',
        'date_last_issue_online',
        'num_last_vol_online',
        'num_last_issue_online',
        'title_url',
        'first_author',
        'title_id',
        'embargo_info',
        'coverage_depth',
        'coverage_notes',
        'publisher_name',
        'publication_type',
        'date_monograph_published_print',
        'date_monograph_published_online',
        'monograph_volume',
        'monograph_edition',
        'first_editor',
        'parent_publication_title_id',
        'preceding_publication_title_id',
        'access_type',
        'notes'
    );
}

=head3 calculate_chunked_params_size

Calculates average line size to work out how many lines to chunk a large file into
Uses only 75% of the max_allowed_packet as an upper limit

=cut

sub calculate_chunked_params_size {
    my ( $params_size, $max_allowed_packet, $number_of_rows ) = @_;

    my $average_line_size = $params_size / $number_of_rows;
    my $lines_possible    = ( $max_allowed_packet * 0.75 ) / $average_line_size;
    my $rounded_value     = floor($lines_possible);
    return $rounded_value;
}

=head3 is_file_too_large

Calculates the final size of the background job object that will need storing to check if we exceed the max_allowed_packet

=cut

sub is_file_too_large {
    my ( $params_to_store, $max_allowed_packet ) = @_;

    my $json           = JSON->new->utf8(0);
    my $encoded_params = $json->encode($params_to_store);
    my $params_size    = length $encoded_params;

    # A lot more than just the params are stored in the background job table and this is difficult to calculate
    # We should allow for no more than 75% of the max_allowed_packet to be made up of the job params to avoid db conflicts
    return {
        file_too_large => 1,
        params_size    => $params_size
    } if $params_size > ( $max_allowed_packet * 0.75 );

    return {
        file_too_large => 0,
        params_size    => $params_size
    };
}

=head3 _rescue_EBSCO_files

EBSCO have an incorrect spelling for "preceding_publication_title_id" in all of their KBART files (preceding is spelled with a double 'e').
This means all of their KBART files fail to import using the current methodology.
There is no simple way of finding out who the vendor is before importing so all KBART files from any vendor are going to have to be checked for this spelling and corrected.

=cut

sub _rescue_EBSCO_files {
    my ($column_headers) = @_;

    my ($index) = grep { @$column_headers[$_] eq 'preceeding_publication_title_id' } ( 0 .. @$column_headers - 1 );
    @$column_headers[$index] = 'preceding_publication_title_id' if $index;

    return $column_headers;
}

=head3 _detect_delimiter_and_quote

Identifies the delimiter and the quote character used in the KBART file and returns both.

=cut

sub _detect_delimiter_and_quote {
    my ($file) = @_;
    my $sample_lines = 5;    # Number of lines to sample for detection

    open my $fh, '<', \$file or die "Could not open '$file': $!";

    my @lines;
    while (<$fh>) {
        push @lines, $_;
        last if $. >= $sample_lines;
    }
    close $fh;

    my %delimiter_count;
    my %quote_count;

    foreach my $line (@lines) {
        foreach my $char ( ",", "\t", ";", "|" ) {
            my $count = () = $line =~ /\Q$char\E/g;
            $delimiter_count{$char} += $count if $count;
        }
        foreach my $char ( '"', "'" ) {
            my $count = () = $line =~ /\Q$char\E/g;
            $quote_count{$char} += $count if $count;
        }
    }

    # Guess the delimiter with the highest count
    my ($delimiter) = sort { $delimiter_count{$b} <=> $delimiter_count{$a} } keys %delimiter_count;

    # Guess the quote character with the highest count
    my ($quote) = sort { $quote_count{$b} <=> $quote_count{$a} } keys %quote_count;

    # Fallback to common defaults if nothing is detected
    $delimiter //= ',';
    $quote     //= '"';

    return ( $delimiter, $quote );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ErmEholdingsTitle';
}

1;
