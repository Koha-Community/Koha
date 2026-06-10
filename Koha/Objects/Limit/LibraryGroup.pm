package Koha::Objects::Limit::LibraryGroup;

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

use C4::Context;
use Koha::Database;

=head1 NAME

Koha::Objects::Limit::LibraryGroup - Generic library group limit handling class

=head1 SYNOPSIS

    use base qw(Koha::Objects Koha::Objects::Limit::LibraryGroup);
    my $objects = Koha::Objects->search_with_library_group_limits(
        $params, $attributes, $library_id, $ft_column
    );

=head1 DESCRIPTION

This class is provided as a generic way of handling library group limits for
Koha::Objects-based classes in Koha.

This class must always be subclassed. The object class must implement
C<_library_limits()> (from L<Koha::Object::Limit::Library>) as this method
reuses the same junction table but expands the branchcode match to all
libraries in the user's qualifying groups. A new C<_library_group_limits()>
method unwraps that information and also provides the 'C <ft_*> property
that the groups should be identified by.

=head1 API

=head2 Class methods

=cut

=head3 search_with_library_group_limits

my $results = $objects->search_with_library_group_limits(
    $params, $attributes, $library_id, $ft_column
);

Searches objects respecting library group limits. For the given C<$library_id>
(defaults to the logged-in user's branch), finds all library groups where
C<$ft_column> is enabled on the root group and the user's library is a member,
then returns objects whose junction-table entry matches any branchcode in those
groups (or has no limit at all).

C<$ft_column> must be the name of an C<ft_*> boolean column on the
C<library_groups> table (e.g. C<'ft_limit_reports'>).

=cut

sub search_with_library_group_limits {
    my ( $self, $params, $attributes, $library_id, $ft_column ) = @_;

    $library_id //= C4::Context->userenv->{branch}
        if defined C4::Context->userenv;

    return $self->search( $params, $attributes ) unless $library_id;

    require Koha::Library::Groups;

    # Find all library groups that have $ft_column enabled on the root group
    # and contain the user's library, then collect every branchcode in those groups.
    my @accessible_branchcodes = ($library_id);
    my $lib_nodes              = Koha::Library::Groups->search( { branchcode => $library_id } );

    for my $lib_node ( $lib_nodes->as_list ) {
        my $root = Koha::Library::Groups->get_root_ancestor( { id => $lib_node->id } );
        next unless $root->$ft_column;
        my $parent = $lib_node->parent;
        push @accessible_branchcodes,
            map { $_->branchcode } $parent->all_libraries;
    }

    return $self->search( $params, $attributes ) unless @accessible_branchcodes;

    my $library_limits       = $self->object_class()->_library_limits;
    my $library_limits_table = Koha::Database->new->schema->resultset( $library_limits->{class} )->result_source->name;
    my $library_field        = $library_limits->{library};

    my $where = {
        '-or' => [
            "$library_limits_table.$library_field" => undef,
            "$library_limits_table.$library_field" => { '-in' => \@accessible_branchcodes },
        ]
    };

    $params     //= {};
    $attributes //= {};
    if ( exists $attributes->{join} ) {
        if ( ref $attributes->{join} eq 'ARRAY' ) {
            push @{ $attributes->{join} }, $library_limits_table;
        } else {
            $attributes->{join} = [ $attributes->{join}, $library_limits_table ];
        }
    } else {
        $attributes->{join} = $library_limits_table;
    }
    $attributes->{distinct} = 1;
    return $self->search( { %$params, %$where }, $attributes );
}

1;
