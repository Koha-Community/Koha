package Koha::Object::Limit::Library;

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
use Koha::Exceptions;
use Koha::Libraries;

use Try::Tiny qw( catch try );

=head1 NAME

Koha::Object::Limit::Library - Generic library limit handling class

=head1 SYNOPSIS

    use base qw(Koha::Object Koha::Object::Limit::Library);
    my $object = Koha::Object->new({ property1 => $property1, property2 => $property2, etc... } );

=head1 DESCRIPTION

This class is provided as a generic way of handling library limits for Koha::Object-based classes
in Koha.

This class must always be subclassed.

=head1 API

=head2 Class Methods

=cut

=head3 library_limits

my $limits = $object->library_limits();

$object->library_limits( \@branchcodes );

Accessor method for library limits. When updating library limits, it accepts
a list of branchcodes. If requested to return the current library limits
it returns a Koha::Libraries object with the corresponding libraries.

=cut

sub library_limits {
    my ( $self, $branchcodes ) = @_;

    if ($branchcodes) {
        return $self->replace_library_limits($branchcodes);
    }
    else {
        return $self->get_library_limits();
    }
}

=head3 get_library_limits

my $limits = $object->get_library_limits();

Returns the current library limits in the form of a Koha::Libraries iterator object.
It returns undef if no library limits defined.

=cut

sub get_library_limits {
    my ($self) = @_;

    my @branchcodes
        = $self->_library_limit_rs->search(
        { $self->_library_limits->{id} => $self->id } )
        ->get_column( $self->_library_limits->{library} )->all();

    return unless @branchcodes;

    my $filter = [ map { { branchcode => $_ } } @branchcodes ];
    my $libraries = Koha::Libraries->search( $filter );

    return $libraries;
}

=head3 add_library_limit

$object->add_library_limit( $branchcode );

=cut

sub add_library_limit {
    my ( $self, $branchcode ) = @_;

    Koha::Exceptions::MissingParameter->throw(
        "Required parameter 'branchcode' missing")
        unless $branchcode;

    try {
        $self->_library_limit_rs->update_or_create(
            {   $self->_library_limits->{id}      => $self->id,
                $self->_library_limits->{library} => $branchcode
            }
        );
    }
    catch {
        Koha::Exceptions::CannotAddLibraryLimit->throw( $_->{msg} );
    };

    return $self;
}

=head3 del_library_limit

$object->del_library_limit( $branchcode );

=cut

sub del_library_limit {
    my ( $self, $branchcode ) = @_;

    Koha::Exceptions::MissingParameter->throw(
        "Required parameter 'branchcode' missing")
        unless $branchcode;

    my $limitation = $self->_library_limit_rs->search(
        {   $self->_library_limits->{id}      => $self->id,
            $self->_library_limits->{library} => $branchcode
        }
    );

    Koha::Exceptions::ObjectNotFound->throw(
              "No branch limit for branch $branchcode found for id "
            . $self->id
            . " to delete!" )
        unless ($limitation->count);

    return $limitation->delete();
}

=head3 replace_library_limits

$object->replace_library_limits( \@branchcodes );

=cut

sub replace_library_limits {
    my ( $self, $branchcodes ) = @_;

    $self->_result->result_source->schema->txn_do(
        sub {
            $self->_library_limit_rs->search(
                { $self->_library_limits->{id} => $self->id } )->delete;

            map { $self->add_library_limit($_) } @$branchcodes;
        }
    );

    return $self;
}


=head3 Koha::Objects->_library_limit_rs

Returns the internal resultset for the branch limitation table or creates it if undefined

=cut

sub _library_limit_rs {
    my ($self) = @_;
    return Koha::Database->new->schema->resultset( $self->_library_limits->{class} );
}

1;
