package Koha::Auth::PermissionModules;

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
use Scalar::Util qw(blessed);

use Koha::Auth::PermissionModule;

use base qw(Koha::Objects);

sub _type {
    return 'PermissionModule';
}
sub object_class {
    return 'Koha::Auth::PermissionModule';
}

sub _get_castable_unique_columns {
    return ['permission_module_id', 'module'];
}

1;
