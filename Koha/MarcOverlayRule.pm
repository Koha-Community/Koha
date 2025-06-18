package Koha::MarcOverlayRule;

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

use parent qw(Koha::Object);

use Koha::Caches;
my $cache = Koha::Caches->get_instance();

=head1 NAME

Koha::MarcOverlayRule - Koha MarcOverlayRule Object class

=cut

=head2 store

Override C<store> to clear marc merge rules cache.

=cut

sub store {
    my $self = shift @_;
    $cache->clear_from_cache('marc_overlay_rules');
    $self->SUPER::store(@_);
}

=head2 delete

Override C<delete> to clear marc merge rules cache.

=cut

sub delete {
    my $self = shift @_;
    $cache->clear_from_cache('marc_overlay_rules');
    $self->SUPER::delete(@_);
}

sub _type {
    return 'MarcOverlayRule';
}

1;
