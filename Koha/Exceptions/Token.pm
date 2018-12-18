package Koha::Exceptions::Token;

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

use Exception::Class (
    'Koha::Exceptions::Token' => {
        description => 'Something went wrong!',
    },
    'Koha::Exceptions::Token::BadPattern' => {
        isa => 'Koha::Exceptions::Token',
        description => 'Bad pattern for random token generation'
    },
);

=head1 NAME

Koha::Exceptions::Token - Base class for Token exceptions

=head1 Exceptions

=head2 Koha::Exceptions::Token

Generic Token exception

=head2 Koha::Exceptions::Token::BadPattern

Exception to be used when an non-valid pattern is entered for generation random token.

=cut

1;
