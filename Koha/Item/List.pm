package Koha::Item::List;

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

use Koha::Exceptions::Item::List;
use Koha::Items;
use Koha::Item::ListContents;
use Koha::Item::ListShares;

use base qw(Koha::Object);

=head1 NAME

Koha::Item::List - Koha Item List object class

=head1 API

=head2 Class methods

=head3 store

Persist the object in the database.

=cut

sub store {
    my ($self) = @_;

    # Check for duplicates
    my $duplicates = Koha::Item::Lists->search(
        {
            name => $self->name,
            id   => { '!=' => $self->id }
        }
    );
    Koha::Exceptions::Item::List::DuplicateObject->throw if $duplicates->count;

    return $self->SUPER::store($self);
}

=head3 items

    my $items = $list->items;

Returns a resultset of Koha::Items representing the content of this item list.

=cut

sub items {
    my ($self) = @_;

    return Koha::Items->search(
        {
            'item_list_contents.item_list_id' => $self->id,
        },
        {
            join => 'item_list_contents',
        }
    );
}

=head3 add_item

    $list->add_item($itemnumber);

Adds a new Koha::Item to the item list by its itemnumber.

=cut

sub add_item {
    my ( $self, $itemnumber ) = @_;

    $self->item_list_contents->find_or_create( { itemnumber => $itemnumber } );
}

=head3 remove_item

    $list->remove_item($itemnumber);

Removes a new Koha::Item from the item list by its itemnumber.

=cut

sub remove_item {
    my ( $self, $itemnumber ) = @_;

    return $self->remove_items( [$itemnumber] );
}

=head3 remove_items

    $list->remove_items([100, 250, 310]);

Removes multiple Koha::Item objects from the item list by their itemnumbers.

=cut

sub remove_items {
    my ( $self, $itemnumbers ) = @_;

    my $contents = $self->item_list_contents->search( { itemnumber => { '-in' => $itemnumbers } } );

    return $contents->delete();
}

=head3 share

    $list->share({ borrowernumber => $borrowernumber, permission => 'edit' });

Shares the item list with a Koha::Patron, with a given permission ('view' or
'edit').

=cut

sub share {
    my ( $self, $params ) = @_;
    my $borrowernumber = $params->{borrowernumber} or return;
    my $permission     = $params->{permission}     or return;

    $self->item_list_shares->_resultset->update_or_create(
        {
            borrowernumber => $borrowernumber,
            permission     => $permission,
        }
    );
}

=head3 remove_share

    $list->remove_share($borrowernumber);

Stop sharing the item list with a Koha::Patron.

=cut

sub remove_share {
    my ( $self, $borrowernumber ) = @_;

    my $shares = $self->item_list_shares->search(
        {
            borrowernumber => $borrowernumber,
        }
    );

    return 0 unless $shares->count;
    return $shares->delete();
}

=head3 is_shared_with

    return unless $list->is_shared_with({ borrowernumber => $borrowernumber });
    return unless $list->is_shared_with({ borrowernumber => $borrowernumber, permission => 'edit' });

Returns whether the item list has been shared with the given patron. If
'permission' is specified, the share must be with that permission.

=cut

sub is_shared_with {
    my ( $self, $params ) = @_;
    my $borrowernumber = $params->{borrowernumber} or return;
    my $permission     = $params->{permission};

    my $rs = $self->item_list_shares->search( { borrowernumber => $borrowernumber } );
    if ($permission) {
        $rs = $rs->search(
            {
                permission => $permission,
            }
        );
    }

    return $rs->count();
}

=head3 can_be_read_by

    return unless $list->can_be_read_by($patron);

Returns whether the item list may be read by the given patron, accounting for
the list visibility, its shares, and the patron's permissions.

=cut

sub can_be_read_by {
    my ( $self, $patron ) = @_;
    return $self->_check_access( { patron => $patron } );
}

=head3 can_be_updated_by

    return unless $list->can_be_updated_by($patron);

Returns whether the item list may be updated by the given patron, accounting for
the list visibility, its shares, and the patron's permissions.

=cut

