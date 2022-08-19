package Koha::Virtualshelves;

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

use Koha::Patrons;
use Koha::Virtualshelf;


use base qw(Koha::Objects);

=head1 NAME

Koha::Virtualshelf - Koha Virtualshelf Object class

=head1 API

=head2 Class methods

=head3 disown_or_delete

    $lists->disown_or_delete;

This method will transfer public/shared lists to the appropriate patron or
just delete them if not possible.

=cut

sub disown_or_delete {
    my ($self) = @_;

    $self->_resultset->result_source->schema->txn_do(
        sub {
            if ( C4::Context->preference('ListOwnershipUponPatronDeletion') eq 'transfer' ) {
                my $new_owner;

                $new_owner = C4::Context->preference('ListOwnerDesignated')
                  if C4::Context->preference('ListOwnerDesignated')
                  and Koha::Patrons->find( C4::Context->preference('ListOwnerDesignated') );

                if( !$new_owner && C4::Context->userenv ) {
                    $new_owner = C4::Context->userenv->{number};
                }

                while ( my $list = $self->next ) {
                    if ( $new_owner && ( $list->is_public or $list->is_shared ) ) {
                        $list->transfer_ownership($new_owner);
                    } else {
                        $list->delete;
                    }
                }
            } else {    # 'delete'
                $_->delete for $self->as_list;
            }
        }
    );

    return $self;
}

=head3 get_private_shelves

=cut

sub get_private_shelves {
    my ( $self, $params ) = @_;
    my $page = $params->{page};
    my $rows = $params->{rows};
    my $borrowernumber = $params->{borrowernumber} || 0;

    $self->search(
        {
            public => 0,
            -or => {
                'virtualshelfshares.borrowernumber' => $borrowernumber,
                'me.owner' => $borrowernumber,
            }
        },
        {
            join => [ 'virtualshelfshares' ],
            distinct => 'shelfnumber',
            order_by => 'shelfname',
            ( ( $page and $rows ) ? ( page => $page, rows => $rows ) : () ),
        }
    );
}

=head3 get_public_shelves

=cut

sub get_public_shelves {
    my ( $self, $params ) = @_;
    my $page = $params->{page};
    my $rows = $params->{rows};

    $self->search(
        {
            public => 1,
        },
        {
            distinct => 'shelfnumber',
            order_by => 'shelfname',
            ( ( $page and $rows ) ? ( page => $page, rows => $rows ) : () ),
        }
    );
}

=head3 get_some_shelves

=cut

sub get_some_shelves {
    my ( $self, $params ) = @_;
    my $borrowernumber = $params->{borrowernumber} || 0;
    my $public = $params->{public} || 0;
    my $add_allowed = $params->{add_allowed};

    my @conditions;
    my $patron;
    my $staffuser = 0;
    my $permitteduser = 0;
    if ( $borrowernumber != 0 ) {
        $patron = Koha::Patrons->find( $borrowernumber );
        $staffuser = $patron->can_patron_change_staff_only_lists;
        $permitteduser = $patron->can_patron_change_permitted_staff_lists;
    }
    if ( $add_allowed ) {
        if ( $permitteduser ) {
            push @conditions, {
                -or =>
                [
                    {
                        "me.owner" => $borrowernumber,
                        "me.allow_change_from_owner" => 1,
                    },
                    "me.allow_change_from_others"          => 1,
                    "me.allow_change_from_staff"           => 1,
                    "me.allow_change_from_permitted_staff" => 1
                ]
            };
        } elsif ( $staffuser ) {
            push @conditions, {
                -or =>
                [
                    {
                        "me.owner" => $borrowernumber,
                        "me.allow_change_from_owner" => 1,
                    },
                    "me.allow_change_from_others"          => 1,
                    "me.allow_change_from_staff"           => 1
                ]
            };
        } else {
            push @conditions, {
                -or =>
                [
                    {
                        "me.owner" => $borrowernumber,
                        "me.allow_change_from_owner" => 1,
                    },
                    "me.allow_change_from_others" => 1,
                ]
            };
        }
    }
    if ( !$public ) {
        push @conditions, {
            -or =>
            {
                "virtualshelfshares.borrowernumber" => $borrowernumber,
                "me.owner" => $borrowernumber,
            }
        };
    }

    $self->search(
        {
            public => $public,
            ( @conditions ? ( -and => \@conditions ) : () ),
        },
        {
            join => [ 'virtualshelfshares' ],
            distinct => 'shelfnumber',
            order_by => { -desc => 'lastmodified' },
        }
    );
}

=head3 get_shelves_containing_record

=cut

sub get_shelves_containing_record {
    my ( $self, $params ) = @_;
    my $borrowernumber = $params->{borrowernumber};
    my $biblionumber   = $params->{biblionumber};

    my @conditions = ( 'virtualshelfcontents.biblionumber' => $biblionumber );
    if ($borrowernumber) {
        push @conditions,
          {
              -or => [
                {
                    public => 0,
                    -or      => {
                        'me.owner' => $borrowernumber,
                        -or        => {
                            'virtualshelfshares.borrowernumber' => $borrowernumber,
                        },
                    }
                },
                { public => 1 },
            ]
          };
    } else {
        push @conditions, { public => 1 };
    }

    return Koha::Virtualshelves->search(
        {
            -and => \@conditions
        },
        {
            join     => [ 'virtualshelfcontents', 'virtualshelfshares' ],
            distinct => 'shelfnumber',
            order_by => { -asc => 'shelfname' },
        }
    );
}

=head3 _type

=cut

sub _type {
    return 'Virtualshelve';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::Virtualshelf';
}

1;
