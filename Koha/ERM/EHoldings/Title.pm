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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Database;

use base qw(Koha::Object);

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
        foreach my $char ( ',', '\t', ';', '|' ) {
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
