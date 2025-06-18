package Koha::Objects::Limit::Library;

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

Koha::Objects::Limit::Library - Generic library limit handling class

=head1 SYNOPSIS

    use base qw(Koha::Objects Koha::Object::Limit::Library);
    my $objects = Koha::Objects->search_with_library_limits( $params, $attributes, $library_id );

=head1 DESCRIPTION

This class is provided as a generic way of handling library limits for Koha::Objects-based classes
in Koha.

This class must always be subclassed.

=head1 API

=head2 Class methods

=cut

=head3 search_with_library_limits

my $results = $objects->search_with_library_limits( $params, $attributes, $library_id );

Wrapper method for searching objects with library limits, respecting those
limits

=cut

sub search_with_library_limits {
    my ( $self, $params, $attributes, $library_id ) = @_;

    $library_id //= C4::Context->userenv->{branch}
        if defined C4::Context->userenv;

    return $self->search( $params, $attributes ) unless $library_id;

    my $library_limits       = $self->object_class()->_library_limits;
    my $library_limits_table = Koha::Database->new->schema->resultset( $library_limits->{class} )->result_source->name;
    my $library_field        = $library_limits->{library};

    my $where = {
        '-or' => [
            "$library_limits_table.$library_field" => undef,
            "$library_limits_table.$library_field" => $library_id,
        ]
    };

    $params     //= {};
    $attributes //= {};
    if ( exists $attributes->{join} ) {
        if ( ref $attributes->{join} eq 'ARRAY' ) {
            push @{ $attributes->{join} }, "$library_limits_table";
        } else {
            $attributes->{join} = [ $attributes->{join}, "$library_limits_table" ];
        }
    } else {
        $attributes->{join} = $library_limits_table;
    }

    return $self->search( { %$params, %$where, }, $attributes );
}

1;
