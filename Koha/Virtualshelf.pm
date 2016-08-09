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

use C4::Auth;

use Koha::Patrons;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions;
use Koha::Virtualshelfshare;
use Koha::Virtualshelfshares;
use Koha::Virtualshelfcontent;
use Koha::Virtualshelfcontents;

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

    unless ( $self->owner ) {
        Koha::Exceptions::Virtualshelves::UseDbAdminAccount->throw;
    }

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

sub get_shares {
    my ( $self ) = @_;
    my $rs = $self->{_result}->virtualshelfshares;
    my $shares = Koha::Virtualshelfshares->_new_from_dbic( $rs );
    return $shares;
}

sub get_contents {
    my ( $self ) = @_;
    my $rs = $self->{_result}->virtualshelfcontents;
    my $contents = Koha::Virtualshelfcontents->_new_from_dbic( $rs );
    return $contents;
}

sub share {
    my ( $self, $key ) = @_;
    unless ( $key ) {
        Koha::Exceptions::Virtualshelves::InvalidKeyOnSharing->throw;
    }
    Koha::Virtualshelfshare->new(
        {
            shelfnumber => $self->shelfnumber,
            invitekey => $key,
            sharedate => dt_from_string,
        }
    )->store;
}

sub is_shared {
    my ( $self ) = @_;
    return  $self->get_shares->search(
        {
            borrowernumber => { '!=' => undef },
        }
    )->count;
}

sub is_shared_with {
    my ( $self, $borrowernumber ) = @_;
    return unless $borrowernumber;
    return  $self->get_shares->search(
        {
            borrowernumber => $borrowernumber,
        }
    )->count;
}

sub remove_share {
    my ( $self, $borrowernumber ) = @_;
    my $shelves = Koha::Virtualshelfshares->search(
        {
            shelfnumber => $self->shelfnumber,
            borrowernumber => $borrowernumber,
        }
    );
    return 0 unless $shelves->count;

    # Only 1 share with 1 patron can exist
    return $shelves->next->delete;
}

sub add_biblio {
    my ( $self, $biblionumber, $borrowernumber ) = @_;
    return unless $biblionumber;
    my $already_exists = $self->get_contents->search(
        {
            biblionumber => $biblionumber,
        }
    )->count;
    return if $already_exists;
    my $content = Koha::Virtualshelfcontent->new(
        {
            shelfnumber => $self->shelfnumber,
            biblionumber => $biblionumber,
            borrowernumber => $borrowernumber,
        }
    )->store;
    $self->lastmodified(dt_from_string);
    $self->store;

    return $content;
}

sub remove_biblios {
    my ( $self, $params ) = @_;
    my $biblionumbers = $params->{biblionumbers} || [];
    my $borrowernumber = $params->{borrowernumber};
    return unless @$biblionumbers;

    my $number_removed = 0;
    for my $biblionumber ( @$biblionumbers ) {
        if ( $self->owner == $borrowernumber or $self->allow_delete_own ) {
            $number_removed += $self->get_contents->search(
                {
                    biblionumber => $biblionumber,
                    borrowernumber => $borrowernumber,
                }
            )->delete;
        }
        if ( $self->allow_delete_other ) {
            $number_removed += $self->get_contents->search(
                {
                    biblionumber => $biblionumber,
                    # FIXME
                    # This does not make sense, but it's has been backported from DelFromShelf.
                    # Why shouldn't we allow to remove his own contribution if allow_delete_other is on?
                    borrowernumber => {
                        -or => {
                            '!=' => $borrowernumber,
                            '=' => undef
                        }
                    },
                }
            )->delete;
        }
    }
    return $number_removed;
}

sub can_be_viewed {
    my ( $self, $borrowernumber ) = @_;
    return 1 if $self->category == $PUBLIC;
    return 0 unless $borrowernumber;
    return 1 if $self->owner == $borrowernumber;
    return $self->get_shares->search(
        {
            borrowernumber => $borrowernumber,
        }
    )->count;
}

sub can_be_deleted {
    my ( $self, $borrowernumber ) = @_;

    return 0 unless $borrowernumber;
    return 1 if $self->owner == $borrowernumber;

    my $patron = Koha::Patrons->find( $borrowernumber );

    return 1 if $self->category == $PUBLIC and C4::Auth::haspermission( $patron->userid, { lists => 'delete_public_lists' } );

    return 0;
}

sub can_be_managed {
    my ( $self, $borrowernumber ) = @_;
    return 1
      if $borrowernumber and $self->owner == $borrowernumber;
    return 0;
}

sub can_biblios_be_added {
    my ( $self, $borrowernumber ) = @_;

    return 1
      if $borrowernumber
      and ( $self->owner == $borrowernumber
         or $self->allow_add );
    return 0;
}

sub can_biblios_be_removed {
    my ( $self, $borrowernumber ) = @_;

    return 1
      if $borrowernumber
      and (  $self->owner == $borrowernumber
          or $self->allow_delete_own
          or $self->allow_delete_other );
    return 0;
}

sub _type {
    return 'Virtualshelve';
}

1;
