package Koha::Clubs;

# Copyright ByWater Solutions 2014
#
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

use Koha::Club;

use base qw(Koha::Objects);

=head1 NAME

Koha::Clubs - Koha Clubs Object class

This object represents a collection of clubs a patron may enroll in.

=head1 API

=head2 Class Methods

=cut

=head3 get_enrollable

=cut

sub get_enrollable {
    my ( $self, $params ) = @_;

    # We need to filter out all the already enrolled in clubs
    my $borrower = $params->{borrower};
    if ($borrower) {
        delete( $params->{borrower} );
        my @enrollments = $borrower->get_club_enrollments();
        if (@enrollments) {
            $params->{'me.id'} = { -not_in => [ map { $_->club()->id() } @enrollments ] };
        }
    }

    my $dtf = Koha::Database->new->schema->storage->datetime_parser;

    # Only clubs with no end date or an end date in the future can be enrolled in
    $params->{'-and'} = [
        -or => [
            date_end => { '>=' => $dtf->format_datetime( dt_from_string() ) },
            date_end => undef,
        ],
        -or => [
            'me.branchcode' => $borrower->branchcode,
            'me.branchcode' => undef,
        ]
    ];

    my $rs = $self->_resultset()->search( $params, { prefetch => 'club_template' } );

    if (wantarray) {
        my $class = ref($self) ? ref($self) : $self;

        return $class->_wrap( $rs->all() );

    }
    else {
        my $class = ref($self) ? ref($self) : $self;

        return $class->_new_from_dbic($rs);
    }
}

=head3 type

=cut

sub _type {
    return 'Club';
}

sub object_class {
    return 'Koha::Club';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
