package Koha::Edifact::File::Error;

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

use base qw(Koha::Object);

=encoding utf8

=head1 Name

Koha::Edifact::File::Error - Koha::Object class for single EDIFACT file

=head2 Class methods

=head3 file

  my $file = $error->file;

Returns the I<Koha::Edifact::File> associated with this error

=cut

sub file {
    my ($self) = @_;
    my $file_rs = $self->_result->message;
    return unless $file_rs;
    return Koha::Edifact::File->_new_from_dbic($file_rs);
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Edifact::File::Error object
on the API.

=cut

sub to_api_mapping {
    return {
        message_id => 'file_id',
    };
}

=head2 Internal methods

=head3 _type

Returns name of corresponding DBIC resultset

=cut

sub _type {
    return 'EdifactError';
}

=head1 AUTHOR

Martin Renvoize <martin.renvoize@ptfs-europe.com>

Koha Development Team

=cut

1;
