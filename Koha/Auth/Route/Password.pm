package Koha::Auth::Route::Password;

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

use Koha::Auth::Challenge::OPACMaintenance;
use Koha::Auth::Challenge::Version;
use Koha::Auth::Challenge::IndependentBranchesAutolocation;
use Koha::Auth::Challenge::Password;
use Koha::Auth::Challenge::Permission;

use base qw(Koha::Auth::Route);

=head challenge
See Koha::Auth::Route, for usage documentation.
@THROWS Koha::Exceptions from authentication components.
=cut

sub challenge {
    my ($rae, $permissionsRequired, $routeParams) = @_;

    Koha::Auth::Challenge::OPACMaintenance::challenge() if $routeParams->{inOPAC};
    Koha::Auth::Challenge::Version::challenge();
    Koha::Auth::Challenge::IndependentBranchesAutolocation::challenge($routeParams->{branch});
    my $borrower = Koha::Auth::Challenge::Password::challenge($rae->{postParams}->{userid}, $rae->{postParams}->{password});
    Koha::Auth::Challenge::Permission::challenge($borrower, $permissionsRequired) if $permissionsRequired;
    return $borrower;
}

1;