sub can_be_updated_by {
    my ( $self, $patron ) = @_;
    return $self->_check_access(
        {
            patron           => $patron,
            subpermission    => 'edit_item_lists',
            share_permission => 'edit'
        }
    );
}

=head3 can_be_deleted_by

    return unless $list->can_be_deleted_by($patron);

Returns whether the item list may be deleted by the given patron, accounting for
the list visibility, its shares, and the patron's permissions.

=cut

sub can_be_deleted_by {
    my ( $self, $patron ) = @_;
    return $self->_check_access(
        {
            patron           => $patron,
            subpermission    => 'delete_item_lists',
            share_permission => 'edit'
        }
    );
}

=head3 can_be_managed_by

    return unless $list->can_be_managed_by($patron);

Returns whether the item list's contents may be managed by the given patron,
accounting for the list visibility, its shares, and the patron's permissions.

=cut

sub can_be_managed_by {
    my ( $self, $patron ) = @_;
    return $self->_check_access(
        {
            patron           => $patron,
            subpermission    => 'manage_item_list_contents',
            share_permission => 'edit'
        }
    );
}

=head3 item_list_contents

    my $contents = $list->item_list_contents;

Returns a Koha::Item::ListContents representing the contents of this item list.

=cut

sub item_list_contents {
    my ($self)   = @_;
    my $rs       = $self->_result->related_resultset('item_list_contents');
    my $contents = Koha::Item::ListContents->_new_from_dbic($rs);
    return $contents;
}

=head3 item_list_shares

    my $shares = $list->item_list_shares;

Returns a Koha::Item::ListShares representing the shares of this item list.

=cut

sub item_list_shares {
    my ($self) = @_;
    my $rs = $self->_result->related_resultset('item_list_shares');
    return Koha::Item::ListShares->_new_from_dbic($rs);
}

=head3 to_api_mapping

Returns the mapping required to represent this object through the REST API.

=cut

sub to_api_mapping {
    return {
        created_on => 'created_date',
        updated_on => 'updated_date'
    };
}

=head3 to_api

Overloaded to_api method to add permission booleans

=cut

sub to_api {
    my ( $self, $params ) = @_;
    my $patron = $params->{user};

    my $response = $self->SUPER::to_api($params);

    if ($patron) {
        $response->{can_read}   = $self->can_be_read_by($patron);
        $response->{can_update} = $self->can_be_updated_by($patron);
        $response->{can_delete} = $self->can_be_deleted_by($patron);
        $response->{can_manage} = $self->can_be_managed_by($patron);
    }

    return $response;
}

=head2 Internal methods

=head3 _check_access

Helper method to check whether a patron has a specified level of access to an
item list, taking into account ownership, shares, and patron permissions.

Takes a HASHref with the following parameters:
    'patron': the patron the check the access for
    'subpermission' (optional): if specified, the item_lists subpermission required
        by the patron if they do not have explicit access through ownership or shares
    'share_permission': the required permission level of a share to grant this access
        ('view' or 'edit')

=cut

sub _check_access {
    my ( $self, $params ) = @_;
    my $patron           = $params->{patron};
    my $subpermission    = $params->{subpermission};
    my $share_permission = $params->{share_permission};

    my $borrowernumber = $patron->borrowernumber;

    # First, check for explicit access: either the list is unowned, we own it, or it
    # was explicitly shared with us.
    return 1
        if !defined( $self->owner )
        || $self->owner == $borrowernumber
        || $self->is_shared_with( { borrowernumber => $borrowernumber, permission => $share_permission } );

    # If it wasn't explicitly shared with us, check we have the relevant permission for
    # accessing lists implicitly.
    return 0
        unless !defined($subpermission) || $patron->has_permission( { item_lists => $subpermission } );

    my $branchcode = Koha::Patrons->find( $self->owner )->branchcode;

    # Check we can see it implicitly, either because it's public or because it's shared
    # within a group we have visibility into.
    return (
        $self->visibility eq 'group' && $patron->can_see_things_from(
            {
                branchcode    => $branchcode,
                permission    => 'superlibrarian',
                subpermission => '*'
            }
        )
    ) || $self->visibility eq 'public';
}

=head3 _type

The Result type of this object

=cut

sub _type {
    return 'ItemList';
}

1;
