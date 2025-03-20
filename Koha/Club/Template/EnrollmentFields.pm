package Koha::Club::Template::EnrollmentFields;

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

use Koha::Club::Template::EnrollmentField;

use base qw(Koha::Objects);

=head1 NAME

Koha::Club::Template::EnrollemntFields

Represents a collection of club fields that are only set at the time a patron is enrolled

=head1 API

=head2 Class Methods

=cut

=head3 type

=cut

sub _type {
    return 'ClubTemplateEnrollmentField';
}

=head2 object_class

Missing POD for object_class.

=cut

sub object_class {
    return 'Koha::Club::Template::EnrollmentField';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
