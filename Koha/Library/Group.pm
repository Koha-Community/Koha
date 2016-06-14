package Koha::Library::Group;

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
use Koha::DateUtils qw(dt_from_string);
use Koha::Libraries;

use base qw(Koha::Object);

=head1 NAME

Koha::Library::Group - Koha Library::Group object class

=head1 API

=head2 Class Methods

=cut

=head3 my @parent = $self->parent()

=cut

sub parent {
    my ($self) = @_;

    $self->{_parent} ||= Koha::Library::Groups->find( $self->parent_id );

    return $self->{_parent};
}

=head3 my @children = $self->children()

=cut

sub children {
    my ($self) = @_;

    my $children =
      Koha::Library::Groups->search( { parent_id => $self->id }, { order_by => [ 'title', 'branchcode' ] } );

    return $children;
}

=head3 library

my $library = $group->library();

Returns the library for this group if one exists

=cut

sub library {
    my ($self) = @_;

    return unless $self->branchcode;

    $self->{_library} ||= Koha::Libraries->find( $self->branchcode );

    return $self->{_library};
}

=head3 libraries_not_direct_children

my @libraries = $group->libraries_not_direct_children();

Returns the libraries *not* set as direct children of this group

=cut

sub libraries_not_direct_children {
    my ($self) = @_;

    my @children = Koha::Library::Groups->search(
        {
            parent_id  => $self->id,
            branchcode => { '!=' => undef },
        },
        { order_by => 'branchcode' }
    );

    my @branchcodes = map { $_->branchcode } @children;

    return Koha::Libraries->search(
        {
            branchcode => { -not_in => \@branchcodes }
        },
        {
            order_by => 'branchname'
        }
    );
}

=head3 store

=cut

sub store {
    my ($self) = @_;

    my $now = dt_from_string;
    $self->updated_on($now);
    $self->created_on($now) unless $self->in_storage();

    return $self->SUPER::store(@_);
}

=head3 type

=cut

sub _type {
    return 'LibraryGroup';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
