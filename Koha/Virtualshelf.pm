package Koha::Virtualshelf;

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

use C4::Auth;

use Koha::Patrons;
use Koha::Database;
use Koha::DateUtils qw( dt_from_string );
use Koha::Exceptions;
use Koha::Exceptions::Virtualshelf;
use Koha::Virtualshelfshare;
use Koha::Virtualshelfshares;
use Koha::Virtualshelfcontent;
use Koha::Virtualshelfcontents;

use base qw(Koha::Object);

=head1 NAME

Koha::Virtualshelf - Koha Virtualshelf Object class

=head1 API

=head2 Class methods

=cut

=head2 store

Missing POD for store.

=cut

sub store {
    my ($self) = @_;

    unless ( $self->owner ) {
        Koha::Exceptions::Virtualshelf::UseDbAdminAccount->throw;
    }

    unless ( $self->is_shelfname_valid ) {
        Koha::Exceptions::Virtualshelf::DuplicateObject->throw;
    }

    $self->allow_change_from_owner(1)
        unless defined $self->allow_change_from_owner;
    $self->allow_change_from_others(0)
        unless defined $self->allow_change_from_others;
    $self->allow_change_from_staff(0)
        unless defined $self->allow_change_from_staff;
    $self->allow_change_from_permitted_staff(0)
        unless defined $self->allow_change_from_permitted_staff;

    $self->created_on(dt_from_string)
        unless defined $self->created_on;

    return $self->SUPER::store($self);
}

=head2 is_public

Missing POD for is_public.

=cut

sub is_public {
    my ($self) = @_;
    return $self->public;
}

=head2 is_private

Missing POD for is_private.

=cut

sub is_private {
    my ($self) = @_;
    return !$self->public;
}

=head2 is_shelfname_valid

Missing POD for is_shelfname_valid.

=cut

sub is_shelfname_valid {
    my ($self) = @_;

    my $conditions = {
        shelfname => $self->shelfname,
        ( $self->shelfnumber ? ( "me.shelfnumber" => { '!=', $self->shelfnumber } ) : () ),
    };

    if ( $self->is_private and defined $self->owner ) {
        $conditions->{-or} = {
            "virtualshelfshares.borrowernumber" => $self->owner,
            "me.owner"                          => $self->owner,
        };
        $conditions->{public} = 0;
    } elsif ( $self->is_private and not defined $self->owner ) {
        $conditions->{owner}  = undef;
        $conditions->{public} = 0;
    } else {
        $conditions->{public} = 1;
    }

    my $count = Koha::Virtualshelves->search(
        $conditions,
        {
            join => 'virtualshelfshares',
        }
    )->count;
    return $count ? 0 : 1;
}

=head2 get_shares

Missing POD for get_shares.

=cut

sub get_shares {
    my ($self) = @_;
    my $rs     = $self->_result->virtualshelfshares;
    my $shares = Koha::Virtualshelfshares->_new_from_dbic($rs);
    return $shares;
}

=head2 get_contents

Missing POD for get_contents.

=cut

sub get_contents {
    my ($self)   = @_;
    my $rs       = $self->_result->virtualshelfcontents;
    my $contents = Koha::Virtualshelfcontents->_new_from_dbic($rs);
    return $contents;
}

=head2 share

Missing POD for share.

=cut

sub share {
    my ( $self, $key ) = @_;
    unless ($key) {
        Koha::Exceptions::Virtualshelf::InvalidKeyOnSharing->throw;
    }
    Koha::Virtualshelfshare->new(
        {
            shelfnumber => $self->shelfnumber,
            invitekey   => $key,
            sharedate   => dt_from_string,
        }
    )->store;
}

=head2 is_shared

Missing POD for is_shared.

=cut

sub is_shared {
    my ($self) = @_;
    return $self->get_shares->search(
        {
            borrowernumber => { '!=' => undef },
        }
    )->count;
}

=head2 is_shared_with

Missing POD for is_shared_with.

=cut

sub is_shared_with {
    my ( $self, $borrowernumber ) = @_;
    return unless $borrowernumber;
    return $self->get_shares->search(
        {
            borrowernumber => $borrowernumber,
        }
    )->count;
}

=head2 remove_share

Missing POD for remove_share.

=cut

sub remove_share {
    my ( $self, $borrowernumber ) = @_;
    my $shelves = Koha::Virtualshelfshares->search(
        {
            shelfnumber    => $self->shelfnumber,
            borrowernumber => $borrowernumber,
        }
    );
    return 0 unless $shelves->count;

    # Only 1 share with 1 patron can exist
    return $shelves->next->delete;
}

