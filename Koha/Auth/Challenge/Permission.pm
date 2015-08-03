package Koha::Auth::Challenge::Permission;

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

use Koha::Auth::PermissionManager;

use base qw(Koha::Auth::Challenge);

=head challenge
STATIC

    Koha::Auth::Challenge::Permission::challenge($borrower, $permissionsRequired);

@THROWS Koha::Exception::NoPermission with the missing permission if permissions
                are inadequate
=cut

sub challenge {
    my ($borrower, $permissionsRequired) = @_;

    my $permissionManager = Koha::Auth::PermissionManager->new();
    $permissionManager->hasPermissions($borrower, $permissionsRequired);
}

1;
