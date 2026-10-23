package Koha::Object::Limit::LibraryGroup;

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

=head1 NAME

Koha::Object::Limit::LibraryGroup - Generic library group limit handling class

=head1 SYNOPSIS

    use base qw(Koha::Object Koha::Object::Limit::LibraryGroup);
    my $object = Koha::Object->new({ property1 => $property1, property2 => $property2, etc... } );

=head1 DESCRIPTION

This class is provided as a generic way of handling library group limits for
Koha::Object-based classes in Koha.

This class must always be subclassed .

=head1 API

=head2 Class Methods

=cut

=head3 library_group_limits

my $limits = $object->library_group_limits();

Returns an array reference of Koha::Library::Group objects representing the
current library group limits: the root library groups that have the feature
column enabled and contain at least one of the limited libraries, at any
depth. A library group is the whole tree under such a root. Returns an empty
array reference if no limits are defined.

=cut

sub library_group_limits {
    my ($self) = @_;

    my @branchcodes = @{ $self->_library_group_limit_branchcodes };

    return [] unless @branchcodes;

    require Koha::Library::Groups;

    my $ft_column = $self->_library_group_limits->{group};

    my %seen;
    my @roots =
        grep { $_->$ft_column }
        grep { !$seen{ $_->id }++ }
        map  { Koha::Library::Groups->get_root_ancestor( { id => $_->id } ) }
        Koha::Library::Groups->search( { branchcode => { '-in' => \@branchcodes } } )->as_list;

    return \@roots;
}

=head3 ungrouped_library_limits

my $libraries = $object->ungrouped_library_limits();

Returns an array reference of Koha::Library objects for the library limits
that are not members of any group returned by C<library_group_limits>. Each
of these libraries is enforced as a group of one. Returns an empty array
reference if there are none.

=cut

sub ungrouped_library_limits {
    my ($self) = @_;

    my @branchcodes = @{ $self->_library_group_limit_branchcodes };

    return [] unless @branchcodes;

    my %grouped =
        map { $_->branchcode => 1 }
        map { $_->all_libraries } @{ $self->library_group_limits };

    my @ungrouped = grep { !$grouped{$_} } @branchcodes;

    return [] unless @ungrouped;

    require Koha::Libraries;

    return [
        Koha::Libraries->search(
            { branchcode => { '-in' => \@ungrouped } },
            { order_by   => 'branchname' }
        )->as_list
    ];
}

=head3 library_group_limit_branchcodes

my $branchcodes = $object->library_group_limit_branchcodes();

Returns an array reference of every branchcode the library group limits
resolve to: the branchcodes stored as limits plus every library in the
groups returned by C<library_group_limits>. Returns an empty array reference
if no limits are defined. Use this for access checks.

=cut

sub library_group_limit_branchcodes {
    my ($self) = @_;

    my @branchcodes = @{ $self->_library_group_limit_branchcodes };

    return [] unless @branchcodes;

    my %seen;
    my @all =
        grep { !$seen{$_}++ }
        ( @branchcodes, map { $_->branchcode } map { $_->all_libraries } @{ $self->library_group_limits } );

    return \@all;
}

=head3 _library_group_limit_branchcodes

Returns an array reference of the branchcodes stored in the limitation table
for this object.

=cut

sub _library_group_limit_branchcodes {
    my ($self) = @_;

    my @branchcodes =
        $self->_library_group_limit_rs->search( { $self->_library_group_limits->{id} => $self->id } )
        ->get_column( $self->_library_group_limits->{library} )
        ->all();

    return \@branchcodes;
}

=head3 _library_group_limit_rs

Returns the internal resultset for the group limitation table.

=cut

sub _library_group_limit_rs {
    my ($self) = @_;
    return Koha::Database->new->schema->resultset( $self->_library_group_limits->{class} );
}

1;
