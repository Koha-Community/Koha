package Koha::ClassSource;

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

use Koha::Caches;
use Koha::Database;

use base qw(Koha::Object);

=head1 NAME

Koha::ClassSource - Koha Classfication Source Object class

=head1 API

=head2 Class Methods

=head3 store

ClassSource specific store to ensure relevant caches are flushed on change

=cut

sub store {
    my ($self) = @_;

    my $flush = 0;

    if ( !$self->in_storage ) {
        $flush = 1;
    }
    else {
        my $self_from_storage = $self->get_from_storage;
        $flush = 1 if ( $self_from_storage->description ne $self->description );
    }

    $self = $self->SUPER::store;

    if ($flush) {
        my $cache = Koha::Caches->get_instance();
        $cache->clear_from_cache('cn)sources:description');
    }

    return $self;
}

=head3 _type

Returns name of corresponding DBIC resultset

=cut

sub _type {
    return 'ClassSource';
}

1;
