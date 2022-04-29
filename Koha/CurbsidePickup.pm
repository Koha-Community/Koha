package Koha::CurbsidePickup;

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

use base qw(Koha::Object);

use Koha::Patron;
use Koha::Library;
use Koha::CurbsidePickupIssues;

=head1 NAME

Koha::CurbsidePickup - Koha Curbside Pickup Object class

=head1 API

=head2 Class methods

=head3 checkouts

Return the checkouts linked to this pickup

=cut

sub checkouts {
    my ( $self ) = @_;

    my @pi = Koha::CurbsidePickupIssues->search({ curbside_pickup_id => $self->id })->as_list;

    my @checkouts = map { $_->checkout } @pi;
    @checkouts = grep { defined $_ } @checkouts;

    return @checkouts;
}

=head3 patron

Return the patron linked to this pickup

=cut

sub patron {
    my ( $self ) = @_;
    my $rs = $self->_result->borrowernumber;
    return unless $rs;
    return Koha::Patron->_new_from_dbic( $rs );
}

=head3 staged_by_staff

Return the staff member that staged this pickup

=cut

sub staged_by_staff {
    my ( $self ) = @_;
    my $rs = $self->_result->staged_by;
    return unless $rs;
    return Koha::Patron->_new_from_dbic( $rs );
}

=head3 library

Return the branch associated with this pickup

=cut

sub library {
    my ( $self ) = @_;
    my $rs = $self->_result->branchcode;
    return unless $rs;
    return Koha::Library->_new_from_dbic( $rs );
}

=head2 Internal methods

=head3 _type

=cut

sub _type {
    return 'CurbsidePickup';
}

1;
