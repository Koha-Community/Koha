package Koha::Club::Enrollment;

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
use Koha::Clubs;
use Koha::Patrons;
use Koha::DateUtils qw( dt_from_string );
use DateTime;

use base qw(Koha::Object);

=head1 NAME

Koha::Club::Enrollment

Represents a "pattern" on which many clubs can be created.
In this way we can directly compare different clubs of the same 'template'
for statistical purposes.

=head1 API

=head2 Class Methods

=cut

=head3 cancel

=cut

sub cancel {
    my ($self) = @_;

    $self->_result()->update( { date_canceled => \'NOW()' } );

    return $self;
}

=head3 club

=cut

sub club {
    my ($self) = @_;
    return Koha::Clubs->find( $self->club_id() );
}

=head3 patron

=cut

sub patron {
    my ($self) = @_;
    return Koha::Patrons->find( $self->borrowernumber() );
}

=head3 is_canceled

Determines if enrollment is canceled

=cut

sub is_canceled {
    my ($self) = @_;

    return 0 unless $self->date_canceled;
    my $today         = dt_from_string;
    my $date_canceled = dt_from_string( $self->date_canceled );

    return DateTime->compare( $date_canceled, $today ) < 1;
}

=head3 type

=cut

sub _type {
    return 'ClubEnrollment';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
