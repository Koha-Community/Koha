package Koha::Club;

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

use Koha::Club::Templates;
use Koha::Club::Fields;
use Koha::Libraries;

use base qw(Koha::Object);

=head1 NAME

Koha::Club - Koha Club Object class

=head1 API

=head2 Class Methods

=cut

=head3 club_template

=cut

sub club_template {
    my ($self) = @_;

    return unless $self->club_template_id();

    return Koha::Club::Templates->find( $self->club_template_id() );
}

=head3 club_fields

=cut

sub club_fields {
    my ($self) = @_;

    return unless $self->id();

    return Koha::Club::Fields->search( { club_id => $self->id() } );
}

=head3 club_enrollments

=cut

sub club_enrollments {
    my ($self) = @_;

    return unless $self->id();

    return Koha::Club::Enrollments->search( { club_id => $self->id(), date_canceled => undef } );
}

=head3 club_fields

=cut

=head2 branch

Missing POD for branch.

=cut

sub branch {
    my ($self) = @_;

    return unless $self->branchcode();

    return Koha::Libraries->find( $self->branchcode() );
}

=head3 type

=cut

sub _type {
    return 'Club';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
