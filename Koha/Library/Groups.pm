package Koha::Library::Groups;

# Copyright ByWater Solutions 2016
#
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

use Carp;

use Koha::Database;

use Koha::Library::Group;

use base qw(Koha::Objects);

=head1 NAME

Koha::Library::Groups - Koha Library::Group object set class

=head1 API

=head2 Class Methods

=head3 get_root_groups

my @root_groups = $self->get_root_group()

=cut

sub get_root_groups {
    my ( $self ) = @_;

    return $self->search( { parent_id => undef }, { order_by => 'title' } );
}

=head3 get_search_groups

my @search_groups = $self->get_search_groups({[interface => 'staff' || 'opac']}))

Returns search groups for the specified interface.
Defaults to OPAC if no interface is specified.

=cut

sub get_search_groups {
    my ( $self, $params ) = @_;
    my $interface = $params->{interface} || q{};

    my $title = $interface eq 'staff' ? '__SEARCH_GROUPS__' : '__SEARCH_GROUPS_OPAC__';

    my ($search_groups_root) =
      $self->search( { parent_id => undef, title => $title } );

    return unless $search_groups_root;

    my $children = $search_groups_root->children();

    return wantarray ? $children->as_list : $children;
}

=head3 type

=cut

sub _type {
    return 'LibraryGroup';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Library::Group';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
