package Koha::Biblio::ItemGroup::Item;

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

use base qw(Koha::Object);

use Koha::Biblio::ItemGroup;

=head1 NAME

Koha::Biblio::ItemGroup::Item - Koha ItemGroup Item Object class

=head1 API

=head2 Class methods

=head3 item_group

=cut

sub item_group {
    my ($self) = @_;
    my $rs = $self->_result->item_group;
    return Koha::Biblio::ItemGroup->_new_from_dbic($rs);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ItemGroupItem';
}

1;
