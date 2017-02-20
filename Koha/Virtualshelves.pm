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

use Koha::Virtualshelf;


use base qw(Koha::Objects);

=head1 NAME

Koha::Virtualshelf - Koha Virtualshelf Object class

=head1 API

=head2 Class Methods

=cut

=head3 type

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

sub get_some_shelves {
    my ( $self, $params ) = @_;
    my $borrowernumber = $params->{borrowernumber} || 0;
    my $public = $params->{public} || 0;
    my $add_allowed = $params->{add_allowed};

    my @conditions;
    my $patron;
    my $staffuser = 0;
    if ( $borrowernumber != 0 ) {
        $patron = Koha::Patrons->find( $borrowernumber );
        $staffuser = $patron->can_patron_change_staff_only_lists;
    }
    if ( $add_allowed ) {
        if ( $staffuser ) {
            push @conditions, {
                -or =>
                [
                    {
                        "me.owner" => $borrowernumber,
                        "me.allow_change_from_owner" => 1,
                    },
                    "me.allow_change_from_others" => 1,
                    "me.allow_change_from_staff"  => 1
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

sub get_shared_shelves {
    my ( $self, $params ) = @_;
    my $borrowernumber = $params->{borrowernumber} || 0;

    $self->search(
        {
            'me.owner' => $borrowernumber,
            'me.shelfnumber' => { -ident => 'virtualshelfshares.shelfnumber' }
        },
        { prefetch => 'virtualshelfshares' }
    );
}

sub _type {
    return 'Virtualshelve';
}

sub object_class {
    return 'Koha::Virtualshelf';
}

1;
