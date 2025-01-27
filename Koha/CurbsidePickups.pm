package Koha::CurbsidePickups;

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

use Carp;

use Koha::Database;
use Koha::DateUtils qw( dt_from_string );

use Koha::CurbsidePickup;

use base qw(Koha::Objects);

=head1 NAME

Koha::CurbsidePickups - Koha Curbside Pickup Object set class

=head1 API

=head2 Class Methods

=cut

=head3 filter_by_to_be_staged

Filter by pickups that have not been staged yet

=cut

sub filter_by_to_be_staged {
    my ($self) = @_;
    return $self->search( { staged_datetime => undef } );
}

=head3 filter_by_staged_and_ready

Filter by pickups that have been staged and are ready

=cut

sub filter_by_staged_and_ready {
    my ($self) = @_;
    return $self->search( { staged_datetime => { -not => undef }, arrival_datetime => undef } );
}

=head3 filter_by_patron_outside

Filter by pickups with patrons waiting outside

=cut

sub filter_by_patron_outside {
    my ($self) = @_;
    return $self->search( { arrival_datetime => { -not => undef }, delivered_datetime => undef } );
}

=head3 filter_by_delivered

Filter by pickups that have been delivered already

=cut

sub filter_by_delivered {
    my ($self) = @_;
    return $self->search( { delivered_datetime => { -not => undef } } );
}

=head3 filter_by_scheduled_today

Filter by pickups that are scheduled today

=cut

sub filter_by_scheduled_today {
    my ($self) = @_;
    my $dtf = Koha::Database->new->schema->storage->datetime_parser;
    return $self->search( { scheduled_pickup_datetime => { '>' => $dtf->format_date(dt_from_string) } } );
}

=head2 Internal Methods

=cut

=head3 _type

=cut

sub _type {
    return 'CurbsidePickup';
}

=head3 object_class

=cut

sub object_class {
    return 'Koha::CurbsidePickup';
}

1;
