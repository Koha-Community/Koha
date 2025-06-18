package Koha::Club::Template::Fields;

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

use Koha::Club::Template::Field;

use base qw(Koha::Objects);

=head1 NAME

Koha::Club::Template::Fields

Represents a collection of club fields that are set when the club is created

=head1 API

=head2 Class Methods

=cut

=head3 type

=cut

sub _type {
    return 'ClubTemplateField';
}

=head2 object_class

Missing POD for object_class.

=cut

sub object_class {
    return 'Koha::Club::Template::Field';
}

=head1 AUTHOR

Kyle M Hall <kyle@bywatersolutions.com>

=cut

1;
