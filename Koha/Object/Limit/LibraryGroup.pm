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
current library group limits. Returns an empty array reference if no limits
are defined.

=cut

sub library_group_limits {
    my ($self) = @_;

    my @branchcodes =
        $self->_library_group_limit_rs->search( { $self->_library_group_limits->{id} => $self->id } )
        ->get_column( $self->_library_group_limits->{library} )
        ->all();

    return [] unless @branchcodes;

    require Koha::Library::Groups;

    my $ft_column = $self->_library_group_limits->{group};

    my %seen;
    my @parents =
        grep { !$seen{ $_->id }++ }
        grep { defined }
        map  { $_->parent } Koha::Library::Groups->search( { branchcode => { '-in' => \@branchcodes } } )->as_list;

    @parents = grep {
        my $root = Koha::Library::Groups->get_root_ancestor( { id => $_->id } );
        $root && $root->$ft_column;
    } @parents;

    return \@parents;
}

=head3 _library_group_limit_rs

Returns the internal resultset for the group limitation table.

=cut

sub _library_group_limit_rs {
    my ($self) = @_;
    return Koha::Database->new->schema->resultset( $self->_library_group_limits->{class} );
}

1;
