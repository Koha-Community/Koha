package Koha::Biblio::Metadata::Extractor;

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

Koha::Biblio::Metadata::Extractor - Extract specific metadata from MARC::Record objects

=cut

use Modern::Perl;

use Koha::Exceptions;

=head1 API

=head2 Class methods

=head3 new

    my $extractor = Koha::Biblio::Metadata::Extractor->new;

Constructor for the I<Koha::Biblio::Metadata::Extractor> class.

=cut

sub new {
    my ($class) = @_;
    my $self = { extractors => {} };

    return
        bless $self,
        $class;
}

=head2 get_normalized_upc

    my $normalized_upc = $extractor->get_normalized_upc( { record => $record, schema => $schema } );

Returns the normalized UPC for the passed I<$record>.

=cut

sub get_normalized_upc {
    my ( $self, $params ) = @_;

    Koha::Exceptions::MissingParameter->throw( parameter => 'record' )
        unless $params->{record};

    return $self->get_extractor( { schema => $params->{schema} } )->get_normalized_upc( $params->{record} );
}

=head2 Internal methods

=head3 get_extractor

    my $extractor = $self->get_extractor( { schema => $schema } );

Returns the cached extractor for the specified I<$schema>.

=cut

sub get_extractor {
    my ( $self, $params ) = @_;

    my $schema = $params->{schema};

    Koha::Exceptions::MissingParameter->throw( parameter => 'schema' )
        unless $schema;

    my $valid_schemas = { 'MARC21' => 1, 'UNIMARC' => 1 };

    Koha::Exceptions::WrongParameter->throw( name => 'schema', value => $schema )
        unless $valid_schemas->{$schema};

    unless ( $self->{extractors}->{$schema} ) {
        my $extractor_class = "Koha::Biblio::Metadata::Extractor::MARC::$schema";
        eval "require $extractor_class";
        $self->{extractors}->{$schema} = $extractor_class->new;
    }

    return $self->{extractors}->{$schema};
}

=head1 AUTHOR

Tomas Cohen Arazi, E<lt>tomascohen@theke.ioE<gt>

=cut

1;

__END__
