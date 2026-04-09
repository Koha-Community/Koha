package Koha::Calendar::SingleClosure;

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

use Koha::Caches;
use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::Calendar::SingleClosure - Koha single-date closure Object class

=head1 API

=head2 Class methods

=head3 store

Overloaded store method that clears the holidays cache on insert.

Only flushes on insert (new closure), not on title/description updates,
because the holidays cache only stores dates and their open/closed status.

=cut

sub store {
    my ($self) = @_;

    my $flush = !$self->in_storage;

    $self = $self->SUPER::store;

    if ($flush) {
        Koha::Caches->get_instance()->clear_from_cache( $self->library_id . '_holidays' );
    }

    return $self;
}

=head3 delete

Overloaded delete method that clears the holidays cache.

=cut

sub delete {
    my ($self) = @_;
    my $library_id = $self->library_id;
    $self->SUPER::delete;
    Koha::Caches->get_instance()->clear_from_cache( $library_id . '_holidays' );
    return $self;
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'LibrarySingleClosure';
}

1;
