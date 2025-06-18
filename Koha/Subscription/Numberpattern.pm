package Koha::Subscription::Numberpattern;

# Copyright 2016 BibLibre Morgane Alonso
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

use Modern::Perl;
use Koha::Database;
use base qw(Koha::Object);

=head1 NAME

Koha::SubscriptionNumberpattern - Koha SubscriptionNumberpattern Object class

=head1 API

=head2 Class Methods

=cut

=head3 type

=cut

sub _type {
    return 'SubscriptionNumberpattern';
}

=head1 AUTHOR

Morgane Alonso <morgane.alonso@biblibre.com>

=cut

1;
