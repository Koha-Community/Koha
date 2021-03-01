package Koha::HoldGroup;

# Copyright 2020 Koha Development team
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

use Modern::Perl;

use base qw(Koha::Object);

=head1 NAME

Koha::HoldGroup - Koha Hold Group object class

=head1 API

=head2 Class Methods

=cut

=head3 holds

    $holds = $hold_group->holds

Return all holds associated with this group

=cut

sub holds {
    my ($self) = @_;

    my $holds_rs = $self->_result->reserves->search;
    return Koha::Holds->_new_from_dbic($holds_rs);
}

=head3 _type

=cut

sub _type {
    return 'HoldGroup';
}

=head1 AUTHORS

Josef Moravec <josef.moravec@gmail.com>

=cut

1;
