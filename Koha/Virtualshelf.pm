package Koha::Virtualshelf;

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
use Koha::DateUtils qw( dt_from_string );
use Koha::Exception::DuplicateObject;

use base qw(Koha::Object);

=head1 NAME

Koha::Virtualshelf - Koha Virtualshelf Object class

=head1 API

=head2 Class Methods

=cut

=head3 type

=cut

our $PRIVATE = 1;
our $PUBLIC = 2;

sub store {
    my ( $self ) = @_;

    unless ( $self->is_shelfname_valid ) {
        Koha::Exceptions::Virtualshelves::DuplicateObject->throw;
    }

    $self->allow_add( 0 )
        unless defined $self->allow_add;
    $self->allow_delete_own( 1 )
        unless defined $self->allow_delete_own;
    $self->allow_delete_other( 0 )
        unless defined $self->allow_delete_other;

    $self->created_on( dt_from_string );

    return $self->SUPER::store( $self );
}

sub is_shelfname_valid {
    my ( $self ) = @_;

    my $conditions = {
        shelfname => $self->shelfname,
        ( $self->shelfnumber ? ( "me.shelfnumber" => { '!=', $self->shelfnumber } ) : () ),
    };

    if ( $self->category == $PRIVATE and defined $self->owner ) {
        $conditions->{-or} = {
            "virtualshelfshares.borrowernumber" => $self->owner,
            "me.owner" => $self->owner,
        };
        $conditions->{category} = $PRIVATE;
    }
    elsif ( $self->category == $PRIVATE and not defined $self->owner ) {
        $conditions->{owner} = undef;
        $conditions->{category} = $PRIVATE;
    }
    else {
        $conditions->{category} = $PUBLIC;
    }

    my $count = Koha::Virtualshelves->search(
        $conditions,
        {
            join => 'virtualshelfshares',
        }
    )->count;
    return $count ? 0 : 1;
}

sub type {
    return 'Virtualshelve';
}

1;
