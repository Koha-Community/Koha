package Koha::Acquisition::Bookseller::Issue;

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

=head1 NAME

Koha::Acquisition::Bookseller::Issue - Koha Issue Object class

=head1 API

=head2 Class methods

=head3 strings_map

=cut

sub strings_map {
    my ( $self, $params ) = @_;

    my $strings = {};

    if ( defined $self->type ) {
        my $type_av_category = 'VENDOR_ISSUE_TYPE';
        my $av = Koha::AuthorisedValues->search(
            {
                category => $type_av_category,
                authorised_value => $self->type,
            }
        );

        my $type_str = $av->count
          ? $params->{public}
              ? $av->next->opac_description
              : $av->next->lib
          : $self->type;

        $strings->{type} = {
            category => 'VENDOR_ISSUE_TYPE',
            str      => $type_str,
            type     => 'av',
        };
    }

    return $strings;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'AqbooksellerIssue';
}

1;
