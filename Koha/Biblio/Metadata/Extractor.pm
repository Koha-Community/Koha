package Koha::Biblio::Metadata::Extractor;

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

Koha::Biblio::Metadata::Extractor - Extract specific metadata from MARC::Record objects

=cut

use Modern::Perl;

use Koha::Exceptions;
use Koha::Biblio::Metadata::Extractor::MARC;

=head1 API

=head2 Class methods

=head3 new

    my $extractor = Koha::Biblio::Metadata::Extractor->new({ biblio => $biblio });

Constructor for the I<Koha::Biblio::Metadata::Extractor> class.

=cut

sub new {
    my ( $class, $params ) = @_;

    # We only support MARC for now, no need to complexify here
    return Koha::Biblio::Metadata::Extractor::MARC->new($params);
}

=head1 AUTHOR

Tomas Cohen Arazi, E<lt>tomascohen@theke.ioE<gt>

Jonathan Druart, E<lt>jonathan.druart@bugs.koha-community.orgE<gt>

=cut

1;

__END__
