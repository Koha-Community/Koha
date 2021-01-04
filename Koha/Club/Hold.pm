package Koha::Club::Hold;

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

use Koha::Club::Template::Fields;

use base qw(Koha::Object);
use Koha::Exceptions::ClubHold;
use Koha::Club::Hold::PatronHold;
use Koha::Clubs;

use List::Util 'shuffle';

=head1 NAME

Koha::Club::Hold

Represents a hold made for every member of club

=head1 API

=head2 Class methods

=cut

=head3 add

Class (static) method that returns a new Koha::Club::Hold instance

=cut

sub add {
    my ( $params ) = @_;

    Koha::Exceptions::ClubHold->throw()
        unless $params->{club_id} && $params->{biblio_id};

    my $club = Koha::Clubs->find($params->{club_id});
    my @enrollments = $club->club_enrollments->as_list;

    Koha::Exceptions::ClubHold::NoPatrons->throw()
        unless scalar @enrollments;

    my $biblio = Koha::Biblios->find($params->{biblio_id});

    my $club_params = {
        club_id   => $params->{club_id},
        biblio_id => $params->{biblio_id},
        item_id   => $params->{item_id}
    };

    my $club_hold = Koha::Club::Hold->new($club_params)->store();

    @enrollments = shuffle(@enrollments);

    foreach my $enrollment (@enrollments) {
        my $patron_id = $enrollment->borrowernumber;

        my $can_place_hold
        = $params->{item_id}
        ? C4::Reserves::CanItemBeReserved( $patron_id, $params->{club_id} )
        : C4::Reserves::CanBookBeReserved( $patron_id, $params->{biblio_id} );

        unless ( $can_place_hold->{status} eq 'OK' ) {
            warn "Patron(".$patron_id.") Hold cannot be placed. Reason: " . $can_place_hold->{status};
            Koha::Club::Hold::PatronHold->new({
                patron_id => $patron_id,
                club_hold_id => $club_hold->id,
                error_code => $can_place_hold->{status}
            })->store();
            next;
        }

        my $priority = C4::Reserves::CalculatePriority($params->{biblio_id});

        my $hold_id = C4::Reserves::AddReserve(
            $params->{pickup_library_id},
            $patron_id,
            $params->{biblio_id},
            undef,    # $bibitems param is unused
            $priority,
            undef,    # hold date, we don't allow it currently
            $params->{expiration_date},
            $params->{notes},
            $biblio->title,
            $params->{item_id},
            undef,    # TODO: Why not?
            $params->{item_type}
        );
        if ($hold_id) {
            Koha::Club::Hold::PatronHold->new({
                patron_id => $patron_id,
                club_hold_id => $club_hold->id,
                hold_id => $hold_id
            })->store();
        } else {
            warn "Could not create hold for Patron(".$patron_id.")";
            Koha::Club::Hold::PatronHold->new({
                patron_id => $patron_id,
                club_hold_id => $club_hold->id,
                error_message => "Could not create hold for Patron(".$patron_id.")"
            })->store();
        }

    }

    return $club_hold;

}


=head3 to_api_mapping

This method returns the mapping for representing a Koha::Club::Hold object
on the API.

=cut

sub to_api_mapping {
    return {
        id        => 'club_hold_id',
        club_id   => 'club_id',
        biblio_id => 'biblio_id',
        item_id   => 'item_id'
    };
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'ClubHold';
}

=head1 AUTHOR

Agustin Moyano <agustinmoyano@theke.io>

=cut

1;
