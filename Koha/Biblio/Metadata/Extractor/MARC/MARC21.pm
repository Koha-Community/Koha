package Koha::Biblio::Metadata::Extractor::MARC::MARC21;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

=head1 NAME

Koha::Biblio::Metadata::Extractor::MARC::MARC21 - Extract specific metadata from MARC21 MARC::Record objects

=cut

use Modern::Perl;

use base qw(Koha::Biblio::Metadata::Extractor::MARC);

use Koha::Exceptions;

=head1 API

=head2 Class methods

=head3 new

    my $extractor = Koha::Biblio::Metadata::Extractor::MARC::MARC21->new;

Constructor for the I<Koha::Biblio::Metadata::Extractor::MARC::MARC21> class.

=cut

sub new {
    my ( $class, $params ) = @_;

    return
        bless $params,
        $class;
}

=head2 get_normalized_upc

    my $normalized_upc = $extractor->get_normalized_upc();

Returns a normalized UPC.

=cut

sub get_normalized_upc {
    my ($self) = @_;

    my $record = $self->metadata;
    my @fields = $record->field('024');
    foreach my $field (@fields) {

        my $indicator = $field->indicator(1);

        my $normalized_upc = $self->_normalize_string( $field->subfield('a') );

        if ( $normalized_upc && $indicator eq "1" ) {
            return $normalized_upc;
        }
    }
}

=head2 get_normalized_oclc

    my $normalized_oclc = $extractor->get_normalized_oclc();

Returns a normalized OCLC number.

=cut

sub get_normalized_oclc {
    my ($self) = @_;

    my $record = $self->metadata;
    my @fields = $record->field('035');
    foreach my $field (@fields) {
        my $oclc = $field->subfield('a');
        if ( $oclc && $oclc =~ /OCoLC/ ) {
            $oclc =~ s/\(OCoLC\)//;
            return $oclc;
        }
    }
}

=head1 AUTHOR

Tomas Cohen Arazi, E<lt>tomascohen@theke.ioE<gt>

Jonathan Druart, E<lt>jonathan.druart@bugs.koha-community.orgE<gt>

=cut

1;

__END__
