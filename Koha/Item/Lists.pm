package Koha::Item::Lists;

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

use Koha::Item::List;

use base qw(Koha::Objects);

=head1 NAME

Koha::Item::Lists - Koha Item List object set class

=head1 API

=head2 Class methods

=head3 get_readable_lists

    my $lists = Koha::Item::Lists->get_readable_lists($patron);

Returns a Koha::Item::Lists resultset containing the item lists a given patron
may read.

=cut

sub get_readable_lists {
    my ( $self, $patron ) = @_;

    return $self->_search_limited(
        {
            patron                  => $patron,
            share_permission        => [ 'view', 'edit' ],
            has_implicit_permission => 1,
        }
    );
}

=head3 get_manageable_lists

    my $lists = Koha::Item::Lists->get_manageable_lists($patron);

Returns a Koha::Item::Lists resultset containing the item lists a given patron
may manage.

=cut

sub get_manageable_lists {
    my ( $self, $patron ) = @_;

    return $self->_search_limited(
        {
            patron                  => $patron,
            share_permission        => 'edit',
            has_implicit_permission => $patron->has_permission( { item_lists => 'manage_item_list_contents' } ),
        }
    );
}

=head2 Internal methods

=head3 _search_limited

Helper method to limit searches according to list visibility, permissions, and
shares.

Takes a HASHref with the following parameters:
    'patron': the patron to check access against
    'share_permission': the DBIx WHERE values for relevant share permissions
    'has_implicit_permission': whether the patron can access lists implicitly
        shared via 'public' or 'group' visibility

=cut

sub _search_limited {
    my ( $self, $params ) = @_;
    my $patron                  = $params->{patron};
    my $share_permission        = $params->{share_permission};
    my $has_implicit_permission = $params->{has_implicit_permission};

    # group_filter handles the conditions for viewing a list shared within
    # a group. If we don't have the permission for implicit access, it
    # will always fail.
    my $group_filter = {
        'me.visibility' => ( $has_implicit_permission ? 'group' : [] ),
    };

    # If we have limited visibility into groups, add this restriction to
    # group_filter.
    my @allowed_branchcodes = $patron->libraries_where_can_see_things(
        {
            permission    => 'superlibrarian',
            subpermission => '*'
        }
    );
    $group_filter->{'owner.branchcode'} = \@allowed_branchcodes if @allowed_branchcodes;

    return $self->search(
        {
            '-or' => [

                # A public list we can implicitly see
                'me.visibility' => ( $has_implicit_permission ? 'public' : [] ),

                # A list that is unowned or belongs to us
                'me.owner' => [ $patron->borrowernumber, undef ],

                # A list shared with us at the required access level
                '-and' => {
                    'item_list_shares.borrowernumber' => $patron->borrowernumber,
                    'item_list_shares.permission'     => $share_permission,
                },

                # A list shared within a group we can implicitly see
                '-and' => $group_filter,
            ]
        },
        { join => [ 'owner', 'item_list_shares' ], order_by => 'me.name' }
    );
}

=head3 _type

The Result type of this object set.

=cut

sub _type {
    return 'ItemList';
}

=head3 object_class

The object class for this object set.

=cut

sub object_class {
    return 'Koha::Item::List';
}

1;
