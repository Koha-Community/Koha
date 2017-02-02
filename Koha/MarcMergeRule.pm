package Koha::MarcMergeRule;

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

use parent qw(Koha::Object);

my $cache = Koha::Caches->get_instance();

=head1 NAME

Koha::MarcMergeRule - Koha MarcMergeRule Object class

=cut

=head2 store

Override C<store> to clear marc merge rules cache.

=cut

sub store {
    my $self = shift @_;
    $cache->clear_from_cache('marc_merge_rules');
    $self->SUPER::store(@_);
}

=head2 delete

Override C<delete> to clear marc merge rules cache.

=cut

sub delete {
    my $self = shift @_;
    $cache->clear_from_cache('marc_merge_rules');
    $self->SUPER::delete(@_);
}

sub _type {
    return 'MarcMergeRule';
}

1;
