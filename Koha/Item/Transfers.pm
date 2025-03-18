package Koha::Item::Transfers;

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

use Koha::Item::Transfer;

use base qw(Koha::Objects);

=head1 NAME

Koha::Item::Transfers - Koha Item Transfer Object set class

=head1 API

=head2 Class methods

=head3 filter_by_current

    my $current_transfers = $transfers->filter_by_current;

Filters out completed transfers from the resultset.

=cut

sub filter_by_current {
    my ($self) = @_;

    return $self->search(
        {
            datearrived   => undef,
            datecancelled => undef,
        }
    );
}

=head3 type

=cut

sub _type {
    return 'Branchtransfer';
}

=head2 object_class

Missing POD for object_class.

=cut

sub object_class {
    return 'Koha::Item::Transfer';
}

1;
