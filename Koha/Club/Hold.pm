package Koha::Club::Hold;

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
# along with Koha; if not, see <https://www.gnu.org/licenses>.

use Modern::Perl;

use Koha::Database;

use Koha::Club::Template::Fields;

use base qw(Koha::Object);
use Koha::Exceptions;
use Koha::Exceptions::ClubHold;
use Koha::Club::Hold::PatronHold;
use Koha::Club::Holds;
use Koha::Clubs;
use Koha::Patrons;

use List::Util qw( shuffle );

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
    my ($params) = @_;
    my $itemnumber = $params->{item_id};

    # check for mandatory params
    my @mandatory = ( 'biblio_id', 'club_id' );
    for my $param (@mandatory) {
        unless ( defined( $params->{$param} ) ) {
            Koha::Exceptions::MissingParameter->throw( error => "The $param parameter is mandatory" );
        }
    }

    my $club        = Koha::Clubs->find( $params->{club_id} );
    my @enrollments = $club->club_enrollments->as_list;

    Koha::Exceptions::ClubHold::NoPatrons->throw()
        unless scalar @enrollments;

    my $biblio = Koha::Biblios->find( $params->{biblio_id} );

    my $club_params = {
        club_id   => $params->{club_id},
        biblio_id => $params->{biblio_id},
        item_id   => $params->{item_id}
    };

    my $club_hold = Koha::Club::Hold->new($club_params)->store();
    $club_hold->discard_changes;

    @enrollments = shuffle(@enrollments);

    foreach my $enrollment (@enrollments) {
        my $patron_id = $enrollment->borrowernumber;
        my $pickup_id = $params->{pickup_library_id};

        my $can_place_hold;
        my $patron = Koha::Patrons->find($patron_id);
        my $item   = $itemnumber ? Koha::Items->find($itemnumber) : undef;
        if ( $params->{default_patron_home} ) {
            my $patron_home = $patron->branchcode;
            $can_place_hold =
                $itemnumber
                ? C4::Reserves::CanItemBeReserved( $patron, $item, $patron_home )
                : C4::Reserves::CanBookBeReserved( $patron_id, $params->{biblio_id}, $patron_home );
            $pickup_id = $patron_home if $can_place_hold->{status} eq 'OK';
            unless ( $can_place_hold->{status} eq 'OK' ) {
                warn "Patron("
                    . $patron_id
                    . ") Hold cannot be placed with patron's homebranch ($patron_home). Reason: "
                    . $can_place_hold->{status};
            }
        }

        unless ( defined $can_place_hold && $can_place_hold->{status} eq 'OK' ) {
            $can_place_hold =
                $itemnumber
                ? C4::Reserves::CanItemBeReserved( $patron, $item, $pickup_id )
                : C4::Reserves::CanBookBeReserved( $patron_id, $params->{biblio_id}, $pickup_id );
        }

        unless ( $can_place_hold->{status} eq 'OK' ) {
            warn "Patron(" . $patron_id . ") Hold cannot be placed. Reason: " . $can_place_hold->{status};
            Koha::Club::Hold::PatronHold->new(
                {
                    patron_id    => $patron_id,
                    club_hold_id => $club_hold->id,
                    error_code   => $can_place_hold->{status}
                }
            )->store();
            next;
        }

        my $priority = C4::Reserves::CalculatePriority( $params->{biblio_id} );

        my $hold_id = C4::Reserves::AddReserve(
            {
                branchcode      => $pickup_id,
                borrowernumber  => $patron_id,
                biblionumber    => $params->{biblio_id},
                priority        => $priority,
                expiration_date => $params->{expiration_date},
                notes           => $params->{notes},
                title           => $biblio->title,
                itemnumber      => $params->{item_id},
                found           => undef,                        # TODO: Why not?
                itemtype        => $params->{item_type},
            }
        );
        if ($hold_id) {
            Koha::Club::Hold::PatronHold->new(
                {
                    patron_id    => $patron_id,
                    club_hold_id => $club_hold->id,
                    hold_id      => $hold_id
                }
            )->store();
        } else {
            warn "Could not create hold for Patron(" . $patron_id . ")";
            Koha::Club::Hold::PatronHold->new(
                {
                    patron_id     => $patron_id,
                    club_hold_id  => $club_hold->id,
                    error_message => "Could not create hold for Patron(" . $patron_id . ")"
                }
            )->store();
        }
    }

    return $club_hold;

}

=head3 to_api_mapping

This method returns the mapping for representing a Koha::Club::Hold object
on the API.

=cut

sub to_api_mapping {
    return { id => 'club_hold_id' };
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
