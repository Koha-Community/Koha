package Koha::Library::Calendar::WeeklyClosure;

# Copyright 2026 Theke Solutions
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
use Koha::Exceptions;

use base qw(Koha::Object);

=head1 NAME

Koha::Library::Calendar::WeeklyClosure - Koha weekly closure Object class

=head1 API

=head2 Class methods

=head3 store

Overloaded store method that validates weekday is in the range 0-6
(Sunday-Saturday) before storing.

=cut

sub store {
    my ($self) = @_;

    my $weekday = $self->weekday;
    Koha::Exceptions::BadParameter->throw(
        error     => "Invalid weekday: " . ( $weekday // 'undef' ) . " (must be 0-6)",
        parameter => 'weekday'
    ) unless defined($weekday) && $weekday =~ m/^[0-6]$/;

    return $self->SUPER::store;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'LibraryWeeklyClosure';
}

1;