=head2 add_biblio

Missing POD for add_biblio.

=cut

sub add_biblio {
    my ( $self, $biblionumber, $borrowernumber ) = @_;
    return unless $biblionumber;
    my $already_exists = $self->get_contents->search(
        {
            biblionumber => $biblionumber,
        }
    )->count;
    return if $already_exists;

    # Check permissions
    my $patron = Koha::Patrons->find($borrowernumber) or return 0;
    return 0
        unless ( $self->owner == $borrowernumber && $self->allow_change_from_owner )
        || ( $self->allow_change_from_staff           && $patron->can_patron_change_staff_only_lists )
        || ( $self->allow_change_from_permitted_staff && $patron->can_patron_change_permitted_staff_lists )
        || $self->allow_change_from_others;

    my $content = Koha::Virtualshelfcontent->new(
        {
            shelfnumber    => $self->shelfnumber,
            biblionumber   => $biblionumber,
            borrowernumber => $borrowernumber,
        }
    )->store;
    $self->lastmodified(dt_from_string);
    $self->store;

    return $content;
}

=head2 remove_biblios

Missing POD for remove_biblios.

=cut

sub remove_biblios {
    my ( $self, $params ) = @_;
    my $biblionumbers  = $params->{biblionumbers} || [];
    my $borrowernumber = $params->{borrowernumber};
    return unless @$biblionumbers;

    my $number_removed = 0;
    my $patron         = Koha::Patrons->find($borrowernumber) or return 0;
    if (   ( $self->owner == $borrowernumber && $self->allow_change_from_owner )
        || ( $self->allow_change_from_staff           && $patron->can_patron_change_staff_only_lists )
        || ( $self->allow_change_from_permitted_staff && $patron->can_patron_change_permitted_staff_lists )
        || $self->allow_change_from_others )
    {
        $number_removed += $self->get_contents->search(
            {
                biblionumber => $biblionumbers,
            }
        )->delete;
    }
    return $number_removed;
}

=head2 can_be_viewed

Missing POD for can_be_viewed.

=cut

sub can_be_viewed {
    my ( $self, $borrowernumber ) = @_;
    return 1 if $self->is_public;
    return 0 unless $borrowernumber;
    return 1 if $self->owner == $borrowernumber;
    return $self->get_shares->search(
        {
            borrowernumber => $borrowernumber,
        }
    )->count;
}

=head2 can_be_deleted

Missing POD for can_be_deleted.

=cut

sub can_be_deleted {
    my ( $self, $borrowernumber ) = @_;

    return 0 unless $borrowernumber;
    return 1 if $self->owner == $borrowernumber;

    my $patron = Koha::Patrons->find($borrowernumber) or return 0;

    return 1 if $self->is_public and C4::Auth::haspermission( $patron->userid, { lists => 'delete_public_lists' } );

    return 0;
}

=head2 can_be_managed

Missing POD for can_be_managed.

=cut

sub can_be_managed {
    my ( $self, $borrowernumber ) = @_;
    return 1
        if $borrowernumber and $self->owner == $borrowernumber;

    my $patron = Koha::Patrons->find($borrowernumber) or return 0;
    return 1
        if $self->is_public and C4::Auth::haspermission( $patron->userid, { lists => 'edit_public_lists' } );
    return 0;
}

=head2 can_biblios_be_added

Missing POD for can_biblios_be_added.

=cut

sub can_biblios_be_added {
    my ( $self, $borrowernumber ) = @_;

    my $patron = Koha::Patrons->find($borrowernumber) or return 0;
    return 1
        if $borrowernumber
        and ( ( $self->owner == $borrowernumber && $self->allow_change_from_owner )
        or ( $self->allow_change_from_staff           && $patron->can_patron_change_staff_only_lists )
        or ( $self->allow_change_from_permitted_staff && $patron->can_patron_change_permitted_staff_lists )
        or $self->allow_change_from_others )
        and ( ( $self->public && C4::Auth::haspermission( $patron->userid, { lists => 'edit_public_list_contents' } ) )
        or !$self->public );
    return 0;
}

=head2 can_biblios_be_removed

Missing POD for can_biblios_be_removed.

=cut

sub can_biblios_be_removed {
    my ( $self, $borrowernumber ) = @_;
    return $self->can_biblios_be_added($borrowernumber);

    # Same answer since bug 18228
}

