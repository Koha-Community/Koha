package Koha::Club::Template;

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
use Koha::Club::Template::EnrollmentFields;

use base qw(Koha::Object);

=head1 NAME

Koha::Club::Template

Represents a "pattern" on which many clubs can be created.
In this way we can directly compare different clubs of the same 'template'
for statistical purposes.

=head1 API

=head2 Class Methods

=cut

=head3 club_template_fields

=cut

sub club_template_fields {
    my ($self) = @_;

    return Koha::Club::Template::Fields->search( { club_template_id => $self->id() } );
}

=head2 club_template_enrollment_fields

Missing POD for club_template_enrollment_fields.

=cut

sub club_template_enrollment_fields {
    my ($self) = @_;

    return Koha::Club::Template::EnrollmentFields->search( { club_template_id => $self->id() } );
}

=head3 type

=cut

sub _type {
    return 'ClubTemplate';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
