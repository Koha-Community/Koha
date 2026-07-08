package Koha::Biblio::Metadata::Errors;

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

use Koha::Biblio::Metadata::Error;

use base qw(Koha::Objects);

=head1 NAME

Koha::Biblio::Metadata::Errors - Koha Biblio Metadata Errors object set class

=head1 API

=head2 Class methods

=head3 by_type

    my $errors = Koha::Biblio::Metadata::Errors->search(...)->by_type('nonxml_stripped');

Filters the resultset down to a single C<error_type>. See
L<Koha::Biblio::Metadata::Error> for the known type constants.

=cut

sub by_type {
    my ( $self, $error_type ) = @_;
    return $self->search( { error_type => $error_type } );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'BiblioMetadataError';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Biblio::Metadata::Error';
}

1;