=head3 cannot_be_transferred

    $shelf->cannot_be_transferred({
        by => $p1, to => $p2, interface => opac|intranet|undef,
            # p1 and p2 are borrowernumbers
    });

    This routine has two main goals:
    [1] Decide if patron may transfer a shared list to another
        sharee (patron).
    [2] Decide if staff member may transfer a public list.

    If you pass interface, we'll check if it supports transfer too.
    NOTE: The explicit passing is still more reliable than via context,
    since we could switch interface after login in the same session.

    Returns a true value (read: error_code) when not allowed.
    The following error codes are possible:
        unauthorized_transfer, missing_by_parameter, new_owner_not_found,
        new_owner_has_no_share, missing_to_parameter.
    Otherwise returns false (zero).

=cut

sub cannot_be_transferred {
    my ( $self, $params ) = @_;
    my $to        = $params->{to};
    my $by        = $params->{by};
    my $interface = $params->{interface};

    # Check on interface: currently we don't support transfer shared on intranet, transfer public on OPAC
    if ($interface) {
        return 'unauthorized_transfer'
            if ( $self->public && $interface eq 'opac' )
            or ( $self->is_private && $interface eq 'intranet' );

        # is_private call is enough here, get_shares tested below
    }

    my $shares = $self->public ? undef : $self->get_shares->search( { borrowernumber => { '!=' => undef } } );
    return 'unauthorized_transfer' if $self->is_private && !$shares->count;

    if ($by) {
        if ( $self->public ) {
            my $by_patron = Koha::Patrons->find($by);
            return 'unauthorized_transfer'
                if !$by_patron || !C4::Auth::haspermission( $by_patron->userid, { lists => 'edit_public_lists' } );
        } else {
            return 'unauthorized_transfer' if !$self->can_be_managed($by);
        }
    } else {
        return 'missing_by_parameter';
    }

    if ($to) {
        if ( !Koha::Patrons->find($to) ) {
            return 'new_owner_not_found';
        }
        my $to_patron = Koha::Patrons->find($to);

        if ( $self->public ) {
            return 'unauthorized_transfer'
                unless C4::Auth::haspermission(
                $to_patron->userid,
                {
                    lists => [
                        'create_public_lists', 'delete_public_lists', 'edit_public_list_contents', 'edit_public_lists'
                    ]
                }
                );
        }
        if ( !$self->public && !$shares->search( { borrowernumber => $to } )->count ) {
            return 'new_owner_has_no_share';
        }
    } else {
        return 'missing_to_parameter';
    }
    return 0;    # serving as green light
}

=head3 transfer_ownership

    $list->transfer_ownership( $patron_id );

This method transfers the list ownership to the passed I<$patron_id>.

=cut

sub transfer_ownership {
    my ( $self, $patron_id ) = @_;

    Koha::Exceptions::MissingParameter->throw("Mandatory parameter 'patron' missing")
        unless $patron_id;

    ## before we change the owner, collect some details
    my $old_owner  = Koha::Patrons->find( $self->owner );
    my $new_owner  = Koha::Patrons->find($patron_id);
    my $userenv    = C4::Context->userenv;
    my $branchcode = $userenv->{branch};

    ## first we change the owner
    $self->remove_share($patron_id) if $self->is_private;
    $self->set( { owner => $patron_id } )->store;

    ## now we message the new owner
    my $letter = C4::Letters::GetPreparedLetter(
        module      => 'lists',
        letter_code => 'TRANSFER_OWNERSHIP',
        branchcode  => $branchcode,
        lang        => $new_owner->lang || 'default',
        objects     => {
            old_owner => $old_owner,
            owner     => $new_owner,
            shelf     => $self,
        },
        want_librarian         => 1,
        message_transport_type => 'email',
    );

    if ($letter) {
        my $message_id = C4::Letters::EnqueueLetter(
            {
                letter                 => $letter,
                borrowernumber         => $patron_id,
                message_transport_type => 'email',
            }
        ) or warn "can't enqueue letter $letter";
    }

    return $self;
}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Virtualshelf object
on the API.

=cut

sub to_api_mapping {
    return {
        created_on   => 'creation_date',
        lastmodified => 'updated_on_date',
        owner        => 'owner_id',
        shelfname    => 'name',
        shelfnumber  => 'list_id',
        sortfield    => 'default_sort_field',
    };
}

=head3 public_read_list

This method returns the list of publicly readable database fields for both API and UI output purposes

=cut

sub public_read_list {
    return [
        'created_on',              'lastmodified', 'shelfname',
        'shelfnumber',             'public',       'sortfield',
        'allow_change_from_owner', 'allow_change_from_others'
    ];
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'Virtualshelve';
}

1;
