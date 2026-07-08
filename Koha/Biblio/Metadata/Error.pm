package Koha::Biblio::Metadata::Error;

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

use Koha::Exceptions;

use base qw(Koha::Object);

=head1 NAME

Koha::Biblio::Metadata::Error - Koha Biblio Metadata Error object class

=head1 Constants

=cut

use constant {
    NONXML_STRIPPED          => 'nonxml_stripped',
    EMPTY_DATAFIELD_STRIPPED => 'empty_datafield_stripped',
};

my %VALID_ERROR_TYPES = map { $_ => 1 } ( NONXML_STRIPPED, EMPTY_DATAFIELD_STRIPPED );

=head1 API

=head2 Class methods

=head3 store

Rejects an C<error_type> outside the known set, so a typo in a future caller
fails loudly at store time rather than silently writing an unrecognised value
into the database.

=cut

sub store {
    my ($self) = @_;

    Koha::Exceptions::BadParameter->throw( parameter => 'error_type' )
        unless $VALID_ERROR_TYPES{ $self->error_type // '' };

    return $self->SUPER::store;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'BiblioMetadataError';
}

1;
