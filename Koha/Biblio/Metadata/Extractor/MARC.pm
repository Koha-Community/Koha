package Koha::Biblio::Metadata::Extractor::MARC;

# Copyright Koha Development Team 2023
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
# along with Koha; if not, see <http://www.gnu.org/licenses>.

=head1 NAME

Koha::Biblio::Metadata::Extractor::MARC - Extract specific metadata from MARC::Record objects

=cut

use Modern::Perl;

use Koha::Exceptions;

=head1 API

=head2 Class methods

=head3 new

    my $extractor = Koha::Biblio::Metadata::Extractor::MARC->new({ biblio => $biblio });

Constructor for the I<Koha::Biblio::Metadata::Extractor::MARC> class.

=cut

sub new {
    my ( $class, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw( parameter => 'metadata' )
        unless $params->{metadata} || $params->{biblio};

    #my $metadata = $biblio->metadata;
    #my $schema   = $metadata->schema;
    # Get the schema from the pref so that we do not fetch the biblio_metadata
    my $schema = C4::Context->preference('marcflavour');

    my $valid_schemas = { 'MARC21' => 1, 'UNIMARC' => 1 };
    Koha::Exceptions::WrongParameter->throw( name => 'schema', value => $schema )
        unless $valid_schemas->{$schema};

    my $sub_class = "Koha::Biblio::Metadata::Extractor::MARC::$schema";
    require "Koha/Biblio/Metadata/Extractor/MARC/$schema.pm";

    return $sub_class->new($params);
}

=head3 metadata

    my $metadata = $marc_extractor->metadata;

Return a MARC record.

=cut

sub metadata {
    my ($self) = @_;
    if ( $self->{biblio} ) {
        $self->{metadata} ||= $self->{biblio}->metadata->record;
    }
    return $self->{metadata};
}

=head2 get_control_number

    my $control_number = $extractor->get_control_number();

Returns the control number/record identifier as extracted from the metadata.
It returns an empty string if no 001 present or if undef.

=cut

sub get_control_number {
    my ($self) = @_;

    my $record = $self->metadata;
    my $field  = $record->field('001');

    my $control_number = q{};

    if ($field) {
        $control_number = $field->data() // q{};
    }

    return $control_number;
}

=head2 get_opac_suppression

    my $opac_suppressed = $extractor->get_opac_suppression();

Returns whether the record is flagged as suppressed in the OPAC.
FIXME: Revisit after 38330 discussion

=cut

sub get_opac_suppression {
    my ($self) = @_;

    my $record = $self->metadata;

    return $record->subfield( '942', 'n' ) ? 1 : 0;
}

=head3 _normalize_string

    my $normalized_string = $self->_normalize_string($string);

Returns a normalized string (remove dashes)

=cut

sub _normalize_string {
    my ( $self, $string ) = @_;
    ( my $normalized_string ) = $string =~ /([\d-]*[X]*)/;
    $normalized_string =~ s/-//g;

    return $normalized_string;
}

=head1 AUTHOR

Tomas Cohen Arazi, E<lt>tomascohen@theke.ioE<gt>

Jonathan Druart, E<lt>jonathan.druart@bugs.koha-community.orgE<gt>

=cut

1;

__END__
