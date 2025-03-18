package Koha::Clubs;

# Copyright ByWater Solutions 2014
#
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
        my @enrollments = $borrower->get_club_enrollments->as_list;
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

    return $self->search( $params, { prefetch => 'club_template' } );
}

=head3 filter_out_empty

    my $filtered_rs = $clubs_rs->filter_out_empty;

Return a new I<Koha::Clubs> resultset, containing only clubs with current enrollments.

=cut

sub filter_out_empty {
    my ($self) = @_;
    return $self->search(
        {
            -and => [
                { 'club_enrollments.club_id'       => { '!=' => undef } },
                { 'club_enrollments.date_canceled' => undef },
            ]
        },
        {
            join     => 'club_enrollments',
            distinct => 1,
        }
    );
}

=head3 type

=cut

sub _type {
    return 'Club';
}

=head2 object_class

Missing POD for object_class.

=cut

sub object_class {
    return 'Koha::Club';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
