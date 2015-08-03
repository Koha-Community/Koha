package Koha::Auth::Route;

use Modern::Perl;

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

=head

=NAME Koha::Auth::Route

=SYNOPSIS

This is an interface definition for Koha::Auth::Route::* -subclasses.
This documentation explains how to subclass different routes.

=USAGE

    if ($userid && $password) {
        $borrower = Koha::Auth::Route::<RouteName>::challenge($requestAuthElements, $permissionsRequired, $routeParams);
    }

=head INPUT

Each Route gets three parameters:
    $requestAuthElements, HASHRef of HASHRefs:
        headers =>      HASHRef of HTTP Headers matching the @authenticationHeaders-package
                        variable in Koha::Auth,
                        Eg. { 'X-Koha-Signature' => "23in4ow2gas2opcnpa", ... }
        postParams =>   HASHRef of HTTP POST parameters matching the
                        @authenticationPOSTparams-package variable in Koha::Auth,
                        Eg. { password => '1234', 'userid' => 'admin'}
        cookies =>      HASHRef of HTTP Cookies matching the
                        @authenticationPOSTparams-package variable in Koha::Auth,
                        EG. { CGISESSID => '9821rj1kn3tr9ff2of2ln1' }
    $permissionsRequired:
                        HASHRef of Koha permissions.
                        See Koha::Auth::PermissionManager for example.
    $routeParams:       HASHRef of special Route-related data
                        {inOPAC => 1, authnotrequired => 0, ...}

=head OUTPUT

Each route must return a Koha::Patron-object representing the authenticated user.
Even if the login succeeds with a superuser or similar virtual user, like
anonymous login, a mock Borrower-object must be returned.
If the login fails, each route must throw Koha::Exceptions to notify the cause
of the failure.

=head ROUTE STRUCTURE

Each route consists of Koha::Auth::Challenge::*-objects to test for various
authentication challenges.

See. Koha::Auth::Challenge for more information.

=cut

sub challenge {}; #@OVERLOAD this "interface"

1;
