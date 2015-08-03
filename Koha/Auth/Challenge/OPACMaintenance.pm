package Koha::Auth::Challenge::OPACMaintenance;

# Copyright 2015 Vaara-kirjastot
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

use C4::Context;

use base qw(Koha::Auth::Challenge);

use Koha::Exception::ServiceTemporarilyUnavailable;

=head challenge
STATIC

    Koha::Auth::Challenge::OPACMaintenance::challenge();

Checks if OPAC is under maintenance.

@THROWS Koha::Exception::ServiceTemporarilyUnavailable
=cut

sub challenge {
    if ( C4::Context->preference('OpacMaintenance') ) {
        Koha::Exception::ServiceTemporarilyUnavailable->throw(error => 'OPAC is under maintenance');
    }
}

1;
