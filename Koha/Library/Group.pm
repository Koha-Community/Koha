package Koha::Library::Group;

# Copyright ByWater Solutions 2016
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


use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Libraries;

use base qw(Koha::Object);

=head1 NAME

Koha::Library::Group - Koha Library::Group object class

=head1 API

=head2 Class methods

=cut

=head3 my @parent = $self->parent()

=cut

sub parent {
    my ($self) = @_;
    my $rs = $self->_result->parent;
    return unless $rs;
    return Koha::Library::Group->_new_from_dbic($rs);
}

=head3 my @children = $self->children()

=cut

sub children {
    my ($self) = @_;

    my $children =
      Koha::Library::Groups->search( { parent_id => $self->id }, { order_by => [ 'title', 'branchcode' ] } );

    return wantarray ? $children->as_list : $children;
}

=head3 has_child

my $has_child = $group->has_child( $branchcode );

Return true if the given branchcode library is a child of this group.

=cut

sub has_child {
    my ( $self, $branchcode ) = @_;
    return unless $branchcode; # Does not support group of libraries.
    return ( grep { $_ and $_ eq $branchcode }
          $self->children->get_column('branchcode') ) ? 1 : 0;
}

=head3 library

my $library = $group->library();

Returns the library for this group if one exists

=cut

sub library {
    my ($self) = @_;
    my $rs = $self->_result->branchcode;
    return unless $rs;
    return Koha::Library->_new_from_dbic($rs);
}

=head3 libraries

my $libraries = $group->libraries( { [invert => 1] } );

Returns the libraries set as direct children of this group.

If invert param is true, the returned list will be libraries
that are *not* direct children of this group.

=cut

sub libraries {
    my ($self, $params) = @_;
    my $invert = $params->{invert};

    my $in_or_not = $invert ? '-not_in' : '-in';

    my @branchcodes = Koha::Library::Groups->search(
        {
            parent_id  => $self->id,
            branchcode => { '!=' => undef },
        },
        { order_by => 'branchcode' }
    )->get_column('branchcode');

    return Koha::Libraries->search(
        {
            branchcode => { $in_or_not => \@branchcodes }
        },
        {
            order_by => 'branchname'
        }
    );
}

=head3 all_libraries

my @libraries = $group->all_libraries( { [invert => 1] } );

Returns the libraries set as children of this group or any subgroup.

=cut

sub all_libraries {
    my ( $self, $params ) = @_;

    my @libraries;

    push (@libraries, $self->libraries->as_list);
    my @children = $self->children->search({ branchcode => undef })->as_list;
    foreach my $c (@children) {
        push( @libraries, $c->all_libraries );
    }

    my %seen;
    @libraries =
      grep { !$seen{ $_->id }++ } @libraries;

    return @libraries;
}

=head3 libraries_not_direct_children

my $libraries = $group->libraries_not_direct_children();

Returns the libraries *not* set as direct children of this group

=cut

sub libraries_not_direct_children {
    my ($self) = @_;

    return $self->libraries( { invert => 1 } );
}

=head3 store

=cut

sub store {
    my ($self) = @_;

    $self->created_on( dt_from_string() ) unless $self->in_storage();

    return $self->SUPER::store(@_);
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'LibraryGroup';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
