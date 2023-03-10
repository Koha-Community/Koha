package Koha::Localization;

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

use base qw(Koha::Object);

my $cache = Koha::Caches->get_instance();

=head1 NAME

Koha::Localization - Koha Localization type Object class

=head1 API

=head2 Class methods

=cut

=head3 store

Localization specific store to ensure relevant caches are flushed on change

=cut

sub store {
    my ($self) = @_;
    $self = $self->SUPER::store;

    if ($self->entity eq 'itemtypes') {
        my $key = "itemtype:description:".$self->lang;
        $cache->clear_from_cache($key);
    }

    return $self;
}

=head2 delete

Localization specific C<delete> to clear relevant caches on delete.

=cut

sub delete {
    my $self = shift @_;
    if ($self->entity eq 'itemtypes') {
        my $key = "itemtype:description:".$self->lang;
        $cache->clear_from_cache($key);
    }
    $self->SUPER::delete(@_);
}

sub _type {
    return 'Localization';
}

1;
