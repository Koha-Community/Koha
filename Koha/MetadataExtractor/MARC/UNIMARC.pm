package Koha::MetadataExtractor::MARC::UNIMARC;

# Copyright ByWater Solutions 2023
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

Koha::MetadataExtractor - Extract specific metadata from MARC::Record objects

=cut

use Modern::Perl;

use Koha::Exceptions;

=head1 API

=head2 Class methods

=head3 new

    my $extractor = Koha::MetadataExtractor::MARC::UNIMARC->new;

Constructor for the I<Koha::MetadataExtractor::MARC::UNIMARC> class.

=cut

sub new {
    my ($class) = @_;
    my $self = {};

    return
        bless $self,
        $class;
}

=head2 get_normalized_upc

    my $normalized_upc = $extractor->get_normalized_upc( $record );

Returns the normalized UPC for the passed I<$record>.

=cut

sub get_normalized_upc {
    my ( $self, $record ) = @_;

    Koha::Exceptions::MissingParameter->throw( parameter => 'record' )
        unless $record;

    Koha::Exceptions::WrongParameter->throw( name => 'record', type => ref($record) )
        unless ref($record) eq 'MARC::Record';

    my @fields = $record->field('072');
    foreach my $field (@fields) {

        my $upc = $field->subfield('a');

        ( my $normalized_upc ) = $upc =~ /([\d-]*[X]*)/;
        $normalized_upc =~ s/-//g;

        if ($normalized_upc) {
            return $normalized_upc;
        }
    }
}

=head1 AUTHOR

Tomas Cohen Arazi, E<lt>tomascohen@theke.ioE<gt>

=cut

1;

__END__
