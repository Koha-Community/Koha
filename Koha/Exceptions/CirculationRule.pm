package Koha::Exceptions::CirculationRule;

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

use Koha::Exception;

use Exception::Class (
    'Koha::Exceptions::CirculationRule' => {
        isa => 'Koha::Exception',
    },
    'Koha::Exceptions::CirculationRule::NotDecimal' => {
        isa         => 'Koha::Exceptions::CirculationRule',
        description => "The circulation rule expected a decimal value",
        fields      => [ 'name', 'value' ],
    },
);

=head1 NAME

Koha::Exceptions::CirculationRule - Base class for CirculationRule exceptions

=head1 Exceptions

=head2 Koha::Exceptions::CirculationRule

Generic CirculationRule exception

=head2 Koha::Exceptions::CirculationRule::NotDecimal

Exception to be used when an attempt is made to insert a non-decimal value into
a monetary rule.

=cut

1;
