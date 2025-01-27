package Koha::Course::Item;

# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 3 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use Modern::Perl;

use base qw(Koha::Object);

use Koha::Course::Reserves;

=head1 NAME

Koha::Course::Item - Koha Course Item Object class

=head1 API

=head2 Methods

=head3 is_enabled

=cut

sub is_enabled {
    my ($self) = @_;

    return $self->enabled eq 'yes';
}

=head3 course_reserves

=cut

sub course_reserves {
    my ($self) = @_;

    my $rs = $self->_result->course_reserves;
    return Koha::Course::Reserves->_new_from_dbic($rs);
}

=head3 item

=cut

sub item {
    my ($self) = @_;

    my $rs = $self->_result->itemnumber;
    return Koha::Item->_new_from_dbic($rs);
}

=head2 Internal methods

=cut

=head3 _type

=cut

sub _type {
    return 'CourseItem';
}

1;
