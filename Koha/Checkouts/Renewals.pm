package Koha::Checkouts::Renewals;

# Copyright PTFS Europe 2022
#
# This file is part of oha.
#
# oha is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# oha is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with oha; if not, see <http://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Database;

use Koha::Checkouts::Renewal;

use base qw(Koha::Objects);

=head1 NAME

Koha::Checkouts::Renewals - Koha Renewal object set class

=head1 API

=head2 Class Methods

=cut

=head3 type

=cut

sub _type {
    return 'CheckoutRenewal';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Checkouts::Renewal';
}

=head1 AUTHOR

Martin Renvoize <martin.renvoize@ptfs-europe.com>

=cut

1;
